using System;
using System.Linq;
using Microsoft.Web.WebView2.Core;

namespace NetWebView2Lib
{
    public partial class WebView2Manager
    {
        #region 11. PUBLIC API: IFRAME MANAGEMENT
        private void RegisterFrame(CoreWebView2Frame frame)
        {
            lock (_frames)
            {
                _frames.Add(frame);
                lock (_frameUrls) { _frameUrls[frame] = "about:blank"; }
                frame.Destroyed += (s, e) => 
                {
                    InvokeOnUiThread(() => OnFrameDestroyed?.Invoke(this, FormatHandle(_parentHandle), new WebView2Frame(frame, this)));
                    lock (_frames) { _frames.Remove(frame); }
                    lock (_frameUrls) { _frameUrls.Remove(frame); }
                };

                frame.NameChanged += (s, e) => InvokeOnUiThread(() => OnFrameNameChanged?.Invoke(this, FormatHandle(_parentHandle), new WebView2Frame(frame, this)));

                frame.NavigationStarting += (s, e) =>
                {
                   lock (_frameUrls) { _frameUrls[frame] = e.Uri; }
                   InvokeOnUiThread(() => OnFrameNavigationStarting?.Invoke(this, FormatHandle(_parentHandle), new WebView2Frame(frame, this), e.Uri));
                };
                frame.NavigationCompleted += (s, e) => 
                {
                    if (e.IsSuccess) { lock (_frameUrls) { _frameUrls[frame] = frame.GetType().GetProperty("Source")?.GetValue(frame) as string ?? _frameUrls[frame]; } }
                    InvokeOnUiThread(() => OnFrameNavigationCompleted?.Invoke(this, FormatHandle(_parentHandle), new WebView2Frame(frame, this), e.IsSuccess, (int)e.WebErrorStatus));
                };
                frame.ContentLoading += (s, e) => InvokeOnUiThread(() => OnFrameContentLoading?.Invoke(this, FormatHandle(_parentHandle), new WebView2Frame(frame, this), (long)e.NavigationId));
                frame.DOMContentLoaded += (s, e) => InvokeOnUiThread(() => OnFrameDOMContentLoaded?.Invoke(this, FormatHandle(_parentHandle), new WebView2Frame(frame, this), (long)e.NavigationId));
                frame.WebMessageReceived += (s, e) =>
                {
                   string msg = "";
                   try { msg = e.TryGetWebMessageAsString(); } catch { msg = e.WebMessageAsJson; }
                   InvokeOnUiThread(() => OnFrameWebMessageReceived?.Invoke(this, FormatHandle(_parentHandle), new WebView2Frame(frame, this), msg));
                };
                frame.PermissionRequested += (s, e) => InvokeOnUiThread(() => OnFramePermissionRequested?.Invoke(this, FormatHandle(_parentHandle), new WebView2Frame(frame, this), new WebView2PermissionRequestedEventArgsWrapper(e, _parentHandle)));
            }
        }

        internal string GetFrameUrlByObject(CoreWebView2Frame frame)
        {
            lock (_frameUrls) { return _frameUrls.TryGetValue(frame, out var url) ? url : "about:blank"; }
        }

        public int GetFrameCount() { lock (_frames) return _frames.Count; }

        public string GetFrameUrl(int index)
        {
            lock (_frames)
            {
                if (index < 0 || index >= _frames.Count) return "ERROR: Invalid frame index";
                lock (_frameUrls) { return _frameUrls.TryGetValue(_frames[index], out var url) ? url : "about:blank"; }
            }
        }

        public string GetFrameName(int index)
        {
            lock (_frames) { if (index < 0 || index >= _frames.Count) return "ERROR: Invalid frame index"; try { return _frames[index].Name; } catch { return "ERROR: Access failed"; } }
        }

        public object GetFrame(int index)
        {
            lock (_frames) { if (index < 0 || index >= _frames.Count) return null; try { return new WebView2Frame(_frames[index], this); } catch { return null; } }
        }

        public string GetFrameUrls()
        {
            lock (_frames) { lock (_frameUrls) { var urls = _frames.Select(f => _frameUrls.TryGetValue(f, out var url) ? url : "about:blank"); return string.Join("|", urls); } }
        }

        public string GetFrameNames()
        {
            lock (_frames) { var names = _frames.Select(f => { try { return f.Name; } catch { return "ERROR"; } }); return string.Join("|", names); }
        }

        public async void GetFrameHtmlSource(int index)
        {
            CoreWebView2Frame frame = null;
            lock (_frames) { if (index >= 0 && index < _frames.Count) frame = _frames[index]; }
            if (frame == null) { OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), $"ERROR|FRAME_NOT_FOUND:{index}"); return; }
            try {
                string html = await frame.ExecuteScriptAsync("document.documentElement.outerHTML");
                InvokeOnUiThread(() => OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), $"FRAME_HTML_SOURCE|{index}|" + CleanJsString(html)));
            }
            catch (Exception ex) { OnMessageReceived?.Invoke(this, FormatHandle(_parentHandle), $"ERROR|FRAME_HTML_FAILED|{index}|" + ex.Message); }
        }

        public object GetFrameById(uint frameId)
        {
            lock (_frames)
            {
                var frame = _frames.FirstOrDefault(f => {
                    try { return f.FrameId == frameId; }
                    catch { return false; }
                });
                return frame != null ? new WebView2Frame(frame, this) : null;
            }
        }
        #endregion
    }
}
