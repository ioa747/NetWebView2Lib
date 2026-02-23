using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;

namespace NetWebView2Lib
{
    public partial class WebView2Manager
    {
        #region 9. PUBLIC API: NAVIGATION & CONTROL
        public void Navigate(string url) => InvokeOnUiThread(() => _webView.CoreWebView2.Navigate(url));

        public void NavigateToString(string htmlContent)
        {
            _webView.Invoke(new Action(async () => {
                int attempts = 0;
                while (_webView.CoreWebView2 == null && attempts < 20) { await Task.Delay(50); attempts++; }
                _webView.CoreWebView2?.NavigateToString(htmlContent);
            }));
        }

        public void Reload() => InvokeOnUiThread(() => _webView.CoreWebView2?.Reload());
        public void Stop() => InvokeOnUiThread(() => _webView.CoreWebView2?.Stop());
        public void GoBack() => InvokeOnUiThread(() => { if (_webView?.CoreWebView2 != null && _webView.CoreWebView2.CanGoBack) _webView.CoreWebView2.GoBack(); });
        public void GoForward() => InvokeOnUiThread(() => { if (_webView?.CoreWebView2 != null && _webView.CoreWebView2.CanGoForward) _webView.CoreWebView2.GoForward(); });
        public bool GetCanGoBack() => _webView?.CoreWebView2?.CanGoBack ?? false;
        public bool GetCanGoForward() => _webView?.CoreWebView2?.CanGoForward ?? false;

        public string AddInitializationScript(string script)
        {
            if (_webView?.CoreWebView2 == null) return "ERROR: WebView not initialized";
            return RunOnUiThread(() =>
            {
                try
                {
                    var task = _webView.CoreWebView2.AddScriptToExecuteOnDocumentCreatedAsync(script);
                    string scriptId = WaitAndGetResult(task);
                    _webView.CoreWebView2.ExecuteScriptAsync(script);
                    return scriptId;
                }
                catch (Exception ex) { return "ERROR: " + ex.Message; }
            });
        }

        public void RemoveInitializationScript(string scriptId)
        {
            InvokeOnUiThread(() => { if (_webView?.CoreWebView2 != null && !string.IsNullOrEmpty(scriptId)) _webView.CoreWebView2.RemoveScriptToExecuteOnDocumentCreated(scriptId); });
        }

        public void SetContextMenuEnabled(bool enabled)
        {
            _contextMenuEnabled = enabled;
            InvokeOnUiThread(() => { if (_webView?.CoreWebView2 != null) _webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = true; });
        }
        #endregion

        #region 10. PUBLIC API: DATA EXTRACTION
        public async void GetHtmlSource()
        {
            if (_webView?.CoreWebView2 == null) return;
            string html = await _webView.CoreWebView2.ExecuteScriptAsync("document.documentElement.outerHTML");
            OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "HTML_SOURCE|" + CleanJsString(html));
        }

        public async void GetSelectedText()
        {
            if (_webView?.CoreWebView2 == null) return;
            string selectedText = await _webView.CoreWebView2.ExecuteScriptAsync("window.getSelection().toString()");
            OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "SELECTED_TEXT|" + CleanJsString(selectedText));
        }

        public bool ParseJsonToInternal(string json) => _internalParser.Parse(json?.Trim());
        public string GetInternalJsonValue(string path) => _internalParser.GetTokenValue(path);

        public bool BindJsonToBrowser(string variableName)
        {
            try
            {
                if (_webView?.CoreWebView2 == null) return false;
                string jsonData = _internalParser.GetMinifiedJson() ?? "{}";
                string safeJson = jsonData.Replace("\\", "\\\\").Replace("'", "\\'");
                string script = $@"try {{ window.{variableName} = JSON.parse('{safeJson}'); true; }} catch(e) {{ false; }}";
                _webView.CoreWebView2.ExecuteScriptAsync(script);
                return true;
            }
            catch { return false; }
        }

        public void SyncInternalData(string json, string bindToVariableName = "")
        {
            if (ParseJsonToInternal(json) && !string.IsNullOrEmpty(bindToVariableName)) BindJsonToBrowser(bindToVariableName);
        }

        public async void GetInnerText()
        {
            if (_webView?.CoreWebView2 == null) return;
            try {
                string text = await _webView.CoreWebView2.ExecuteScriptAsync("document.documentElement.innerText");
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "INNER_TEXT|" + CleanJsString(text));
            } catch (Exception ex) { OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "ERROR|INNER_TEXT_FAILED: " + ex.Message); }
        }
        #endregion

        #region 11. PUBLIC API: UI & INTERACTION
        public void ExecuteScript(string script) => InvokeOnUiThread(() => _webView.CoreWebView2.ExecuteScriptAsync(script));

        public async void ExecuteScriptOnPage(string script)
        {
            if (_webView?.CoreWebView2 != null) await _webView.CoreWebView2.ExecuteScriptAsync(script);
        }

        public void PostWebMessage(string message) => InvokeOnUiThread(() => _webView.CoreWebView2.PostWebMessageAsString(message));

        public string ExecuteScriptWithResult(string script)
        {
            if (_webView?.CoreWebView2 == null) return "ERROR: WebView not initialized";
            try
            {
                var task = _webView.CoreWebView2.ExecuteScriptAsync(script);
                return CleanJsString(WaitAndGetResult(task));
            }
            catch (Exception ex) { return "ERROR: " + ex.Message; }
        }

        public async void InjectCss(string cssCode)
        {
            string js = $"(function() {{ let style = document.getElementById('{StyleId}'); if (!style) {{ style = document.createElement('style'); style.id = '{StyleId}'; document.head.appendChild(style); }} style.innerHTML = `{cssCode.Replace("`", "\\` text-decoration")}`; }})();";
            ExecuteScript(js);
            if (!string.IsNullOrEmpty(_lastCssRegistrationId)) _webView.CoreWebView2.RemoveScriptToExecuteOnDocumentCreated(_lastCssRegistrationId);
            _lastCssRegistrationId = await _webView.CoreWebView2.AddScriptToExecuteOnDocumentCreatedAsync(js);
        }

        public void ClearInjectedCss()
        {
            if (!string.IsNullOrEmpty(_lastCssRegistrationId)) { _webView.CoreWebView2.RemoveScriptToExecuteOnDocumentCreated(_lastCssRegistrationId); _lastCssRegistrationId = ""; }
            ExecuteScript($"(function() {{ let style = document.getElementById('{StyleId}'); if (style) style.remove(); }})();");
        }

        public void ToggleAuditHighlights(bool enable)
        {
            if (enable) InjectCss("img, h1, h2, h3, table, a { outline: 3px solid #FF6A00 !important; outline-offset: -3px !important; }");
            else ClearInjectedCss();
        }

        public async void CapturePreview(string filePath, string format)
        {
            if (_webView?.CoreWebView2 == null) return;
            var imgFormat = format.ToLower().Contains("jpg") ? CoreWebView2CapturePreviewImageFormat.Jpeg : CoreWebView2CapturePreviewImageFormat.Png;
            try {
                using (var fs = File.Create(filePath)) await _webView.CoreWebView2.CapturePreviewAsync(imgFormat, fs);
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "CAPTURE_SUCCESS|" + filePath);
            } catch (Exception ex) { OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "CAPTURE_ERROR|" + ex.Message); }
        }

        public void ShowPrintUI() => _webView?.CoreWebView2.ShowPrintUI();

        public void Print()
        {
             InvokeOnUiThread(async () => {
                if (_webView?.CoreWebView2 != null) {
                     try { await _webView.CoreWebView2.ExecuteScriptAsync("window.print();"); } 
                     catch(Exception ex) { OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "PRINT_ERROR|" + ex.Message); }
                }
             });
        }

        public void SetLockState(bool lockState)
        {
            InvokeOnUiThread(() => {
                if (_webView?.CoreWebView2 != null) {
                    var s = _webView.CoreWebView2.Settings;
                    s.AreDefaultContextMenusEnabled = !lockState;
                    s.AreDevToolsEnabled = !lockState;
                    s.IsZoomControlEnabled = !lockState;
                    s.IsBuiltInErrorPageEnabled = !lockState;
                    s.AreDefaultScriptDialogsEnabled = !lockState;
                    s.AreBrowserAcceleratorKeysEnabled = !lockState;
                    s.IsStatusBarEnabled = !lockState;
                }
                _areBrowserPopupsAllowed = !lockState;
                _contextMenuEnabled = !lockState;
            });
        }

        public void LockWebView() => SetLockState(true);
        public void UnLockWebView() => SetLockState(false);
        public void DisableBrowserFeatures() => LockWebView();
        public void EnableBrowserFeatures() => UnLockWebView();

        public async void ExportToPdf(string filePath)
        {
            if (_webView?.CoreWebView2 == null) return;
            try {
                await _webView.CoreWebView2.PrintToPdfAsync(filePath);
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "PDF_EXPORT_SUCCESS|" + filePath);
            } catch (Exception ex) { OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "PDF_EXPORT_ERROR|" + ex.Message); }
        }

        public string CaptureSnapshot(string cdpParameters = "{\"format\": \"mhtml\"}")
        {
            if (_webView?.CoreWebView2 == null) return "ERROR: WebView not initialized";
            return RunOnUiThread(() => {
                try {
                    var task = _webView.CoreWebView2.CallDevToolsProtocolMethodAsync("Page.captureSnapshot", cdpParameters);
                    string json = WaitAndGetResult(task);
                    var dict = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, string>>(json);
                    return dict != null && dict.ContainsKey("data") ? dict["data"] : "ERROR: Page capture failed";
                } catch (Exception ex) { return "ERROR: " + ex.Message; }
            });
        }

        public string ExportPageData(int format, string filePath)
        {
            if (_webView?.CoreWebView2 == null) return "ERROR: WebView not initialized";
            return RunOnUiThread(() => {
                try {
                    string result = "";
                    if (format == 0) result = CleanJsString(WaitAndGetResult(_webView.CoreWebView2.ExecuteScriptAsync("document.documentElement.outerHTML")));
                    else if (format == 1) result = CaptureSnapshot();
                    if (!string.IsNullOrEmpty(filePath) && !result.StartsWith("ERROR:")) File.WriteAllText(filePath, result);
                    return result;
                } catch (Exception ex) { return "ERROR: " + ex.Message; }
            });
        }

        public string PrintToPdfStream()
        {
            if (_webView?.CoreWebView2 == null) return "ERROR: WebView not initialized";
            return RunOnUiThread(() => {
                try {
                    var task = _webView.CoreWebView2.PrintToPdfStreamAsync(null);
                    Stream stream = WaitAndGetResult(task);
                    using (MemoryStream ms = new MemoryStream()) { stream.CopyTo(ms); return Convert.ToBase64String(ms.ToArray()); }
                } catch (Exception ex) { return "ERROR: " + ex.Message; }
            });
        }

        public async void CallDevToolsProtocolMethod(string methodName, string parametersJson)
        {
            if (_webView?.CoreWebView2 == null) return;
            try {
                string result = await _webView.CoreWebView2.CallDevToolsProtocolMethodAsync(methodName, parametersJson);
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), $"CDP_RESULT|{methodName}|{result}");
            } catch (Exception ex) { OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), $"CDP_ERROR|{methodName}|{ex.Message}"); }
        }

        public void SetZoom(double factor) => InvokeOnUiThread(() => _webView.ZoomFactor = factor);
        public void ResetZoom() => SetZoom(1.0);
        public void SetMuted(bool muted) => InvokeOnUiThread(() => { if (_webView?.CoreWebView2 != null) _webView.CoreWebView2.IsMuted = muted; });
        public bool IsMuted() => _webView?.CoreWebView2?.IsMuted ?? false;
        public void Resize(int w, int h) => InvokeOnUiThread(() => _webView.Size = new Size(w, h));

        public async void ClearBrowserData()
        {
            await _webView.EnsureCoreWebView2Async();
            await _webView.CoreWebView2.Profile.ClearBrowsingDataAsync();
            OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "DATA_CLEARED");
        }

        public async void ClearCache()
        {
            if (_webView?.CoreWebView2 != null)
                await _webView.CoreWebView2.Profile.ClearBrowsingDataAsync(CoreWebView2BrowsingDataKinds.DiskCache | CoreWebView2BrowsingDataKinds.LocalStorage);
        }

        public async void GetCookies(string channelId)
        {
            if (_webView?.CoreWebView2?.CookieManager == null) return;
            try {
                var cookieList = await _webView.CoreWebView2.CookieManager.GetCookiesAsync(null);
                var sb = new System.Text.StringBuilder("[");
                for(int i=0; i<cookieList.Count; i++) {
                    var c = cookieList[i];
                    sb.Append($"{{\"name\":\"{c.Name}\",\"value\":\"{c.Value}\",\"domain\":\"{c.Domain}\",\"path\":\"{c.Path}\"}}");
                    if (i < cookieList.Count - 1) sb.Append(",");
                }
                sb.Append("]");
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), $"COOKIES_B64|{channelId}|{EncodeB64(sb.ToString())}");
            } catch (Exception ex) { OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), $"COOKIES_ERROR|{channelId}|{ex.Message}"); }
        }

        public void AddCookie(string name, string value, string domain, string path)
        {
            if (_webView?.CoreWebView2?.CookieManager == null) return;
            try {
                var cookie = _webView.CoreWebView2.CookieManager.CreateCookie(name, value, domain, path);
                _webView.CoreWebView2.CookieManager.AddOrUpdateCookie(cookie);
            } catch (Exception ex) { OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), $"COOKIE_ADD_ERROR|{ex.Message}"); }
        }

        public void DeleteCookie(string name, string domain, string path)
        {
            if (_webView?.CoreWebView2?.CookieManager == null) return;
            var cookie = _webView.CoreWebView2.CookieManager.CreateCookie(name, "", domain, path);
            _webView.CoreWebView2.CookieManager.DeleteCookie(cookie);
        }

        public void DeleteAllCookies() => _webView?.CoreWebView2?.CookieManager?.DeleteAllCookies();

        public void SetAdBlock(bool active) => _isAdBlockActive = active;
        public void AddBlockRule(string domain) { if (!string.IsNullOrEmpty(domain)) _blockList.Add(domain.ToLower()); }
        public void ClearBlockRules() => _blockList.Clear();

        public void SetAutoResize(bool enabled)
        {
            if (_parentHandle == IntPtr.Zero || _parentSubclass == null) return;
            _autoResizeEnabled = enabled;
            if (_autoResizeEnabled) { _parentSubclass.AssignHandle(_parentHandle); PerformSmartResize(); }
            else _parentSubclass.ReleaseHandle();
        }

        public void SetZoomFactor(double factor) { if (factor >= 0.1 && factor <= 5.0) InvokeOnUiThread(() => _webView.ZoomFactor = factor); }
        public void OpenDevToolsWindow() => InvokeOnUiThread(() => _webView?.CoreWebView2?.OpenDevToolsWindow());
        public void WebViewSetFocus() => InvokeOnUiThread(() => _webView?.Focus());

        public void SetUserAgent(string userAgent) { InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.UserAgent = userAgent; }); }
        public string GetDocumentTitle() => _webView?.CoreWebView2?.DocumentTitle ?? "";
        public string GetSource() => _webView?.Source?.ToString() ?? "";
        public uint GetBrowserProcessId() { try { return _webView?.CoreWebView2?.BrowserProcessId ?? 0; } catch { return 0; } }

        public void SetScriptEnabled(bool enabled) { InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.IsScriptEnabled = enabled; }); }
        public void SetWebMessageEnabled(bool enabled) { InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.IsWebMessageEnabled = enabled; }); }
        public void SetStatusBarEnabled(bool enabled) { InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.IsStatusBarEnabled = enabled; }); }

        public void SetDownloadPath(string path) { _customDownloadPath = path; if (!Directory.Exists(path)) Directory.CreateDirectory(path); }
        public string ActiveDownloadsList => string.Join("|", _activeDownloads.Keys);

        public void CancelDownloads(string uri = "")
        {
            if (string.IsNullOrEmpty(uri)) { foreach (var d in _activeDownloads.Values) d.Cancel(); _activeDownloads.Clear(); }
            else if (_activeDownloads.ContainsKey(uri)) { _activeDownloads[uri].Cancel(); _activeDownloads.Remove(uri); }
        }

        public void SetVirtualHostNameToFolderMapping(string hostName, string folderPath, int accessKind)
        {
            InvokeOnUiThread(() => _webView?.CoreWebView2?.SetVirtualHostNameToFolderMapping(hostName, folderPath, (Microsoft.Web.WebView2.Core.CoreWebView2HostResourceAccessKind)accessKind));
        }

        public string CapturePreviewAsBase64(string format)
        {
            try {
                var imgFormat = format.ToLower() == "jpeg" ? CoreWebView2CapturePreviewImageFormat.Jpeg : CoreWebView2CapturePreviewImageFormat.Png;
                using (var ms = new MemoryStream()) {
                    WaitTask(_webView.CoreWebView2.CapturePreviewAsync(imgFormat, ms));
                    return $"data:image/{format.ToLower()};base64,{Convert.ToBase64String(ms.ToArray())}";
                }
            } catch (Exception ex) { return "Error: " + ex.Message; }
        }

        public void AddExtension(string extensionPath)
        {
            InvokeOnUiThread(async () => {
                if (_webView?.CoreWebView2?.Profile == null || !Directory.Exists(extensionPath)) return;
                try {
                    var ext = await _webView.CoreWebView2.Profile.AddBrowserExtensionAsync(extensionPath);
                    OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "EXTENSION_LOADED|" + ext.Id);
                } catch (Exception ex) { OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "ERROR|EXTENSION_FAILED|" + ex.Message); }
            });
        }

        public void RemoveExtension(string extensionId)
        {
            InvokeOnUiThread(async () => {
                if (_webView?.CoreWebView2?.Profile == null) return;
                try {
                    var extensions = await _webView.CoreWebView2.Profile.GetBrowserExtensionsAsync();
                    foreach (var ext in extensions) {
                        if (ext.Id == extensionId) { await ext.RemoveAsync(); OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "EXTENSION_REMOVED|" + extensionId); return; }
                    }
                } catch (Exception ex) { OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "ERROR|REMOVE_EXTENSION_FAILED|" + ex.Message); }
            });
        }
        #endregion

        #region 16. UNIFIED SETTINGS (PROPERTIES)
        public bool AreDevToolsEnabled
        {
            get => RunOnUiThread(() => _webView?.CoreWebView2?.Settings?.AreDevToolsEnabled ?? false);
            set => InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.AreDevToolsEnabled = value; });
        }
		
        public bool AreBrowserPopupsAllowed
        {
            get => _areBrowserPopupsAllowed;
            set => InvokeOnUiThread(() => _areBrowserPopupsAllowed = value);
        }

        public bool AreDefaultContextMenusEnabled
        {
            get => _contextMenuEnabled;
            set => SetContextMenuEnabled(value);
        }

        public bool Verbose
        {
            get => _verbose;
            set { _verbose = value; Log("Verbose mode: " + (_verbose ? "ENABLED" : "DISABLED")); }
        }

        public bool AreDefaultScriptDialogsEnabled
        {
            get => RunOnUiThread(() => _webView?.CoreWebView2?.Settings?.AreDefaultScriptDialogsEnabled ?? true);
            set => InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.AreDefaultScriptDialogsEnabled = value; });
        }

        public bool AreBrowserAcceleratorKeysEnabled
        {
            get => RunOnUiThread(() => _webView?.CoreWebView2?.Settings?.AreBrowserAcceleratorKeysEnabled ?? true);
            set => InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.AreBrowserAcceleratorKeysEnabled = value; });
        }

        public bool IsStatusBarEnabled
        {
            get => RunOnUiThread(() => _webView?.CoreWebView2?.Settings?.IsStatusBarEnabled ?? true);
            set => SetStatusBarEnabled(value);
        }

        public double ZoomFactor
        {
            get => RunOnUiThread(() => _webView?.ZoomFactor ?? 1.0);
            set => SetZoomFactor(value);
        }

        public string BackColor
        {
            get => RunOnUiThread(() => ColorTranslator.ToHtml(_webView.DefaultBackgroundColor));
            set => InvokeOnUiThread(() => {
                try { _webView.DefaultBackgroundColor = ColorTranslator.FromHtml(value.Replace("0x", "#")); }
                catch { _webView.DefaultBackgroundColor = Color.White; }
            });
        }

        public bool AreHostObjectsAllowed
        {
            get => RunOnUiThread(() => _webView?.CoreWebView2?.Settings?.AreHostObjectsAllowed ?? true);
            set => InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.AreHostObjectsAllowed = value; });
        }

        public int Anchor
        {
            get => RunOnUiThread(() => (int)_webView.Anchor);
            set => InvokeOnUiThread(() => _webView.Anchor = (AnchorStyles)value);
        }

        public int BorderStyle { get => 0; set { } }
        public bool CustomMenuEnabled { get => _customMenuEnabled; set => _customMenuEnabled = value; }
        public string AdditionalBrowserArguments { get => _additionalBrowserArguments; set => _additionalBrowserArguments = value; }

        public int HiddenPdfToolbarItems
        {
            get => RunOnUiThread(() => (int)(_webView?.CoreWebView2?.Settings?.HiddenPdfToolbarItems ?? CoreWebView2PdfToolbarItems.None));
            set => InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.HiddenPdfToolbarItems = (CoreWebView2PdfToolbarItems)value; });
        }

        public bool IsDownloadUIEnabled { get => _isDownloadUIEnabled; set => _isDownloadUIEnabled = value; }
        public bool HttpStatusCodeEventsEnabled { get => _httpStatusCodeEventsEnabled; set => _httpStatusCodeEventsEnabled = value; }
        public bool HttpStatusCodeDocumentOnly { get => _httpStatusCodeDocumentOnly; set => _httpStatusCodeDocumentOnly = value; }
        public bool IsDownloadHandled { get => _isDownloadHandledOverride; set => _isDownloadHandledOverride = value; }

        public bool IsZoomControlEnabled
        {
            get => _webView?.CoreWebView2?.Settings?.IsZoomControlEnabled ?? _isZoomControlEnabled;
            set { _isZoomControlEnabled = value; InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.IsZoomControlEnabled = value; }); }
        }

        public bool IsBuiltInErrorPageEnabled
        {
            get => RunOnUiThread(() => _webView?.CoreWebView2?.Settings?.IsBuiltInErrorPageEnabled ?? true);
            set => InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.IsBuiltInErrorPageEnabled = value; });
        }
        #endregion

        private void PerformSmartResize()
        {
            if (_webView == null || _parentHandle == IntPtr.Zero) return;
            if (_webView.InvokeRequired) { _webView.Invoke(new Action(PerformSmartResize)); return; }
            if (GetClientRect(_parentHandle, out Rect rect))
            {
                int newWidth = (rect.Right - rect.Left) - _offsetX - _marginRight;
                int newHeight = (rect.Bottom - rect.Top) - _offsetY - _marginBottom;
                Log($"SmartResize: ParentSize={rect.Right - rect.Left}x{rect.Bottom - rect.Top}, NewWebViewSize={newWidth}x{newHeight}");
                _webView.Left = _offsetX; _webView.Top = _offsetY;
                _webView.Width = Math.Max(10, newWidth); _webView.Height = Math.Max(10, newHeight);
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "WINDOW_RESIZED|" + _webView.Width + "|" + _webView.Height);
            }
        }

        private class ParentWindowSubclass : NativeWindow
        {
            private const int WM_SIZE = 0x0005;
            private readonly Action _onResize;

            public ParentWindowSubclass(Action onResize)
            {
                _onResize = onResize;
            }

            protected override void WndProc(ref Message m)
            {
                base.WndProc(ref m);
                if (m.Msg == WM_SIZE) _onResize?.Invoke();
            }
        }
    }
}
