PanelManager = PanelManager or BaseClass()

function PanelManager:GetInstance()
    if self._instance == nil then
        self._instance = PanelManager.New()
    end
    return self._instance
end

function PanelManager:__init()
    self.update = function() self:Update() end
    self:AddListener()

    --界面始终只显示一个window，
    --如果当前打开一个window，再开另一个window会隐藏当前window
    --关闭当前window，假如存在lastWindow，会重新打开window
    self.lastWindow = nil
    self.currentWindow = nil
    self.panelDict = {}
end

function PanelManager:__release()
    self:RemoveListener()
end

function PanelManager:Update()
    --TODO 不同频率
    --管理
    local currentTime = os.time()
    for id, panel in pairs(self.panelDict) do
        if not panel.active then
            local releaseTime = panel.releaseTime
            if currentTime > releaseTime then
                panel:Release()
                self.panelDict[id] = nil
            end
        end
    end
end

function PanelManager:Show(id)
    local config = PanelConfig.data[id]
    local panel
    if self.panelDict[id] == nil then
        local className = config.className
        panel = _G[className].New(id)
    else
        panel = self.panelDict[id]
    end
    if config.window then
        if self.currentWindow ~= nil then
            self.currentWindow:Hide()
            self.lastWindow = self.currentWindow
        end
        self.currentWindow = panel
    end
    panel:Show()
end

function PanelManager:Hide(id)
    if self.panelDict[id] == nil then
        return
    end
    local panel = self.panelDict[id]
    panel:Hide()
    local config = panel.config
    if config.window and self.lastWindow then
        self.lastWindow:Show()
        self.currentWindow = self.lastWindow
        self.lastWindow = nil
    end
end

function PanelManager:AddListener()
    GlobalEvent.frameUpdate:Add(self.update)
end

function PanelManager:RemoveListener()
    GlobalEvent.frameUpdate:Remove(self.update)
end
