RhythmWindow = RhythmWindow or BaseClass(LPanel)

function RhythmWindow:__init()
    self.frameUpdate = function() self:OnFrameUpdate() end
    self.state = RhythmDefine.State.prepare
    self.showRhythmItemList = {}
end

function RhythmWindow:__release()
    self:ReleaseField("rhythmItemPool")
    self:ReleaseField("rhythmPointObjectPool")
end

function RhythmWindow:InitPanel(gameObject)
    local transform = gameObject.transform
    self.matchTrans = transform:Find("Pipeline/Match")
    self.rhythmItemPool = ClassPool.New(RhythmItem)
    local template = transform:Find("RhythmPoint").gameObject
    self.rhythmPointObjectPool = ObjectPool.New(template)
end

function RhythmWindow:AddListener()
    GlobalEvent.frameUpdate:Add(self.frameUpdate)
end

function RhythmWindow:RemoveListener()
    GlobalEvent.frameUpdate:Remove(self.frameUpdate)
end

function RhythmWindow:OnFrameUpdate()
    if self.state ~= RhythmDefine.State.playing then
        return
    end
    local currentTime = self:GetMusicCurrentTime()
    local createdIndex = self.createdIndex
    for i = createdIndex, #rhythmConfigList do
        local config = rhythmConfigList[i]
        if currentTime >= config.time then
            self:CreateRhythmItem(config)
            self.createdIndex = i
        end
    end
end

function RhythmWindow:OnShow()
    self:Start()
end

function RhythmWindow:Start()
    local rhythmConfigList = RhythmConfigHelper.GetMusicRhythm(1)
    self.rhythmConfigList = rhythmConfigList
    self.startTime = LTimer.realtimeSinceStartup
    self.createdIndex = 0
    self.state = RhythmDefine.State.playing
end

function RhythmWindow:GetMusicCurrentTime()
    return LTimer.realtimeSinceStartup - self.startTime
end

function RhythmWindow:CountDown()
end

function RhythmWindow:CreateRhythmItem(config)
    local time = config.time - self.startTime
    local rhythmItem = self.rhythmItemPool:Get(config, self.rhythmPointObjectPool)
end
