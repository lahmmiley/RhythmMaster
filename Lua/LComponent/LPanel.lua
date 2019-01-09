LPanel = LPanel or BaseClass()

LPanel.State = {
    notLoad = 1,    --未加载
    loading = 2,    --加载中
    loaded = 3,     --加载完毕
}

function LPanel:__init(id)
    local config = PanelConfig.Data[id]
    self.config = config
    self.state = LPanel.State.notLoad
    self.active = false
    self.releaseTime = nil
end

function LPanel:__release()
    self:_RemoveListener()
end

function LPanel:Show(args)
    self.active = true
    if self.state == LPanel.State.loading then
        return
    end
    local config = self.config
    self.args = args
    if self.state == LPanel.State.notLoad then
        local assetList = config.assetList
        local gameObject = AssetLoader.Instance:Load(AssetType.ToLogicPath(assetList[1], AssetType.uiPrefab))
        self:AssetsLoaded(gameObject)
    else
        self.gameObject:SetActive(true)
        self:_AddListener()
        self:OnShow()
    end
end


function LPanel:AssetsLoaded(gameObject)
    self.gameObject = gameObject
    self.state = LPanel.State.loaded
    --后面改为异步加载
    local gameObject = self.gameObject
    if self.active then
        self:InitPanel(gameObject)
        gameObject:SetActive(true)
        self:_AddListener()
        self:OnShow()
    end
end

function LPanel:OnShow()
end

function LPanel:Hide()
    self.active = false
    if self.state ~= LPanel.State.loaded then
        return
    end
    self:_RemoveListener()
    self.gameObject:SetActive(false)
    self.releaseTime = os.time() + 30
end

function LPanel:OnHide()
end

function LPanel:_AddListener()
    if self.frameUpdate then
        GlobalEvent.frameUpdate:Add(self.frameUpdate)
    end
    self:AddListener()
end

function LPanel:AddListener()
end

function LPanel:_RemoveListener()
    if self.frameUpdate then
        GlobalEvent.frameUpdate:Remove(self.frameUpdate)
    end
    self:RemoveListener()
end

function LPanel:RemoveListener()
end

function LPanel:ReleaseField(name)
    UtilsBase.ReleaseField(self, name)
end

function LPanel:ReleaseTable(name)
    UtilsBase.ReleaseTable(self, name)
end

function LPanel:DestroyGameObject(name)
    UtilsBase.DestroyGameObject(self, name)
end

function LPanel:CancelTween(name)
    UtilsBase.CancelTween(self, name)
end

function LPanel:CancelTweenIdList(name)
    UtilsBase.CancelTweenIdList(self, name)
end
