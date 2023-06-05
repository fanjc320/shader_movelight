using OpenTK.Graphics.ES30;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.Rendering;

namespace Assets
{
    public static class GLES3_Unity
    {
        delegate void deleNativeCall(int eid);
        static IntPtr unsafeptr_update;
        static GLES3_Unity()
        {
            unsafeptr_update = Marshal.GetFunctionPointerForDelegate<deleNativeCall>(OnRenderThreadUpdate);
            var unsafeinit = Marshal.GetFunctionPointerForDelegate<deleNativeCall>(OnRenderThreadInit);
            GL.IssuePluginEvent(unsafeinit, 001);
        }
        /// <summary>
        /// 注意,这个方法是跑在渲染线程，无论如何不要在渲染线程引发异常
        /// </summary>
        public static event Action OnRenderUnsafe;
        public static event Action OnInitUnsafe;
        static void OnRenderThreadInit(int eventid)
        {
            try
            {
                InitGLES();
                OnInitUnsafe();
            }
            catch
            {

            }
        }
        static void OnRenderThreadUpdate(int eventid)
        {
            try
            {
                OnRenderUnsafe();
            }
            catch
            {

            }
        }
        static CommandBuffer cmdupdate;
        public static void Init(RenderTexture rt)
        {
            if (inited)
                return;
            Debug.Log("GLES3 Unity Init.");
            unsafeptr_update = Marshal.GetFunctionPointerForDelegate<deleNativeCall>(OnRenderThreadUpdate);
            var unsafeinit = Marshal.GetFunctionPointerForDelegate<deleNativeCall>(OnRenderThreadInit);
            cmdupdate = new CommandBuffer();
            cmdupdate.SetRenderTarget(rt);

            Camera.main.AddCommandBuffer(CameraEvent.AfterEverything, cmdupdate);

            cmdupdate.IssuePluginEvent(unsafeinit, 001);
        }
        public static void OnFrame()
        {
            if (!inited)
                throw new Exception("has not inited.");
            cmdupdate.IssuePluginEvent(unsafeptr_update, 002);
            //GL.IssuePluginEvent(unsafeptr_update, 002);
        }


        delegate IntPtr deleGLGetString(int type);
        static deleGLGetString glGetString;
        delegate int deleglGetIntegerv(int type);
        static deleglGetIntegerv glGetIntegerv;
        delegate void deleGLClear(int mask);
        static deleGLClear glClear;
        delegate void deleGLClearColor(float red, float green, float blue, float alpha);
        static deleGLClearColor glClearColor;

        static bool inited = false;
        public static bool Inited
        {
            get
            {
                return inited;
            }
        }
      
        static void InitGLES()
        {
            if (inited)
                return;
            IntPtr addr_glGetString = ES30.ES30e.GetGLProc("glGetString");
            IntPtr addr_glClear = ES30.ES30e.GetGLProc("glClear");
            IntPtr addr_glClearColor = ES30.ES30e.GetGLProc("glClearColor");
            IntPtr addr_glGetIntegerv = ES30.ES30e.GetGLProc("glGetIntegerv");
            ES30.ES30e.GetGLProc("glCreateProgram");
            ES30.ES30e.GetGLProc("glCreateShader");
            glGetString = Marshal.GetDelegateForFunctionPointer<deleGLGetString>(addr_glGetString);
            glClear = Marshal.GetDelegateForFunctionPointer<deleGLClear>(addr_glClear);
            glClearColor = Marshal.GetDelegateForFunctionPointer<deleGLClearColor>(addr_glClearColor);
            glGetIntegerv = Marshal.GetDelegateForFunctionPointer<deleglGetIntegerv>(addr_glGetIntegerv);

            inited = true;
        }
        public static string R_GetVersion()
        {
            var str = glGetString((int)All.Version);
            string ver = Marshal.PtrToStringAnsi(str);

            return ver;
        }
        public static void R_Clear()
        {
            glClearColor(1.0f, 0.5f, 1.0f, 1.0f);
            glClear((int)All.ColorBufferBit);
        }
    }
}
