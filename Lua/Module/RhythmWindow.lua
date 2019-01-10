RhythmWindow = RhythmWindow or BaseClass(LPanel)
local _table_remove = table.remove
local _table_insert = table.insert

function RhythmWindow:__init()
    self.frameUpdate = function() self:OnFrameUpdate() end
    self.state = RhythmDefine.State.prepare
    self.pipelineX = 0
    self.showRhythmItemList = {}
end

function RhythmWindow:__release()
    self:ReleaseField("rhythmItemPool")
end

function RhythmWindow:InitPanel(gameObject)
    local transform = gameObject.transform
    self.pipelineTrans = transform:Find("PipelineBg/Pipeline")
    self.matchTrans = transform:Find("PipelineBg/Match")
    self.rhythmItemPool = ClassPool.New(RhythmItem)
    self.rhythmPointTemplate = transform:Find("RhythmPoint").gameObject

    UtilsUI.AddButtonListener(transform, "RedButton", function() self:RedButtonClick() end)
    UtilsUI.AddButtonListener(transform, "BlueButton", function() self:BlueButtonClick() end)
    self.startButtonGo = transform:Find("StartButton").gameObject
    UtilsUI.AddButtonListener(transform, "StartButton", function() self:StartButtonClick() end)
end

function RhythmWindow:AddListener()
end

function RhythmWindow:RemoveListener()
end

function RhythmWindow:OnFrameUpdate()
    if self.state ~= RhythmDefine.State.playing then
        return
    end
    self:CreateRhythmItem()
    self:RecycleRhythmItem()
    self:Move()
    self:InputUpdate()
end

function RhythmWindow:OnShow()
end

function RhythmWindow:Start()
    local rhythmConfigList = RhythmConfigHelper.GetMusicRhythm(1)
    self.rhythmConfigList = rhythmConfigList
    self.startTime = LTimer.realtimeSinceStartup
    self.createdIndex = 0
    self.state = RhythmDefine.State.playing
    self:PlayMusic()
end

function RhythmWindow:PlayMusic()
end

function RhythmWindow:GetMusicCurrentTime()
    return LTimer.realtimeSinceStartup - self.startTime
end

function RhythmWindow:CreateRhythmItem()
    local currentTime = self:GetMusicCurrentTime()
    local createdIndex = self.createdIndex
    local rhythmConfigList = self.rhythmConfigList
    for i = createdIndex + 1, #rhythmConfigList do
        local config = rhythmConfigList[i]
        if currentTime >= config.time then
            print("config.time:" .. config.time)
            local rhythmItem = self.rhythmItemPool:Get(self.rhythmPointTemplate)
            local time = config.time - self.startTime
            local x = time * 100 + 150 -- 150是初始偏移值
            rhythmItem:SetParent(self.pipelineTrans, Vector3(x, 0, 0))
            rhythmItem:SetData(config)
            _table_insert(self.showRhythmItemList, rhythmItem)
            self.createdIndex = i
        end
    end
end

function RhythmWindow:RecycleRhythmItem()
    local pipelineX = self.pipelineX
    for key, rhythmItem in pairs(self.showRhythmItemList) do
        local x = self:GetRhythmItemX(rhythmItem)
        if x < 0 then
            self.rhythmItemPool:Recycle(rhythmItem)
            self.showRhythmItemList[key] = nil
        end
    end
end

function RhythmWindow:GetRhythmItemX(rhythmItem)
    return rhythmItem:GetX() + self.pipelineX
end

function RhythmWindow:Move()
    self.pipelineX = self.pipelineX - 1
    UtilsUI.SetAnchoredX(self.pipelineTrans, self.pipelineX)
end

function RhythmWindow:InputUpdate()
    if Input.GetKeyDown(KeyCode.J) then
        self:RedButtonClick()
    end
    if Input.GetKeyDown(KeyCode.K) then
        self:BlueButtonClick()
    end
end

function RhythmWindow:RedButtonClick()
    self:ClickCheck(RhythmDefine.ClickType.red)
end

function RhythmWindow:BlueButtonClick()
    self:ClickCheck(RhythmDefine.ClickType.blue)
end

function RhythmWindow:ClickCheck(clickType)
    for k, rhythmItem in pairs(self.showRhythmItemList) do
        local x = self:GetRhythmItemX(rhythmItem)
        --成功点击 差 良 完美
        --无效点击
        if 0 < x and x < 64 then
        else
        end
    end
end

function RhythmWindow:StartButtonClick()
    print("StartButtonClick")
    self.startButtonGo:SetActive(false)
    self:Start()
end
