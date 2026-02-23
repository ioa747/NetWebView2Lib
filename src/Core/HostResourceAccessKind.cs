using System.Runtime.InteropServices;

namespace NetWebView2Lib
{
    /// <summary>
    /// Resource access kind for Virtual Host Mapping.
    /// </summary>
    [ComVisible(true)]
    public enum HostResourceAccessKind
    {
        Allow = 0,
        Deny = 1,
        DenyCors = 2
    }
}
