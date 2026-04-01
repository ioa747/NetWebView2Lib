# The Volatile Keyword in NetWebView2Lib

In **NetWebView2Lib**, callback functions such as `JS_Events_OnMessageReceived` and `OnBasicAuthenticationRequested` **must** be declared using the `Volatile` qualifier. This is a technical requirement for reliable interaction between AutoIt and the WebView2 runtime.

## What `Volatile` Does
The `Volatile` keyword enables **re-entrant execution**. 
* **With Volatile:** While a function is running, AutoIt continues to process its internal message loop, including GUI and COM events.
* **Without Volatile:** AutoIt pauses message processing until the function returns.

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

## Example
```autoit
; WebView2 callback must be declared as Volatile
Volatile Func JS_Events_OnMessageReceived($oWebV2M, $hGUI, $sMessage)
    ; Handle message from WebView2
    ConsoleWrite("Message received: " & $sMessage & @CRLF)
EndFunc
```

## Object Cleanup

In AutoIt, when working with COM objects (like the WebView2 Manager or Bridge), it is highly recommended to explicitly release the object references when they are no longer needed.

### Why zero out objects?

1. **Reference Counting:** COM objects use reference counting. The object stays in memory as long as there is at least one active reference to it. Setting `$oObject = 0` decrements this count.
    
2. **Preventing Memory Leaks:** If a script runs for a long time and repeatedly creates objects without releasing them, it will consume increasing amounts of RAM.
    
3. **Proper Shutdown:** WebView2 is an external process. Explicitly cleaning up ensures that the underlying `WebView2Loader` and Chromium processes terminate correctly when your GUI closes.
    

### Implementation Example

Always pair your initialization with a cleanup block, typically before the script exits:


```AutoIt
; ... inside your Exit logic ...

; 1. Call the UDF's cleanup function to release internal resources
_NetWebView2_CleanUp($oWebV2M, $oBridge)

; 2. Explicitly nullify the object variables
$oBridge = 0
$oWebV2M = 0

Exit
```

> **Tip:** In `Volatile` functions, if you receive an object as an argument (like `$oArgs`), it is a good habit to set `$oArgs = 0` at the end of the function to ensure the COM reference is released immediately after the event is handled.