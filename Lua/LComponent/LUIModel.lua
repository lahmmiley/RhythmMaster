LUIModel = LUIModel or BaseClass()

function LUIModel:__init(transform)
    if LUIModel.staticInit == nil then
        LUIModel.staticInit = true
        self:StaticInit()
    end
    self.transform = transform
end

function LUIModel:__release()
end

function LUIModel:StaticInit()
    local rootTrans = GameObject.Find("Preview").transform
    LUIModel.rootTrans = rootTrans
    LUIModel.cameraTemplate = AssetLoader.Instance:Load(string.format(AssetDefine.UI_PREFAB_PATH, "PreviewCamera"))
end

function LUIModel:InitCamera()
    if self.cameraGo then
        return
    end
    local cameraGo = GameObject.Instantiate(LUIModel.cameraTemplate)
    self.cameraGo = cameraGo
    self.cameraTrans = cameraGo.transform
    cameraGo.name = "PreviewCamera"
    local cameraTrans = cameraGo.transform
    cameraTrans:SetParent(LUIModel.rootTrans)
    cameraTrans.localEulerAngles = Vector3One
    cameraTrans.localScale = Vector3One
    cameraTrans.localPosition = Vector3(LUIModel.X, 0, 0)
    LUIModel.X = LUIModel.X + 20
end

function LUIModel:SetData(loaderData, offsetY, scale, rotation)
    self.loaderData = loaderData
    -- self:InitCamera()
    local modelGo = ModelLoader.Instance:Load(loaderData)
    self.modelGo = modelGo
    local modelTrans = modelGo.transform
    modelTrans:SetParent(self.transform)
    UtilsBase.SetLayer(modelTrans, "UI")
    local config = ModelConfigHelper.GetConfig(loaderData.modelId)
    modelTrans.localScale = Vector3One * 50
    modelTrans.localEulerAngles = rotation or Vector3(0, 180, 0)
    modelTrans.localPosition = Vector3(150, -50, LUIModel.MODEL_Z)
end
