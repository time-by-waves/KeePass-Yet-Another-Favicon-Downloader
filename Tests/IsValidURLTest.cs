using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Reflection;
using YetAnotherFaviconDownloader;

namespace Tests
{
    [TestClass]
    public class IsValidURLTest
    {
        private static bool InvokeIsValidURL(FaviconDownloader fd,
                                             ref string url,
                                             string prefix = "http://")
        {
            const BindingFlags bf = BindingFlags.NonPublic | BindingFlags.Instance;
            MethodInfo mi = typeof(FaviconDownloader)
                            .GetMethod("IsValidURL", bf);
            object[] args = { url, prefix };
            bool result = (bool)mi.Invoke(fd, args);
            url = (string)args[0];
            return result;
        }

        /// <summary>
        /// Tests valid HTTP/HTTPS URLs, including those with user information to be stripped.
        /// Per RFC 3986 section 3.2.1, user information is removed.
        /// </summary>
        [DataTestMethod]
        [DataRow("http://user:pass@www.example.com/favicon.ico", "http://", "http://www.example.com/favicon.ico")]
        [DataRow("https://admin:1234@mysite.org/", "https://", "https://mysite.org/")]
        [DataRow("https://docs.microsoft.com/", "https://", "https://docs.microsoft.com/")]
        public void StripUserInfo_ValidTheory(string inputUrl, string prefix, string expectedUrl)
        {
            string url = inputUrl;
            using (var fd = new FaviconDownloader())
            {
                bool ok = InvokeIsValidURL(fd, ref url, prefix);
                Assert.IsTrue(ok, "URL should be valid");
                Assert.AreEqual(expectedUrl, url, "Credentials not stripped correctly");
            }
        }
    }
}
