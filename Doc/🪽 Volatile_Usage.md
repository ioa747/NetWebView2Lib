# The Volatile Keyword in NetWebView2Lib

In **NetWebView2Lib**, callback functions such as `JS_Events_OnMessageReceived` and `OnBasicAuthenticationRequested` **must** be declared using the `Volatile` qualifier. This is a technical requirement for reliable interaction between AutoIt and the WebView2 runtime.

## What `Volatile` Does

The `Volatile` keyword enables **re-entrant execution**.

- **With Volatile:** While a function is running, AutoIt continues to process its internal message loop, including GUI and COM events.
    
- **Without Volatile:** AutoIt pauses message processing until the function returns.
    

## Why It Is Required

### 1. Continuous Message Processing

WebView2 communicates with AutoIt through COM events. If AutoIt stops processing messages while handling a callback, incoming events may be delayed or blocked. Declaring the function as `Volatile` ensures that message handling continues during execution, preventing the interface from becoming unresponsive.

### 2. Synchronous COM Callbacks

WebView2 event handlers are invoked through **synchronous COM calls**. This means the WebView2 process waits for AutoIt to finish executing the callback before continuing. If AutoIt is busy (e.g., during GUI interaction like moving the window), the WebView2 process may stall. Using `Volatile` allows the callback to execute without interrupting message handling.

### 3. Deadlock Prevention

Because AutoIt and WebView2 run in separate processes, improper message handling can lead to deadlocks.

> **Deadlock Scenario:**
> 1. WebView2 triggers a callback and waits for AutoIt to return.
> 2. AutoIt is blocked (e.g. by a system menu or moving the GUI) and is not processing messages.
> 3. Neither process can continue, resulting in a frozen application.

Declaring callbacks as `Volatile` prevents this by allowing AutoIt to remain responsive.

## Rule of Thumb

**All functions used as WebView2 event handlers MUST be declared Volatile.**

**Example**

```AutoIt
; WebView2 callback must be declared as Volatile
Volatile Func JS_Events_OnMessageReceived($oWebV2M, $hGUI, $sMessage)
    ; Handle message from WebView2
    ConsoleWrite("Message received: " & $sMessage & @CRLF)
EndFunc
```

---

## Object Cleanup & Memory Management in Callbacks

When working with **Volatile** functions in `NetWebView2Lib`, AutoIt often receives COM objects as arguments (like `$oArgs` or `$oFrame`) directly from the WebView2 engine. To ensure high performance and stability, it is highly recommended to explicitly release these references before the function returns.

### Why zero out objects in Volatile functions?

1. **Immediate Reference Release:** COM objects use **Reference Counting**. As long as AutoIt holds a reference to an object in a variable, that object stays alive in memory. By setting `$oObject = 0`, you decrement this count immediately.
    
2. **Preventing Memory Leaks:** WebView2 events can fire hundreds of times (e.g., during navigation or frame changes). If these references are not cleared, your script's RAM usage will grow unnecessarily over time.
    
3. **Process Sync:** Since WebView2 is an external Chromium process, clearing the reference in AutoIt tells the engine that you are done with that specific resource, allowing it to clean up its own internal memory.
    

### Implementation Example

In every **Volatile** event handler, make it a habit to nullify any object received as a parameter at the end of the code block.


```AutoIt
; Example: Handling a new frame creation
Volatile Func NetWebView2_Events_OnFrameCreated($oWebV2M, $hGUI, $oFrame)
    Local Const $s_Prefix = "[EVENT: OnFrameCreated]: WebV2M: " & VarGetType($oWebV2M) & " GUI: " & $hGUI & " Frame: " & VarGetType($oFrame)
    
    ; Perform your logic here
    __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)

    ; --- Performance Tip ---
    ; Manually release the object reference to help AutoIt's memory management
    $oFrame = 0 
EndFunc   ;==>NetWebView2_Events_OnFrameCreated
```


> **💡 Pro Tip:** This practice is especially important for the `$oArgs` object in events like `OnWebMessageReceived` or `OnNavigationCompleted`. Even though AutoIt will eventually clear local variables when the function exits, setting them to `0` manually is an "active" safeguard against memory fragmentation in high-frequency events.


---
