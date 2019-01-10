UIPrefabLoader = UIPrefabLoader or BaseClass()

function UIPrefabLoader:GetInstance()
    if self._instance == nil then
        self._instance = UIPrefabLoader.New()
    end
    return self._instance
end

function UIPrefabLoader:__init()
end

function UIPrefabLoader:Load(path)
    local prefab = AssetLoader:GetInstance():Load(AssetType.ToLogicPath(path, AssetType.uiPrefab))
    local go = GameObject.Instantiate(prefab)
    return go
end