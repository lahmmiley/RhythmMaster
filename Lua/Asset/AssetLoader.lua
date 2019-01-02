AssetLoader = AssetLoader or BaseClass()

function AssetLoader:__init()
    if AssetLoader.Instance then
        pError("重复生成单例")
        return
    end
    AssetLoader.Instance = self
end

function AssetLoader:Load(path)
    local result = Resources.Load(path)--, GameObject)
    return result
end
