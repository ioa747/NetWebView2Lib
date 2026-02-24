using System.Runtime.InteropServices;

namespace NetWebView2Lib
{
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
        /// <summary>Enable major browser features.</summary>
        [DispId(227)] void EnableBrowserFeatures();
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
        /// <summary>Set the lockdown state of the WebView.</summary>
        [DispId(220)] void SetLockState(bool lockState);

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
        /// <summary>Get current frame count.</summary>
        [DispId(146)] int GetFrameCount();
        /// <summary>Get HTML source of a specific frame.</summary>
        [DispId(147)] void GetFrameHtmlSource(int index);
        /// <summary>Get URL of a specific frame.</summary>
        [DispId(148)] string GetFrameUrl(int index);
        /// <summary>Get Name of a specific frame.</summary>
        [DispId(149)] string GetFrameName(int index);
        /// <summary>Get all frame URLs pipe-separated.</summary>
        [DispId(152)] string GetFrameUrls();
        /// <summary>Get all frame names pipe-separated.</summary>
        [DispId(153)] string GetFrameNames();
        /// <summary>Get a Frame Object (IWebView2Frame).</summary>
        [DispId(154)] object GetFrame(int index);
        /// <summary>Get a Frame Object by its FrameId.</summary>
        [DispId(230)] object GetFrameById(uint frameId);

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
        /// <summary>Are DevTools enabled.</summary>
        [DispId(170)] bool AreDevToolsEnabled { get; set; }
        /// <summary>Are default context menus enabled.</summary>
        [DispId(171)] bool AreDefaultContextMenusEnabled { get; set; }
        /// <summary>Verbose Log state.</summary>
        [DispId(228)] bool Verbose { get; set; }
        /// <summary>Are default script dialogs enabled.</summary>
        [DispId(172)] bool AreDefaultScriptDialogsEnabled { get; set; }
        /// <summary>Are browser accelerator keys enabled.</summary>
        [DispId(173)] bool AreBrowserAcceleratorKeysEnabled { get; set; }
        /// <summary>Is status bar enabled.</summary>
        [DispId(174)] bool IsStatusBarEnabled { get; set; }
        /// <summary>Zoom Factor.</summary>
        [DispId(175)] double ZoomFactor { get; set; }
        /// <summary>Background Color (Hex string).</summary>
        [DispId(176)] string BackColor { get; set; }
        /// <summary>Are host objects allowed.</summary>
        [DispId(177)] bool AreHostObjectsAllowed { get; set; }
        /// <summary>Anchor (Resizing).</summary>
        [DispId(178)] int Anchor { get; set; }
        /// <summary>Border Style.</summary>
        [DispId(179)] int BorderStyle { get; set; }

        // --- NEW UNIFIED METHODS ---
        /// <summary>Set Zoom Factor (Wrapper).</summary>
        [DispId(180)] void SetZoomFactor(double factor);
        /// <summary>Open DevTools Window.</summary>
        [DispId(181)] void OpenDevToolsWindow();
        /// <summary>Focus the WebView.</summary>
        [DispId(182)] void WebViewSetFocus();
        /// <summary>Are browser popups allowed or redirected to the same window.</summary>
        [DispId(183)] bool AreBrowserPopupsAllowed { get; set; }
        /// <summary>Add a script that executes on every page load (Permanent Injection). Returns the ScriptId.</summary>
        [DispId(184)] string AddInitializationScript(string script);
        /// <summary>Removes a script previously added via AddInitializationScript.</summary>
        [DispId(217)] void RemoveInitializationScript(string scriptId);
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
        /// <summary>Enable/Disable the built-in browser error page.</summary>
        [DispId(213)] bool IsBuiltInErrorPageEnabled { get; set; }
        /// <summary>Encodes raw binary data (byte array) to a Base64 string.</summary>
        [DispId(219)] string EncodeBinaryToB64(object binaryData);
        /// <summary>Maps a virtual host name to a local folder path.</summary>
        [DispId(218)] void SetVirtualHostNameToFolderMapping(string hostName, string folderPath, int accessKind);

        /// <summary>Gets the internal window handle of the WebView2 control.</summary>
        [DispId(222)] string BrowserWindowHandle { get; }

        /// <summary>Gets the parent window handle provided during initialization.</summary>
        [DispId(229)] string ParentWindowHandle { get; }

        /// <summary>A comma-separated list of Virtual Key codes to block (e.g., "116,123").</summary>
        [DispId(223)] string BlockedVirtualKeys { get; set; }
        /// <summary>Gets the version of the DLL.</summary>
        [DispId(224)] string Version { get; }

        /// <summary>Gets or sets the folder path where WebView2 failure reports (crash dumps) are stored.</summary>
        [DispId(226)] string FailureReportFolderPath { get; set; }
    }
}
