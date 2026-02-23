using System;
using System.Runtime.InteropServices;
using System.Threading.Tasks;

namespace NetWebView2Lib
{
    public partial class WebView2Manager
    {
        #region 3. NATIVE METHODS & HELPERS
        [DllImport("user32.dll")]
        private static extern bool GetClientRect(IntPtr hWnd, out Rect lpRect);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);

        [DllImport("user32.dll")]
        private static extern IntPtr GetFocus();

        [DllImport("user32.dll")]
        private static extern bool IsChild(IntPtr hWndParent, IntPtr hWnd);

        /// <summary>
        /// A simple Rectangle struct.
        /// </summary>
        [StructLayout(LayoutKind.Sequential)]
        public struct Rect { 
            public int Left;
            public int Top; 
            public int Right; 
            public int Bottom; 
        }
        #endregion

        #region 17. HELPER METHODS
        private void Log(string message)
        {
            if (_verbose)
            {
                string h = FormatHandle(_parentHandle);
                Console.WriteLine($"+++[NetWebView2Lib]{h}[{DateTime.Now:HH:mm:ss.fff}] {message}");
            }
        }

        private T RunOnUiThread<T>(Func<T> func)
        {
            if (_webView == null || _webView.IsDisposed) return default;
            if (_webView.InvokeRequired) return (T)_webView.Invoke(func);
            return func();
        }

        private void InvokeOnUiThread(Action action)
        {
            if (_webView == null || _webView.IsDisposed) return;
            if (_webView.InvokeRequired) _webView.Invoke(action);
            else action();
        }

        private T WaitAndGetResult<T>(Task<T> task, int timeoutSeconds = 20)
        {
            var start = DateTime.Now;
            while (!task.IsCompleted)
            {
                System.Windows.Forms.Application.DoEvents();
                if ((DateTime.Now - start).TotalSeconds > timeoutSeconds) throw new TimeoutException("Operation timed out.");
                System.Threading.Thread.Sleep(1);
            }
            return task.Result;
        }

        private void WaitTask(Task task, int timeoutSeconds = 20)
        {
            var start = DateTime.Now;
            while (!task.IsCompleted)
            {
                System.Windows.Forms.Application.DoEvents();
                if ((DateTime.Now - start).TotalSeconds > timeoutSeconds) throw new TimeoutException("Operation timed out.");
                System.Threading.Thread.Sleep(1);
            }
            if (task.IsFaulted && task.Exception != null) throw task.Exception.InnerException;
        }

        public string EncodeURI(string value) => string.IsNullOrEmpty(value) ? "" : System.Net.WebUtility.UrlEncode(value);
        public string DecodeURI(string value) => string.IsNullOrEmpty(value) ? "" : System.Net.WebUtility.UrlDecode(value);
        public string EncodeB64(string value) => string.IsNullOrEmpty(value) ? "" : Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(value));

        /// <summary>Decodes a Base64-encoded string into a byte array.</summary>
        public byte[] DecodeB64ToBinary(string base64Text)
        {
            if (string.IsNullOrEmpty(base64Text)) return new byte[0];
            try { return Convert.FromBase64String(base64Text); }
            catch { return new byte[0]; }
        }

        /// <summary>Encodes raw binary data (byte array) to a Base64 string.</summary>
        public string EncodeBinaryToB64(object binaryData)
        {
            if (binaryData is byte[] bytes) return Convert.ToBase64String(bytes);
            return "";
        }

        public string DecodeB64(string value)
        {
            if (string.IsNullOrEmpty(value)) return "";
            try { return System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(value)); }
            catch { return ""; }
        }

        private string CleanJsString(string input)
        {
            if (string.IsNullOrEmpty(input)) return "";
            string decoded = System.Text.RegularExpressions.Regex.Unescape(input);
            if (decoded.StartsWith("\"") && decoded.EndsWith("\"") && decoded.Length >= 2) decoded = decoded.Substring(1, decoded.Length - 2);
            return decoded;
        }

        private string GetReasonPhrase(int statusCode, string originalReason)
        {
            if (!string.IsNullOrEmpty(originalReason)) return originalReason;
            switch (statusCode)
            {
                case 200: return "OK";
                case 201: return "Created";
                case 204: return "No Content";
                case 301: return "Moved Permanently";
                case 302: return "Found";
                case 304: return "Not Modified";
                case 400: return "Bad Request";
                case 401: return "Unauthorized";
                case 403: return "Forbidden";
                case 404: return "Not Found";
                case 429: return "Too Many Requests";
                case 500: return "Internal Server Error";
                case 502: return "Bad Gateway";
                case 503: return "Service Unavailable";
                case 504: return "Gateway Timeout";
                default: 
                    try { return ((System.Net.HttpStatusCode)statusCode).ToString(); }
                    catch { return "Unknown"; }
            }
        }
        #endregion
    }
}
