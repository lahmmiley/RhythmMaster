using SLua;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

[CustomLuaClass]
public class Main : MonoBehaviour
{
    private LuaFunction _luaUpdate = null;

    public delegate void LoadLuaClassDelegate(string[] classPathArray);

    public static LoadLuaClassDelegate LoadLuaClass;

    void Awake()
    {
        Application.targetFrameRate = 30;
        LuaSvr svr = new LuaSvr();
        LuaSvr.mainState.loaderDelegate += LoadFile;
        LuaSvr.MainState luaState = LuaSvr.mainState;

        svr.init(null, () =>
        {
            svr.start("Main");
            LoadLuaClass.Invoke(GetLuaClassPathArray());
            _luaUpdate = LuaSvr.mainState.getFunction("Update");
            LuaFunction main = LuaSvr.mainState.getFunction("Main");
            main.call();
        });
    }

    private string[] GetLuaClassPathArray()
    {
        List<string> result = new List<string>();
        List<string> pathList = FileUtils.GetFilesRecursive(FileUtils.LUA_ROOT);
        for (int i = 0; i < pathList.Count; i++)
        {
            string path = pathList[i];
            if (!path.EndsWith(".lua"))
            {
                continue;
            }
            string fileName = FileUtils.GetFileName(path);
            path = path.Replace(FileUtils.LUA_ROOT, string.Empty);
            result.Add(path.Replace(".lua", string.Empty));
        }
        return result.ToArray();
    }

    private byte[] LoadFile(string name)
    {
        string path = FileUtils.LUA_ROOT + name + ".lua";
        return File.ReadAllBytes(path);
    }

    void Update()
    {
        if (_luaUpdate != null)
        {
            _luaUpdate.call();
        }
    }
}
