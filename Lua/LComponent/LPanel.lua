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
        self:AddListener()
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
        self:AddListener()
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
    self:RemoveListener()
    self.gameObject:SetActive(false)
    self.releaseTime = os.time() + 30
end

function LPanel:OnHide()
end

function LPanel:AddListener()
end

function LPanel:RemoveListener()
end
