AssetLoader = AssetLoader or BaseClass()

function AssetLoader:GetInstance()
    if self._instance == nil then
        self._instance = AssetLoader.New()
    end
    return self._instance
end

function AssetLoader:__init()
end

function AssetLoader:Load(path)
    local result = Resources.Load(path)
    return result
end
