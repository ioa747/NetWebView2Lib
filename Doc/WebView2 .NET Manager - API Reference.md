A powerful bridge that allows **AutoIt** to use the modern **Microsoft Edge WebView2** (Chromium) engine via a C# COM wrapper. This project enables you to render modern HTML5, CSS3, and JavaScript directly inside your AutoIt applications with a 100% event-driven architecture.

---

## 1. WebViewManager (`NetWebView2.Manager`)

### **Lifecycle & Core State**

|**Method**|**Description**|
|---|---|
|**`.Initialize(parentHandle, userDataFolder, x, y, width, height)`**|Initializes the WebView2.<br><br>  <br><br>_Note: Uses default values (0) for coordinates/size if not specified._|
|**`.IsReady()`**|Returns `True` if the WebView2 environment is fully initialized.|
|**`.Cleanup()`**|Releases all resources and closes the browser engine.|
|**`.GetBridge()`**|Returns the `IBridgeActions` object for AutoIt/JS communication.|

### **Navigation & Document**

|**Method**|**Description**|
|---|---|
|**`.Navigate(url)`**|Navigates to the specified URL.|
|**`.NavigateToString(html)`**|Loads raw HTML content.|
|**`.Reload()`**|Refreshes the current page.|
|**`.Stop()`**|Stops the current loading process.|
|**`.GoBack()`**|Navigates backward in history.|
|**`.GoForward()`**|Navigates forward in history.|
|**`.GetSource()`**|Returns the current URL as a string.|
|**`.GetDocumentTitle()`**|Returns the title of the current document.|
|**`.GetHtmlSource()`**|Triggers a request to retrieve the full HTML source.|
|**`.GetSelectedText()`**|Retrieves currently selected text from the page.|

### **UI & Layout**

|**Method**|**Description**|
|---|---|
|**`.Resize(width, height)`**|Updates the dimensions of the WebView control.|
|**`.SetZoom(factor)`**|Sets the zoom factor (e.g., `1.5` for 150%).|
|**`.ResetZoom()`**|Resets zoom to the default level.|
|**`.SetStatusBarEnabled(bool)`**|Shows/hides the browser status bar.|
|**`.SetContextMenuEnabled(bool)`**|Enables/disables the right-click context menu.|
|**`.SetMuted(bool)`**|Mutes or unmutes all browser audio.|
|**`.IsMuted()`**|Returns the current mute state (`Boolean`).|
|**`.SetUserAgent(string)`**|Sets a custom User Agent string.|

### **Security & Restrictions**

|**Method**|**Description**|
|---|---|
|**`.LockWebView()`**|High-level method to lock down the browser UI and features.|
|**`.DisableBrowserFeatures()`**|Disables specific built-in browser functionalities.|
|**`.SetScriptEnabled(bool)`**|Enables or disables JavaScript execution.|
|**`.SetWebMessageEnabled(bool)`**|Enables or disables Web Message communication.|

### **Scripting & CSS**

|**Method**|**Description**|
|---|---|
|**`.ExecuteScript(script)`**|Runs a JavaScript string in the page context.|
|**`.InjectCss(cssCode)`**|Injects custom CSS styles into the page.|
|**`.ClearInjectedCss()`**|Removes all previously injected CSS.|
|**`.ToggleAuditHighlights(bool)`**|Toggles visual audit highlights for debugging.|

### **Content Filtering (AdBlock)**

|**Method**|**Description**|
|---|---|
|**`.SetAdBlock(active)`**|Enables or disables the AdBlocker interceptor.|
|**`.AddBlockRule(domain)`**|Adds a specific domain or pattern to the block list.|
|**`.ClearBlockRules()`**|Removes all active blocking rules.|

### **Advanced Features**

|**Method**|**Description**|
|---|---|
|**`.CapturePreview(path, format)`**|Saves a screenshot (`"png"` or `"jpg"`).|
|**`.ExportToPdf(path)`**|Saves the current page as a PDF file.|
|**`.Print()`**|Opens the standard system print dialog.|
|**`.ShowPrintUI()`**|Shows the WebView2-specific print interface.|
|**`.AddExtension(path)`**|Loads a Chromium extension from the specified folder.|
|**`.CallDevToolsProtocolMethod(method, json)`**|Directly calls a CDP method.|
|**`.ClearBrowserData()`**|Wipes history, cache, and other browsing data.|

### **Cookie Management**

|**Method**|**Description**|
|---|---|
|**`.GetCookies(channelId)`**|Starts an async request to fetch cookies (result via events).|
|**`.AddCookie(name, val, dom, path)`**|Adds or updates a cookie.|
|**`.DeleteCookie(name, dom, path)`**|Deletes a specific cookie.|
|**`.DeleteAllCookies()`**|Clears all cookies from the session.|

### **Internal JSON Support**

|**Method**|**Description**|
|---|---|
|**`.ParseJsonToInternal(json)`**|Parses a JSON string into the Manager's internal storage.|
|**`.GetInternalJsonValue(path)`**|Retrieves a value from the internal JSON storage by path.|

---

## 2. JsonParser (`NetJson.Parser`)

### **Methods**

| **Method**                        | **Description**                                   |
| --------------------------------- | ------------------------------------------------- |
| **`.Parse(jsonString)`**          | Parses a raw JSON string.                         |
| **`.LoadFromFile(path)`**         | Loads JSON from a text file.                      |
| **`.SaveToFile(path)`**           | Writes current JSON back to a file.               |
| **`.GetTokenValue(path)`**        | Gets a value using path notation (`"root.node"`). |
| **`.SetTokenValue(path, value)`** | Updates or adds a value at a specific path.       |
| **`.Exists(path)`**               | Checks if a path exists (Returns Boolean).        |
| **`.GetArrayCount()`**            | Returns the number of items in a JSON array.      |
| **`.GetPrettyJson()`**            | Returns formatted JSON.                           |
| **`.GetMinifiedJson()`**          | Returns compact JSON.                             |
| **`.EscapeString(text)`**         | Escapes a string for JSON safety.                 |
| **`.UnescapeString(text)`**       | Reverts JSON-escaped text.                        |
| **`.Clear()`**                    | Resets the parser state.                          |

---
