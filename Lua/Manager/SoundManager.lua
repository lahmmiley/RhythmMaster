SoundManager = SoundManager or BaseClass()

function SoundManager:GetInstance()
    if self._instance == nil then
        self._instance = SoundManager.New()
    end
    return self._instance
end

function SoundManager:__init()
    local go = GameObject.Find("AudioSource").gameObject
    self.audioSourceGo = go
    DontDestroyOnLoad(go)
    self.musicAudioSource = go:GetComponent(AudioSource)
    self.soundAudioSourceList = {}
end

function SoundManager:PlayMusic(id)
    -- self.musicAudioSource 
end

function SoundManager:PlaySound(id)
end
