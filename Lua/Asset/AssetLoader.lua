AssetLoader = AssetLoader or BaseClass()

function AssetLoader.GetInstance()
    if AssetLoader._instance == nil then
        AssetLoader._instance = AssetLoader.New()
    end
    return AssetLoader._instance
end

function AssetLoader:__init()
end

function AssetLoader:Load(path)
    local result = Resources.Load(path)
    return result
end
