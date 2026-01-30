using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using System.Windows.Forms;

// --- Version 1.5.0 ---

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
        [DispId(1)] void OnMessageReceived(string message);
        /// <summary>
        /// Triggered when navigation starts.
        /// </summary>
        /// <param name="url">The URL being navigated to.</param> 
        [DispId(2)] void OnNavigationStarting(string url);
        /// <summary>
        /// Triggered when navigation is completed.
        /// </summary>
        /// <param name="isSuccess">Indicates if navigation was successful.</param>  
        /// <param name="webErrorStatus">The web error status code.</param> 
        [DispId(3)] void OnNavigationCompleted(bool isSuccess, int webErrorStatus);
        /// <summary>
        /// Triggered when the document title changes.
        /// </summary>
        /// <param name="newTitle">The new document title.</param> 
        [DispId(4)] void OnTitleChanged(string newTitle);

        /// <summary>Triggered when a custom context menu is requested.</summary>
        /// <param name="menuData">JSON string containing context info (kind, link, selection).</param>
        [DispId(6)] void OnContextMenu(string menuData);

        /// <summary>Triggered when the zoom factor changes.</summary>
        [DispId(10)] void OnZoomChanged(double factor);
        /// <summary>Triggered when the browser gets focus.</summary>
        [DispId(11)] void OnBrowserGotFocus(int reason);
        /// <summary>Triggered when the browser loses focus.</summary>
        [DispId(12)] void OnBrowserLostFocus(int reason);
        /// <summary>
        /// Triggered when the URL changes.
        /// </summary>
        /// <param name="newUrl">The new URL.</param> 
        [DispId(13)] void OnURLChanged(string newUrl);

        /// <summary>Triggered when a web resource response is received (e.g., for HttpStatusCode).</summary>
        /// <param name="statusCode">The HTTP status code.</param>
        /// <param name="reasonPhrase">The HTTP reason phrase.</param>
        /// <param name="requestUrl">The full URL of the request.</param>
        [DispId(5)] void OnWebResourceResponseReceived(int statusCode, string reasonPhrase, string requestUrl);

        /// <param name="selectionText">The selected text under the cursor, if any.</param>
        [DispId(190)] void OnContextMenuRequested(string linkUrl, int x, int y, string selectionText);

        /// <summary>Triggered when a download is starting.</summary>
        [DispId(208)] void OnDownloadStarting(string uri, string defaultPath);

        /// <summary>Triggered when a download state changed.</summary>
        [DispId(209)] void OnDownloadStateChanged(string state, string uri, long totalBytes, long receivedBytes);
    }

    /// <summary>
    /// Actions available to call from AutoIt.
    /// </summary>
    [Guid("CCB12345-6789-4ABC-DEF0-1234567890AB")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IWebViewActions
    {
        /// <summary>Set additional browser arguments (switches) before initialization.</summary>
        [DispId(100)] string AdditionalBrowserArguments { get; set; }
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
        /// <summary>Unlock the WebView by re-enabling restricted features.</summary>
        [DispId(215)] void UnLockWebView();
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
        /// <summary>Remove Extension.</summary>
        [DispId(151)] void RemoveExtension(string extensionId);

        /// <summary>Check if can go back.</summary>
        [DispId(162)] bool GetCanGoBack();
        /// <summary>Check if can go forward.</summary>
        [DispId(163)] bool GetCanGoForward();
        /// <summary>Get Browser Process ID.</summary>
        [DispId(164)] uint GetBrowserProcessId();
        /// <summary>Encode a string for URL.</summary>
        [DispId(165)] string EncodeURI(string value);
        /// <summary>Decode a URL string.</summary>
        [DispId(166)] string DecodeURI(string value);
        /// <summary>Encode a string for Base64.</summary>
        [DispId(167)] string EncodeB64(string value);
        /// <summary>Decode a Base64 string.</summary>
        [DispId(168)] string DecodeB64(string value);

        // --- NEW UNIFIED SETTINGS (PROPERTIES) ---
        /// <summary>Check if DevTools are enabled.</summary>
        [DispId(170)] bool AreDevToolsEnabled { get; set; }
        /// <summary>Check if default context menus are enabled.</summary>
        [DispId(171)] bool AreDefaultContextMenusEnabled { get; set; }
        /// <summary>Check if default script dialogs are enabled.</summary>
        [DispId(172)] bool AreDefaultScriptDialogsEnabled { get; set; }
        /// <summary>Check if browser accelerator keys are enabled.</summary>
        [DispId(173)] bool AreBrowserAcceleratorKeysEnabled { get; set; }
        /// <summary>Check if status bar is enabled.</summary>
        [DispId(174)] bool IsStatusBarEnabled { get; set; }
        /// <summary>Get/Set Zoom Factor.</summary>
        [DispId(175)] double ZoomFactor { get; set; }
        /// <summary>Set Background Color (Hex string).</summary>
        [DispId(176)] string BackColor { get; set; }
        /// <summary>Check if host objects are allowed.</summary>
        [DispId(177)] bool AreHostObjectsAllowed { get; set; }
        /// <summary>Get/Set Anchor (Resizing).</summary>
        [DispId(178)] int Anchor { get; set; }
        /// <summary>Get/Set Border Style.</summary>
        [DispId(179)] int BorderStyle { get; set; }

        // --- NEW UNIFIED METHODS ---
        /// <summary>Set Zoom Factor (Wrapper).</summary>
        [DispId(180)] void SetZoomFactor(double factor);
        /// <summary>Open DevTools Window.</summary>
        [DispId(181)] void OpenDevToolsWindow();
        /// <summary>Focus the WebView.</summary>
        [DispId(182)] void WebViewSetFocus();
        /// <summary>Check if browser popups are allowed or redirected to the same window.</summary>
        [DispId(183)] bool AreBrowserPopupsAllowed { get; set; }
        /// <summary>Add a script that executes on every page load (Permanent Injection).</summary>
        [DispId(184)] void AddInitializationScript(string script);
        /// <summary>Binds the internal JSON data to a browser variable.</summary>
        [DispId(185)] bool BindJsonToBrowser(string variableName);
        /// <summary>Syncs JSON data to internal parser and optionally binds it to a browser variable.</summary>
        [DispId(186)] void SyncInternalData(string json, string bindToVariableName = "");

        /// <summary>Execute JavaScript and return result synchronously (Blocking wait).</summary>
        [DispId(188)] string ExecuteScriptWithResult(string script);
        /// <summary>Enables or disables automatic resizing of the WebView to fill its parent.</summary>
        [DispId(189)] void SetAutoResize(bool enabled);

        /// <summary>Execute JavaScript on the current page immediately.</summary>
        [DispId(191)] void ExecuteScriptOnPage(string script);

        /// <summary>Clears the browser cache (DiskCache and LocalStorage).</summary>
        [DispId(193)] void ClearCache();
        /// <summary>Enables or disables custom context menu handling.</summary>
        [DispId(194)] bool CustomMenuEnabled { get; set; }
        /// <summary>Enable/Disable OnWebResourceResponseReceived event.</summary>
        [DispId(195)] bool HttpStatusCodeEventsEnabled { get; set; }
        /// <summary>Filter HttpStatusCode events to only include the main document.</summary>
        [DispId(196)] bool HttpStatusCodeDocumentOnly { get; set; }


        /// <summary>Get inner text.</summary>
        [DispId(200)] void GetInnerText();

        /// <summary>Capture page data as MHTML or other CDP snapshot formats.</summary>
        [DispId(201)] string CaptureSnapshot(string cdpParameters = "{\"format\": \"mhtml\"}");
        /// <summary>Export page data as HTML or MHTML (Legacy Support).</summary>
        [DispId(207)] string ExportPageData(int format, string filePath);
        /// <summary>Capture page as PDF and return as Base64 string.</summary>
        [DispId(202)] string PrintToPdfStream();
        /// <summary>Control PDF toolbar items visibility.</summary>
        [DispId(203)] int HiddenPdfToolbarItems { get; set; }
        /// <summary>Custom Download Path.</summary>
        [DispId(204)] void SetDownloadPath(string path);
        /// <summary>Enable/Disable default Download UI.</summary>
        [DispId(205)] bool IsDownloadUIEnabled { get; set; }
        /// <summary>Decode a Base64 string to raw binary data (byte array).</summary>
        [DispId(206)] byte[] DecodeB64ToBinary(string base64Text);

        /// <summary>Capture preview as Base64 string.</summary>
        [DispId(216)] string CapturePreviewAsBase64(string format);

        /// <summary>Cancels downloads. If uri is null or empty, cancels all active downloads.</summary>
        [DispId(210)] void CancelDownloads(string uri = "");
        /// <summary>Returns a pipe-separated string of all active download URIs.</summary>
        [DispId(214)] string ActiveDownloadsList { get; }
        /// <summary>Set to true to suppress the default download UI, typically set during the OnDownloadStarting event.</summary>
        [DispId(211)] bool IsDownloadHandled { get; set; }
        /// <summary>Enable/Disable Zoom control (Ctrl+Wheel, shortcuts).</summary>
        [DispId(212)] bool IsZoomControlEnabled { get; set; }
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
        #region 1. PRIVATE FIELDS
        private readonly WebView2 _webView;
        private readonly WebViewBridge _bridge;
        private readonly JsonParser _internalParser = new JsonParser();

        private bool _isAdBlockActive = false;
        private readonly List<string> _blockList = new List<string>();
        private const string StyleId = "autoit-injected-style";
        private bool _areBrowserPopupsAllowed = false;
        private bool _contextMenuEnabled = true;
        private bool _autoResizeEnabled = false;
        private bool _customMenuEnabled = false;
        private string _additionalBrowserArguments = "";
        private string _customDownloadPath = "";
        private bool _isDownloadUIEnabled = true;
        private bool _httpStatusCodeEventsEnabled = true;
        private bool _httpStatusCodeDocumentOnly = true;
        private bool _isDownloadHandledOverride = false;
        private bool _isZoomControlEnabled = true;

        private int _offsetX = 0;
        private int _offsetY = 0;
        private int _marginRight = 0;
        private int _marginBottom = 0;
        private IntPtr _parentHandle = IntPtr.Zero;
        private ParentWindowSubclass _parentSubclass;

        private string _lastCssRegistrationId = "";

        // Keeps active downloads keyed by their URI
        private readonly Dictionary<string, CoreWebView2DownloadOperation> _activeDownloads = new Dictionary<string, CoreWebView2DownloadOperation>();

        #endregion

        #region 2. DELEGATES & EVENTS
        /// <summary>
        /// Delegate for detecting when messages are received.
        /// </summary>
        /// <param name="message">The message content.</param>
        public delegate void OnMessageReceivedDelegate(string message);

        /// <summary>
        /// Delegate for navigation starting event.
        /// </summary>
        /// <param name="url">The URL being navigated to.</param> 
        public delegate void OnNavigationStartingDelegate(string url);

        /// <summary>
        /// Delegate for navigation completed event.
        /// </summary> 
        /// <param name="isSuccess">Indicates if navigation was successful.</param>
        /// <param name="webErrorStatus">The web error status code.</param> 
        public delegate void OnNavigationCompletedDelegate(bool isSuccess, int webErrorStatus);

        /// <summary>
        /// Delegate for title changed event.
        /// </summary>
        /// <param name="newTitle">The new document title.</param> 
        public delegate void OnTitleChangedDelegate(string newTitle);

        /// <summary>
        /// Delegate for URL changed event.
        /// </summary>
        /// <param name="newUrl">The new URL.</param> 
        public delegate void OnURLChangedDelegate(string newUrl);

        /// <summary>Delegate for custom context menu event.</summary>
        /// <param name="message">JSON string with context info.</param>
        public delegate void OnContextMenuDelegate(string message);

        /// <summary>Delegate for simplified context menu event.</summary>
        public delegate void OnContextMenuRequestedDelegate(string linkUrl, int x, int y, string selectionText);

        /// <summary>Delegate for Zoom Changed.</summary>
        public delegate void OnZoomChangedDelegate(double factor);
        /// <summary>Delegate for Got Focus.</summary>
        public delegate void OnBrowserGotFocusDelegate(int reason);
        /// <summary>Delegate for Lost Focus.</summary>
        public delegate void OnBrowserLostFocusDelegate(int reason);

        /// <summary>Delegate for Web Resource Response Received (HttpStatusCode).</summary>
        /// <param name="statusCode">The HTTP status code.</param>
        /// <param name="reasonPhrase">The HTTP reason phrase.</param>
        /// <param name="requestUrl">The full URL of the request.</param>
        public delegate void OnWebResourceResponseReceivedDelegate(int statusCode, string reasonPhrase, string requestUrl);

        /// <summary>Delegate for Download Starting.</summary>
        public delegate void OnDownloadStartingDelegate(string uri, string defaultPath);
        /// <summary>Delegate for Download State Changed.</summary>
        public delegate void OnDownloadStateChangedDelegate(string state, string uri, long totalBytes, long receivedBytes);

        /// <summary>
        /// Event fired when a message is received.
        /// </summary>
        public event OnMessageReceivedDelegate OnMessageReceived;

        /// <summary>
        /// Event fired when navigation starts.
        /// </summary> 
        public event OnNavigationStartingDelegate OnNavigationStarting;

        /// <summary>
        /// Event fired when navigation is completed.
        /// </summary>
        public event OnNavigationCompletedDelegate OnNavigationCompleted;

        /// <summary>
        /// Event fired when the document title changes.
        /// </summary> 
        public event OnTitleChangedDelegate OnTitleChanged;

        /// <summary>
        /// Event fired when the URL changes.
        /// </summary> 
        public event OnURLChangedDelegate OnURLChanged;

        /// <summary>Event fired when a web resource response is received.</summary>
        public event OnWebResourceResponseReceivedDelegate OnWebResourceResponseReceived;

        /// <summary>Event fired when a download is starting.</summary>
        public event OnDownloadStartingDelegate OnDownloadStarting;
        /// <summary>Event fired when a download state changed.</summary>
        public event OnDownloadStateChangedDelegate OnDownloadStateChanged;

        /// <summary>Event fired when a custom context menu is requested.</summary>
        public event OnContextMenuDelegate OnContextMenu;

        /// <summary>Event fired when a simplified context menu is requested.</summary>
        public event OnContextMenuRequestedDelegate OnContextMenuRequested;

        /// <summary>Event fired when zoom factor changes.</summary>
        public event OnZoomChangedDelegate OnZoomChanged;
        /// <summary>Event fired when browser gets focus.</summary>
        public event OnBrowserGotFocusDelegate OnBrowserGotFocus;
        /// <summary>Event fired when browser loses focus.</summary>
        public event OnBrowserLostFocusDelegate OnBrowserLostFocus;
        #endregion

        #region 3. NATIVE METHODS & HELPERS
        [DllImport("user32.dll")]
        private static extern bool GetClientRect(IntPtr hWnd, out Rect lpRect);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);

        [DllImport("user32.dll")]
        private static extern IntPtr GetFocus();

        [DllImport("user32.dll")]
        private static extern bool IsChild(IntPtr hWndParent, IntPtr hWnd);

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
        #endregion

        #region 4. CONSTRUCTOR
        /// <summary>
        /// Initializes a new instance of the WebViewManager class.
        /// </summary>
        public WebViewManager()
        {
            _webView = new WebView2();
            _bridge = new WebViewBridge();
        }
        #endregion

        #region 5. BRIDGE & STATUS
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
        #endregion

        #region 6. CORE INITIALIZATION
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
                _parentHandle = new IntPtr(rawHandleValue);

                // Store offsets for Smart Resize
                _offsetX = x;
                _offsetY = y;

                // Calculate Margins based on Parent's size at initialization
                int calcWidth = width;
                int calcHeight = height;

                if (GetClientRect(_parentHandle, out Rect parentRect))
                {
                    int pWidth = parentRect.Right - parentRect.Left;
                    int pHeight = parentRect.Bottom - parentRect.Top;

                    // If user provides 0 (or less), we assume they want to fill the parent
                    if (width <= 0)
                    {
                        calcWidth = Math.Max(10, pWidth - x);
                        _marginRight = 0;
                    }
                    else
                    {
                        _marginRight = Math.Max(0, (pWidth - x) - width);
                    }

                    if (height <= 0)
                    {
                        calcHeight = Math.Max(10, pHeight - y);
                        _marginBottom = 0;
                    }
                    else
                    {
                        _marginBottom = Math.Max(0, (pHeight - y) - height);
                    }
                }
                else
                {
                    _marginRight = 0;
                    _marginBottom = 0;
                }

                // Initialize the Subclass helper for Smart Resize
                _parentSubclass = new ParentWindowSubclass(() => PerformSmartResize());

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
                    _webView.Size = new Size(calcWidth, calcHeight);
                    // Attach the WebView to the AutoIt window/container
                    SetParent(_webView.Handle, _parentHandle);
                    _webView.Visible = false;
                });

                // --- NEW: EXTENSION SUPPORT SETUP ---
                // We must enable extensions in the Environment Options BEFORE creation
                var options = new CoreWebView2EnvironmentOptions { AreBrowserExtensionsEnabled = true };
                if (!string.IsNullOrEmpty(_additionalBrowserArguments)) options.AdditionalBrowserArguments = _additionalBrowserArguments;

                // Initialize the Environment with the Custom Data Folder and our Options
                // Note: The second parameter is the userDataFolder, the third is the options
                var env = await CoreWebView2Environment.CreateAsync(null, userDataFolder, options);

                // Wait for the CoreWebView2 engine to be ready
                await _webView.EnsureCoreWebView2Async(env);

                // Apply settings and register events
                ConfigureSettings();
                RegisterEvents();

                // Add default context menu bridge helper
                await _webView.CoreWebView2.AddScriptToExecuteOnDocumentCreatedAsync(@"
                    window.dispatchEventToAutoIt = function(lnk, x, y, sel) {
                        window.chrome.webview.postMessage('CONTEXT_MENU_REQUEST|' + (lnk||'') + '|' + (x||0) + '|' + (y||0) + '|' + (sel||''));
                    };
                ");

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
        public void AddExtension(string extensionPath)
        {
            InvokeOnUiThread(async () =>
            {
                // Ensure the WebView and Profile are ready
                if (_webView?.CoreWebView2?.Profile == null)
                {
                    OnMessageReceived?.Invoke("ERROR|EXTENSION|WebView2 Profile not ready.");
                    return;
                }

                // Validate the extension path
                if (!System.IO.Directory.Exists(extensionPath))
                {
                    OnMessageReceived?.Invoke("ERROR|EXTENSION|Path not found: " + extensionPath);
                    return;
                }

                try
                {
                    // Add the browser extension
                    var ext = await _webView.CoreWebView2.Profile.AddBrowserExtensionAsync(extensionPath);

                    // Notify AutoIt that the extension has been loaded successfully
                    OnMessageReceived?.Invoke("EXTENSION_LOADED|" + ext.Id);
                }
                catch (Exception ex)
                {
                    OnMessageReceived?.Invoke("ERROR|EXTENSION_FAILED|" + ex.Message);
                }
            });
        }

        /// <summary>
        /// Removes a browser extension by its ID.
        /// </summary>
        /// <param name="extensionId">The ID of the extension to remove.</param> 
        public void RemoveExtension(string extensionId)
        {
            InvokeOnUiThread(async () =>
            {
                if (_webView?.CoreWebView2?.Profile == null) return;

                try
                {
                    // Retrieve all installed extensions
                    var extensions = await _webView.CoreWebView2.Profile.GetBrowserExtensionsAsync();

                    foreach (var ext in extensions)
                    {
                        if (ext.Id == extensionId)
                        {
                            await ext.RemoveAsync();
                            OnMessageReceived?.Invoke("EXTENSION_REMOVED|" + extensionId);
                            return;
                        }
                    }
                    OnMessageReceived?.Invoke("ERROR|EXTENSION_NOT_FOUND|" + extensionId);
                }
                catch (Exception ex)
                {
                    OnMessageReceived?.Invoke("ERROR|REMOVE_EXTENSION_FAILED|" + ex.Message);
                }
            });
        }
        #endregion

        #region 7. SETTINGS & CONFIGURATION
        /// <summary>
        /// Configure WebView2 settings.
        /// </summary>
        private void ConfigureSettings()
        {
            var settings = _webView.CoreWebView2.Settings;
            settings.IsWebMessageEnabled = true;            // Enable Web Messages
            settings.AreDevToolsEnabled = true;             // Enable DevTools by default
            settings.AreDefaultContextMenusEnabled = true;  // Keep TRUE to ensure the event fires
            settings.IsZoomControlEnabled = _isZoomControlEnabled; // Apply custom zoom setting
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
        #endregion

        #region 8. EVENT REGISTRATION
        /// <summary>
        /// Register event handlers for WebView2 events.
        /// </summary>
        private void RegisterEvents()
        {
            if (_webView?.CoreWebView2 == null) return;

            // --- RESTORED LOGIC ---

            // Context Menu Event
            _webView.CoreWebView2.ContextMenuRequested += async (sender, args) =>
            {
                // 1. Browser Default Menu Strategy
                // Handled=true means we block the browser's menu. 
                // Handled=false means we let the browser show its own menu.
                args.Handled = !_contextMenuEnabled;

                try
                {
                    // 2. Data Retrieval (Async parts first)
                    // Check if the element or any of its parents is TABLE
                    string script = "document.elementFromPoint(" + args.Location.X + "," + args.Location.Y + ").closest('table') ? 'TABLE' : document.elementFromPoint(" + args.Location.X + "," + args.Location.Y + ").tagName";
                    string tagName = await _webView.CoreWebView2.ExecuteScriptAsync(script);
                    tagName = tagName?.Trim('\"') ?? "UNKNOWN";

                    // Extraction of Context info
                    string k = args.ContextMenuTarget.Kind.ToString();
                    string src = args.ContextMenuTarget.HasSourceUri ? args.ContextMenuTarget.SourceUri : "";
                    string lnk = args.ContextMenuTarget.HasLinkUri ? args.ContextMenuTarget.LinkUri : "";
                    string sel = args.ContextMenuTarget.HasSelection ? args.ContextMenuTarget.SelectionText : "";

                    // --- CASE A: Parameter-based Event (v1.4.2 Priority) ---
                    // This is DispId 190 for AutoIt compatibility
                    _webView.BeginInvoke(new Action(() => {
                        OnContextMenuRequested?.Invoke(lnk, args.Location.X, args.Location.Y, sel);
                    }));

                    // --- CASE B: Legacy JSON-based Event (v1.4.1 compatibility) ---
                    // Build JSON - Escaping for safety
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

                    _webView.BeginInvoke(new Action(() => {
                        OnContextMenu?.Invoke("JSON:" + json);
                    }));
                }
                catch (Exception ex) 
                { 
                    Debug.WriteLine("ContextMenu Error: " + ex.Message); 
                }
            };

            // Ad Blocking
            _webView.CoreWebView2.AddWebResourceRequestedFilter("*", CoreWebView2WebResourceContext.All);
            _webView.CoreWebView2.WebResourceRequested += (s, e) =>
            {
                // Track if this is a Document request for HttpStatusCode filtering
                if (_httpStatusCodeEventsEnabled && _httpStatusCodeDocumentOnly && e.ResourceContext == CoreWebView2WebResourceContext.Document)
                {
                    e.Request.Headers.SetHeader("X-NetWebView2-IsDoc", "1");
                }

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
			
            _webView.CoreWebView2.NewWindowRequested += (s, e) => 
            {
                if (!_areBrowserPopupsAllowed) {
                    e.Handled = true;
                    if (!string.IsNullOrEmpty(e.Uri))
                    {
                        string targetUri = e.Uri;
                        _webView.BeginInvoke(new Action(() => {
                            if (_webView?.CoreWebView2 != null)
                            {
                                _webView.CoreWebView2.Navigate(targetUri);
                            }
                        }));
                    }
                }
            };

            // --- END RESTORED LOGIC ---

            // Navigation & Content Events
            _webView.CoreWebView2.NavigationStarting += (s, e) => { 
                OnNavigationStarting?.Invoke(e.Uri); 
				
				string url = e.Uri;
				
				// Notify AutoIt about navigation start
                OnMessageReceived?.Invoke("NAV_STARTING|" + url);
            };

            _webView.CoreWebView2.NavigationCompleted += (s, e) => { 
                OnNavigationCompleted?.Invoke(e.IsSuccess, (int)e.WebErrorStatus); 
				
				// Keep the old OnMessageReceived for compatibility (optional)
                if (e.IsSuccess)
                {
                    OnMessageReceived?.Invoke("NAV_COMPLETED");
                    OnMessageReceived?.Invoke("TITLE_CHANGED|" + _webView.CoreWebView2.DocumentTitle);
                }
                else
                {
                    OnMessageReceived?.Invoke("NAV_ERROR|" + e.WebErrorStatus);
                }
            };

            _webView.CoreWebView2.SourceChanged += (s, e) => { 
                OnURLChanged?.Invoke(_webView.CoreWebView2.Source); 
            };
			
			// Source Changed Event
            _webView.CoreWebView2.SourceChanged += (s, e) => OnMessageReceived?.Invoke("URL_CHANGED|" + _webView.Source);

            _webView.CoreWebView2.DocumentTitleChanged += (s, e) => { 
                OnTitleChanged?.Invoke(_webView.CoreWebView2.DocumentTitle); 
            };

            // Zoom Factor Changed Event
            _webView.ZoomFactorChanged += (s, e) => {
                OnZoomChanged?.Invoke(_webView.ZoomFactor);
                OnMessageReceived?.Invoke("ZOOM_CHANGED|" + _webView.ZoomFactor);
            };

            // Communication Event <---> AutoIt <---> JavaScript
            //_webView.CoreWebView2.WebMessageReceived += (s, e) => {
            //    OnMessageReceived?.Invoke(e.TryGetWebMessageAsString());
            //};
			
			// --- THE FIX IS HERE ---
            // Instead of sending the WebMessage to OnMessageReceived (Manager),
            // we send it to Bridge so that Bridge_OnMessageReceived in AutoIt can catch it.
            _webView.CoreWebView2.WebMessageReceived += (s, e) =>
            {
                string message = e.TryGetWebMessageAsString();
                
                // Routing: Check if this is a JS-triggered context menu request
                if (message != null && message.StartsWith("CONTEXT_MENU_REQUEST|"))
                {
                    var parts = message.Split('|');
                    if (parts.Length >= 5)
                    {
                        string lnk = parts[1];
                        int x = int.TryParse(parts[2], out int px) ? px : 0;
                        int y = int.TryParse(parts[3], out int py) ? py : 0;
                        string sel = parts[4];
                        
                        _webView.BeginInvoke(new Action(() => {
                            OnContextMenuRequested?.Invoke(lnk, x, y, sel);
                        }));
                        return; // Handled
                    }
                }

                _bridge.RaiseMessage(message); // Send message to the correct channel
            };

            // Focus Events (Native Bridge) 
            _webView.GotFocus += (s, e) => { OnBrowserGotFocus?.Invoke(0); };
            
            _webView.LostFocus += (s, e) => {
                _webView.BeginInvoke(new Action(() => {
                    // Use Native API to see which HWND REALLY has the focus
                    IntPtr focusedHandle = GetFocus(); 
                    
                    // If focusedHandle is NOT _webView.Handle 
                    // AND is NOT a child (IsChild) of _webView.Handle, then we truly lost focus.
                    if (focusedHandle != _webView.Handle && !IsChild(_webView.Handle, focusedHandle)) {
                        OnBrowserLostFocus?.Invoke(0);
                    }
                }));
            };
			
            // Communication Event <---> AutoIt <---> JavaScript
            _webView.CoreWebView2.AddHostObjectToScript("autoit", _bridge);

            // HttpStatusCode Tracking
            _webView.CoreWebView2.WebResourceResponseReceived += (s, e) =>
            {
                if (!_httpStatusCodeEventsEnabled) return;

                if (_httpStatusCodeDocumentOnly)
                {
                    bool isDoc = e.Request.Headers.Contains("X-NetWebView2-IsDoc");
                    if (!isDoc) return;
                }

                if (e.Response != null)
                {
                    int statusCode = e.Response.StatusCode;
                    string reasonPhrase = GetReasonPhrase(statusCode, e.Response.ReasonPhrase);
                    string requestUrl = e.Request.Uri;
                    _webView.BeginInvoke(new Action(() => {
                        OnWebResourceResponseReceived?.Invoke(statusCode, reasonPhrase, requestUrl);
                    }));
                }
            };

            _webView.CoreWebView2.DownloadStarting += (s, e) =>
            {
                string currentUri = e.DownloadOperation.Uri;
				
				// 1. Apply Custom Download Path if it exists
                if (!string.IsNullOrEmpty(_customDownloadPath))
                {
                    string fileName = System.IO.Path.GetFileName(e.ResultFilePath);
                    string fullPath = System.IO.Path.Combine(_customDownloadPath, fileName);
                    e.ResultFilePath = fullPath;
                }
				
				// Add to list so it can be canceled later
				_activeDownloads[currentUri] = e.DownloadOperation;

                // Reset per-download overrides
                _isDownloadHandledOverride = false; // Default to FALSE (Let Edge handle it)

                // Fire the event to AutoIt
                OnDownloadStarting?.Invoke(e.DownloadOperation.Uri, e.ResultFilePath); // Using the updated path

                // --- ROBUST WAIT FOR AUTOIT ---
                var sw = Stopwatch.StartNew();
                while (sw.ElapsedMilliseconds < 600 && !_isDownloadHandledOverride)
                {
                    System.Windows.Forms.Application.DoEvents();
                    System.Threading.Thread.Sleep(5);
                }

                if (_isDownloadHandledOverride)
                {
                    e.Cancel = true;
                    OnMessageReceived?.Invoke($"DOWNLOAD_CANCELLED|{e.DownloadOperation.Uri}");
                    return;
                }

                // --- STANDARD MODE: EDGE ---
                e.Handled = !_isDownloadUIEnabled;

                // Using e.ResultFilePath which now contains the correct path
                OnMessageReceived?.Invoke($"DOWNLOAD_STARTING|{e.DownloadOperation.Uri}|{e.ResultFilePath}");

                e.DownloadOperation.StateChanged += (sender, args) =>
                {
                    long totalBytes = (long)(e.DownloadOperation.TotalBytesToReceive ?? 0);
                    long receivedBytes = (long)e.DownloadOperation.BytesReceived;
					
					// Update status (InProgress, Completed, etc.)
                    OnDownloadStateChanged?.Invoke(e.DownloadOperation.State.ToString(), e.DownloadOperation.Uri, totalBytes, receivedBytes);
					
					// DOWNLOAD_CANCELLED
					if (e.DownloadOperation.State == Microsoft.Web.WebView2.Core.CoreWebView2DownloadState.Interrupted)
					{
						// Send DOWNLOAD_CANCELLED|URL|Reason (e.g. UserCanceled, NetworkFailed, etc.)
						var reason = e.DownloadOperation.InterruptReason;
						OnMessageReceived?.Invoke($"DOWNLOAD_CANCELLED|{currentUri}|{reason}");
					}

					// Clear list when finished (for any reason)
					if (e.DownloadOperation.State != Microsoft.Web.WebView2.Core.CoreWebView2DownloadState.InProgress)
					{
						_activeDownloads.Remove(currentUri);
					}
                };

                // --- Progress Tracking ---
                int lastPercent = -1;
                e.DownloadOperation.BytesReceivedChanged += (sender, args) =>
                {
                    long total = (long)(e.DownloadOperation.TotalBytesToReceive ?? 0);
                    long received = (long)e.DownloadOperation.BytesReceived;

                    if (total > 0)
                    {
                        int currentPercent = (int)((received * 100) / total);

                        // We only send an update to AutoIt if the percentage has changed
                        // so as not to "clog" the script with thousands of messages.
                        if (currentPercent > lastPercent)
                        {
                            lastPercent = currentPercent;
                            OnDownloadStateChanged?.Invoke("InProgress", e.DownloadOperation.Uri, total, received);
                        }
                    }
                };
            };
        }
        #endregion

        #region 9. PUBLIC API: NAVIGATION & CONTROL
        /// <summary>Navigate to a specified URL.</summary>
        public void Navigate(string url) => InvokeOnUiThread(() => _webView.CoreWebView2?.Navigate(url));

        /// <summary>Navigate to a string containing HTML content.</summary>
        public void NavigateToString(string htmlContent)
        {
            _webView.Invoke(new Action(async () => {
                int attempts = 0;
                while (_webView.CoreWebView2 == null && attempts < 20) { await Task.Delay(50); attempts++; }
                _webView.CoreWebView2?.NavigateToString(htmlContent);
            }));
        }

        /// <summary>Reload the current page.</summary>
        public void Reload() => InvokeOnUiThread(() => _webView.CoreWebView2?.Reload());

        /// <summary>Stops any ongoing navigation or loading.</summary>
        public void Stop() => InvokeOnUiThread(() => _webView.CoreWebView2?.Stop());

        /// <summary>Navigate back in history.</summary>
        public void GoBack() => InvokeOnUiThread(() => { if (_webView?.CoreWebView2 != null && _webView.CoreWebView2.CanGoBack) _webView.CoreWebView2.GoBack(); });

        /// <summary>Navigate forward in history.</summary>
        public void GoForward() => InvokeOnUiThread(() => { if (_webView?.CoreWebView2 != null && _webView.CoreWebView2.CanGoForward) _webView.CoreWebView2.GoForward(); });

        /// <summary>Check if it's possible to navigate back.</summary>
        public bool GetCanGoBack() => _webView?.CoreWebView2?.CanGoBack ?? false;

        /// <summary>Check if it's possible to navigate forward.</summary>
        public bool GetCanGoForward() => _webView?.CoreWebView2?.CanGoForward ?? false;

        /// <summary>Adds a script that executes on every page load (Permanent Injection).</summary>
        public async void AddInitializationScript(string script)
        {
            if (_webView?.CoreWebView2 == null) return;
            try {
                await _webView.CoreWebView2.AddScriptToExecuteOnDocumentCreatedAsync(script);
                await _webView.CoreWebView2.ExecuteScriptAsync(script);
            } catch (Exception ex) { Debug.WriteLine("Error adding initialization script: " + ex.Message); }
        }

        /// <summary>Controls the context menu behavior.</summary>
        public void SetContextMenuEnabled(bool enabled)
        {
            _contextMenuEnabled = enabled;
            InvokeOnUiThread(() => { if (_webView?.CoreWebView2 != null) _webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = true; });
        }
        #endregion

        #region 10. PUBLIC API: DATA EXTRACTION
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
        /// Parse JSON into the internal parser.
        /// </summary>
        public bool ParseJsonToInternal(string json) => _internalParser.Parse(json?.Trim());

        /// <summary>
        /// Get a value from the internal JSON parser.
        /// </summary>
        public string GetInternalJsonValue(string path) => _internalParser.GetTokenValue(path);

        /// <summary>
        /// Binds the internal JSON data to a browser variable.
        /// </summary>
        public bool BindJsonToBrowser(string variableName)
        {
            try
            {
                if (_webView?.CoreWebView2 == null) return false;

                // 2. Get minified JSON from internal parser
                string jsonData = _internalParser.GetMinifiedJson();
                if (string.IsNullOrEmpty(jsonData))
                {
                    jsonData = "{}"; // Fallback to empty object
                }

                // 3. Escape for JS safety
                string safeJson = jsonData.Replace("\\", "\\\\").Replace("'", "\\'");

                // 3. Build script with JS try-catch and console logging
                string script = $@"
                    try {{
                        window.{variableName} = JSON.parse('{safeJson}');
                        console.log('NetWebView2Lib: Data bound to window.{variableName}');
                        true;
                    }} catch (e) {{
                        console.error('NetWebView2Lib Bind Error:', e);
                        false;
                    }}";

                // 4. Execute script
                _webView.CoreWebView2.ExecuteScriptAsync(script);
                return true;
            }
            catch (Exception ex)
            {
                Debug.WriteLine("BindJsonToBrowser Error: " + ex.Message);
                return false;
            }
        }

        /// <summary>
        /// Syncs JSON data to internal parser and optionally binds it to a browser variable.
        /// </summary>
        public void SyncInternalData(string json, string bindToVariableName = "")
        {
            if (ParseJsonToInternal(json))
            {
                if (!string.IsNullOrEmpty(bindToVariableName))
                {
                    BindJsonToBrowser(bindToVariableName);
                }
            }
        }

        /// <summary>
        /// Retrieves the entire text content (innerText) of the document and sends it back to AutoIt.
        /// </summary>
        public async void GetInnerText()
        {
            if (_webView?.CoreWebView2 == null) return;
            try {
                string html = await _webView.CoreWebView2.ExecuteScriptAsync("document.documentElement.innerText");
                OnMessageReceived?.Invoke("INNER_TEXT|" + CleanJsString(html));
            } catch (Exception ex) { OnMessageReceived?.Invoke("ERROR|INNER_TEXT_FAILED: " + ex.Message); }
        }
        #endregion

        #region 11. PUBLIC API: UI & INTERACTION
        /// <summary>
        /// Execute arbitrary JavaScript code.
        /// </summary>
        public void ExecuteScript(string script)
        {
            if (_webView?.CoreWebView2 != null)
                _webView.Invoke(new Action(() => _webView.CoreWebView2.ExecuteScriptAsync(script)));
        }

        /// <summary>
        /// Execute JavaScript on the current page immediately.
        /// </summary>
        /// <param name="script">The JavaScript code to be executed.</param>
        public async void ExecuteScriptOnPage(string script)
        {
            if (_webView?.CoreWebView2 == null) return;
            await _webView.CoreWebView2.ExecuteScriptAsync(script);
        }

        /// <summary>
        /// Executes JavaScript and returns the result synchronously using a Message Pump.
        /// </summary>
        public string ExecuteScriptWithResult(string script)
        {
            if (_webView?.CoreWebView2 == null) return "ERROR: WebView not initialized";
            try
            {
                var task = _webView.CoreWebView2.ExecuteScriptAsync(script);
                var start = DateTime.Now;
                while (!task.IsCompleted)
                {
                    System.Windows.Forms.Application.DoEvents();
                    if ((DateTime.Now - start).TotalSeconds > 5) return "ERROR: Script Timeout";
                    System.Threading.Thread.Sleep(1);
                }
                string result = task.Result;
                if (result == "null" || result == null) return string.Empty;
                if (result.StartsWith("\"") && result.EndsWith("\""))
                {
                    result = result.Substring(1, result.Length - 2);
                    result = System.Text.RegularExpressions.Regex.Unescape(result);
                }
                return result;
            }
            catch (Exception ex) { return "ERROR: " + ex.Message; }
        }

        /// <summary>
        /// Inject CSS code into the current page.
        /// </summary>
        public async void InjectCss(string cssCode)
        {
            string js = $"(function() {{ let style = document.getElementById('{StyleId}'); if (!style) {{ style = document.createElement('style'); style.id = '{StyleId}'; document.head.appendChild(style); }} style.innerHTML = `{cssCode.Replace("`", "\\` text-decoration")}`; }})();";
            ExecuteScript(js);
            if (!string.IsNullOrEmpty(_lastCssRegistrationId)) _webView.CoreWebView2.RemoveScriptToExecuteOnDocumentCreated(_lastCssRegistrationId);
            _lastCssRegistrationId = await _webView.CoreWebView2.AddScriptToExecuteOnDocumentCreatedAsync(js);
        }

        /// <summary>
        /// Remove previously injected CSS.
        /// </summary>
        public void ClearInjectedCss()
        {
            if (!string.IsNullOrEmpty(_lastCssRegistrationId))
            {
                _webView.CoreWebView2.RemoveScriptToExecuteOnDocumentCreated(_lastCssRegistrationId);
                _lastCssRegistrationId = "";
            }
            ExecuteScript($"(function() {{ let style = document.getElementById('{StyleId}'); if (style) style.remove(); }})();");
        }

        /// <summary>
        /// Toggle audit highlights on/off.
        /// </summary>
        public void ToggleAuditHighlights(bool enable)
        {
            if (enable) InjectCss("img, h1, h2, h3, table, a { outline: 3px solid #FF6A00 !important; outline-offset: -3px !important; }");
            else ClearInjectedCss();
        }

        /// <summary>
        /// Capture a screenshot (preview) of the current view.
        /// </summary>
        public async void CapturePreview(string filePath, string format)
        {
            if (_webView?.CoreWebView2 == null) return;
            CoreWebView2CapturePreviewImageFormat imageFormat = format.ToLower().Contains("jpg") ? CoreWebView2CapturePreviewImageFormat.Jpeg : CoreWebView2CapturePreviewImageFormat.Png;
            try
            {
                using (var fileStream = File.Create(filePath)) await _webView.CoreWebView2.CapturePreviewAsync(imageFormat, fileStream);
                OnMessageReceived?.Invoke("CAPTURE_SUCCESS|" + filePath);
            }
            catch (Exception ex) { OnMessageReceived?.Invoke("CAPTURE_ERROR|" + ex.Message); }
        }

        /// <summary>
        /// Shows the print UI dialog.
        /// </summary>
        public void ShowPrintUI() => _webView?.CoreWebView2.ShowPrintUI();

        /// <summary>
        /// Initiate the native Print dialog via JS.
        /// </summary>
        public void Print()
        {
             InvokeOnUiThread(async () => {
                if (_webView?.CoreWebView2 != null)
                {
                     try { await _webView.CoreWebView2.ExecuteScriptAsync("window.print();"); } 
                     catch(Exception ex) { OnMessageReceived?.Invoke("PRINT_ERROR|" + ex.Message); }
                }
             });
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
                    s.AreDefaultContextMenusEnabled = false;
                    s.AreDevToolsEnabled = false;
                    s.IsZoomControlEnabled = false;
                    s.IsBuiltInErrorPageEnabled = false;
                }
            });
        }

        /// <summary>
        /// Unlock the WebView by re-enabling restricted features.
        /// </summary>
        public void UnLockWebView()
        {
            InvokeOnUiThread(() => {
                if (_webView?.CoreWebView2 != null)
                {
                    var s = _webView.CoreWebView2.Settings;
                    s.AreDefaultContextMenusEnabled = true;
                    s.AreDevToolsEnabled = true;
                    s.IsZoomControlEnabled = true;
                    s.IsBuiltInErrorPageEnabled = true;
                }
            });
        }

        /// <summary>
        /// Saves the current page as a PDF file.
        /// </summary>
        public async void ExportToPdf(string filePath)
        {
            if (_webView?.CoreWebView2 == null) return;
            try
            {
                await _webView.CoreWebView2.PrintToPdfAsync(filePath);
                OnMessageReceived?.Invoke("PDF_EXPORT_SUCCESS|" + filePath);
            }
            catch (Exception ex) { OnMessageReceived?.Invoke("PDF_EXPORT_ERROR|" + ex.Message); }
        }

        /// <summary>
        /// Capture page data as MHTML or other CDP snapshot formats.
        /// </summary>
        public string CaptureSnapshot(string cdpParameters = "{\"format\": \"mhtml\"}")
        {
            if (_webView?.CoreWebView2 == null) return "ERROR: WebView not initialized";

            return RunOnUiThread(() =>
            {
                try
                {
                    // Use a more robust wait that pumps messages
                    var task = _webView.CoreWebView2.CallDevToolsProtocolMethodAsync("Page.captureSnapshot", cdpParameters);
                    string json = WaitAndGetResult(task);

                    if (string.IsNullOrEmpty(json) || json == "null")
                    {
                        return "ERROR: CDP Page.captureSnapshot returned empty result.";
                    }

                    // CDP returns a JSON object like {"data": "..."}
                    var dict = Newtonsoft.Json.JsonConvert.DeserializeObject<Dictionary<string, string>>(json);
                    if (dict != null && dict.ContainsKey("data"))
                    {
                        return dict["data"];
                    }
                    return "ERROR: Page capture failed - 'data' field missing in CDP response.";
                }
                catch (Exception ex)
                {
                    return "ERROR: " + ex.Message;
                }
            });
        }

        /// <summary>
        /// Export page data as HTML or MHTML.
        /// </summary>
        public string ExportPageData(int format, string filePath)
        {
            if (_webView?.CoreWebView2 == null) return "ERROR: WebView not initialized";

            return RunOnUiThread(() =>
            {
                try
                {
                    string result = string.Empty;
                    if (format == 0) // HTML Only
                    {
                        var task = _webView.CoreWebView2.ExecuteScriptAsync("document.documentElement.outerHTML");
                        result = WaitAndGetResult(task);
                        result = CleanJsString(result);
                    }
                    else if (format == 1) // MHTML Snapshot
                    {
                        result = CaptureSnapshot();
                    }

                    // Check if the result itself is an error from CaptureSnapshot
                    if (string.IsNullOrEmpty(result) || result.StartsWith("ERROR:"))
                    {
                        return string.IsNullOrEmpty(result) ? "ERROR: Export failed - empty result." : result;
                    }

                    if (!string.IsNullOrEmpty(filePath))
                    {
                        try
                        {
                            File.WriteAllText(filePath, result);
                            return "SUCCESS: File saved to " + filePath;
                        }
                        catch (Exception ex)
                        {
                            return "ERROR: File write failed: " + ex.Message;
                        }
                    }
                    return result;
                }
                catch (Exception ex) { return "ERROR: " + ex.Message; }
            });
        }

        /// <summary>
        /// Capture the current page as a PDF and return it as a Base64 string.
        /// </summary>
        public string PrintToPdfStream()
        {
            if (_webView?.CoreWebView2 == null) return "ERROR: WebView not initialized";

            return RunOnUiThread(() =>
            {
                try
                {
                    var task = _webView.CoreWebView2.PrintToPdfStreamAsync(null);
                    Stream stream = WaitAndGetResult(task);
                    if (stream == null) return "ERROR: PDF stream is null";

                    using (MemoryStream ms = new MemoryStream())
                    {
                        stream.CopyTo(ms);
                        return Convert.ToBase64String(ms.ToArray());
                    }
                }
                catch (Exception ex) { return "ERROR: " + ex.Message; }
            });
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
            catch (Exception ex) { OnMessageReceived?.Invoke($"CDP_ERROR|{methodName}|{ex.Message}"); }
        }

        /// <summary>
        /// Set the zoom factor.
        /// </summary>
        public void SetZoom(double factor) => InvokeOnUiThread(() => _webView.ZoomFactor = factor);

        /// <summary>
        /// Reset zoom to default (100%).
        /// </summary>
        public void ResetZoom() => SetZoom(1.0);

        /// <summary>
        /// Sets the mute status for audio.
        /// </summary>
        public void SetMuted(bool muted) => InvokeOnUiThread(() => { if (_webView?.CoreWebView2 != null) _webView.CoreWebView2.IsMuted = muted; });

        /// <summary>
        /// Gets the current mute status.
        /// </summary>
        public bool IsMuted() => _webView?.CoreWebView2?.IsMuted ?? false;

        /// <summary>
        /// Resize the WebView control.
        /// </summary>
        public void Resize(int w, int h) => InvokeOnUiThread(() => _webView.Size = new Size(w, h));

        /// <summary>
        /// Clean up resources.
        /// </summary>
        public void Cleanup() => _webView?.Dispose();

        #endregion

        #region 12. COOKIES & CACHE
        /// <summary>
        /// Clear browser data (cookies, cache, history, etc.).
        /// </summary>
        public async void ClearBrowserData()
        {
            await _webView.EnsureCoreWebView2Async();
            await _webView.CoreWebView2.Profile.ClearBrowsingDataAsync();
            OnMessageReceived?.Invoke("DATA_CLEARED");
        }

        /// <summary>
        /// Clears the browser cache (DiskCache and LocalStorage).
        /// </summary>
        public async void ClearCache()
        {
            if (_webView?.CoreWebView2 == null) return;
            await _webView.CoreWebView2.Profile.ClearBrowsingDataAsync(CoreWebView2BrowsingDataKinds.DiskCache | CoreWebView2BrowsingDataKinds.LocalStorage);
        }

        /// <summary>
        /// Get Cookies asynchronously.
        /// </summary>
        public async void GetCookies(string channelId)
        {
            if (_webView?.CoreWebView2?.CookieManager == null) return;
            try
            {
                var cookieList = await _webView.CoreWebView2.CookieManager.GetCookiesAsync(null);
                var sb = new System.Text.StringBuilder("[");
                for(int i=0; i<cookieList.Count; i++)
                {
                    var c = cookieList[i];
                    sb.Append($"{{\"name\":\"{c.Name}\",\"value\":\"{c.Value}\",\"domain\":\"{c.Domain}\",\"path\":\"{c.Path}\"}}");
                    if (i < cookieList.Count - 1) sb.Append(",");
                }
                sb.Append("]");
                byte[] bytes = System.Text.Encoding.UTF8.GetBytes(sb.ToString());
                OnMessageReceived?.Invoke($"COOKIES_B64|{channelId}|{Convert.ToBase64String(bytes)}");
            }
            catch (Exception ex) { OnMessageReceived?.Invoke($"COOKIES_ERROR|{channelId}|{ex.Message}"); }
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
            catch (Exception ex) { OnMessageReceived?.Invoke($"COOKIE_ADD_ERROR|{ex.Message}"); }
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
        public void DeleteAllCookies() => _webView?.CoreWebView2?.CookieManager?.DeleteAllCookies();
        #endregion

        #region 13. AD BLOCKING
        /// <summary>
        /// Set AdBlock active state.
        /// </summary>
        public void SetAdBlock(bool active) => _isAdBlockActive = active;

        /// <summary>
        /// Add a domain to the block list.
        /// </summary>
        public void AddBlockRule(string domain) { if (!string.IsNullOrEmpty(domain)) _blockList.Add(domain.ToLower()); }

        /// <summary>
        /// Clear all ad block rules.
        /// </summary>
        public void ClearBlockRules() => _blockList.Clear();
        #endregion

        #region 14. SMART RESIZE
        /// <summary>
        /// Enables or disables automatic resizing.
        /// </summary>
        public void SetAutoResize(bool enabled)
        {
            if (_parentHandle == IntPtr.Zero || _parentSubclass == null) return;
            _autoResizeEnabled = enabled;
            if (_autoResizeEnabled) { _parentSubclass.AssignHandle(_parentHandle); PerformSmartResize(); }
            else _parentSubclass.ReleaseHandle();
        }

        private void PerformSmartResize()
        {
            if (_webView == null || _parentHandle == IntPtr.Zero) return;
            if (_webView.InvokeRequired) { _webView.Invoke(new Action(PerformSmartResize)); return; }
            if (GetClientRect(_parentHandle, out Rect rect))
            {
                int newWidth = (rect.Right - rect.Left) - _offsetX - _marginRight;
                int newHeight = (rect.Bottom - rect.Top) - _offsetY - _marginBottom;
                _webView.Left = _offsetX; _webView.Top = _offsetY;
                _webView.Width = Math.Max(10, newWidth); _webView.Height = Math.Max(10, newHeight);
                OnMessageReceived?.Invoke("WINDOW_RESIZED|" + _webView.Width + "|" + _webView.Height);
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
        #endregion

        #region 15. MISC PUBLIC API
        public void SetZoomFactor(double factor)
        {
            if (factor < 0.1 || factor > 5.0) return;
            InvokeOnUiThread(() => _webView.ZoomFactor = factor);
        }

        public void OpenDevToolsWindow() => InvokeOnUiThread(() => _webView?.CoreWebView2?.OpenDevToolsWindow());

        public void WebViewSetFocus() => InvokeOnUiThread(() => _webView?.Focus());

        public void SetUserAgent(string userAgent)
        {
            InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.UserAgent = userAgent; });
        }

        public string GetDocumentTitle() => _webView?.CoreWebView2?.DocumentTitle ?? "";

        public string GetSource() => _webView?.Source?.ToString() ?? "";

        public uint GetBrowserProcessId()
        {
            try { return _webView?.CoreWebView2?.BrowserProcessId ?? 0; }
            catch { return 0; }
        }

        public void SetScriptEnabled(bool enabled)
        {
            InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.IsScriptEnabled = enabled; });
        }

        public void SetWebMessageEnabled(bool enabled)
        {
            InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.IsWebMessageEnabled = enabled; });
        }

        public void SetStatusBarEnabled(bool enabled)
        {
            InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.IsStatusBarEnabled = enabled; });
        }
        #endregion

        #region 16. UNIFIED SETTINGS (PROPERTIES)
        public bool AreDevToolsEnabled
        {
            get => RunOnUiThread(() => _webView?.CoreWebView2?.Settings?.AreDevToolsEnabled ?? false);
            set => InvokeOnUiThread(() => { if (_webView?.CoreWebView2?.Settings != null) _webView.CoreWebView2.Settings.AreDevToolsEnabled = value; });
        }
		
        /// <summary>
        /// Check if browser popups are allowed or redirected to the same window.
        /// </summary>
        public bool AreBrowserPopupsAllowed
        {
            get => _areBrowserPopupsAllowed;
            set => InvokeOnUiThread(() => _areBrowserPopupsAllowed = value);
        }

        public bool AreDefaultContextMenusEnabled
        {
            get => _contextMenuEnabled;
            set => SetContextMenuEnabled(value); // Reuse existing logic
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
            set => SetStatusBarEnabled(value); // Reuse existing logic
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
                try {
                    // Fix 0x prefix for AutoIt
                    string hex = value.Replace("0x", "#");
                    _webView.DefaultBackgroundColor = ColorTranslator.FromHtml(hex);
                } catch { _webView.DefaultBackgroundColor = Color.White; }
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

        public int BorderStyle
        {
            get => 0; // WebView2 control does not support BorderStyle property natively.
            set { /* No-op: WebView2 does not support BorderStyle directly */ }
        }

        /// <summary>Enable/Disable Custom Context Menu.</summary>
        public bool CustomMenuEnabled
        {
            get => _customMenuEnabled;
            set => _customMenuEnabled = value;
        }

        /// <summary>
        /// Gets or sets additional browser arguments (switches) to be passed to the Chromium engine.
        /// These must be set BEFORE calling Initialize().
        /// </summary>
        public string AdditionalBrowserArguments
        {
            get => _additionalBrowserArguments;
            set => _additionalBrowserArguments = value;
        }

        /// <summary>
        /// Control PDF toolbar items visibility (bitwise combination of CoreWebView2PdfToolbarItems).
        /// </summary>
        public int HiddenPdfToolbarItems
        {
            get => RunOnUiThread(() => (int)(_webView?.CoreWebView2?.Settings?.HiddenPdfToolbarItems ?? CoreWebView2PdfToolbarItems.None));
            set => InvokeOnUiThread(() => {
                if (_webView?.CoreWebView2?.Settings != null)
                    _webView.CoreWebView2.Settings.HiddenPdfToolbarItems = (CoreWebView2PdfToolbarItems)value;
            });
        }

        /// <summary>Sets a custom download path for file downloads.</summary>
        public void SetDownloadPath(string path)
        {
            _customDownloadPath = path;
            if (!System.IO.Directory.Exists(path))
            {
                System.IO.Directory.CreateDirectory(path); // Create the folder if it doesn't exist
            }
        }

        /// <summary>Returns a pipe-separated string of all active download URIs.</summary>
        public string ActiveDownloadsList => string.Join("|", _activeDownloads.Keys);

        /// <summary>Cancels downloads. If uri is null or empty, cancels all active downloads.</summary>
        /// <param name="uri">Optional: The specific URI to cancel.</param>
        public void CancelDownloads(string uri = "")
        {
            if (string.IsNullOrEmpty(uri))
            {
                // Cancel all
                foreach (var download in _activeDownloads.Values)
                {
                    download.Cancel();
                }
                _activeDownloads.Clear();
            }
            else if (_activeDownloads.ContainsKey(uri))
            {
                // Cancel specific
                _activeDownloads[uri].Cancel();
                _activeDownloads.Remove(uri);
            }
        }

        public bool IsDownloadUIEnabled
        {
            get => _isDownloadUIEnabled;
            set => _isDownloadUIEnabled = value;
        }

        /// <summary>Decodes a Base64-encoded string into a byte array.</summary>
        /// <param name="base64Text">The Base64-encoded string to decode.</param>
        /// <returns>A byte array containing the decoded binary data, or an empty array if the input is null, empty, or invalid.</returns>
        public byte[] DecodeB64ToBinary(string base64Text)
        {
            if (string.IsNullOrEmpty(base64Text)) return new byte[0];
            try
            {
                return Convert.FromBase64String(base64Text);
            }
            catch { return new byte[0]; }
        }

        /// <summary>Enable/Disable OnWebResourceResponseReceived event.</summary>
        public bool HttpStatusCodeEventsEnabled
        {
            get => _httpStatusCodeEventsEnabled;
            set => _httpStatusCodeEventsEnabled = value;
        }

        /// <summary>Filter HttpStatusCode events to only include the main document.</summary>
        public bool HttpStatusCodeDocumentOnly
        {
            get => _httpStatusCodeDocumentOnly;
            set => _httpStatusCodeDocumentOnly = value;
        }


        public bool IsDownloadHandled
        {
            get => _isDownloadHandledOverride;
            set => _isDownloadHandledOverride = value;
        }

        public bool IsZoomControlEnabled
        {
            get => _webView?.CoreWebView2?.Settings?.IsZoomControlEnabled ?? _isZoomControlEnabled;
            set
            {
                _isZoomControlEnabled = value;
                InvokeOnUiThread(() => {
                    if (_webView?.CoreWebView2?.Settings != null)
                        _webView.CoreWebView2.Settings.IsZoomControlEnabled = value;
                });
            }
        }

        /// <summary>
        /// Captures a screenshot of the current WebView2 content and returns it as a Base64-encoded data URL.
        /// </summary>
        /// <param name="format">The image format for the screenshot, either 'png' or 'jpeg'.</param>
        /// <returns>A Base64-encoded data URL representing the captured image.</returns>
        public string CapturePreviewAsBase64(string format)
        {
            try
            {
                var imgFormat = format.ToLower() == "jpeg" ?
                    CoreWebView2CapturePreviewImageFormat.Jpeg :
                    CoreWebView2CapturePreviewImageFormat.Png;

                using (var ms = new System.IO.MemoryStream())
                {
                    var task = _webView.CoreWebView2.CapturePreviewAsync(imgFormat, ms);
                    WaitTask(task);
                    return $"data:image/{format.ToLower()};base64,{Convert.ToBase64String(ms.ToArray())}";
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        #endregion

        /// <summary>
        /// Provides a standard HTTP reason phrase if the server response is empty (common in HTTP/2+).
        /// </summary>
        private string GetReasonPhrase(int statusCode, string originalReason)
        {
            if (!string.IsNullOrEmpty(originalReason)) return originalReason;

            switch (statusCode)
            {
                case 200: return "OK";
                case 201: return "Created";
                case 204: return "No Content";
                case 301: return "Moved Permanently";
                case 302: return "Found";
                case 304: return "Not Modified";
                case 400: return "Bad Request";
                case 401: return "Unauthorized";
                case 403: return "Forbidden";
                case 404: return "Not Found";
                case 429: return "Too Many Requests";
                case 500: return "Internal Server Error";
                case 502: return "Bad Gateway";
                case 503: return "Service Unavailable";
                case 504: return "Gateway Timeout";
                default: 
                    try { return ((System.Net.HttpStatusCode)statusCode).ToString(); }
                    catch { return "Unknown"; }
            }
        }

        #region 17. HELPER METHODS
        private T RunOnUiThread<T>(Func<T> func)
        {
            if (_webView == null || _webView.IsDisposed) return default;
            if (_webView.InvokeRequired) return (T)_webView.Invoke(func);
            else return func();
        }

        /// Invoke actions on the UI thread
        private void InvokeOnUiThread(Action action)
        {
            if (_webView == null || _webView.IsDisposed) return;
            if (_webView.InvokeRequired) _webView.Invoke(action);
            else action();
        }

        /// <summary>
        /// Wait for an async task to complete and return the result (Synchronous wrapper for COM).
        /// </summary>
        private T WaitAndGetResult<T>(Task<T> task, int timeoutSeconds = 20)
        {
            var start = DateTime.Now;
            while (!task.IsCompleted)
            {
                System.Windows.Forms.Application.DoEvents();
                if ((DateTime.Now - start).TotalSeconds > timeoutSeconds) throw new TimeoutException("Operation timed out.");
                System.Threading.Thread.Sleep(1);
            }
            return task.Result;
        }

        /// <summary>
        /// Waits for the specified Task to complete, processing Windows Forms events during the wait and enforcing a
        /// timeout.
        /// </summary>
        /// <param name="task">The Task to wait for completion.</param>
        /// <param name="timeoutSeconds">The maximum number of seconds to wait before timing out. Defaults to 20 seconds.</param>
        /// <exception cref="TimeoutException">Thrown if the Task does not complete within the specified timeout.</exception>
        private void WaitTask(Task task, int timeoutSeconds = 20)
        {
            var start = DateTime.Now;
            while (!task.IsCompleted)
            {
                System.Windows.Forms.Application.DoEvents();
                if ((DateTime.Now - start).TotalSeconds > timeoutSeconds)
                    throw new TimeoutException("Operation timed out.");
                System.Threading.Thread.Sleep(1);
            }
            if (task.IsFaulted && task.Exception != null)
                throw task.Exception.InnerException;
        }


        /// <summary>
        /// Encodes a string for safe use in a URL.
        /// </summary>
        public string EncodeURI(string value)
        {
            if (string.IsNullOrEmpty(value)) return "";
            return System.Net.WebUtility.UrlEncode(value);
        }

        /// <summary>
        /// Decodes a URL-encoded string.
        /// </summary>
        public string DecodeURI(string value)
        {
            if (string.IsNullOrEmpty(value)) return "";
            return System.Net.WebUtility.UrlDecode(value);
        }

        /// <summary>
        /// Encodes a string to Base64 (UTF-8).
        /// </summary>
        public string EncodeB64(string value)
        {
            if (string.IsNullOrEmpty(value)) return "";
            var bytes = System.Text.Encoding.UTF8.GetBytes(value);
            return Convert.ToBase64String(bytes);
        }

        /// <summary>
        /// Decodes a Base64 string to plain text (UTF-8).
        /// </summary>
        public string DecodeB64(string value)
        {
            if (string.IsNullOrEmpty(value)) return "";
            try {
                var bytes = Convert.FromBase64String(value);
                return System.Text.Encoding.UTF8.GetString(bytes);
            } catch { return ""; } // Fail safe
        }

        /// <summary>
        /// Clean up JavaScript string results.
        /// </summary>
        private string CleanJsString(string input)
        {
            if (string.IsNullOrEmpty(input)) return "";
            string decoded = System.Text.RegularExpressions.Regex.Unescape(input);
            if (decoded.StartsWith("\"") && decoded.EndsWith("\"") && decoded.Length >= 2)
                decoded = decoded.Substring(1, decoded.Length - 2);
            return decoded;
        }
        #endregion
    }
}