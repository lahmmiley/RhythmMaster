import("UnityEngine")
import('UnityEngine.UI')

_print = print
print = function(msg)
    Debug.LogError(msg .. "\n" .. debug.traceback())
end
pError = function(msg)
    Debug.LogError(msg .. "\n" .. debug.traceback())
end

string.Empty = ""

math.round = function(value)
    return math.floor(value + 0.5)
end

IS_DEBUG = true

if IS_DEBUG then
    local mt = {
        __index = function(_, key)
            local info = debug.getinfo(2, "S")
            if info and info.what ~= "main" and info.what ~= "C" then
                pError("访问不存在的全局变量：" .. key)
            end
            return rawget(_G, key)
        end,
        __newindex = function(_, key, value)
            local info = debug.getinfo(2, "S")
            if info and info.what ~= "main" and info.what ~= "C" then
                pError("赋值不存在的全局变量：" .. key)
            end
            return rawset(_G, key, value)
        end
    }
    setmetatable(_G, mt)
end


Vector2One = Vector3(1, 1)
Vector2Zero = Vector3(0, 0)
Vector2Down = Vector3(0, -1)
Vector2Left = Vector3(-1, 0)
Vector2Up = Vector3(0, 1)
Vector2Right = Vector3(1, 0)
Vector2Middle = Vector3(0.5, 0.5)

Vector3One = Vector3(1, 1, 1)
Vector3Zero = Vector3(0, 0, 0)

Vector3OutOfView = Vector3(10000, 0, 0)

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
    PanelManager:GetInstance():Show(PanelId.rhythmWindow)
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
    local deltaTime = Time.deltaTime
    LTimer.realtimeSinceStartup = Time.realtimeSinceStartup * 1000
    -- print(LTimer.realtimeSinceStartup)
    LTimer:GetInstance():Update(deltaTime)
    GlobalEvent.frameUpdate:Dispatcher()
end

