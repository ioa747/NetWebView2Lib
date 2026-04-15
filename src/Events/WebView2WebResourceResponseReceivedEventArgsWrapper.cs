using System;
using System.Runtime.InteropServices;
using Microsoft.Web.WebView2.Core;

namespace NetWebView2Lib
{
    [Guid("A7B8C9D0-E1F2-4B3C-9D0E-1F2A3B4C5D6E")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IWebView2WebResourceResponseReceivedEventArgs : IBaseWebViewEventArgs
    {
        [DispId(1)] int StatusCode { get; }
        [DispId(2)] string ReasonPhrase { get; }
        [DispId(3)] string RequestUri { get; }
        [DispId(5)] bool IsDocument { get; }
    }

    [ClassInterface(ClassInterfaceType.None)]
    [ComVisible(true)]
    [Guid("C1D2E3F4-A5B6-4B7C-9D0E-1F2A3B4C5D6E")]
    public class WebView2WebResourceResponseReceivedEventArgsWrapper : BaseWebViewEventArgs, IWebView2WebResourceResponseReceivedEventArgs
    {
        private readonly CoreWebView2WebResourceResponseReceivedEventArgs _args;
        private readonly int _statusCode;
        private readonly string _reasonPhrase;
        private readonly string _requestUri;
        private readonly bool _isDocument;

        public WebView2WebResourceResponseReceivedEventArgsWrapper(CoreWebView2WebResourceResponseReceivedEventArgs args, IntPtr parentHandle)
        {
            _args = args;
            
            // Buffered Property Pattern (Capture on UI Thread)
            _statusCode = args.Response != null ? args.Response.StatusCode : 0;
            _reasonPhrase = args.Response != null ? args.Response.ReasonPhrase : "Unknown";
            _requestUri = args.Request?.Uri ?? "";
            
            // Determine if it's a document using the Sec-Fetch-Dest header
            string fetchDest = args.Request?.Headers?.GetHeader("Sec-Fetch-Dest") ?? "";
            _isDocument = fetchDest.Equals("document", StringComparison.OrdinalIgnoreCase);
            
            // Fallback: If it's a top-level document, sometimes Sec-Fetch-Dest is missing or different in very old environments.
            // But for Chromium (WebView2), "document" is the standard for the main page navigation.

            InitializeSender(parentHandle);
        }

        public int StatusCode => _statusCode;
        public string ReasonPhrase => _reasonPhrase;
        public string RequestUri => _requestUri;
        public bool IsDocument => _isDocument;
    }
}
