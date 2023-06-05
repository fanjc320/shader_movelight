using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace ES30
{
    internal class ES30e
    {
        [DllImport("kernel32.dll", CharSet = CharSet.Ansi, SetLastError = true)]
        public static extern IntPtr GetModuleHandleA(string dllToLoad);

        [DllImport("kernel32.dll", CharSet = CharSet.Ansi, SetLastError = true)]
        public static extern IntPtr LoadLibraryA(string dllToLoad);

        [DllImport("kernel32.dll", CharSet = CharSet.Ansi, SetLastError = true)]
        public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);

        delegate IntPtr delewglGetProcAddress(IntPtr pstr);
        static delewglGetProcAddress wglGetProcAddress = null;

        static IntPtr gl;
        public static IntPtr GetGLProc(string name)
        {
            if (gl == IntPtr.Zero)
                gl = GetModuleHandleA("opengl32.dll");
            if (wglGetProcAddress == null)
            {
                IntPtr wgl = GetProcAddress(gl, "wglGetProcAddress");
                wglGetProcAddress = Marshal.GetDelegateForFunctionPointer<delewglGetProcAddress>(wgl);
            }


            IntPtr pstr = Marshal.StringToHGlobalAnsi(name);
            IntPtr res = wglGetProcAddress(pstr);
            Marshal.FreeHGlobal(pstr);
            if (res != IntPtr.Zero)
            {
                //UnityEngine.Debug.Log("init from wglGetProcAddress:" + name);
                return res;
            }

            res = GetProcAddress(gl, name);
            if (res != IntPtr.Zero)
            {
                //UnityEngine.Debug.Log("init from GetProcAddress:" + name);
                return res;
            }


            UnityEngine.Debug.Log("not found:" + name);

            return IntPtr.Zero;
        }

    }
}
