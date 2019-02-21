UIPrefabLoader = UIPrefabLoader or BaseClass()

function UIPrefabLoader.GetInstance()
    if UIPrefabLoader._instance == nil then
        UIPrefabLoader._instance = UIPrefabLoader.New()
    end
    return UIPrefabLoader._instance
end

function UIPrefabLoader:__init()
end

function UIPrefabLoader:Load(path)
    local prefab = AssetLoader.GetInstance():Load(AssetType.ToLogicPath(path, AssetType.uiPrefab))
    local go = GameObject.Instantiate(prefab)
    return go
end