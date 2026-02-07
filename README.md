## 🪪 AutoIt WebView2 Component (COM Interop)

A powerful bridge that allows **AutoIt** to use the modern **Microsoft Edge WebView2** (Chromium) engine via a C# COM wrapper. This project enables you to render modern HTML5, CSS3, and JavaScript directly inside your AutoIt applications with a 100% event-driven architecture.

🔗 link to AutoIt forum
https://www.autoitscript.com/forum/topic/213375-webview2autoit-autoit-webview2-component-com-interop

---
### 🚀 Key Features

* **Chromium Engine**: Leverage the speed and security of modern Microsoft Edge.
* **Bi-directional Communication**: Send messages from JS to AutoIt (`postMessage`) and execute JS from AutoIt (`ExecuteScript`).
* **Event-Driven**: No more `While/Sleep` loops to check for updates. Uses COM Sinks for instant notifications.
* **Advanced JSON Handling**: Includes a built-in `JsonParser` for deep-path data access (e.g., `user.items\[0].name`).
* **Content Control**: Built-in Ad-blocker, CSS injection, and Zoom control.
* **Dual Architecture**: Fully supports both **x86** and **x64** environments.
- **Extension Support**: Load and use Chromium extensions (unpacked).
- **Advanced Cookie & CDP Control**: Full cookie manipulation and raw access to Chrome DevTools Protocol.
- **Kiosk & Security Mode**: Enhanced methods to restrict user interaction for production environments.

---

### 🛠 Prerequisites

1. **.NET Framework 4.8** or higher.
2. **Microsoft Edge WebView2 Runtime**.

   * *The registration script will check for this and provide a download link if missing.*

---
### 📦 Deployment & Installation

1. **Extract** the `NetWebView2Lib` folder to a permanent location.
    
2. **Clean & Prepare (Essential Step):**
    
    - If you have a previous version installed, it is **highly recommended** to run the included `\bin\RegCleaner.au3` before registering the new version.
        
    - This ensures that any stale registry entries from previous builds are purged, preventing "Object action failed" errors and GUID conflicts.
        
3. **Registration:**
    
    - Run `\bin\Register_web2.au3` to register the library.
        
    - This script verifies the **WebView2 Runtime** presence and registers `NetWebView2Lib.dll` for COM Interop on both 32-bit and 64-bit architectures.
        
4. **Uninstallation:**
    
    - To remove the library from your system, simply run `\bin\Unregister.au3`.
        
5. **Run Examples:**
    
    - Execute any script in the `\Example\*` folder to see the bridge in action.


---
### ⚖️ License

This project is provided "as-is". You are free to use, modify, and distribute it for both personal and commercial projects.


<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" width="100%">
</p>

## 🚀 What's New in v2.0.0-beta.1 - Multi-Instance & Stability Focus

This major beta release re-engineers the core event architecture to support professional multi-instance applications and solves long-standing COM deadlock issues with pre-emptive key blocking.

### ⚡ Key Features & Enhancements

#### **1. Sender-Aware Event Architecture**

The entire event system has been refactored for multi-instance reliability. Every event fired from the C# core now provides a "Sender" context.

- **Instance Isolation**: AutoIt scripts can now easily distinguish which WebView2 instance triggered an event using the `parentHandle` parameter.
- **Sealed Contexts**: The communication bridge is now sealed to its parent manager, preventing message cross-talk in complex multi-window setups.

#### **2. Pre-emptive Key Blocking (Zero Deadlocks)**

We have abandoned the legacy synchronous polling for accelerator keys in favor of a proactive, list-based approach.

- **`BlockedVirtualKeys`**: Define a list of VK codes (like F5, F12) to be blocked directly by the C# engine.
- **Performance**: Eliminates the 600ms sync-wait loops, resulting in instant response times and 0% risk of COM re-entrancy deadlocks.
- **OnAcceleratorKeyPressed**: Still available for monitoring, but the "Handled" logic is now pre-emptively managed by the property list.

#### **3. Native Win32 Integration**

- **`BrowserWindowHandle`**: A new property that exposes the internal `HWND` of the browser control. This allows for advanced parent-child window relationship management and direct Win32 message interception via DLL calls.

#### **4. Internal Messaging Overlay**

- **Improved Stability**: A new internal messaging system ensures that background state updates never interfere with the primary UI event loop, ensuring a smoother user experience during heavy navigation sequences.


<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" width="100%">
</p>

## 📖 NetWebView2Lib Version 2.0.0-beta.1 (Quick Reference)

### NetWebView2Lib (ProgId: NetWebView2.Manager)

#### === Properties ===

##### AreDevToolsEnabled
Determines whether the user is able to use the context menu or keyboard shortcuts to open the DevTools window.
`object.AreDevToolsEnabled = Value`

##### AreDefaultContextMenusEnabled
Activates or Deactivates the contextual menus of the WebView2 browser.
`object.AreDefaultContextMenusEnabled = Value`

##### AreDefaultScriptDialogsEnabled
Determines whether the standard JavaScript dialogs (alert, confirm, prompt) are enabled.
`object.AreDefaultScriptDialogsEnabled = Value`

##### AreBrowserAcceleratorKeysEnabled
Determines whether browser-specific accelerator keys are enabled (e.g., Ctrl+P, F5, etc.).
`object.AreBrowserAcceleratorKeysEnabled = Value`

##### IsStatusBarEnabled
Determines whether the status bar is visible.
`object.IsStatusBarEnabled = Value`

##### ZoomFactor
Gets or sets the current zoom factor (e.g., 1.0 for 100%).
`object.ZoomFactor = Value`

##### BackColor
Sets the background color of the WebView using a Hex string (e.g., "#FFFFFF" or "0xFFFFFF").
`object.BackColor = Value`

##### AreHostObjectsAllowed
Determines whether host objects (like the 'autoit' bridge) are accessible from JavaScript.
`object.AreHostObjectsAllowed = Value`

##### Anchor
Determines how the control is anchored when the parent window is resized.
`object.Anchor = Value`

##### BorderStyle
Note: Not supported natively by WebView2, provided for compatibility.
`object.BorderStyle = Value`
  
##### AreBrowserPopupsAllowed
Determines whether new window requests are allowed or redirected to the same window.
`object.AreBrowserPopupsAllowed = Value`

##### CustomMenuEnabled
Enables or disables custom context menu handling.
`object.CustomMenuEnabled = Value`

##### AdditionalBrowserArguments
Sets additional command-line arguments to be passed to the Chromium engine during initialization. Must be set BEFORE calling Initialize().
`object.AdditionalBrowserArguments = Value`

##### HiddenPdfToolbarItems
Controls the visibility of buttons in the PDF viewer toolbar using a bitwise combination of CoreWebView2PdfToolbarItems (e.g., 1=Save, 2=Print, 4=Search).
`object.HiddenPdfToolbarItems = Value`

##### IsDownloadUIEnabled
Determines whether the browser's default download UI (shelf/bubble) is shown.
`object.IsDownloadUIEnabled = Value`

##### HttpStatusCodeEventsEnabled
Enables or disables the `OnWebResourceResponseReceived` event entirely.
`object.HttpStatusCodeEventsEnabled = Value`

##### HttpStatusCodeDocumentOnly
Determines whether `OnWebResourceResponseReceived` triggers for all resources (False) or only for the main document (True). Essential for preventing GUI deadlocks in AutoIt.
`object.HttpStatusCodeDocumentOnly = Value`

##### IsDownloadHandled
Determines whether the download is handled by the application. If set to **True** during `OnDownloadStarting`, the internal Edge download is cancelled.
`object.IsDownloadHandled = Value`

##### ActiveDownloadsList
Returns a pipe-separated string of all active download URIs.
`object.ActiveDownloadsList`

##### IsZoomControlEnabled
Determines whether user can zoom the page (Ctrl+MouseWheel, shortcuts).
`object.IsZoomControlEnabled = Value`

##### IsBuiltInErrorPageEnabled
Control visibility of the browser's default error pages (e.g., connection lost).
`object.IsBuiltInErrorPageEnabled = Value`

##### BrowserWindowHandle
Returns the internal window handle (HWND) of the WebView2 control. This is the child window attached to the parent GUI.
`object.BrowserWindowHandle`

##### BlockedVirtualKeys
A comma-separated list of Virtual Key codes to be blocked synchronously (e.g., "116,123").
`object.BlockedVirtualKeys = "116,123"`

#### === Method ===

##### Initialize
Initializes the WebView2 control within a parent window.
`object.Initialize(ParentHandle As HWND, UserDataFolder As String, X As Integer, Y As Integer, Width As Integer, Height As Integer)`

##### Navigate
Navigates the browser to the specified URL.
`object.Navigate(Url As String)`

##### NavigateToString
Loads the provided HTML content directly into the browser.
`object.NavigateToString(HtmlContent As String)`

##### ExecuteScript
**Type**: void (Fire-and-Forget)
**Description**: Sends the command to the UI thread. No return value.
**Use Case**: UI Actions (click, scroll, focus).
`object.ExecuteScript(Script As String)`

##### Resize
Changes the dimensions of the WebView2 control.
`object.Resize(Width As Integer, Height As Integer)`

##### Cleanup
Disposes of the WebView2 control and releases resources.
`object.Cleanup()`

##### GetBridge
Returns the Bridge object for advanced AutoIt-JavaScript interaction.
`object.GetBridge()`

##### ExportToPdf
Saves the current page as a PDF file.
`object.ExportToPdf(FilePath As String)`

##### IsReady
Checks if the WebView2 control is fully initialized and ready for use.
`object.IsReady()`

##### SetContextMenuEnabled
Toggles between Native (true) and Custom (false) context menu modes.
`object.SetContextMenuEnabled(Enabled As Boolean)`

##### LockWebView
Locks down the WebView by disabling context menus, dev tools, zoom control, default error pages, script dialogs, accelerator keys, and popups.
`object.LockWebView()`

##### UnLockWebView
Re-enables the features previously restricted by `LockWebView()` (ContextMenus, DevTools, Zoom, ErrorPages, Dialogs, Keys, Popups).
`object.UnLockWebView()`

##### DisableBrowserFeatures
Disables major browser features for a controlled environment (Unified with `LockWebView`).
`object.DisableBrowserFeatures()`

##### GoBack
Navigates back to the previous page in history.
`object.GoBack()`

##### GoForward
Navigates forward to the next page in history.
`object.GoForward()`

##### ResetZoom
Resets the zoom factor to the default 100%.
`object.ResetZoom()`

##### InjectCss
Injects a block of CSS code into the current page.
`object.InjectCss(CssCode As String)`

##### ClearInjectedCss
Removes any CSS previously injected via InjectCss.
`object.ClearInjectedCss()`

##### ToggleAuditHighlights
Toggles visual highlights on common web elements for auditing purposes.
`object.ToggleAuditHighlights(Enable As Boolean)`

##### SetAdBlock
Enables or disables the built-in ad blocker.
`object.SetAdBlock(Active As Boolean)`

##### AddBlockRule
Adds a domain pattern to the ad block list.
`object.AddBlockRule(Domain As String)`

##### ClearBlockRules
Clears all active ad block rules.
`object.ClearBlockRules()`

##### GetHtmlSource
Asynchronously retrieves the full HTML source (sent via OnMessageReceived with 'HTML_SOURCE|').
`object.GetHtmlSource()`

##### GetSelectedText
Asynchronously retrieves the currently selected text (sent via OnMessageReceived with 'SELECTED_TEXT|').
`object.GetSelectedText()`

##### SetZoom
Sets the zoom factor (wrapper for ZoomFactor property).
`object.SetZoom(Factor As Double)`

##### ParseJsonToInternal
Parses a JSON string into the internal JSON storage.
`object.ParseJsonToInternal(Json As String)`

##### GetInternalJsonValue
Retrieves a value from the internal JSON storage using a path.
`object.GetInternalJsonValue(Path As String)`

##### ClearBrowserData
Clears all browsing data including cookies, cache, and history.
`object.ClearBrowserData()`

##### Reload
Reloads the current page.
`object.Reload()`

##### Stop
Stops any ongoing navigation or loading.
`object.Stop()`

##### ShowPrintUI
Opens the standard Print UI dialog.
`object.ShowPrintUI()`

##### SetMuted
Mutes or unmutes the audio output of the browser.
`object.SetMuted(Muted As Boolean)`

##### IsMuted
Returns true if the browser audio is currently muted.
`object.IsMuted()`

##### SetUserAgent
Sets a custom User Agent string for the browser.
`object.SetUserAgent(UserAgent As String)`

##### GetDocumentTitle
Returns the title of the current document.
`object.GetDocumentTitle()`

##### GetSource
Returns the current URL of the browser.
`object.GetSource()`

##### SetScriptEnabled
Enables or disables JavaScript execution.
`object.SetScriptEnabled(Enabled As Boolean)`

##### SetWebMessageEnabled
Enables or disables the Web Message communication system.
`object.SetWebMessageEnabled(Enabled As Boolean)`
  
##### SetStatusBarEnabled
Enables or disables the browser status bar.
`object.SetStatusBarEnabled(Enabled As Boolean)`
  
##### CapturePreview
Captures a screenshot of the current view to a file.
`object.CapturePreview(FilePath As String, Format As String)`

##### CallDevToolsProtocolMethod
Calls a Chrome DevTools Protocol (CDP) method directly.
`object.CallDevToolsProtocolMethod(MethodName As String, ParametersJson As String)`

##### GetCookies
Retrieves all cookies (results sent via OnMessageReceived as 'COOKIES_B64|').
`object.GetCookies(ChannelId As String)`

##### AddCookie
Adds or updates a cookie in the browser.
`object.AddCookie(Name As String, Value As String, Domain As String, Path As String)`

##### DeleteCookie
Deletes a specific cookie.
`object.DeleteCookie(Name As String, Domain As String, Path As String)`

##### DeleteAllCookies
Deletes all cookies from the current profile.
`object.DeleteAllCookies()`

##### Print
Opens the print dialog (via window.print()).
`object.Print()`
  
##### AddExtension
Adds a browser extension from an unpacked folder.
`object.AddExtension(ExtensionPath As String)`

##### RemoveExtension
Removes an extension by its ID.
`object.RemoveExtension(ExtensionId As String)`

##### GetCanGoBack
Returns true if navigating back is possible.
`object.GetCanGoBack()`

##### GetCanGoForward
Returns true if navigating forward is possible.
`object.GetCanGoForward()`

##### GetBrowserProcessId
Returns the Process ID (PID) of the browser process.
`object.GetBrowserProcessId()`

##### EncodeURI
URL-encodes a string.
`object.EncodeURI(Value As String)

##### DecodeURI
URL-decodes a string.
`object.DecodeURI(Value As String)`

##### EncodeB64
Encodes a string to Base64 (UTF-8).
`object.EncodeB64(Value As String)`

##### DecodeB64
Decodes a Base64 string back to **plain text** (UTF-8).
`object.DecodeB64(Value As String)`

##### DecodeB64ToBinary
Decodes a Base64 string directly into a **raw byte array**. Optimized for memory-based binary processing (e.g., images, PDFs).
`object.DecodeB64ToBinary(Base64Text As String)`

##### CapturePreviewAsBase64
Captures a screenshot of the current page  content and returns it as a Base64-encoded data URL.
`object.CapturePreviewAsBase64(format)`

##### SetZoomFactor
Sets the zoom factor for the control.
`object.SetZoomFactor(Factor As Double)`

##### OpenDevToolsWindow
Opens the DevTools window for the current project.
`object.OpenDevToolsWindow()`

##### WebViewSetFocus
Gives focus to the WebView control.
`object.WebViewSetFocus()` 

##### SetAutoResize
Enables or disables robust "Smart Anchor" resizing. Uses Win32 subclassing to perfectly sync with any parent window (AutoIt/Native). Sends "WINDOW_RESIZED" via OnMessageReceived on completion.
`object.SetAutoResize(Enabled As Boolean)`

##### AddInitializationScript
Registers a script that will run automatically every time a new page loads. Returns the unique **ScriptId** (string).
`ResultString = object.AddInitializationScript(Script As String)`

##### RemoveInitializationScript
Removes a script previously added via AddInitializationScript using its ScriptId.
`object.RemoveInitializationScript(ScriptId As String)`

##### SetVirtualHostNameToFolderMapping
Maps a virtual host name (e.g., `app.local`) to a local folder path for local resource loading.
`object.SetVirtualHostNameToFolderMapping(hostName As String, folderPath As String, accessKind As Integer)`

##### BindJsonToBrowser
Binds the internal JSON data to a browser variable.
`object.BindJsonToBrowser(VariableName As String)`

##### SyncInternalData
Syncs JSON data to internal parser and optionally binds it to a browser variable.
`object.SyncInternalData(Json As String, BindToVariableName As String)`

##### ExecuteScriptOnPage
**Type**: void (Async-Fire)
**Description**: Starts asynchronously but does not wait. No return value.
**Use Case**: Quick background actions.
`object.ExecuteScriptOnPage(Script As String)`

##### ExecuteScriptWithResult
**Type**: string (Synchronous/Blocking)
**Description**: Uses Message Pump (DoEvents) to wait for the response (timeout 5s).
**Special**: Performs automatic JSON Unescaping (removes extra quotes and fixes escape characters).
**Use Case**: Scraping, retrieving variables from JS, checking DOM state.
`object.ExecuteScriptWithResult(Script As String)`

##### ClearCache
Clears the browser cache (DiskCache and LocalStorage).
`object.ClearCache()`

##### GetInnerText
Asynchronously retrieves the entire visible text content of the document (sent via OnMessageReceived with 'Inner_Text|').
`object.GetInnerText()`

##### CaptureSnapshot
Captures page data using Chrome DevTools Protocol. Can return MHTML or other CDP formats based on the `cdpParameters` JSON string.
`object.CaptureSnapshot(CdpParameters As String)`

##### SetDownloadPath
Sets a global default folder or file path for all browser downloads. If a directory is provided, the filename is automatically appended by the library.
`object.SetDownloadPath(Path As String)`

##### CancelDownloads
Cancels active downloads. If `uri` is empty or omitted, cancels all active downloads.
`object.CancelDownloads([Uri As String])`

##### ExportPageData
[LEGACY] Consolidated into **CaptureSnapshot**.
`object.ExportPageData(Format As Integer, FilePath As String)`

##### PrintToPdfStream
Captures the current page as a PDF and returns the content as a Base64-encoded string.
`object.PrintToPdfStream()`

#### === Events ===

##### OnMessageReceived
Fired when a message or notification is sent from the library to AutoIt.
`object_OnMessageReceived(Sender As Object, ParentHandle As HWND, Message As String)`

##### OnWebResourceResponseReceived
Fired when a web resource response is received (useful for tracking HTTP Status Codes).
`object_OnWebResourceResponseReceived(Sender As Object, ParentHandle As HWND, StatusCode As Integer, ReasonPhrase As String, RequestUrl As String)`

##### OnNavigationStarting
Fired when the browser starts navigating to a new URL.
`object_OnNavigationStarting(Sender As Object, ParentHandle As HWND, Url As String)`

##### OnNavigationCompleted
Fired when navigation has finished.
`object_OnNavigationCompleted(Sender As Object, ParentHandle As HWND, IsSuccess As Boolean, WebErrorStatus As Integer)`

##### OnTitleChanged
Fired when the document title changes.
`object_OnTitleChanged(Sender As Object, ParentHandle As HWND, NewTitle As String)`
  
##### OnURLChanged
Fired when the current URL changes.
`object_OnURLChanged(Sender As Object, ParentHandle As HWND, NewUrl As String)`

##### OnContextMenu
Fired when a custom context menu is requested (if SetContextMenuEnabled is false).
`object_OnContextMenu(Sender As Object, ParentHandle As HWND, MenuData As String)`

##### OnZoomChanged
Fired when the zoom factor is changed.
`object_OnZoomChanged(Sender As Object, ParentHandle As HWND, Factor As Double)`

##### OnBrowserGotFocus
Fired when the browser receives focus.
`object_OnBrowserGotFocus(Sender As Object, ParentHandle As HWND, Reason As Integer)`

##### OnBrowserLostFocus
Fired when the browser loses focus.
`object_OnBrowserLostFocus(Sender As Object, ParentHandle As HWND, Reason As Integer)`

##### OnContextMenuRequested
Fired when a context menu is requested (Simplified for AutoIt).
`object_OnContextMenuRequested(Sender As Object, ParentHandle As HWND, LinkUrl As String, X As Integer, Y As Integer, SelectionText As String)`

##### OnDownloadStarting
Fired when a download is starting. Provides core metadata to allow decision making. Path overrides and UI suppression should be handled via the `DownloadResultPath` and `IsDownloadHandled` properties.
`object_OnDownloadStarting(Sender As Object, ParentHandle As HWND, Uri As String, DefaultPath As String)`

##### OnDownloadStateChanged
Fired when a download state changes (e.g., Progress, Completed, Failed).
`object_OnDownloadStateChanged(Sender As Object, ParentHandle As HWND, State As String, Uri As String, TotalBytes As Long, ReceivedBytes As Long)`

##### OnAcceleratorKeyPressed
Fired when an accelerator key is pressed. Allows blocking browser shortcuts.
`object_OnAcceleratorKeyPressed(Sender As Object, ParentHandle As HWND, Args As Object)`
	*Args properties: 
		VirtualKey (uint): The VK code of the key.
		KeyEventKind (int): Type of key event (Down, Up, etc.).
		Handled (bool): Set to `True` to stop the browser from processing the key.*
  

---

### JsonParser (ProgId: NetJson.Parser)

#### === Methods ===

##### Parse
Parses a JSON string. Automatically detects if it's an Object or an Array.
`bool Parse(Json As String)`

##### GetTokenValue
Retrieves a value by JSON path (e.g., "items[0].name").
`string GetTokenValue(Path As String)`

##### GetArrayLength
Returns the count of elements if the JSON is an array (Legacy wrapper for GetTokenCount).
`int GetArrayLength(Path As String)`

##### GetTokenCount
Returns the count of elements (array items or object properties) at the specified path.
`int GetTokenCount(Path As String)`

##### GetKeys
Returns a delimited string of keys for the object at the specified path.
`string GetKeys(Path As String, Delimiter As String)`

##### SetTokenValue
Updates or adds a value at the specified path. Supports **Deep Creation** (automatic path creation) and **Smart Typing** (auto-detection of bool/null/numbers).
`void SetTokenValue(Path As String, Value As String)`

##### LoadFromFile
Loads JSON content directly from a file.
`bool LoadFromFile(FilePath As String)`

##### SaveToFile
Saves the current JSON state back to a file.
`bool SaveToFile(FilePath As String)`

##### Exists
Checks if a path exists in the current JSON structure.
`bool Exists(Path As String)`

##### Clear
Clears the internal data.
`void Clear()`

##### GetJson
Returns the full JSON string.
`string GetJson()`

##### EscapeString
Escapes a string to be safe for use in JSON.
`string EscapeString(PlainText As String)`

##### UnescapeString
Unescapes a JSON string back to plain text.
`string UnescapeString(EscapedText As String)`

##### GetPrettyJson
Returns the JSON string with nice formatting (Indented).
`string GetPrettyJson()`
  
##### GetMinifiedJson
Minifies a JSON string (removes spaces and new lines).
`string GetMinifiedJson()`

##### Merge
Merges another JSON string into the current JSON structure.
`bool Merge(JsonContent As String)`

##### MergeFromFile
Merges JSON content from a file into the current JSON structure.
`bool MergeFromFile(FilePath As String)`
  
##### GetTokenType
Returns the type of the token at the specified path (e.g., Object, Array, String).
`string GetTokenType(Path As String)` 

##### RemoveToken
Removes the token at the specified path.
`bool RemoveToken(Path As String)`

##### Search
Searches the JSON structure using a JSONPath query and returns a JSON array of results.
`string Search(Query As String)`

##### Flatten
Flattens the JSON structure into a single-level object with dot-notated paths.
`string Flatten()`

##### CloneTo
Clones the current JSON data to another named parser instance.
`bool CloneTo(ParserName As String)`

##### FlattenToTable
Flattens the JSON structure into a table-like string with specified delimiters.
`string FlattenToTable(ColDelim As String, RowDelim As String)`

##### EncodeB64
Encodes a string to Base64 (UTF-8).
`string EncodeB64(PlainText As String)`

##### DecodeB64ToBinary
Converts a Base64-encoded string back into raw binary data (byte array).
`Variant DecodeB64ToBinary(Base64Text As String)`

##### EncodeBinaryToB64
Converts raw binary data (byte array) to a Base64-encoded string.
`string EncodeBinaryToB64(BinaryData As Variant)`

##### DecodeB64
Decodes a Base64 string back to **plain text** (UTF-8).
`string DecodeB64(Base64Text As String)`

##### DecodeB64ToFile
Decodes a Base64 string and saves the binary content directly to a file.
`bool DecodeB64ToFile(Base64Text As String, FilePath As String)`

##### SortArray
Sorts a JSON array by a specific key.
`bool SortArray(ArrayPath As String, Key As String, Descending As Boolean)`

##### SelectUnique
Removes duplicate objects from a JSON array based on a key's value.
`bool SelectUnique(ArrayPath As String, Key As String)`

