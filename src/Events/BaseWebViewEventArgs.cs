using System;
using System.Runtime.InteropServices;

namespace NetWebView2Lib
{
    /// <summary>
    /// Base interface for all WebView2 event arguments.
    /// Provides consistent sender information for multi-instance support.
    /// </summary>
    [Guid("D1D2D3D4-E5F6-4A5B-9C8D-7E6F5A4B3C2D")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IBaseWebViewEventArgs
    {
        /// <summary>Raw pointer to the parent window handle.</summary>
        [DispId(100)] int SenderPtr { get; }
        
        /// <summary>Formatted AutoIt handle string: [HANDLE:0x...]</summary>
        [DispId(101)] string SenderHandle { get; }
    }

    /// <summary>
    /// Abstract base class for WebView2 event argument wrappers.
    /// Includes common properties for identifying the sender instance.
    /// </summary>
    [ComVisible(true)]
    public abstract class BaseWebViewEventArgs : IBaseWebViewEventArgs
    {
        public int SenderPtr { get; protected set; }
        public string SenderHandle { get; protected set; }

        protected BaseWebViewEventArgs() { }

        /// <summary>
        /// Initializes the sender information from the manager's handle.
        /// </summary>
        protected void InitializeSender(IntPtr handle)
        {
            SenderPtr = (int)handle;
            SenderHandle = $"[HANDLE:0x{handle.ToInt64():X}]";
        }
    }
}
