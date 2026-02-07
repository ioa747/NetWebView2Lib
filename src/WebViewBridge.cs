using System;
using System.Runtime.InteropServices;
using System.Threading;

// --- Version 2.0.0-beta.1 ---
// Breaking Change: Sender-Aware Events (Issue #52)

namespace NetWebView2Lib
{    
    /// <summary>
    /// Delegate for detecting when messages are received from JavaScript.
    /// v2.0.0: Now includes sender object and parent window handle.
    /// </summary>
    /// <param name="sender">The WebViewManager instance that owns this bridge.</param>
    /// <param name="parentHandle">The parent window handle (hWnd).</param>
    /// <param name="message">The message content.</param>
    [ComVisible(true)]
    public delegate void OnMessageReceivedDelegate(object sender, object parentHandle, string message);

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
        void OnMessageReceived(object sender, object parentHandle, string message);
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
    }

    /// <summary>
    /// Implementation of the bridge between WebView2 JavaScript and AutoIt.
    /// v2.0.0: Supports Sender-Aware event pattern.
    /// </summary>
    [Guid("1A2B3C4D-5E6F-4A8B-9C0D-1E2F3A4B5C6D")]
    [ClassInterface(ClassInterfaceType.None)]
    [ComSourceInterfaces(typeof(IBridgeEvents))]
    [ComVisible(true)]
    public class WebViewBridge : IBridgeActions
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
        private object _parentManager;
        private object _parentHandle;

        /// <summary>
        /// Initializes a new instance of the WebViewBridge class.
        /// </summary>
        public WebViewBridge()
        {
            _syncContext = SynchronizationContext.Current ?? new SynchronizationContext();
        }

        /// <summary>
        /// Sets the parent context for Sender-Aware events.
        /// Must be called immediately after construction.
        /// </summary>
        /// <param name="manager">The parent WebViewManager instance.</param>
        /// <param name="hwnd">The parent window handle.</param>
        public void SetParentContext(object manager, object hwnd)
        {
            _parentManager = manager;
            _parentHandle = hwnd;
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
                _syncContext?.Post(_ => OnMessageReceived?.Invoke(_parentManager, _parentHandle, message), null);
            }
        }
    }
}
