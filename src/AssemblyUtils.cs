using System.Reflection;
using System.Runtime.InteropServices;

namespace NetWebView2Lib
{
    /// <summary>
    /// Helper class to retrieve assembly metadata.
    /// </summary>
    internal static class AssemblyUtils
    {
        public static string GetVersion()
        {
            try
            {
                // Try to get AssemblyInformationalVersion first
                var attribute = (AssemblyInformationalVersionAttribute)Assembly.GetExecutingAssembly()
                    .GetCustomAttribute(typeof(AssemblyInformationalVersionAttribute));
                
                if (attribute != null && !string.IsNullOrEmpty(attribute.InformationalVersion))
                {
                    return attribute.InformationalVersion;
                }
            }
            catch { }

            // Fallback to AssemblyVersion
            return Assembly.GetExecutingAssembly().GetName().Version.ToString();
        }
    }
}
