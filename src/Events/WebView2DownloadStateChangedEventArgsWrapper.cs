using System;
using System.Runtime.InteropServices;
using Microsoft.Web.WebView2.Core;

namespace NetWebView2Lib
{
    [Guid("B8C9D0E1-F2A3-4B3C-9D0E-1F2A3B4C5D6E")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IWebView2DownloadStateChangedEventArgs : IBaseWebViewEventArgs
    {
        [DispId(1)] string State { get; }
        [DispId(2)] string Uri { get; }
        [DispId(3)] long TotalBytesToReceive { get; }
        [DispId(4)] long BytesReceived { get; }
        [DispId(5)] int PercentComplete { get; }
    }

    [ClassInterface(ClassInterfaceType.None)]
    [ComVisible(true)]
    [Guid("D1E2F3A4-B5C6-4B7C-9D0E-1F2A3B4C5D6E")]
    public class WebView2DownloadStateChangedEventArgsWrapper : BaseWebViewEventArgs, IWebView2DownloadStateChangedEventArgs
    {
        private readonly CoreWebView2DownloadOperation _operation;
        private readonly string _state;
        private readonly string _uri;
        private readonly long _totalBytesToReceive;
        private readonly long _bytesReceived;
        private readonly int _percentComplete;

        public WebView2DownloadStateChangedEventArgsWrapper(CoreWebView2DownloadOperation operation, IntPtr parentHandle)
        {
            _operation = operation;
            
            // Buffered Property Pattern (Capture on UI Thread)
            _state = operation.State.ToString();
            _uri = operation.Uri ?? "";
            _totalBytesToReceive = (long)(operation.TotalBytesToReceive ?? 0);
            _bytesReceived = (long)operation.BytesReceived;
            
            if (_totalBytesToReceive > 0)
            {
                _percentComplete = (int)((_bytesReceived * 100) / _totalBytesToReceive);
            }
            else
            {
                _percentComplete = -1; // Unknown
            }

            InitializeSender(parentHandle);
        }

        public string State => _state;
        public string Uri => _uri;
        public long TotalBytesToReceive => _totalBytesToReceive;
        public long BytesReceived => _bytesReceived;
        public int PercentComplete => _percentComplete;
    }
}
