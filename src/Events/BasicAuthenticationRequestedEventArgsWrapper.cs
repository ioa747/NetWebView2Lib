using System.Runtime.InteropServices;
using System;
using Microsoft.Web.WebView2.Core;

namespace NetWebView2Lib
{
    /// <summary>
    /// Interface for BasicAuthenticationRequested event arguments.
    /// </summary>
    [Guid("A1B2C3D4-E5F6-4A5B-9C8D-7E6F5A4B3C2D")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IBasicAuthenticationRequestedEventArgs : IBaseWebViewEventArgs
    {
        [DispId(1)] string Uri { get; }
        [DispId(2)] string Challenge { get; }
        [DispId(3)] bool Cancel { get; set; }
        [DispId(4)] string UserName { get; set; }
        [DispId(5)] string Password { get; set; }
        [DispId(6)] void Complete();
    }

    /// <summary>
    /// Wrapper for CoreWebView2BasicAuthenticationRequestedEventArgs to support COM/AutoIt.
    /// Includes support for Deferral to allow asynchronous credential gathering.
    /// </summary>
    [Guid("B1C2D3E4-F5A6-4B7C-8D9E-0F1A2B3C4D5E")]
    [ClassInterface(ClassInterfaceType.None)]
    [ComVisible(true)]
    public class BasicAuthenticationRequestedEventArgsWrapper : BaseWebViewEventArgs, IBasicAuthenticationRequestedEventArgs
    {
        private readonly CoreWebView2BasicAuthenticationRequestedEventArgs _args;
        private readonly CoreWebView2Deferral _deferral;

        public string Uri => _args.Uri;
        public string Challenge => _args.Challenge;

        public bool Cancel
        {
            get => _args.Cancel;
            set => _args.Cancel = value;
        }

        public string UserName
        {
            get => _args.Response.UserName;
            set => _args.Response.UserName = value;
        }

        public string Password
        {
            get => _args.Response.Password;
            set => _args.Response.Password = value;
        }

        /// <summary>
        /// Default constructor for COM compatibility.
        /// </summary>
        public BasicAuthenticationRequestedEventArgsWrapper() { }

        public BasicAuthenticationRequestedEventArgsWrapper(CoreWebView2BasicAuthenticationRequestedEventArgs args, IntPtr senderHandle)
        {
            InitializeSender(senderHandle);
            _args = args;
            _deferral = args.GetDeferral();
        }

        /// <summary>
        /// Completes the deferral, notifying WebView2 that authentication is finished.
        /// </summary>
        public void Complete()
        {
            try
            {
                _deferral?.Complete();
            }
            catch (Exception ex)
            {
                // Log or handle deferral completion error if necessary
                System.Diagnostics.Debug.WriteLine("BasicAuth Deferral Completion Error: " + ex.Message);
            }
        }
    }
}
