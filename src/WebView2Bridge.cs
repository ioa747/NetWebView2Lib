using System;
using System.Runtime.InteropServices;
using System.Threading;

// --- Version 2.0.0-beta.3 ---
// Breaking Change: Sender-Aware Events (Issue #52)

namespace NetWebView2Lib
{    
    /// <summary>
    /// Delegate for detecting when messages are received from JavaScript.
    /// v2.0.0: Now includes sender object and parent window handle.
    /// </summary>
    /// <param name="sender">The WebViewManager instance that owns this bridge.</param>
    /// <param name="parentHandle">The parent window handle (Advanced Window Description).</param>
    /// <param name="message">The message content.</param>
    [ComVisible(true)]
    public delegate void OnMessageReceivedDelegate(object sender, string parentHandle, string message);

    /// <summary>
    /// Event interface for receiving messages from JavaScript via AutoIt.
    /// v2.0.0: Sender-Aware pattern.
    /// </summary>
    [Guid("3E4F5A6B-7C8D-9E0F-1A2B-3C4D5E6F7A8B")]
    [InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
    [ComVisible(true)]
    public interface IBridgeEvents
    {
        /// <summary>
        /// Triggered when a message is received from JavaScript.
        /// </summary>
        /// <param name="sender">The WebViewManager instance.</param>
        /// <param name="parentHandle">The parent window handle.</param>
        /// <param name="message">The message content.</param>
        [DispId(1)]
        void OnMessageReceived(object sender, string parentHandle, string message);
    }

    /// <summary>
    /// Action interface for sending messages from JavaScript to AutoIt.
    /// </summary>
    [Guid("2D3E4F5A-6A7A-4A9B-8C7D-2E3F4A5B6C7D")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IBridgeActions
    {
        /// <summary>
        /// Send a message to AutoIt.
        /// </summary>
        /// <param name="message">The message to send.</param>
        [DispId(1)]
        void RaiseMessage(string message);

        /// <summary>Gets the version of the DLL.</summary>
        [DispId(2)] string Version { get; }
    }

    /// <summary>
    /// Implementation of the bridge between WebView2 JavaScript and AutoIt.
    /// v2.0.0: Supports Sender-Aware event pattern.
    /// </summary>
    [Guid("8F9A0B1C-2D3E-4F5A-6B7C-8D9E0F1A2B3C")]
    [ClassInterface(ClassInterfaceType.None)]
    [ComSourceInterfaces(typeof(IBridgeEvents))]
    [ComVisible(true)]
    [ProgId("NetWebView2Lib.WebView2Bridge")]
    public class WebView2Bridge : IBridgeActions
    {
        /// <summary>
        /// Event fired when a message is received from JavaScript.
        /// </summary>
        public event OnMessageReceivedDelegate OnMessageReceived;

        private SynchronizationContext _syncContext;
        private readonly System.Diagnostics.Stopwatch _throttleStopwatch = System.Diagnostics.Stopwatch.StartNew();
        private long _lastMessageTicks = 0;
        private const long ThrottlingIntervalTicks = TimeSpan.TicksPerSecond / 50; // max 50 calls/sec

        // v2.0.0: Parent context for Sender-Aware events
        private object _sender;
        private string _parentHandle;

        /// <summary>
        /// Initializes a new instance of the WebView2Bridge class.
        /// </summary>
        public WebView2Bridge()
        {
            _syncContext = SynchronizationContext.Current ?? new SynchronizationContext();
        }

        /// <summary>
        /// Sets the parent context for Sender-Aware events.
        /// Must be called immediately after construction.
        /// </summary>
        public void SetParentContext(object sender, object hwnd)
        {
            _sender = sender;
            
            if (hwnd is IntPtr ptr)
            {
                _parentHandle = "[HANDLE:0x" + ptr.ToString("X").PadLeft(IntPtr.Size * 2, '0') + "]";
            }
            else
            {
                _parentHandle = hwnd?.ToString() ?? "[HANDLE:0x" + IntPtr.Zero.ToString("X").PadLeft(IntPtr.Size * 2, '0') + "]";
            }
        }

        /// <summary>
        /// Updates the SynchronizationContext used for raising events.
        /// </summary>
        /// <param name="context">The new context.</param>
        public void SetSyncContext(SynchronizationContext context)
        {
            _syncContext = context;
        }

        /// <summary>
        /// Send a message from JavaScript to AutoIt.
        /// v2.0.0: Now passes sender and parentHandle to the event.
        /// </summary>
        /// <param name="message">The message content.</param>
        public void RaiseMessage(string message)
        {
            if (OnMessageReceived != null)
            {
                // Throttling: Max 50 messages per second (Law #2: Performance)
                long currentTicks = _throttleStopwatch.ElapsedTicks;
                if (currentTicks - _lastMessageTicks < ThrottlingIntervalTicks) return;
                _lastMessageTicks = currentTicks;

                // v2.0.0: Pass sender and parentHandle for multi-instance support
                _syncContext?.Post(_ => OnMessageReceived?.Invoke(_sender, _parentHandle, message), null);
            }
        }

        /// <summary>Gets the version of the DLL.</summary>
        public string Version => AssemblyUtils.GetVersion();
    }

    /// <summary>
    /// Compatibility Layer for WebViewBridge (Legacy name).
    /// Inherits all functionality from WebView2Bridge.
    /// </summary>
    [Guid("1A2B3C4D-5E6F-4A8B-9C0D-1E2F3A4B5C6D")] // OLD GUID
    [ClassInterface(ClassInterfaceType.None)]
    [ComSourceInterfaces(typeof(IBridgeEvents))]
    [ComVisible(true)]
    [ProgId("NetWebView2Lib.WebViewBridge")] // Explicit OLD ProgID
    public class WebViewBridge : WebView2Bridge, IBridgeActions
    {
        // Inherits everything
    }
}
