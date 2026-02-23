using System;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NetWebView2Lib
{
    [Guid("12345678-ABCD-1234-EF00-1234567890AB")] // New GUID
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IWebView2Frame
    {
        [DispId(1)] string Name { get; }
        [DispId(2)] void ExecuteScript(string script);
        [DispId(3)] void PostWebMessageAsJson(string webMessageAsJson);
        [DispId(4)] void PostWebMessageAsString(string webMessageAsString);
        [DispId(5)] bool IsDestroyed { get; }
        [DispId(6)] string ExecuteScriptWithResult(string script);
        [DispId(7)] void AddHostObjectToScript(string name, object rawObject);
        [DispId(8)] void RemoveHostObjectFromScript(string name);
        [DispId(9)] uint FrameId { get; }
        [DispId(10)] string Source { get; }
    }

    [ClassInterface(ClassInterfaceType.None)]
    [ComVisible(true)]
    [Guid("87654321-DCBA-4321-00FE-BA0987654321")] // New GUID
    [ProgId("NetWebView2Lib.WebView2Frame")]
    public class WebView2Frame : IWebView2Frame
    {
        private readonly Microsoft.Web.WebView2.Core.CoreWebView2Frame _frame;
        private readonly WebView2Manager _manager;

        public WebView2Frame(Microsoft.Web.WebView2.Core.CoreWebView2Frame frame, WebView2Manager manager = null)
        {
            _frame = frame;
            _manager = manager;
        }

        public string Name
        {
            get 
            {
                try { return _frame.Name; }
                catch { return ""; }
            }
        }

        public uint FrameId
        {
            get
            {
                try { return _frame.FrameId; }
                catch { return 0; }
            }
        }

        public string Source
        {
            get
            {
                if (_manager != null) return _manager.GetFrameUrlByObject(_frame);
                try { return _frame.GetType().GetProperty("Source")?.GetValue(_frame) as string ?? "unknown"; }
                catch { return "unknown"; }
            }
        }

        public void ExecuteScript(string script)
        {
            if (IsDestroyed) return;
            try { _frame.ExecuteScriptAsync(script); } catch { }
        }

        public string ExecuteScriptWithResult(string script)
        {
            if (IsDestroyed) return "ERROR: Frame Destroyed";
            try 
            { 
                 var task = _frame.ExecuteScriptAsync(script);
                 return WaitAndGetResult(task);
            } 
            catch (Exception ex) { return "ERROR: " + ex.Message; }
        }

        public void AddHostObjectToScript(string name, object rawObject)
        {
            if (IsDestroyed) return;
            try { _frame.AddHostObjectToScript(name, rawObject, new string[] { "*" }); } catch { }
        }

        public void RemoveHostObjectFromScript(string name)
        {
            if (IsDestroyed) return;
            try { _frame.RemoveHostObjectFromScript(name); } catch { }
        }

        private T WaitAndGetResult<T>(Task<T> task, int timeoutSeconds = 20)
        {
            var start = DateTime.Now;
            while (!task.IsCompleted)
            {
                Application.DoEvents();
                if ((DateTime.Now - start).TotalSeconds > timeoutSeconds) throw new TimeoutException("Operation timed out.");
                System.Threading.Thread.Sleep(1);
            }
            if (task.IsFaulted && task.Exception != null) throw task.Exception.InnerException;
            return task.Result;
        }

        public void PostWebMessageAsJson(string webMessageAsJson)
        {
            if (IsDestroyed) return;
            try { _frame.PostWebMessageAsJson(webMessageAsJson); } catch { }
        }

        public void PostWebMessageAsString(string webMessageAsString)
        {
            if (IsDestroyed) return;
            try { _frame.PostWebMessageAsString(webMessageAsString); } catch { }
        }

        public bool IsDestroyed
        {
            get
            {
                try
                {
                    var x = _frame.Name;
                    return false;
                }
                catch
                {
                    return true;
                }
            }
        }

        public bool IsDestroyedMethod() => IsDestroyed;
    }
}
