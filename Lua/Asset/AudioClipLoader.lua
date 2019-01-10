AudioClipLoader = AudioClipLoader or BaseClass()

function AudioClipLoader:GetInstance()
    if self._instance == nil then
        self._instance = AudioClipLoader.New()
    end
    return self._instance
end

function AudioClipLoader:LoadMusic(id)
end