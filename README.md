## AutoIt WebView2 Component (COM Interop)

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
### 📦 Deployment \& Installation

1. **Extract** NetWebView2Lib folder to a permanent location.
2. **Run**:
    `\NetWebView2Lib\bin\Register_web2.au3` to Register
   * Verifies the WebView2 Runtime presence.
   * Registers `NetWebView2Lib.dll` for COM Interop on both 32-bit and 64-bit.
     
    or `\NetWebView2Lib\bin\Unregister.au3` to Unregister

1. **Run `\Example\*`** to see the bridge in action.

### ⚖️ License

This project is provided "as-is". You are free to use, modify, and distribute it for both personal and commercial projects.

<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" width="100%">
</p>

## NetWebView2Lib v1.4.0 - Major Update

This version introduces significant architectural improvements, focusing on deep integration with WebView2 settings and a more robust event-driven system.

### ✨ Key Highlights

* **Comprehensive Settings Control**: Direct access to browser behaviors via new properties. Toggle DevTools, Context Menus, Script Dialogs, and Browser Accelerators (`AreDevToolsEnabled`, `AreDefaultContextMenusEnabled`, etc.) directly from your AutoIt script.
  
* 🎯 **Permanent JS Injection**: Introducing `AddInitializationScript`. Injected JavaScript (like bridges or libraries) now persists across page navigations and refreshes automatically, managed via a new Script ID tracking system.
  
* **Custom Context Menus**: Intercept right-clicks with the new `OnContextMenu` event. Receive rich JSON metadata including coordinates, element tags, selected text, and source URLs to build native-looking custom menus.
  
* **Focus & Lifecycle Management**: Navigation is now fully observable through `OnNavigationStarting` and `OnNavigationCompleted`.
  
* **Integrated Utilities**: Added native methods for `Encode/DecodeURI` and `Base64` (UTF-8) to handle data transfers between AutoIt and JavaScript seamlessly.
  
* **Enhanced State Sync**: Real-time events for Title, URL, and Zoom changes to keep your AutoIt GUI perfectly in sync with the browser state.

---

### 🛠️ Migration Note (Important)

Due to changes in the COM Dispatch IDs (DispIds) for better organization, it is **highly recommended** to run the included `RegCleaner.au3` before registering the new version. This ensures that any stale registry entries from previous builds are purged, preventing "Object action failed" errors.

<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" width="100%">
</p>

### 📖 Understanding the WebDemo (v1.4)

The **`WebDemo_v1.4.au3`** is not just a browser, 
 it is a showcase of **Bi-directional Intelligence**. 
 It demonstrates how AutoIt can "read" the DOM state via COM events to provide a context-specific user interface.

#### 1. Context-Aware Menu (The "Right-Click" Magic)

The demo intercepts the native context menu and replaces it with a dynamic AutoIt menu. The options change based on the **HTML element** under your cursor:

- **📥 Table Intelligence**:
    
    - **Action**: Right-click anywhere inside a `<table>`.
        
    - **What happens**: The library detects the `tagName`, calculates the table's index via coordinates, and offers an **Export to CSV** option. It uses the `bridge.js` to scrape the data directly from the browser's memory.
        
- **📋 Form Automation**:
    
    - **Action**: Right-click on an `<input>`, `<textarea>`, or `<form>`.
        
    - **What happens**:
        
        - **Map Form to JSON**: Automatically crawls the form and generates a JSON file with all current values.
            
        - **Fill Form from JSON**: Lets you select a previously saved JSON file to instantly re-populate the form.
            
- **🔍 Smart Selection**:
    
    - **Action**: Highlight any text on the page and right-click.
        
    - **What happens**: The menu offers a Google Search for that specific string, using the new native `EncodeURI` method to handle special characters.
        

#### 2. Advanced Utilities

- **📸 Full Page Screenshot**: Unlike standard screen captures, this utility renders the **entire document** (including the parts you need to scroll to see) and saves it as a high-quality PNG.
    
- **⚡ Persistent Bridge**: Notice that even if you navigate to a new website or refresh, the "Table Export" and "Form Mapping" still work. This is thanks to the new `AddInitializationScript` which ensures our `bridge.js` is part of every page's DNA.
    
---

#### ⚙️ How it Works: The "Context-JSON" Bridge

The secret behind this intelligent menu is the seamless communication between the Browser's DOM and AutoIt's COM interface.

#### The Workflow:

1. **The Trigger**: When you right-click, the `bridge.js` (injected via `AddInitializationScript`) intercepts the event.
    
2. **Data Gathering**: It instantly gathers metadata about the element under the mouse (Coordinates, Tag Type, Selected Text, Image Sources, etc.).
    
3. **The Dispatch**: This metadata is packed into a **JSON string** and sent to AutoIt via the `OnContextMenu` event.
    
4. **The Decision**: AutoIt receives the JSON, parses it using `NetJson.Parser`, and decides which menu items to show.
    

#### Why JSON?

- **Structure**: It allows passing multiple data points (X, Y, Tag, URL) in a single, organized string.
    
- **Performance**: By prefixing with `JSON:`, we bypass complex string encoding, making the communication near-instant.
    
- **Flexibility**: You can easily add more data points to the `bridge.js` without ever changing the core DLL.
    

---

#### 💡 Pro Tip for Developers:

> "You can extend this! If you want to detect specifically if a user clicked on a **Video** or a **PDF link**, just update the `bridge.js` to include those tags. 

<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png" width="100%">
</p>
  
## 📖 NetWebView2Lib Version 1.4.0 (Quick Reference)

### Properties

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

### Methods

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
`object.EncodeURI(Value As String)`

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

##### AddInitializationScript
Registers a script that will run automatically every time a new page loads.
`object.AddInitializationScript(Script As String)`

### Events

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

---


---

