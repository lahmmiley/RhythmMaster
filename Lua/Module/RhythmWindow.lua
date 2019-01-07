RhythmWindow = RhythmWindow or BaseClass(LPanel)

function RhythmWindow:__init()
    self.frameUpdate = function() self:OnFrameUpdate() end
    self.state = nil
end

function RhythmWindow:__release()
end

function RhythmWindow:InitPanel(gameObject)
    local transform = gameObject.transform
    self.drumButton = UtilsUI.GetButton(transform, "drum")
    self.redTemplate = transform:Find("Red").gameObject
    self.redTemplate:SetActive(false)
    self.blueTemplate = transform:Find("Blue").gameObject
    self.blueTemplate:SetActive(false)
    self.roundList = {}
end

function RhythmWindow:AddListener()
    GlobalEvent.frameUpdate:Add(self.frameUpdate)
end

function RhythmWindow:RemoveListener()
    GlobalEvent.frameUpdate:Remove(self.frameUpdate)
end

function RhythmWindow:OnFrameUpdate()
end

function RhythmWindow:OnShow()
    self:Start()
end

function RhythmWindow:Start()
end
