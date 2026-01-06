## 🪪 AutoIt WebView2 Component (COM Interop)

A powerful bridge that allows **AutoIt** to use the modern **Microsoft Edge WebView2** (Chromium) engine via a C# COM wrapper. This project enables you to render modern HTML5, CSS3, and JavaScript directly inside your AutoIt applications with a 100% event-driven architecture.

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

---

<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" width="100%">
</p>

## 🚀 What's New in v1.4.2 - Major Update

This major update transforms **NetWebView2Lib** into a high-performance automation framework, bridging the gap between synchronous procedural logic (AutoIt) and asynchronous web environments.

### ⚡ Key Features & Enhancements

#### **1. Synchronous Script Execution**

The long-awaited `ExecuteScriptWithResult(script)` is here. You can now execute JavaScript and receive the return value directly in a single line of AutoIt code, eliminating the need for complex event-callback chains.

- **Automatic Unescaping:** Results are automatically cleaned from JSON quotes and escaped characters.
    
- **Safety First:** Built-in 5-second timeout to prevent application hangs during script execution.
    

#### **2. Persistent Code Injection**

The new `AddInitializationScript(script)` allows you to register JavaScript or CSS that "survives" page reloads and navigations.

- **Persistence:** Scripts are automatically re-injected by the engine the moment a new document is created.
    
- **Stackable:** Multiple scripts can be registered simultaneously without overwriting previous ones.
    

#### **3. Unified Context Menu Handling**

A new, streamlined event `OnContextMenuRequested` provides direct access to context data without manual JSON parsing.

- **Direct Access:** Instantly get the `LinkURL`, `X/Y Coordinates`, and `SelectedText`.
    
- **Legacy Support:** Remains 100% compatible with the previous JSON-based context event for existing projects.
    

#### **4. Integrated Data Sync & Base64 Support**

- **Direct Data Binding:** The new `SyncInternalData(json, variable)` provides an atomic way to synchronize complex data from AutoIt to the browser window without manual JS execution.
    
- **Native Base64 Support:** The `NetJson.Parser` now includes built-in Base64 encoding and decoding (including `DecodeB64ToFile`), providing a high-speed path for processing screenshots and binary data.

#### **5. Professional Layout & Diagnostics**

- **Smart Resizing (v1.4.2):** Replaced legacy docking with native OS message interception for pixel-perfect resizing.
    
- **Global Error Handling:** The standard showcase now implements a global COM error handler for professional debugging.
    

---

### 📝 Quick Migration Example (AutoIt)

**Before (v1.4.1):**

AutoIt

```
$oWeb.ExecuteScript("document.title")
; ... Wait for WebMessageReceived event ...
; ... Parse JSON ...
```

**Now (v1.4.2):**

AutoIt

```
Local $sTitle = $oWeb.ExecuteScriptWithResult("document.title")
ConsoleWrite("Page Title: " & $sTitle & @CRLF)
```

---

### 📦 Technical Breakdown

| **Method / Property**     | **DispId** | **Description**                             |
| ------------------------- | ---------- | ------------------------------------------- |
| `AddInitializationScript` | 184        | Persistent JS injection across navigations. |
| `SyncInternalData`        | 186        | Parses and binds JSON in one step.          |
| `ExecuteScriptWithResult` | 188        | Synchronous JS execution (Returns String).  |
| `OnContextMenuRequested`  | 190        | Unified 4-parameter context menu event.     |
| `EncodeB64 / DecodeB64`   | 222-224    | Integrated Base64 & File decoding.          |
| `ClearCache`              | 193        | Clears Disk Cache & Local Storage.          |

---

<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" width="100%">
</p>


## 🧬 Understanding the GOG Demo Showcase (v1.4.2)

The **`gogDemo_v1.4.2.au3`** is more than just a browser—it is a showcase of **Hybrid Intelligence**. It demonstrates how AutoIt can seamlessly orchestrate a modern, complex e-commerce environment (GOG.com) by combining native Windows logic with the Edge WebView2 DOM.

#### 1. Context-Aware Menu (GOG Edition)

The demo intercepts the native browser menu and replaces it with a dynamic AutoIt menu. The library "senses" exactly what is under your cursor:

- **🎮 Game Tile Intelligence**:
    
    - **Action**: Right-click on a game’s thumbnail or title.
        
    - **What happens**: The script extracts the `Game ID` and `Price` directly from the DOM, offering options to open the game in a new tab or add it to a local AutoIt-managed Watchlist.
        
- **📄 Professional Reporting (PDF & Screenshots)**:
    
    - **Action**: Right-click anywhere on the page.
        
    - **What happens**:
        
        - **Smart PDF Export**: Generates a clean **A4 PDF** report. Before exporting, it uses the new `InjectCss` method to dynamically strip away GOG’s headers, sidebars, and campaign banners for a professional, content-focused document.
            
        - **Full Page Capture**: Leverages the **Chrome DevTools Protocol (CDP)** to capture a high-resolution image of the entire page—even if it exceeds 6,000+ pixels in height—without scrolling artifacts.
            

#### 2. Advanced Framework Features

- **⚡ Native CSS Injection (`InjectCss`)**: Move beyond manual JavaScript DOM manipulation. The demo shows how a single line of AutoIt code can override a website’s layout, making it "Print-Friendly" instantly.
    
- **🔄 Synchronous Data Binding (`SyncInternalData`)**: Effortlessly synchronize complex JSON datasets from AutoIt directly into the browser’s memory. This allows your script to "inject" custom variables that the website’s JavaScript can read in real-time.
    
- **🛠 Robust Event Handling**: The demo implements a **Global COM Error Handler**. Even if the website encounters JavaScript errors or network lag, the AutoIt host remains stable and responsive.
    
- **📏 Precision Resizing**: Utilizing native OS message interception, the browser view adapts to GUI changes with pixel-perfect accuracy, eliminating the flickering typical of standard docking.
    

---

#### ⚙️ How it Works: The v1.4.2 "Direct Path"

Version 1.4.2 simplifies the communication bridge. While previous versions required complex event-callback chains, we now use the **Direct Path**:

1. **Unified Events**: The `OnContextMenuRequested` event now passes 4 clean parameters (Link, X, Y, Selected Text) directly. No more manual JSON parsing for standard context actions.
    
2. **Instant Execution**: With `ExecuteScriptWithResult`, AutoIt asks JavaScript a question (e.g., "What is the total price in the cart?") and receives the answer **immediately** in the next line of code, just like a native function.
    
3. **Persistent DNA**: Via `AddInitializationScript`, your custom bridge logic (like PDF cleaning or menu triggers) survives page reloads and site-wide navigation.
    

---

#### 💡 Pro Tip for Developers:

> "Version 1.4.2 is **GOG-Proof**. Use the `InjectCss` method during PDF Export to target dynamic elements like `.campaign-bar` or `nav`. Using wildcard selectors like `[class*='notification']` allows you to suppress annoying popups and banners automatically, turning any webpage into a clean business report."

---

<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" width="100%">
</p>

## 📖 NetWebView2Lib Version 1.4.2 (Quick Reference)

### NetWebView2Lib (ProgId: NetWebView2.Manager)

#### Properties

##### AreDevToolsEnabled
Determines whether the user is able to use the context menu or keyboard shortcuts to open the DevTools window.
`object.AreDevToolsEnabled[ = Value]`

##### AreDefaultContextMenusEnabled
Activates or Deactivates the contextual menus of the WebView2 browser.
`object.AreDefaultContextMenusEnabled[ = Value]`

##### AreDefaultScriptDialogsEnabled
Determines whether the standard JavaScript dialogs (alert, confirm, prompt) are enabled.
`object.AreDefaultScriptDialogsEnabled[ = Value]`

##### AreBrowserAcceleratorKeysEnabled
Determines whether browser-specific accelerator keys are enabled (e.g., Ctrl+P, F5, etc.).
`object.AreBrowserAcceleratorKeysEnabled[ = Value]`

##### IsStatusBarEnabled
Determines whether the status bar is visible.
`object.IsStatusBarEnabled[ = Value]`

##### ZoomFactor
Gets or sets the current zoom factor (e.g., 1.0 for 100%).
`object.ZoomFactor[ = Value]`

##### BackColor
Sets the background color of the WebView using a Hex string (e.g., "#FFFFFF" or "0xFFFFFF").
`object.BackColor[ = Value]`

##### AreHostObjectsAllowed
Determines whether host objects (like the 'autoit' bridge) are accessible from JavaScript.
`object.AreHostObjectsAllowed[ = Value]`

##### Anchor
Determines how the control is anchored when the parent window is resized.
`object.Anchor[ = Value]`

##### BorderStyle
Note: Not supported natively by WebView2, provided for compatibility.
`object.BorderStyle[ = Value]`
  
##### AreBrowserPopupsAllowed
Determines whether new window requests are allowed or redirected to the same window.
`object.AreBrowserPopupsAllowed[ = Value]`

##### CustomMenuEnabled
Enables or disables custom context menu handling.
`object.CustomMenuEnabled[ = Value]`

#### Method

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
Executes the specified JavaScript code in the current document.
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
Locks down the WebView by disabling DevTools, Context Menus, and Zoom.
`object.LockWebView()`

##### DisableBrowserFeatures
Disables major browser features for a controlled environment.
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
Decodes a Base64 string back to plain text.
`object.DecodeB64(Value As String)`

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
Registers a script that will run automatically every time a new page loads.
`object.AddInitializationScript(Script As String)`

##### BindJsonToBrowser
Binds the internal JSON data to a browser variable.
`object.BindJsonToBrowser(VariableName As String)`

##### SyncInternalData
Syncs JSON data to internal parser and optionally binds it to a browser variable.
`object.SyncInternalData(Json As String, BindToVariableName As String)`

##### ExecuteScriptOnPage
Executes JavaScript on the current page immediately.
`object.ExecuteScriptOnPage(Script As String)`

##### ExecuteScriptWithResult
Executes JavaScript and returns the result synchronously (Blocking wait).
`object.ExecuteScriptWithResult(Script As String)`

##### ClearCache
Clears the browser cache (DiskCache and LocalStorage).
`object.ClearCache()`

##### GetInnerText
Asynchronously retrieves the entire visible text content of the document (sent via OnMessageReceived with 'Inner_Text|').
`object.GetInnerText()`

---
#### Events

##### OnMessageReceived
Fired when a message or notification is sent from the library to AutoIt.
`object_OnMessageReceived(Message As String)`

##### OnNavigationStarting
Fired when the browser starts navigating to a new URL.
`object_OnNavigationStarting(Url As String)`

##### OnNavigationCompleted
Fired when navigation has finished.
`object_OnNavigationCompleted(IsSuccess As Boolean, WebErrorStatus As Integer)`

##### OnTitleChanged
Fired when the document title changes.
`object_OnTitleChanged(NewTitle As String)`
  
##### OnURLChanged
Fired when the current URL changes.
`object_OnURLChanged(NewUrl As String)`

##### OnContextMenu
Fired when a custom context menu is requested (if SetContextMenuEnabled is false).
`object_OnContextMenu(MenuData As String)`

##### OnZoomChanged
Fired when the zoom factor is changed.
`object_OnZoomChanged(Factor As Double)`

##### OnBrowserGotFocus
Fired when the browser receives focus.
`object_OnBrowserGotFocus(Reason As Integer)`

##### OnBrowserLostFocus
Fired when the browser loses focus.
`object_OnBrowserLostFocus(Reason As Integer)`

##### OnContextMenuRequested
Fired when a context menu is requested (Simplified for AutoIt).
`object_OnContextMenuRequested(LinkUrl As String, X As Integer, Y As Integer, SelectionText As String)`
  

---

### JsonParser (ProgId: NetJson.Parser)

#### Methods

##### Parse
Parses a JSON string. Automatically detects if it's an Object or an Array.
`bool Parse(Json As String)`

##### GetTokenValue
Retrieves a value by JSON path (e.g., "items[0].name").
`string GetTokenValue(Path As String)`

##### GetArrayLength
Returns the count of elements if the JSON is an array.
`int GetArrayLength(Path As String)`

##### SetTokenValue
Updates or adds a value at the specified path (only for JObject).
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

##### DecodeB64
Decodes a Base64 string back to plain text.
`string DecodeB64(Base64Text As String)`

##### DecodeB64ToFile
Decodes a Base64 string and saves the binary content directly to a file.
`bool DecodeB64ToFile(Base64Text As String, FilePath As String)`

