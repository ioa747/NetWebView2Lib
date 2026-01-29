using System;
using System.Runtime.InteropServices;
using System.Threading;

// --- Version 1.5.0 ---

namespace NetWebView2Lib
{    
    [ComVisible(true)]
    public delegate void OnMessageReceivedDelegate(string message);

    /// <summary>
    /// Event interface for receiving messages from AutoIt.
    /// </summary>
    // Event interface for receiving messages from AutoIt
    [Guid("3E4F5A6B-7C8D-9E0F-1A2B-3C4D5E6F7A8B")]
    [InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
    [ComVisible(true)]
    public interface IBridgeEvents
    {
        /// <summary>
        /// Triggered when a message is received.
        /// </summary>
        /// <param name="message">The message content.</param>
        [DispId(1)]
        void OnMessageReceived(string message);
    }

    /// <summary>
    /// Action interface for sending messages to AutoIt.
    /// </summary>
    // Action interface for sending messages to AutoIt
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
    /// Implementation of the bridge between WebView2 and AutoIt.
    /// </summary>
    // Implementation of the bridge between WebView2 and AutoIt
    [Guid("1A2B3C4D-5E6F-4A8B-9C0D-1E2F3A4B5C6D")]
    [ClassInterface(ClassInterfaceType.None)]
    [ComSourceInterfaces(typeof(IBridgeEvents))]
    [ComVisible(true)]
    public class WebViewBridge : IBridgeActions
    {
        /// <summary>
        /// Event fired when a message is received.
        /// </summary>
        public event OnMessageReceivedDelegate OnMessageReceived;
        private readonly SynchronizationContext _syncContext;
        
        /// <summary>
        /// Initializes a new instance of the WebViewBridge class.
        /// </summary>
        public WebViewBridge()
        {
            _syncContext = SynchronizationContext.Current ?? new SynchronizationContext();
        }


        /// <summary>
        /// Send a message to AutoIt.
        /// </summary>
        /// <param name="message">The message content.</param>
        // Method to send messages to AutoIt 
        public void RaiseMessage(string message)
        {
            if (OnMessageReceived != null)
            {
                _syncContext.Post(_ => OnMessageReceived?.Invoke(message), null);
            }
        }
    }
}