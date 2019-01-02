import("UnityEngine")
import('UnityEngine.UI')

_print = print
print = function(msg)
    Debug.LogError(msg .. "\n" .. debug.traceback())
end
pError = function(str)
    Debug.LogError(msg .. "\n" .. debug.traceback())
end

string.Empty = ""

math.round = function(value)
    return math.floor(value + 0.5)
end

Vector2One = Vector3(1, 1)
Vector2Zero = Vector3(0, 0)
Vector2Down = Vector3(0, -1)
Vector2Left = Vector3(-1, 0)
Vector2Up = Vector3(0, 1)
Vector2Right = Vector3(1, 0)

Vector3One = Vector3(1, 1, 1)
Vector3Zero = Vector3(0, 0, 0)

--优先加载的类路径数组
PriorClassPathArray = {
    "Base/BaseClass",
    "LComponent/LDefine",
    "LComponent/LItem",
    "LComponent/LTreeNode",
    "LComponent/LTreeNodeData",
    "LComponent/LPanel",
    "Util/UtilsTable",
}

Main.LoadLuaClass = function(classPathArray)
    for _, classPath in ipairs(PriorClassPathArray) do
        require(classPath)
    end
    local loadedClassPathDict = UtilsTable.ArrayToTable(PriorClassPathArray)
    loadedClassPathDict["Main"] = true

    for classPath in Slua.iter(classPathArray) do
        if not loadedClassPathDict[classPath] then
            require(classPath)
        end
    end
end

function Main()
    Init()
end

function Init()
    Tween.New()
    GlobalEvent.New()
    TimerHeap.New()
    AssetLoader.New()
    ModelLoader.New()
    UIEffectLoader.New()
    PanelManager.New()
end

function Update()
    if Input.GetKeyDown(KeyCode.H) and Input.GetKey(KeyCode.LeftControl) then
        print("热更完毕")
    end

    if Input.GetKeyDown(KeyCode.W) and Input.GetKey(KeyCode.LeftControl) then
        print("W")
        -- scrollViewTest.scrollView:Release()
        -- meshTest:DrawTriangle()
    end

    if Input.GetKeyDown(KeyCode.E) and Input.GetKey(KeyCode.LeftControl) then
        print("E")
    end
    TimerHeap.realtimeSinceStartup = Time.realtimeSinceStartup * 1000
    PanelManager.Instance:Update()
    TimerHeap.Instance:Update()
end