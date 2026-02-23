using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;

namespace NetWebView2Lib
{
    // --- 3. THE MANAGER CLASS ---
    /// <summary>
    /// The Main Manager Class for WebView2 Interaction.
    /// </summary>
    [Guid("E3F4A5B6-C7D8-4E9F-0A1B-2C3D4E5F6A7B")]
    [ComSourceInterfaces(typeof(IWebViewEvents))]
    [ClassInterface(ClassInterfaceType.None)] 
    [ComVisible(true)]
    [ProgId("NetWebView2Lib.WebView2Manager")]
    public partial class WebView2Manager : IWebViewActions
    {
        #region 1. PRIVATE FIELDS
        private readonly WebView2 _webView;
        private readonly WebView2Bridge _bridge;
        private readonly WebView2Parser _internalParser = new WebView2Parser();
        private readonly List<CoreWebView2Frame> _frames = new List<CoreWebView2Frame>();
        private readonly Dictionary<CoreWebView2Frame, string> _frameUrls = new Dictionary<CoreWebView2Frame, string>();
        private bool _verbose = false;

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
        private string _failureReportFolderPath = "";

        private int _offsetX = 0;
        private int _offsetY = 0;
        private int _marginRight = 0;
        private int _marginBottom = 0;
        private IntPtr _parentHandle = IntPtr.Zero;
        private ParentWindowSubclass _parentSubclass;

        private string _lastCssRegistrationId = "";
        private System.Threading.SynchronizationContext _uiContext;

        // Keeps active downloads keyed by their URI
        private readonly Dictionary<string, CoreWebView2DownloadOperation> _activeDownloads = new Dictionary<string, CoreWebView2DownloadOperation>();
        #endregion

        #region 4. CONSTRUCTOR
        /// <summary>
        /// Initializes a new instance of the WebViewManager class.
        /// </summary>
        public WebView2Manager()
        {
            _webView = new WebView2();
            _bridge = new WebView2Bridge();
        }

        /// <summary>
        /// Performs cleanup of the WebView2 control and associated resources.
        /// </summary>
        public void Cleanup()
        {
            Log("Cleanup requested.");
            _webView?.Dispose();
            Log("Cleanup completed.");
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

        /// <summary>Allows internal classes to push debug/info messages to AutoIt.</summary>
        internal void InternalPushMessage(string message)
        {
            OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), message);
        }

        /// <summary>
        /// Gets the internal window handle of the WebView2 control.
        /// </summary>
        public string BrowserWindowHandle => FormatHandle(_webView?.Handle ?? IntPtr.Zero);

        /// <summary>
        /// Gets the parent window handle provided during initialization.
        /// </summary>
        public string ParentWindowHandle => FormatHandle(_parentHandle);

        /// <summary>Internal access to parent handle for event wrappers.</summary>
        internal IntPtr ParentHandleIntPtr => _parentHandle;

        private string _blockedVirtualKeys = "";
        /// <summary>
        /// A comma-separated list of Virtual Key codes to be blocked synchronously (e.g., "116,123").
        /// This ensures blocking (Handled = true) works without COM timing issues.
        /// </summary>
        public string BlockedVirtualKeys
        {
            get => _blockedVirtualKeys;
            set => _blockedVirtualKeys = value ?? "";
        }

        /// <summary>Gets the version of the DLL.</summary>
        public string Version => AssemblyUtils.GetVersion();

        /// <summary>
        /// Gets or sets the folder path where WebView2 failure reports (crash dumps) are stored.
        /// If not set before Initialize, defaults to 'Crashes' subfolder in userDataFolder.
        /// </summary>
        public string FailureReportFolderPath
        {
            get => _failureReportFolderPath;
            set => _failureReportFolderPath = value ?? "";
        }
        #endregion

        #region 6. CORE INITIALIZATION
        /// <summary>
        /// Initializes the WebView2 control within the specified parent window handle.
        /// Supports browser extensions and custom user data folders.
        /// </summary>
        public async void Initialize(object parentHandle, string userDataFolder, int x = 0, int y = 0, int width = 0, int height = 0)
        {
            Log($"Initialize request: parent={parentHandle}, x={x}, y={y}, w={width}, h={height}");
            try
            {
                // Capture the UI thread context for Law #1 compliance
                _uiContext = System.Threading.SynchronizationContext.Current;
                if (_uiContext != null) _bridge.SetSyncContext(_uiContext);

                // Convert the incoming handle from AutoIt (passed as object/pointer)
                long rawHandleValue = Convert.ToInt64(parentHandle);
                _parentHandle = new IntPtr(rawHandleValue);

                // v2.0.0: "Seal" the bridge context immediately after handle conversion
                _bridge.SetParentContext(this, _parentHandle);

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
                Log($"UserDataFolder: {userDataFolder}");
                
                // Create the directory if it doesn't exist
                if (!Directory.Exists(userDataFolder)) Directory.CreateDirectory(userDataFolder);

                // UI Setup on the main UI thread
                // Finalize setup
                _webView.Location = new Point(x, y);
                _webView.Size = new Size(calcWidth, calcHeight);
                Log($"Final initial size: {_webView.Size.Width}x{_webView.Size.Height}");

                // Attach to parent
                InvokeOnUiThread(() => {
                    // Attach the WebView to the AutoIt window/container
                    SetParent(_webView.Handle, _parentHandle);
                    _webView.Visible = false;
                });

                // --- NEW: EXTENSION & FAILURE HANDLING SETUP ---
                // We must enable extensions and configure crash dumps in the Environment Options BEFORE creation
                var options = new CoreWebView2EnvironmentOptions { AreBrowserExtensionsEnabled = true };

                // Handle FailureReportFolderPath logic (Law #5 - Practicality)
                if (string.IsNullOrEmpty(_failureReportFolderPath))
                {
                    _failureReportFolderPath = Path.Combine(userDataFolder, "FailureReportFolder");
                }

                if (!Directory.Exists(_failureReportFolderPath))
                {
                    Directory.CreateDirectory(_failureReportFolderPath);
                }
                
                // Fallback: Use environment variable because FailureReportFolderPath is missing from Options in this SDK version
                Environment.SetEnvironmentVariable("WEBVIEW2_FAILURE_REPORT_FOLDER_PATH", _failureReportFolderPath);
                if (_failureReportFolderPath != "") Log($"FailureReportFolderPath: {_failureReportFolderPath}");

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

                // Signal ready
                Log("WebView2 Initialized successfully.");
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "INIT_READY");
            }
            catch (Exception ex)
            {
                Log("Initialization error: " + ex.Message);
                // Send error details back to AutoIt if initialization fails
                OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), "ERROR|INIT_FAILED|" + ex.Message);
            }
        }
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
        #endregion
    }

    /// <summary>
    /// Compatibility Layer for WebViewManager (Legacy name).
    /// Inherits all functionality from WebView2Manager.
    /// </summary>
    [Guid("A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D")] // OLD GUID
    [ComSourceInterfaces(typeof(IWebViewEvents))]
    [ClassInterface(ClassInterfaceType.None)]
    [ComVisible(true)]
    [ProgId("NetWebView2.Manager")] // OLD ProgID
    public partial class WebViewManager : WebView2Manager, IWebViewActions
    {
        // Inherits everything
    }
}
