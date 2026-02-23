using System;
using System.Runtime.InteropServices;
using Microsoft.Web.WebView2.Core;

namespace NetWebView2Lib
{
    [Guid("E2A3B4C5-D6E7-4F8A-9B0C-1D2E3F4A5B6C")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IWebView2PermissionRequestedEventArgs : IBaseWebViewEventArgs
    {
        [DispId(1)] bool Handled { get; set; }
        [DispId(2)] bool IsUserInitiated { get; }
        [DispId(3)] int PermissionKind { get; }
        [DispId(4)] int State { get; set; }
        [DispId(5)] string Uri { get; }
        [DispId(20)] void GetDeferral();
        [DispId(21)] void Complete();
    }

    [ClassInterface(ClassInterfaceType.None)]
    [ComVisible(true)]
    [Guid("9C727559-5496-44B0-AB1B-1977CF83ADB0")] // Updated Guid
    public class WebView2PermissionRequestedEventArgsWrapper : BaseWebViewEventArgs, IWebView2PermissionRequestedEventArgs
    {
        private readonly CoreWebView2PermissionRequestedEventArgs _args;
        private CoreWebView2Deferral _deferral;

        public WebView2PermissionRequestedEventArgsWrapper(CoreWebView2PermissionRequestedEventArgs args, IntPtr parentHandle)
        {
            _args = args;
            InitializeSender(parentHandle);
        }

        public bool Handled
        {
            get => _args.Handled;
            set => _args.Handled = value;
        }

        public bool IsUserInitiated => _args.IsUserInitiated;

        public int PermissionKind => (int)_args.PermissionKind;

        public int State
        {
            get => (int)_args.State;
            set => _args.State = (CoreWebView2PermissionState)value;
        }

        public string Uri => _args.Uri;

        public void GetDeferral()
        {
            if (_deferral == null)
            {
                _deferral = _args.GetDeferral();
            }
        }

        public void Complete()
        {
            if (_deferral != null)
            {
                _deferral.Complete();
            }
        }
    }
}
