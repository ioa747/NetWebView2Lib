using System;
using System.Runtime.InteropServices;
using Microsoft.Web.WebView2.Core;

namespace NetWebView2Lib
{
    [Guid("D3C9B2A1-E4F5-4B6C-8D9E-0F1A2B3C4D5E")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IWebView2DownloadStartingEventArgs : IBaseWebViewEventArgs
    {
        [DispId(1)] string Uri { get; }
        [DispId(2)] string ResultFilePath { get; set; }
        [DispId(3)] bool Handled { get; set; }
        [DispId(4)] bool Cancel { get; set; }
        [DispId(5)] string MimeType { get; }
        [DispId(6)] string ContentDisposition { get; }
        [DispId(7)] long TotalBytesToReceive { get; }
    }

    [ClassInterface(ClassInterfaceType.None)]
    [ComVisible(true)]
    [Guid("B4D1E2F3-A4C5-4B6C-9D0E-1F2A3B4C5D6E")]
    public class WebView2DownloadStartingEventArgsWrapper : BaseWebViewEventArgs, IWebView2DownloadStartingEventArgs
    {
        private readonly CoreWebView2DownloadStartingEventArgs _args;
        private string _resultFilePath;
        private bool _handled;
        private bool _cancel;

        public WebView2DownloadStartingEventArgsWrapper(CoreWebView2DownloadStartingEventArgs args, IntPtr parentHandle)
        {
            _args = args;
            _resultFilePath = args.ResultFilePath;
            _handled = args.Handled;
            _cancel = args.Cancel;
            InitializeSender(parentHandle);
        }

        public string Uri => _args.DownloadOperation.Uri;

        public string ResultFilePath
        {
            get => _resultFilePath;
            set => _resultFilePath = value;
        }

        public bool Handled
        {
            get => _handled;
            set => _handled = value;
        }

        public bool Cancel
        {
            get => _cancel;
            set => _cancel = value;
        }

        public string MimeType => _args.DownloadOperation.MimeType;

        public string ContentDisposition => _args.DownloadOperation.ContentDisposition;

        public long TotalBytesToReceive => _args.DownloadOperation.TotalBytesToReceive.HasValue ? (long)_args.DownloadOperation.TotalBytesToReceive.Value : -1L;
    }
}
