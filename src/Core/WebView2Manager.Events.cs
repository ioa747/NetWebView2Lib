using System;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;

namespace NetWebView2Lib
{
    public partial class WebView2Manager
    {
        #region 2. DELEGATES & EVENTS
        // v2.0.0: All delegates now include sender and parentHandle parameters

        /// <summary>Delegate for message events.</summary>
        public delegate void OnMessageReceivedDelegate(object sender, string parentHandle, string message);
        public delegate void OnNavigationStartingDelegate(object sender, string parentHandle, string url);
        public delegate void OnNavigationCompletedDelegate(object sender, string parentHandle, bool isSuccess, int webErrorStatus);
        public delegate void OnTitleChangedDelegate(object sender, string parentHandle, string newTitle);
        public delegate void OnURLChangedDelegate(object sender, string parentHandle, string newUrl);
        public delegate void OnBrowserGotFocusDelegate(object sender, string parentHandle, int reason);
        public delegate void OnBrowserLostFocusDelegate(object sender, string parentHandle, int reason);
        public delegate void OnWebResourceResponseReceivedDelegate(object sender, string parentHandle, int statusCode, string reasonPhrase, string requestUrl);
        public delegate void OnContextMenuDelegate(object sender, string parentHandle, string menuData);
        public delegate void OnZoomChangedDelegate(object sender, string parentHandle, double factor);
        public delegate void OnContextMenuRequestedDelegate(object sender, string parentHandle, string linkUrl, int x, int y, string selectionText);
        public delegate void OnDownloadStartingDelegate(object sender, string parentHandle, string uri, string defaultPath);
        public delegate void OnDownloadStateChangedDelegate(object sender, string parentHandle, string state, string uri, long totalBytes, long receivedBytes);
        public delegate void OnAcceleratorKeyPressedDelegate(object sender, string parentHandle, object args);
        public delegate void OnProcessFailedDelegate(object sender, string parentHandle, object args);
        public delegate void OnBasicAuthenticationRequestedDelegate(object sender, string parentHandle, object args);
        public delegate void OnPermissionRequestedDelegate(object sender, string parentHandle, object args);

        public delegate void OnFrameNavigationStartingDelegate(object sender, string parentHandle, object frame, string uri);
        public delegate void OnFrameNavigationCompletedDelegate(object sender, string parentHandle, object frame, bool isSuccess, int webErrorStatus);
        public delegate void OnFrameContentLoadingDelegate(object sender, string parentHandle, object frame, long navigationId);
        public delegate void OnFrameDOMContentLoadedDelegate(object sender, string parentHandle, object frame, long navigationId);
        public delegate void OnFrameWebMessageReceivedDelegate(object sender, string parentHandle, object frame, string message);
        public delegate void OnFrameCreatedDelegate(object sender, string parentHandle, object frame);
        public delegate void OnFrameDestroyedDelegate(object sender, string parentHandle, object frame);
        public delegate void OnFrameNameChangedDelegate(object sender, string parentHandle, object frame);
        public delegate void OnFramePermissionRequestedDelegate(object sender, string parentHandle, object frame, object args);

        // Event declarations
        public event OnMessageReceivedDelegate OnMessageReceived;
        public event OnNavigationStartingDelegate OnNavigationStarting;
        public event OnNavigationCompletedDelegate OnNavigationCompleted;
        public event OnTitleChangedDelegate OnTitleChanged;
        public event OnURLChangedDelegate OnURLChanged;
        public event OnWebResourceResponseReceivedDelegate OnWebResourceResponseReceived;
        public event OnDownloadStartingDelegate OnDownloadStarting;
        public event OnDownloadStateChangedDelegate OnDownloadStateChanged;
        public event OnContextMenuDelegate OnContextMenu;
        public event OnContextMenuRequestedDelegate OnContextMenuRequested;
        public event OnZoomChangedDelegate OnZoomChanged;
        public event OnBrowserGotFocusDelegate OnBrowserGotFocus;
        public event OnBrowserLostFocusDelegate OnBrowserLostFocus;
        public event OnAcceleratorKeyPressedDelegate OnAcceleratorKeyPressed;
        public event OnProcessFailedDelegate OnProcessFailed;
        public event OnBasicAuthenticationRequestedDelegate OnBasicAuthenticationRequested;
        public event OnPermissionRequestedDelegate OnPermissionRequested;

        public event OnFrameNavigationStartingDelegate OnFrameNavigationStarting;
        public event OnFrameNavigationCompletedDelegate OnFrameNavigationCompleted;
        public event OnFrameCreatedDelegate OnFrameCreated;
        public event OnFrameDestroyedDelegate OnFrameDestroyed;
        public event OnFrameNameChangedDelegate OnFrameNameChanged;
        public event OnFramePermissionRequestedDelegate OnFramePermissionRequested;
        public event OnFrameContentLoadingDelegate OnFrameContentLoading;
        public event OnFrameDOMContentLoadedDelegate OnFrameDOMContentLoaded;
        public event OnFrameWebMessageReceivedDelegate OnFrameWebMessageReceived;
        #endregion

        /// <summary>
        /// Normalizes an IntPtr handle as an AutoIt Advanced Window Description string.
        /// Format: [HANDLE:0x00160678]
        /// </summary>
        private string FormatHandle(IntPtr handle)
        {
            if (handle == IntPtr.Zero) return "[HANDLE:0x" + IntPtr.Zero.ToString("X").PadLeft(IntPtr.Size * 2, '0') + "]";
            return "[HANDLE:0x" + handle.ToString("X").PadLeft(IntPtr.Size * 2, '0') + "]";
        }

        #region 8. EVENT REGISTRATION
        private void RegisterEvents()
        {
            if (_webView?.CoreWebView2 == null) return;

            // Frame Tracking
            _webView.CoreWebView2.FrameCreated += (s, e) => {
                RegisterFrame(e.Frame);
                InvokeOnUiThread(() => OnFrameCreated?.Invoke(this, FormatHandle(_parentHandle), new WebView2Frame(e.Frame)));
            };

            // Context Menu Event
            _webView.CoreWebView2.ContextMenuRequested += async (sender, args) =>
            {
                Log($"ContextMenuRequested: Location={args.Location.X}x{args.Location.Y}, Target={args.ContextMenuTarget.Kind}");
                args.Handled = !_contextMenuEnabled;

                try
                {
                    string script = "document.elementFromPoint(" + args.Location.X + "," + args.Location.Y + ").closest('table') ? 'TABLE' : document.elementFromPoint(" + args.Location.X + "," + args.Location.Y + ").tagName";
                    string tagNameResult = await _webView.CoreWebView2.ExecuteScriptAsync(script);
                    
                    InvokeOnUiThread(() => {
                        string tagName = tagNameResult?.Trim('\"') ?? "UNKNOWN";
                        string k = args.ContextMenuTarget.Kind.ToString();
                        string src = args.ContextMenuTarget.HasSourceUri ? args.ContextMenuTarget.SourceUri : "";
                        string lnk = args.ContextMenuTarget.HasLinkUri ? args.ContextMenuTarget.LinkUri : "";
                        string sel = args.ContextMenuTarget.HasSelection ? args.ContextMenuTarget.SelectionText : "";

                        OnContextMenuRequested?.Invoke(this, FormatHandle(_parentHandle), lnk, args.Location.X, args.Location.Y, sel);

                        string cleanSrc = src.Replace("\"", "\\\"");
                        string cleanLnk = lnk.Replace("\"", "\\\"");
                        string cleanSel = sel.Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n");

                        string json = "{" +
                            "\"x\":" + args.Location.X + "," +
                            "\"y\":" + args.Location.Y + "," +
                            "\"kind\":\"" + k + "\"," +
                            "\"tagName\":\"" + tagName + "\"," +
                            "\"src\":\"" + cleanSrc + "\"," +
                            "\"link\":\"" + cleanLnk + "\"," +
                            "\"selection\":\"" + cleanSel + "\"" +
                            "}";

                        OnContextMenu?.Invoke(this, FormatHandle(_parentHandle), "JSON:" + json);
                    });
                }
                catch (Exception ex) { Debug.WriteLine("ContextMenu Error: " + ex.Message); }
            };

            // Ad Blocking
            _webView.CoreWebView2.AddWebResourceRequestedFilter("*", CoreWebView2WebResourceContext.All);
            _webView.CoreWebView2.WebResourceRequested += (s, e) =>
            {
                string uri = e.Request.Uri.ToLower();
                if (!_isAdBlockActive) return;
                foreach (var domain in _blockList)
                {
                    if (uri.Contains(domain))
                    {
                        e.Response = _webView.CoreWebView2.Environment.CreateWebResourceResponse(null, 403, "Forbidden", "");
                        OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), $"BLOCKED_AD|{uri}");
                        return;
                    }
                }
            };
			
            _webView.CoreWebView2.NewWindowRequested += (s, e) => 
            {
                if (!_areBrowserPopupsAllowed) {
                    e.Handled = true;
                    if (!string.IsNullOrEmpty(e.Uri))
                    {
                        string targetUri = e.Uri;
                        _webView.BeginInvoke(new Action(() => {
                            if (_webView?.CoreWebView2 != null) _webView.CoreWebView2.Navigate(targetUri);
                        }));
                    }
                }
            };

            // Navigation & Content Events
            _webView.CoreWebView2.NavigationStarting += (s, e) => { 
                OnNavigationStarting?.Invoke(this, FormatHandle(_parentHandle), e.Uri); 
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "NAV_STARTING|" + e.Uri);
            };

            _webView.CoreWebView2.NavigationCompleted += (s, e) => { 
                OnNavigationCompleted?.Invoke(this, FormatHandle(_parentHandle), e.IsSuccess, (int)e.WebErrorStatus); 
                if (e.IsSuccess)
                {
                    OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "NAV_COMPLETED");
                    OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "TITLE_CHANGED|" + _webView.CoreWebView2.DocumentTitle);
                }
                else OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "NAV_ERROR|" + e.WebErrorStatus);
            };

            _webView.CoreWebView2.SourceChanged += (s, e) => {
                OnURLChanged?.Invoke(this, FormatHandle(_parentHandle), _webView.CoreWebView2.Source); 
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "URL_CHANGED|" + _webView.Source);
            };

            _webView.CoreWebView2.DocumentTitleChanged += (s, e) => { 
                OnTitleChanged?.Invoke(this, FormatHandle(_parentHandle), _webView.CoreWebView2.DocumentTitle); 
            };

            _webView.ZoomFactorChanged += (s, e) => {
                OnZoomChanged?.Invoke(this, FormatHandle(_parentHandle), _webView.ZoomFactor);
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "ZOOM_CHANGED|" + _webView.ZoomFactor);
            };

            _webView.CoreWebView2.ProcessFailed += (s, e) => {
                OnProcessFailed?.Invoke(this, FormatHandle(_parentHandle), new ProcessFailedEventArgsWrapper(e, _parentHandle));
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "PROCESS_FAILED|" + e.ProcessFailedKind + "|" + e.Reason);
            };

            _webView.CoreWebView2.BasicAuthenticationRequested += (s, e) => {
                OnBasicAuthenticationRequested?.Invoke(this, FormatHandle(_parentHandle), new BasicAuthenticationRequestedEventArgsWrapper(e, _parentHandle));
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "BASIC_AUTH_REQUESTED|" + e.Uri);
            };

            _webView.CoreWebView2.PermissionRequested += (s, e) => {
                OnPermissionRequested?.Invoke(this, FormatHandle(_parentHandle), new WebView2PermissionRequestedEventArgsWrapper(e, _parentHandle));
            };
        
            _webView.CoreWebView2.WebMessageReceived += (s, e) =>
            {
                string message = e.TryGetWebMessageAsString();
                if (message != null && message.StartsWith("CONTEXT_MENU_REQUEST|"))
                {
                    var parts = message.Split('|');
                    if (parts.Length >= 5)
                    {
                        string lnk = parts[1];
                        int x = int.TryParse(parts[2], out int px) ? px : 0;
                        int y = int.TryParse(parts[3], out int py) ? py : 0;
                        string sel = parts[4];
                        _webView.BeginInvoke(new Action(() => OnContextMenuRequested?.Invoke(this, FormatHandle(_parentHandle), lnk, x, y, sel)));
                        return;
                    }
                }
                _bridge.RaiseMessage(message);
            };

            _webView.GotFocus += (s, e) => { 
                OnBrowserGotFocus?.Invoke(this, FormatHandle(_parentHandle), 0);
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "BROWSER_GOT_FOCUS|");
            };
            
            _webView.LostFocus += (s, e) => {
                _webView.BeginInvoke(new Action(() => {
                    IntPtr focusedHandle = GetFocus(); 
                    if (focusedHandle != _webView.Handle && !IsChild(_webView.Handle, focusedHandle)) {
                        OnBrowserLostFocus?.Invoke(this, FormatHandle(_parentHandle), 0);
                        OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "BROWSER_LOST_FOCUS|");
                    }
                }));
            };
			
            _webView.CoreWebView2.AddHostObjectToScript("autoit", _bridge);

            _webView.CoreWebView2.WebResourceResponseReceived += (s, e) =>
            {
                if (!_httpStatusCodeEventsEnabled || e.Response == null) return;
                int statusCode = e.Response.StatusCode;
                string reasonPhrase = GetReasonPhrase(statusCode, e.Response.ReasonPhrase);
                string requestUrl = e.Request.Uri;
                if (_httpStatusCodeDocumentOnly && !e.Request.Headers.Contains("X-NetWebView2-IsDoc")) return;
                OnWebResourceResponseReceived?.Invoke(this, FormatHandle(_parentHandle), statusCode, reasonPhrase, requestUrl);
            };

            _webView.CoreWebView2.DownloadStarting += async (s, e) =>
            {
                var deferral = e.GetDeferral();
                string currentUri = e.DownloadOperation.Uri;
                if (!string.IsNullOrEmpty(_customDownloadPath))
                {
                    string fileName = System.IO.Path.GetFileName(e.ResultFilePath);
                    e.ResultFilePath = System.IO.Path.Combine(_customDownloadPath, fileName);
                }
				_activeDownloads[currentUri] = e.DownloadOperation;
                _isDownloadHandledOverride = false;
                OnDownloadStarting?.Invoke(this, FormatHandle(_parentHandle), e.DownloadOperation.Uri, e.ResultFilePath);

                var sw = Stopwatch.StartNew();
                while (sw.ElapsedMilliseconds < 600 && !_isDownloadHandledOverride) await Task.Delay(10);

                InvokeOnUiThread(() => {
                    if (_isDownloadHandledOverride)
                    {
                        e.Cancel = true;
                        OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), $"DOWNLOAD_CANCELLED|{e.DownloadOperation.Uri}");
                        deferral.Complete();
                        return;
                    }
                    e.Handled = !_isDownloadUIEnabled;
                    OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), $"DOWNLOAD_STARTING|{e.DownloadOperation.Uri}|{e.ResultFilePath}");

                    e.DownloadOperation.StateChanged += (sender, args) =>
                    {
                        long totalBytes = (long)(e.DownloadOperation.TotalBytesToReceive ?? 0);
                        long receivedBytes = (long)e.DownloadOperation.BytesReceived;
                        OnDownloadStateChanged?.Invoke(this, FormatHandle(_parentHandle), e.DownloadOperation.State.ToString(), e.DownloadOperation.Uri, totalBytes, receivedBytes);
                        if (e.DownloadOperation.State == Microsoft.Web.WebView2.Core.CoreWebView2DownloadState.Interrupted)
                            OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), $"DOWNLOAD_CANCELLED|{currentUri}|{e.DownloadOperation.InterruptReason}");
                        if (e.DownloadOperation.State != Microsoft.Web.WebView2.Core.CoreWebView2DownloadState.InProgress)
                            _activeDownloads.Remove(currentUri);
                    };

                    int lastPercent = -1;
                    e.DownloadOperation.BytesReceivedChanged += (sender, args) =>
                    {
                        long total = (long)(e.DownloadOperation.TotalBytesToReceive ?? 0);
                        long received = (long)e.DownloadOperation.BytesReceived;
                        if (total > 0)
                        {
                            int currentPercent = (int)((received * 100) / total);
                            if (currentPercent > lastPercent)
                            {
                                lastPercent = currentPercent;
                                OnDownloadStateChanged?.Invoke(this, FormatHandle(_parentHandle), "InProgress", e.DownloadOperation.Uri, total, received);
                            }
                        }
                    };
                    deferral.Complete();
                });
            };

            // Accelerator Key Pressed Event (Reflection)
            try
            {
                var controllerField = typeof(WebView2).GetField("_coreWebView2Controller", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                if (controllerField?.GetValue(_webView) is CoreWebView2Controller controller)
                {
                    controller.AcceleratorKeyPressed += (s, e) =>
                    {
                        var eventArgs = new WebView2AcceleratorKeyPressedEventArgs(e, this);
                        if (!string.IsNullOrEmpty(_blockedVirtualKeys))
                        {
                            string vKeyStr = e.VirtualKey.ToString();
                            if (_blockedVirtualKeys.Split(',').Any(k => k.Trim() == vKeyStr))
                            {
                                e.Handled = true;
                                eventArgs.Block();
                            }
                        }
                        OnAcceleratorKeyPressed?.Invoke(this, FormatHandle(_parentHandle), eventArgs);
                        if (eventArgs.IsCurrentlyHandled) e.Handled = true;
                    };
                }
            }
            catch (Exception ex) { Debug.WriteLine("AcceleratorKey Reflection Error: " + ex.Message); }
        }
        #endregion
    }
}
