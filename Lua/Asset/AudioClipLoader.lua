AudioClipLoader = AudioClipLoader or BaseClass()

function AudioClipLoader.GetInstance()
    if AudioClipLoader._instance == nil then
        AudioClipLoader._instance = AudioClipLoader.New()
    end
    return AudioClipLoader._instance
end

function AudioClipLoader:LoadMusic(id)
    local config = RhythmConfig.Music[id]
    local path = AssetType.ToLogicPath(config.name, AssetType.music)
    return AssetLoader.GetInstance():Load(path)
end