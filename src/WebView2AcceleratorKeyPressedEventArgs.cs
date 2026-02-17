using Microsoft.Web.WebView2.Core;
using System;
using System.Runtime.InteropServices;

namespace NetWebView2Lib
{
    /// <summary>
    /// Event arguments for AcceleratorKeyPressed event, wrapped for COM visibility.
    /// v2.0.0-beta.3: Added PhysicalKeyStatus fields.
    /// </summary>
    [Guid("9A8B7C6D-5E4F-3A2B-1C0D-9E8F7A6B5C4D")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IWebView2AcceleratorKeyPressedEventArgs
    {
        [DispId(1)] uint VirtualKey { get; }
        [DispId(2)] int KeyEventLParam { get; }
        [DispId(3)] int KeyEventKind { get; }
        [DispId(4)] object Handled { get; set; }
        [DispId(5)] void Block();
        
        // PhysicalKeyStatus Fields (Flattened for COM/AutoIt)
        [DispId(6)] uint RepeatCount { get; }
        [DispId(7)] uint ScanCode { get; }
        [DispId(8)] bool IsExtendedKey { get; }
        [DispId(9)] bool IsMenuKeyDown { get; }
        [DispId(10)] bool WasKeyDown { get; }
        [DispId(11)] bool IsKeyReleased { get; }
    }

    /// <summary>
    /// Wrapper for CoreWebView2AcceleratorKeyPressedEventArgs.
    /// </summary>
    [Guid("E1F2A3B4-C5D6-4E7F-8A9B-0C1D2E3F4A5B")]
    [ClassInterface(ClassInterfaceType.None)]
    [ComVisible(true)]
    public class WebView2AcceleratorKeyPressedEventArgs : IWebView2AcceleratorKeyPressedEventArgs
    {
        private readonly CoreWebView2AcceleratorKeyPressedEventArgs _args;
        private readonly WebView2Manager _manager;

        public uint VirtualKey { get; }
        public int KeyEventLParam { get; }
        public int KeyEventKind { get; }
        
        public uint RepeatCount { get; }
        public uint ScanCode { get; }
        public bool IsExtendedKey { get; }
        public bool IsMenuKeyDown { get; }
        public bool WasKeyDown { get; }
        public bool IsKeyReleased { get; }

        private volatile bool _handled = false;
        public object Handled 
        { 
            get => _handled;
            set 
            {
                try {
                    _handled = Convert.ToBoolean(value);
                    if (_handled) _args.Handled = true; 
                } catch {
                    _handled = false;
                }
            }
        }

        public void Block()
        {
            _handled = true;
            try { _args.Handled = true; } catch { }
        }

        public WebView2AcceleratorKeyPressedEventArgs(CoreWebView2AcceleratorKeyPressedEventArgs args, WebView2Manager manager)
        {
            _args = args;
            _manager = manager;
            VirtualKey = args.VirtualKey;
            KeyEventLParam = args.KeyEventLParam;
            KeyEventKind = (int)args.KeyEventKind;
            _handled = args.Handled;

            // Map PhysicalKeyStatus
            var status = args.PhysicalKeyStatus;
            RepeatCount = (uint)status.RepeatCount;
            ScanCode = (uint)status.ScanCode;
            IsExtendedKey = status.IsExtendedKey != 0;
            IsMenuKeyDown = status.IsMenuKeyDown != 0;
            WasKeyDown = status.WasKeyDown != 0;
            IsKeyReleased = status.IsKeyReleased != 0;
        }

        // Internal helper for checking handled state in the event loop
        internal bool IsCurrentlyHandled => _handled;
    }
}
