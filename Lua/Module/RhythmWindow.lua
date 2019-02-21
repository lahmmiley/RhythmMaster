RhythmWindow = RhythmWindow or BaseClass(LPanel)
local _table_remove = table.remove
local _table_insert = table.insert

RhythmWindow.InitOffset = 470

function RhythmWindow:__init()
    self.frameUpdate = function() self:OnFrameUpdate() end
    self.state = RhythmDefine.State.prepare
    self.pipelineX = 0
    self.showRhythmItemList = {}
end

function RhythmWindow:__release()
    self:DestroyGameObject("gameObject")
    self:ReleaseField("rhythmItemPool")
end

function RhythmWindow:InitPanel(gameObject)
    self.gameObject = gameObject
    local fun = function()
        local transform = gameObject.transform
        local count = 10000
        if PanelManager.T == true then
            local b = count * 4
            for i = 1, b do
                local a = transform:Find("PipelineBg/Pipeline")
            end
        end
        self.pipelineTrans = transform:Find("PipelineBg/Pipeline")
        self.pipelineWidth = UtilsUI.GetWidth(self.pipelineTrans)
        self.matchTrans = transform:Find("PipelineBg/Match")
        self.rhythmItemPool = ClassPool.New(RhythmItem)
        self.rhythmPointTemplate = transform:Find("RhythmPoint").gameObject
        self.itemWidth = UtilsUI.GetWidth(self.rhythmPointTemplate.transform)
        self.clickResultText = UtilsUI.GetText(transform, "ClickResultText")

        UtilsUI.AddButtonListener(transform, "RedButton", function() self:RedButtonClick() end)
        UtilsUI.AddButtonListener(transform, "BlueButton", function() self:BlueButtonClick() end)
        self.startButtonGo = transform:Find("StartButton").gameObject
        UtilsUI.AddButtonListener(transform, "StartButton", function() self:StartButtonClick() end)

        
        if PanelManager.T == false then
            for i = 1, count do
                local a = transform:Find("PipelineBg/Pipeline")
            end
        end
        transform:Find("PipelineBg").gameObject:SetActive(true)
        transform:Find("ClickResultText").gameObject:SetActive(true)
        if PanelManager.T == false then
            coroutine.yield()
            for i = 1, count do
                local a = transform:Find("PipelineBg/Pipeline")
            end
        end
        transform:Find("RedButton").gameObject:SetActive(true)
        if PanelManager.T == false then
            coroutine.yield()
            for i = 1, count do
                local a = transform:Find("PipelineBg/Pipeline")
            end
        end
        transform:Find("BlueButton").gameObject:SetActive(true)
        if PanelManager.T == false then
            coroutine.yield()
            for i = 1, count do
                local a = transform:Find("PipelineBg/Pipeline")
            end
        end
        transform:Find("StartButton").gameObject:SetActive(true)
        self.co = nil
        local a
        if PanelManager.T then
            a = "同步"
        else
            a = "分帧"
        end
        print(a .. (Time.realtimeSinceStartup - PanelManager.now))
    end

    local co = coroutine.create(fun)
    self.co = co
end

function RhythmWindow:AddListener()
end

function RhythmWindow:RemoveListener()
end

function RhythmWindow:OnFrameUpdate()
    if self.co then
        coroutine.resume(self.co)
    end
    if self.state ~= RhythmDefine.State.playing then
        return
    end
    self:CreateRhythmItem()
    self:RecycleRhythmItem()
    self:Move()
    self:InputUpdate()
end

function RhythmWindow:OnShow()
    --先创建视野内的节奏点
    --self:CreateRhythmItem()
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
    SoundManager.GetInstance():PlayMusic(2)
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
        local x = config.time * 0.1 + self.pipelineWidth + self.itemWidth / 2
        if (x + self.pipelineX + self.itemWidth / 2) < self.pipelineWidth then
            local rhythmItem = self.rhythmItemPool:Get(self.rhythmPointTemplate)
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
        if x < -(self.itemWidth / 2) then
            self.rhythmItemPool:Recycle(rhythmItem)
            self.showRhythmItemList[key] = nil
        end
    end
end

function RhythmWindow:GetRhythmItemX(rhythmItem)
    return rhythmItem:GetX() + self.pipelineX
end

function RhythmWindow:Move()
    self.pipelineX = self.pipelineX - 5
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
    local clickItem
    local absX
    local key
    for k, rhythmItem in pairs(self.showRhythmItemList) do
        local x = self:GetRhythmItemX(rhythmItem)
        if self.itemWidth / 2 <= x and x <= self.itemWidth * 2.5 then
            local x = math.abs(self.itemWidth * 1.5 - x)
            if absX == nil then
                absX = x
                clickItem = rhythmItem
                key = k
            elseif x < absX then
                absX = x
                clickItem = rhythmItem
                key = k
            end
        end
    end
    if clickItem then
        if absX < 5 then
            self.clickResultText.text = "perfect"
        elseif absX < 10 then
            self.clickResultText.text = "good"
        else
            self.clickResultText.text = "bad"
        end
        self.rhythmItemPool:Recycle(clickItem)
        self.showRhythmItemList[key] = nil
    else
        self.clickResultText.text = "无效点击"
    end
end

function RhythmWindow:StartButtonClick()
    print("StartButtonClick")
    self.startButtonGo:SetActive(false)
    self:Start()
end
