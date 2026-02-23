using System;
using System.Runtime.InteropServices;

namespace NetWebView2Lib
{
    // --- 1. EVENTS INTERFACE (What C# sends to AutoIt) ---
    /// <summary>
    /// Events sent from C# to AutoIt.
    /// v2.0.0: All events now include sender and parentHandle for multi-instance support.
    /// </summary>
    [Guid("B2C3D4E5-F6A7-4B6C-9D0E-1F2A3B4C5D6E")]
    [InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
    [ComVisible(true)]
    public interface IWebViewEvents
    {
        /// <summary>Triggered when a message is sent from the WebView.</summary>
        /// <param name="sender">The WebViewManager instance.</param>
        /// <param name="parentHandle">The parent window handle.</param>
        /// <param name="message">The message content.</param>
        [DispId(1)] void OnMessageReceived(object sender, string parentHandle, string message);
        [DispId(2)] void OnNavigationStarting(object sender, string parentHandle, string url);
        [DispId(3)] void OnNavigationCompleted(object sender, string parentHandle, bool isSuccess, int webErrorStatus);
        [DispId(4)] void OnTitleChanged(object sender, string parentHandle, string newTitle);
        [DispId(5)] void OnWebResourceResponseReceived(object sender, string parentHandle, int statusCode, string reasonPhrase, string requestUrl);
        [DispId(6)] void OnContextMenu(object sender, string parentHandle, string menuData);
        [DispId(10)] void OnZoomChanged(object sender, string parentHandle, double factor);
        [DispId(11)] void OnBrowserGotFocus(object sender, string parentHandle, int reason);
        [DispId(12)] void OnBrowserLostFocus(object sender, string parentHandle, int reason);
        [DispId(13)] void OnURLChanged(object sender, string parentHandle, string newUrl);
        [DispId(190)] void OnContextMenuRequested(object sender, string parentHandle, string linkUrl, int x, int y, string selectionText);
        [DispId(208)] void OnDownloadStarting(object sender, string parentHandle, string uri, string defaultPath);
        [DispId(209)] void OnDownloadStateChanged(object sender, string parentHandle, string state, string uri, long totalBytes, long receivedBytes);
        [DispId(221)] void OnAcceleratorKeyPressed(object sender, string parentHandle, object args);
        [DispId(225)] void OnProcessFailed(object sender, string parentHandle, object args);
        [DispId(228)] void OnBasicAuthenticationRequested(object sender, string parentHandle, object args);
        [DispId(239)] void OnPermissionRequested(object sender, string parentHandle, object args);

        // --- FRAME EVENTS ---
        [DispId(229)] void OnFrameNavigationStarting(object sender, string parentHandle, object frame, string uri);
        [DispId(230)] void OnFrameNavigationCompleted(object sender, string parentHandle, object frame, bool isSuccess, int webErrorStatus);
        [DispId(231)] void OnFrameContentLoading(object sender, string parentHandle, object frame, long navigationId);
        [DispId(232)] void OnFrameDOMContentLoaded(object sender, string parentHandle, object frame, long navigationId);
        [DispId(233)] void OnFrameWebMessageReceived(object sender, string parentHandle, object frame, string message);
        [DispId(234)] void OnFrameCreated(object sender, string parentHandle, object frame);
        [DispId(235)] void OnFrameDestroyed(object sender, string parentHandle, object frame);
        [DispId(236)] void OnFrameNameChanged(object sender, string parentHandle, object frame);
        [DispId(238)] void OnFramePermissionRequested(object sender, string parentHandle, object frame, object args);
    }
}
