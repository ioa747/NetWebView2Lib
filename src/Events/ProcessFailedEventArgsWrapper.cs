using System;
using System.Runtime.InteropServices;
using Microsoft.Web.WebView2.Core;

namespace NetWebView2Lib
{
    /// <summary>
    /// Event arguments for ProcessFailed event, wrapped for COM visibility.
    /// v2.0.0-beta.2
    /// </summary>
    [Guid("F3A4B5C6-D7E8-4F9A-0B1C-2D3E4F5A6B7C")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IProcessFailedEventArgs : IBaseWebViewEventArgs
    {
        [DispId(1)] int ProcessFailedKind { get; }
        [DispId(2)] int Reason { get; }
        [DispId(3)] int ExitCode { get; }
        [DispId(4)] string ProcessDescription { get; }
    }

    /// <summary>
    /// Wrapper for CoreWebView2ProcessFailedEventArgs.
    /// </summary>
    [Guid("E2F3A4B5-C6D7-4E8F-9A0B-1C2D3E4F5A6B")]
    [ClassInterface(ClassInterfaceType.None)]
    [ComVisible(true)]
    public class ProcessFailedEventArgsWrapper : BaseWebViewEventArgs, IProcessFailedEventArgs
    {
        public int ProcessFailedKind { get; }
        public int Reason { get; }
        public int ExitCode { get; }
        public string ProcessDescription { get; }

        /// <summary>
        /// Default constructor for COM compatibility.
        /// </summary>
        public ProcessFailedEventArgsWrapper() { }

        public ProcessFailedEventArgsWrapper(CoreWebView2ProcessFailedEventArgs args, IntPtr senderHandle)
        {
            InitializeSender(senderHandle);
            ProcessFailedKind = (int)args.ProcessFailedKind;
            Reason = (int)args.Reason;
            ExitCode = args.ExitCode;
            ProcessDescription = args.ProcessDescription;
        }
    }
}
