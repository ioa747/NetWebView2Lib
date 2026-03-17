using System;
using System.Runtime.InteropServices;
using Microsoft.Web.WebView2.Core;

namespace NetWebView2Lib
{
    [Guid("D2B8A1C4-F5E6-4A5B-9C1D-8E1F2A3B4C5D")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IWebView2NavigationStartingEventArgs : IBaseWebViewEventArgs
    {
        [DispId(1)] string Uri { get; }
        [DispId(2)] bool IsUserInitiated { get; }
        [DispId(3)] bool IsRedirected { get; }
        [DispId(4)] object RequestHeaders { get; }
        [DispId(5)] bool Cancel { get; set; }
        [DispId(6)] long NavigationId { get; }
        [DispId(7)] int NavigationKind { get; }
        [DispId(8)] string AdditionalAllowedFrameAncestors { get; set; }
    }

    [ClassInterface(ClassInterfaceType.None)]
    [ComVisible(true)]
    [Guid("E3C4D5F6-A7B8-4C9D-0E1F-2A3B4C5D6E7F")] // Unique GUID for this wrapper
    public class WebView2NavigationStartingEventArgsWrapper : BaseWebViewEventArgs, IWebView2NavigationStartingEventArgs
    {
        private readonly CoreWebView2NavigationStartingEventArgs _args;

        public WebView2NavigationStartingEventArgsWrapper(CoreWebView2NavigationStartingEventArgs args, IntPtr parentHandle)
        {
            _args = args;
            InitializeSender(parentHandle);
        }

        public string Uri => _args.Uri;
        public bool IsUserInitiated => _args.IsUserInitiated;
        public bool IsRedirected => _args.IsRedirected;
        public object RequestHeaders => _args.RequestHeaders;
        public bool Cancel 
        { 
            get => _args.Cancel; 
            set => _args.Cancel = value; 
        }
        public long NavigationId => (long)_args.NavigationId;
        public int NavigationKind => (int)_args.NavigationKind;
        public string AdditionalAllowedFrameAncestors 
        { 
            get => _args.AdditionalAllowedFrameAncestors; 
            set => _args.AdditionalAllowedFrameAncestors = value; 
        }
    }
}
