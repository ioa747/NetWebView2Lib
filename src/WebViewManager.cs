using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;

namespace NetWebView2Lib
{
    // --- 1. EVENTS INTERFACE (What C# sends to AutoIt) ---
    /// <summary>
    /// Events sent from C# to AutoIt.
    /// </summary>
    [Guid("B2C3D4E5-F6A7-4B6C-9D0E-1F2A3B4C5D6E")]
    [InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
    [ComVisible(true)]
    public interface IWebViewEvents
    {
        /// <summary>
        /// Triggered when a message is sent from the WebView.
        /// </summary>
        /// <param name="message">The message content.</param>
        [DispId(1)]
        void OnMessageReceived(string message);
    }

    /// <summary>
    /// Actions available to call from AutoIt.
    /// </summary>
    [Guid("CCB12345-6789-4ABC-DEF0-1234567890AB")]
    [InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
    [ComVisible(true)]
    public interface IWebViewActions
    {
        /// <summary>Initialize the WebView.</summary>
        [DispId(101)] void Initialize(object parentHandle, string userDataFolder, int x = 0, int y = 0, int width = 0, int height = 0);
        /// <summary>Navigate to a URL.</summary>
        [DispId(102)] void Navigate(string url);
        /// <summary>Navigate to HTML content.</summary>
        [DispId(103)] void NavigateToString(string htmlContent);
        /// <summary>Execute JavaScript.</summary>
        [DispId(104)] void ExecuteScript(string script);
        /// <summary>Resize the WebView.</summary>
        [DispId(105)] void Resize(int width, int height);
        /// <summary>Clean up resources.</summary>
        [DispId(106)] void Cleanup();
        /// <summary>Get the Bridge object.</summary>
        [DispId(107)] IBridgeActions GetBridge();
        /// <summary>Export to PDF.</summary>
        [DispId(108)] void ExportToPdf(string filePath);
        /// <summary>Check if ready.</summary>
        [DispId(109)] bool IsReady();
        /// <summary>Enable/Disable Context Menu.</summary>
        [DispId(110)] void SetContextMenuEnabled(bool enabled);
        /// <summary>Lock the WebView.</summary>
        [DispId(111)] void LockWebView();
        /// <summary>Disable browser features.</summary>
        [DispId(112)] void DisableBrowserFeatures();
        /// <summary>Go Back.</summary>
        [DispId(113)] void GoBack();
        /// <summary>Reset Zoom.</summary>
        [DispId(114)] void ResetZoom();
        /// <summary>Inject CSS.</summary>
        [DispId(115)] void InjectCss(string cssCode);
        /// <summary>Clear Injected CSS.</summary>
        [DispId(116)] void ClearInjectedCss();
        /// <summary>Toggle Audit Highlights.</summary>
        [DispId(117)] void ToggleAuditHighlights(bool enable);
        /// <summary>Set AdBlock active state.</summary>
        [DispId(118)] void SetAdBlock(bool active);
        /// <summary>Add a block rule.</summary>
        [DispId(119)] void AddBlockRule(string domain);
        /// <summary>Clear all block rules.</summary>
        [DispId(120)] void ClearBlockRules();
        /// <summary>Go Forward.</summary>
        [DispId(121)] void GoForward();
        /// <summary>Get HTML Source.</summary>
        [DispId(122)] void GetHtmlSource();
        /// <summary>Get Selected Text.</summary>
        [DispId(123)] void GetSelectedText();
        /// <summary>Set Zoom factor.</summary>
        [DispId(124)] void SetZoom(double factor);
        /// <summary>Parse JSON to internal storage.</summary>
        [DispId(125)] bool ParseJsonToInternal(string json);
        /// <summary>Get value from internal JSON.</summary>
        [DispId(126)] string GetInternalJsonValue(string path);
        /// <summary>Clear browsing data.</summary>
        [DispId(127)] void ClearBrowserData();
        /// <summary>Reload.</summary>
        [DispId(128)] void Reload();
        /// <summary>Stop loading.</summary>
        [DispId(129)] void Stop();
        /// <summary>Show Print UI.</summary>
        [DispId(130)] void ShowPrintUI();
        /// <summary>Set Muted state.</summary>
        [DispId(131)] void SetMuted(bool muted);
        /// <summary>Check if Muted.</summary>
        [DispId(132)] bool IsMuted();
        /// <summary>Set User Agent.</summary>
        [DispId(133)] void SetUserAgent(string userAgent);
        /// <summary>Get Document Title.</summary>
        [DispId(134)] string GetDocumentTitle();
        /// <summary>Get Source URL.</summary>
        [DispId(135)] string GetSource();
        /// <summary>Enable/Disable Script.</summary>
        [DispId(136)] void SetScriptEnabled(bool enabled);
        /// <summary>Enable/Disable Web Message.</summary>
        [DispId(137)] void SetWebMessageEnabled(bool enabled);
        /// <summary>Enable/Disable Status Bar.</summary>
        [DispId(138)] void SetStatusBarEnabled(bool enabled);
        /// <summary>Capture Preview.</summary>
        [DispId(139)] void CapturePreview(string filePath, string format);
        /// <summary>Call CDP Method.</summary>
        [DispId(140)] void CallDevToolsProtocolMethod(string methodName, string parametersJson);
        /// <summary>Get Cookies.</summary>
        [DispId(141)] void GetCookies(string channelId);
        /// <summary>Add a Cookie.</summary>
        [DispId(142)] void AddCookie(string name, string value, string domain, string path);
        /// <summary>Delete a Cookie.</summary>
        [DispId(143)] void DeleteCookie(string name, string domain, string path);
        /// <summary>Delete All Cookies.</summary>
        [DispId(144)] void DeleteAllCookies();
        /// <summary>Print.</summary>
        [DispId(145)] void Print();
        /// <summary>Add Extension.</summary>
        [DispId(150)] void AddExtension(string extensionPath);
    }

    // --- 3. THE MANAGER CLASS ---
    /// <summary>
    /// The Main Manager Class for WebView2 Interaction.
    /// </summary>
    [Guid("A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D")]
    [ComSourceInterfaces(typeof(IWebViewEvents))]
    [ClassInterface(ClassInterfaceType.None)] 
    [ComVisible(true)]
    [ProgId("NetWebView2.Manager")]
    public class WebViewManager : IWebViewActions
    {
        // --- PRIVATE FIELDS ---

        private readonly WebView2 _webView;
        private readonly WebViewBridge _bridge;
        private readonly JsonParser _internalParser = new JsonParser();

        private bool _isAdBlockActive = false;
        private List<string> _blockList = new List<string>();
        private const string StyleId = "autoit-injected-style";

        private bool _contextMenuEnabled = true;

        // --- EVENTS ---

        /// <summary>
        /// Delegate for detecting when messages are received.
        /// </summary>
        /// <param name="message">The message content.</param>
        public delegate void OnMessageReceivedDelegate(string message);
        /// <summary>
        /// Event fired when a message is received.
        /// </summary>
        public event OnMessageReceivedDelegate OnMessageReceived;

        // --- NATIVE METHODS ---

        [DllImport("user32.dll")]
        private static extern bool GetClientRect(IntPtr hWnd, out Rect lpRect);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);

        /// <summary>
        /// A simple Rectangle struct.
        /// </summary>
        [StructLayout(LayoutKind.Sequential)]
        public struct Rect { 
            /// <summary>Left position</summary>
            public int Left;
            /// <summary>Top position</summary>
            public int Top; 
            /// <summary>Right position</summary>
            public int Right; 
            /// <summary>Bottom position</summary>
            public int Bottom; 
        }

        // --- CONSTRUCTOR ---

        /// <summary>
        /// Initializes a new instance of the WebViewManager class.
        /// </summary>
        public WebViewManager()
        {
            _webView = new WebView2();
            _bridge = new WebViewBridge();
        }

        // --- PROPERTIES ---

        /// <summary>
        /// Get the Bridge object for AutoIt interaction.
        /// </summary>
        public IBridgeActions GetBridge()
        {
            return _bridge;
        }

        /// <summary>
        /// Check if WebView2 is initialized and ready.
        /// </summary>
        public bool IsReady() => _webView?.CoreWebView2 != null;


        // --- INITIALIZATION ---

        /// <summary>
        /// Initializes the WebView2 control within the specified parent window handle.
        /// Supports browser extensions and custom user data folders.
        /// </summary>
        public async void Initialize(object parentHandle, string userDataFolder, int x = 0, int y = 0, int width = 0, int height = 0)
        {
            try
            {
                // Convert the incoming handle from AutoIt (passed as object/pointer)
                long rawHandleValue = Convert.ToInt64(parentHandle);
                IntPtr localParentPtr = new IntPtr(rawHandleValue);

                // Manage User Data Folder (User Profile)
                // If no path is provided, create a default one in the application directory
                if (string.IsNullOrEmpty(userDataFolder))
                {
                    userDataFolder = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "WebView2_Default_Profile");
                }

                // Create the directory if it doesn't exist
                if (!Directory.Exists(userDataFolder)) Directory.CreateDirectory(userDataFolder);

                // UI Setup on the main UI thread
                InvokeOnUiThread(() => {
                    _webView.Location = new Point(x, y);
                    _webView.Size = new Size(width, height);
                    // Attach the WebView to the AutoIt window/container
                    SetParent(_webView.Handle, localParentPtr);
                    _webView.Visible = false;
                });

                // --- NEW: EXTENSION SUPPORT SETUP ---
                // We must enable extensions in the Environment Options BEFORE creation
                var options = new CoreWebView2EnvironmentOptions();
                options.AreBrowserExtensionsEnabled = true;

                // Initialize the Environment with the Custom Data Folder and our Options
                // Note: The second parameter is the userDataFolder, the third is the options
                var env = await CoreWebView2Environment.CreateAsync(null, userDataFolder, options);

                // Wait for the CoreWebView2 engine to be ready
                await _webView.EnsureCoreWebView2Async(env);

                // Apply settings and register events
                ConfigureSettings();
                RegisterEvents();

                // Make the browser visible once everything is loaded
                InvokeOnUiThread(() => _webView.Visible = true);

                // Notify AutoIt that the browser is ready (Standard style without ID)
                OnMessageReceived?.Invoke("INIT_READY");
            }
            catch (Exception ex)
            {
                // Send error details back to AutoIt if initialization fails
                OnMessageReceived?.Invoke("ERROR|INIT_FAILED|" + ex.Message);
            }
        }

        /// <summary>
        /// Adds a browser extension from an unpacked folder (containing manifest.json).
        /// This method should be called after receiving the "INIT_READY" message.
        /// </summary>
        /// <param name="extensionPath">The full path to the unpacked extension folder.</param>
        [DispId(150)]
        public async void AddExtension(string extensionPath)
        {
            // Ensure the WebView engine is ready before adding extensions
            if (_webView == null || _webView.CoreWebView2 == null)
            {
                OnMessageReceived?.Invoke("ERROR|EXTENSION|CoreWebView2 is not initialized yet.");
                return;
            }

            try
            {
                // Check if the provided path actually exists on the disk
                if (!System.IO.Directory.Exists(extensionPath))
                {
                    OnMessageReceived?.Invoke("ERROR|EXTENSION|Folder not found: " + extensionPath);
                    return;
                }

                // Add the extension to the browser profile. 
                // This will persist if the same userDataFolder is used next time.
                await _webView.CoreWebView2.Profile.AddBrowserExtensionAsync(extensionPath);

                // Notify AutoIt that the extension was successfully loaded
                OnMessageReceived?.Invoke("EXTENSION_LOADED|" + extensionPath);
            }
            catch (Exception ex)
            {
                // Catch and send any internal exceptions (e.g., invalid manifest.json)
                OnMessageReceived?.Invoke("ERROR|EXTENSION_FAILED|" + ex.Message);
            }
        }


        // --- CONFIGURATION ---

        /// <summary>
        /// Configure WebView2 settings.
        /// </summary>
        private void ConfigureSettings()
        {
            var settings = _webView.CoreWebView2.Settings;
            settings.IsWebMessageEnabled = true;            // Enable Web Messages
            settings.AreDevToolsEnabled = true;             // Enable DevTools by default
            settings.AreDefaultContextMenusEnabled = false; // Disable default context menus
            _webView.DefaultBackgroundColor = Color.Transparent;
        }

        /// <summary>
        /// Disable certain browser features for a controlled environment.
        /// </summary>
        public void DisableBrowserFeatures()
        {
            InvokeOnUiThread(() => {
                if (_webView?.CoreWebView2 != null)
                {
                    var settings = _webView.CoreWebView2.Settings;
                    settings.AreDevToolsEnabled = false;   // Disable DevTools
                    settings.IsStatusBarEnabled = false;   // Disable Status Bar
                    settings.IsZoomControlEnabled = false; // Disable Zoom Control
                }
            });
        }

        // --- EVENT REGISTRATION ---

        /// <summary>
        /// Register event handlers for WebView2 events.
        /// </summary>
        private void RegisterEvents()
        {
            // Context Menu Event
            _webView.CoreWebView2.ContextMenuRequested += (s, e) =>
            {
                if (!_contextMenuEnabled)
                {
                    e.Handled = true;
                    return;
                }

                string contextType = e.ContextMenuTarget.Kind.ToString();
                string linkUri = e.ContextMenuTarget.HasLinkUri ? e.ContextMenuTarget.LinkUri : "";
                string sourceUri = e.ContextMenuTarget.HasSourceUri ? e.ContextMenuTarget.SourceUri : "";

                OnMessageReceived?.Invoke($"CONTEXT_MENU|{e.Location.X}|{e.Location.Y}|{contextType}|{linkUri}|{sourceUri}");
            };

            // Ad Blocking
            _webView.CoreWebView2.AddWebResourceRequestedFilter("*", CoreWebView2WebResourceContext.All);
            _webView.CoreWebView2.WebResourceRequested += (s, e) =>
            {
                if (!_isAdBlockActive) return;
                string uri = e.Request.Uri.ToLower();
                foreach (var domain in _blockList)
                {
                    if (uri.Contains(domain))
                    {
                        e.Response = _webView.CoreWebView2.Environment.CreateWebResourceResponse(null, 403, "Forbidden", "");
                        OnMessageReceived?.Invoke($"BLOCKED_AD|{uri}");
                        return;
                    }
                }
            };

            // Navigation and State Events
            _webView.CoreWebView2.DownloadStarting += (s, e) =>
                OnMessageReceived?.Invoke($"DOWNLOAD_STARTING|{e.DownloadOperation.ResultFilePath}|{e.DownloadOperation.Uri}");

            _webView.CoreWebView2.NewWindowRequested += (s, e) => { e.Handled = true; _webView.CoreWebView2.Navigate(e.Uri); };

            _webView.NavigationStarting += (s, e) => OnMessageReceived?.Invoke("NAV_STARTING");

            _webView.NavigationCompleted += (s, e) => {
                if (e.IsSuccess)
                {
                    OnMessageReceived?.Invoke("NAV_COMPLETED");
                    OnMessageReceived?.Invoke("TITLE_CHANGED|" + _webView.CoreWebView2.DocumentTitle);
                }
                else OnMessageReceived?.Invoke("NAV_ERROR|" + e.WebErrorStatus);
            };

            _webView.CoreWebView2.SourceChanged += (s, e) => OnMessageReceived?.Invoke("URL_CHANGED|" + _webView.Source);

            // --- THE FIX IS HERE ---
            // Instead of sending the WebMessage to OnMessageReceived (Manager),
            // we send it to Bridge so that Bridge_OnMessageReceived in AutoIt can catch it.
            _webView.CoreWebView2.WebMessageReceived += (s, e) =>
            {
                string message = e.TryGetWebMessageAsString();
                _bridge.RaiseMessage(message); // Στέλνει το μήνυμα στο σωστό κανάλι
            };

            _webView.CoreWebView2.AddHostObjectToScript("autoit", _bridge);
        }

        // --- PUBLIC API METHODS ---

        /// <summary>
        /// Clear browser data (cookies, cache, history, etc.).
        /// </summary>
        public async void ClearBrowserData()
        {
            await _webView.EnsureCoreWebView2Async();
            // Clears cookies, history, cache, etc.
            await _webView.CoreWebView2.Profile.ClearBrowsingDataAsync();
            OnMessageReceived?.Invoke("DATA_CLEARED");
        }

        /// <summary>
        /// Lock down the WebView by disabling certain features.
        /// </summary>
        public void LockWebView()
        {
            InvokeOnUiThread(() => {
                if (_webView?.CoreWebView2 != null)
                {
                    var s = _webView.CoreWebView2.Settings;
                    s.AreDefaultContextMenusEnabled = false; // Disable context menus
                    s.AreDevToolsEnabled = false;            // Disable DevTools    
                    s.IsZoomControlEnabled = false;          // Disable Zoom Control
                    s.IsBuiltInErrorPageEnabled = false;     // Disable built-in error pages
                }
            });
        }

        /// <summary>
        /// Stops any ongoing navigation or loading.
        /// </summary>
        public void Stop()
        {
            _webView?.CoreWebView2.Stop();
        }

        /// <summary>
        /// Shows the print UI dialog.
        /// </summary>
        public void ShowPrintUI()
        {
            _webView?.CoreWebView2.ShowPrintUI();
        }

        /// <summary>
        /// Sets the mute status for audio.
        /// </summary>
        public void SetMuted(bool muted)
        {
            if (_webView?.CoreWebView2 != null)
                _webView.CoreWebView2.IsMuted = muted;
        }

        /// <summary>
        /// Gets the current mute status.
        /// </summary>
        public bool IsMuted()
        {
            return _webView?.CoreWebView2?.IsMuted ?? false;
        }

        /// <summary>
        /// Reload the current page.
        /// </summary>
        public void Reload()
        {
            // Check if CoreWebView2 is initialized to avoid null reference exceptions
            if (_webView != null && _webView.CoreWebView2 != null)
            {
                _webView.CoreWebView2.Reload();
            }
        }

        /// <summary>
        /// Navigate back in history.
        /// </summary>
        public void GoBack() => InvokeOnUiThread(() => {
            if (_webView?.CoreWebView2 != null && _webView.CoreWebView2.CanGoBack)
                _webView.CoreWebView2.GoBack();
        });

        /// <summary>
        /// Navigate forward in history.
        /// </summary>
        public void GoForward() => InvokeOnUiThread(() => {
            if (_webView?.CoreWebView2 != null && _webView.CoreWebView2.CanGoForward)
                _webView.CoreWebView2.GoForward();
        });

        /// <summary>
        /// Reset zoom to default (100%).
        /// </summary>
        public void ResetZoom() => SetZoom(1.0);

        /// <summary>
        /// Clear all ad block rules.
        /// </summary>
        public void ClearBlockRules() => _blockList.Clear();

        /// <summary>
        /// Enable or disable the default context menu.
        /// </summary>
        public void SetContextMenuEnabled(bool enabled)
        {
            _contextMenuEnabled = enabled; // Store preference
            InvokeOnUiThread(() => {
                if (_webView?.CoreWebView2 != null)
                    _webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = enabled;
            });
        }

        /// <summary>
        /// Navigate to a specified URL.
        /// </summary>
        public void Navigate(string url) => InvokeOnUiThread(() => _webView.CoreWebView2?.Navigate(url));

        /// <summary>
        /// Navigate to a string containing HTML content.
        /// </summary>
        public void NavigateToString(string htmlContent)
        {
            _webView.Invoke(new Action(async () => {
                int attempts = 0;
                while (_webView.CoreWebView2 == null && attempts < 20) { await Task.Delay(50); attempts++; }
                _webView.CoreWebView2?.NavigateToString(htmlContent);
            }));
        }

        /// <summary>
        /// Execute arbitrary JavaScript code.
        /// </summary>
        public void ExecuteScript(string script)
        {
            if (_webView?.CoreWebView2 != null)
                _webView.Invoke(new Action(() => _webView.CoreWebView2.ExecuteScriptAsync(script)));
        }

        /// <summary>
        /// Inject CSS code into the current page.
        /// </summary>
        public void InjectCss(string cssCode)
        {
            string js = $"(function() {{ let style = document.getElementById('{StyleId}'); if (!style) {{ style = document.createElement('style'); style.id = '{StyleId}'; document.head.appendChild(style); }} style.innerHTML = `{cssCode}`; }})();";
            ExecuteScript(js);
        }

        /// <summary>
        /// Remove previously injected CSS.
        /// </summary>
        public void ClearInjectedCss() => ExecuteScript($"(function() {{ let style = document.getElementById('{StyleId}'); if (style) style.remove(); }})();");

        /// <summary>
        /// Toggle audit highlights on/off.
        /// </summary>
        public void ToggleAuditHighlights(bool enable)
        {
            if (enable) InjectCss("img, h1, h2, h3, table, a { outline: 3px solid #FF6A00 !important; outline-offset: -3px !important; }");
            else ClearInjectedCss();
        }

        /// <summary>
        /// Retrieve the full HTML source of the current page.
        /// </summary>
        public async void GetHtmlSource()
        {
            if (_webView?.CoreWebView2 == null) return;
            string html = await _webView.CoreWebView2.ExecuteScriptAsync("document.documentElement.outerHTML");
            OnMessageReceived?.Invoke("HTML_SOURCE|" + CleanJsString(html));
        }

        /// <summary>
        /// Retrieve the currently selected text on the page.
        /// </summary>
        public async void GetSelectedText()
        {
            if (_webView?.CoreWebView2 == null) return;
            string selectedText = await _webView.CoreWebView2.ExecuteScriptAsync("window.getSelection().toString()");
            OnMessageReceived?.Invoke("SELECTED_TEXT|" + CleanJsString(selectedText));
        }

        /// <summary>
        /// Clean up JavaScript string results.
        /// </summary>
        private string CleanJsString(string input)
        {
            string decoded = System.Text.RegularExpressions.Regex.Unescape(input);
            if (decoded.StartsWith("\"") && decoded.EndsWith("\"") && decoded.Length >= 2)
                decoded = decoded.Substring(1, decoded.Length - 2);
            return decoded;
        }

        /// <summary>
        /// Resize the WebView control.
        /// </summary>
        public void Resize(int w, int h) => InvokeOnUiThread(() => _webView.Size = new Size(w, h));
        
        /// <summary>
        /// Clean up resources.
        /// </summary>
        public void Cleanup() => _webView?.Dispose();

        /// <summary>
        /// Set the zoom factor.
        /// </summary>
        public void SetZoom(double factor) => InvokeOnUiThread(() => _webView.ZoomFactor = factor);

        /// <summary>
        /// Export the current page to a PDF file.
        /// </summary>
        public void ExportToPdf(string filePath)
        {
            InvokeOnUiThread(async () => {
                try
                {
                    if (_webView?.CoreWebView2 != null)
                    {
                        await _webView.CoreWebView2.PrintToPdfAsync(filePath, null);
                        OnMessageReceived?.Invoke("PDF_SUCCESS|" + filePath);
                    }
                }
                catch (Exception ex) { OnMessageReceived?.Invoke("PDF_ERROR|" + ex.Message); }
            });
        }

        /// <summary>
        /// Ad Block Methods. set AdBlock active state.
        /// </summary>
        public void SetAdBlock(bool active) => _isAdBlockActive = active;

        /// <summary>
        /// Add a domain to the block list.
        /// </summary>
        public void AddBlockRule(string domain) { if (!string.IsNullOrEmpty(domain)) _blockList.Add(domain.ToLower()); }

        /// <summary>
        /// Parse JSON into the internal parser.
        /// </summary>
        public bool ParseJsonToInternal(string json) => _internalParser.Parse(json);

        /// <summary>
        /// Get a value from the internal JSON parser.
        /// </summary>
        public string GetInternalJsonValue(string path) => _internalParser.GetTokenValue(path);

        // --- NEW ENRICHED METHODS ---

        /// <summary>
        /// Set a custom User Agent.
        /// </summary>
        public void SetUserAgent(string userAgent)
        {
            InvokeOnUiThread(() => {
                if (_webView?.CoreWebView2?.Settings != null)
                    _webView.CoreWebView2.Settings.UserAgent = userAgent;
            });
        }

        /// <summary>
        /// Get the Document Title.
        /// </summary>
        public string GetDocumentTitle()
        {
            return _webView?.CoreWebView2?.DocumentTitle ?? "";
        }

        /// <summary>
        /// Get the Current Source URL.
        /// </summary>
        public string GetSource()
        {
            return _webView?.Source?.ToString() ?? "";
        }

        /// <summary>
        /// Enable or Disable JavaScript execution.
        /// </summary>
        public void SetScriptEnabled(bool enabled)
        {
            InvokeOnUiThread(() => {
                if (_webView?.CoreWebView2?.Settings != null)
                    _webView.CoreWebView2.Settings.IsScriptEnabled = enabled;
            });
        }

        /// <summary>
        /// Enable or Disable Web Messages (Communication).
        /// </summary>
        public void SetWebMessageEnabled(bool enabled)
        {
            InvokeOnUiThread(() => {
                if (_webView?.CoreWebView2?.Settings != null)
                    _webView.CoreWebView2.Settings.IsWebMessageEnabled = enabled;
            });
        }

        /// <summary>
        /// Enable or Disable the Status Bar.
        /// </summary>
        public void SetStatusBarEnabled(bool enabled)
        {
            InvokeOnUiThread(() => {
                if (_webView?.CoreWebView2?.Settings != null)
                    _webView.CoreWebView2.Settings.IsStatusBarEnabled = enabled;
            });
        }

        /// <summary>
        /// Capture a screenshot (preview) of the current view.
        /// </summary>
        /// <param name="filePath">The destination file path.</param>
        /// <param name="format">The format (png or jpg).</param>
        public async void CapturePreview(string filePath, string format)
        {
            if (_webView?.CoreWebView2 == null) return;
            
            CoreWebView2CapturePreviewImageFormat imageFormat = CoreWebView2CapturePreviewImageFormat.Png;
            if (format.ToLower().Contains("jpg") || format.ToLower().Contains("jpeg"))
                imageFormat = CoreWebView2CapturePreviewImageFormat.Jpeg;

            try
            {
                using (var fileStream = File.Create(filePath))
                {
                    await _webView.CoreWebView2.CapturePreviewAsync(imageFormat, fileStream);
                }
                OnMessageReceived?.Invoke("CAPTURE_SUCCESS|" + filePath);
            }
            catch (Exception ex)
            {
                OnMessageReceived?.Invoke("CAPTURE_ERROR|" + ex.Message);
            }
        }

        /// <summary>
        /// Call a DevTools Protocol (CDP) method directly.
        /// </summary>
        public async void CallDevToolsProtocolMethod(string methodName, string parametersJson)
        {
            if (_webView?.CoreWebView2 == null) return;
            try
            {
                string result = await _webView.CoreWebView2.CallDevToolsProtocolMethodAsync(methodName, parametersJson);
                OnMessageReceived?.Invoke($"CDP_RESULT|{methodName}|{result}");
            }
            catch (Exception ex)
            {
                OnMessageReceived?.Invoke($"CDP_ERROR|{methodName}|{ex.Message}");
            }
        }

        /// <summary>
        /// Get Cookies asynchronously. Results are sent via the COOKIES_RECEIVED event.
        /// </summary>
        public async void GetCookies(string channelId)
        {
            if (_webView?.CoreWebView2?.CookieManager == null) return;
            try
            {
                var cookieList = await _webView.CoreWebView2.CookieManager.GetCookiesAsync(null);
                
                // Build JSON manually since we don't depend on external JSON serializers for this simple array
                var sb = new System.Text.StringBuilder("[");
                for(int i=0; i<cookieList.Count; i++)
                {
                    var c = cookieList[i];
                    sb.Append($"{{\"name\":\"{c.Name}\",\"value\":\"{c.Value}\",\"domain\":\"{c.Domain}\",\"path\":\"{c.Path}\"}}");
                    if (i < cookieList.Count - 1) sb.Append(",");
                }
                sb.Append("]");

                // Build the JSON string as before
                string jsonRaw = sb.ToString();

                // Convert to Base64 to ensure safe transport of large data
                var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(jsonRaw);
                string base64Json = Convert.ToBase64String(plainTextBytes);

                //OnMessageReceived?.Invoke($"COOKIES_B64|{channelId}|{sb.ToString()}");
                OnMessageReceived?.Invoke($"COOKIES_B64|{channelId}|{base64Json}");
            }
            catch (Exception ex)
            {
                OnMessageReceived?.Invoke($"COOKIES_ERROR|{channelId}|{ex.Message}");
            }
        }

        /// <summary>
        /// Add or Update a Cookie.
        /// </summary>
        public void AddCookie(string name, string value, string domain, string path)
        {
            if (_webView?.CoreWebView2?.CookieManager == null) return;
            try
            {
                var cookie = _webView.CoreWebView2.CookieManager.CreateCookie(name, value, domain, path);
                _webView.CoreWebView2.CookieManager.AddOrUpdateCookie(cookie);
            }
            catch (Exception ex)
            {
                OnMessageReceived?.Invoke($"COOKIE_ADD_ERROR|{ex.Message}");
            }
        }

        /// <summary>
        /// Delete a specific Cookie.
        /// </summary>
        public void DeleteCookie(string name, string domain, string path)
        {
            if (_webView?.CoreWebView2?.CookieManager == null) return;
            var cookie = _webView.CoreWebView2.CookieManager.CreateCookie(name, "", domain, path);
            _webView.CoreWebView2.CookieManager.DeleteCookie(cookie);
        }

        /// <summary>
        /// Delete All Cookies.
        /// </summary>
        public void DeleteAllCookies()
        {
            _webView?.CoreWebView2?.CookieManager?.DeleteAllCookies();
        }

        /// <summary>
        /// Initiate the native Print dialog.
        /// </summary>
        public void Print()
        {
            // Note: This might not be available in older WebView2 SDKs, but is standard now.
            // If strictly needed to be safe, we check method existence, but straightforward call is:
             InvokeOnUiThread(async () => {
                if (_webView?.CoreWebView2 != null)
                {
                     // Requires wrapping in try/catch as it relies on valid printing environment
                     try { await _webView.CoreWebView2.ExecuteScriptAsync("window.print();"); } 
                     catch(Exception ex) { OnMessageReceived?.Invoke("PRINT_ERROR|" + ex.Message); }
                }
             });
        }

        // --- HELPER METHODS ---

        /// Invoke actions on the UI thread
        private void InvokeOnUiThread(Action action)
        {
            if (_webView == null || _webView.IsDisposed) return;
            if (_webView.InvokeRequired) _webView.Invoke(action);
            else action();
        }
    }
}