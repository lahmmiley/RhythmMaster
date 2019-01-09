--camera参数设置
--fieldOfView有所改动 因为scale为1，而不是游戏中的配置 z轴也因此有所调整
--透视效果不好处理，模型以脚为锚点，透视还要计算模型的偏移，让摄像机对准模型中点
--否则效果不好，我决定类型改为正交

--rotate参考游戏
--model放在root节点，不放在camera节点是为了让camera rotation生效 不然模型跟着camera一起旋转，始终只能看到模型正面

--模型大小，模型的大小不一定能根据原始比例进行缩放得到，这样会导致有的模型很大，有的模型很小
--需要配置一个uiScale，来代表模型展示时的大小，这样可以让模型在UI上以合理的比例展示出来

--模型的锚点是在脚底，如果模型展示要求底对其，那非常好处理，就是让模型往下偏移一段距离，使模型的脚底能对齐摄像机的下部
--这个偏移不受缩放影响,只受z轴和摄像机显示大小影响，这两个在LUIDemo中是固定值，所以偏移也是固定值
--因为模型的锚点在脚底，缩放都是往上缩放
--Test中的例子就是往下偏移-6个单位坐标，可以看到最终的效果挺好

--居中有空再思考 不好布局，而且80004过高的问题，也不好处理

--StaticInit 就是c#的静态构造函数
--SetData只会重新加载模型 摄像机 RenderTexture都在初始化构造
--RenderTexture用 缓存池机制

--RenderTexture占用的内存貌似过高，高如果只属于UI，其实可以接受，因为好处挺明显
--localRotation 是slua暴露的接口吧，用的参数是Quaternion

LRTModel = LRTModel or BaseClass()

LRTModel.RT_SCALE = 1
LRTModel.MODEL_Z = 10

function LRTModel:__init(transform)
    if LRTModel.staticInit == nil then
        LRTModel.staticInit = true
        self:StaticInit()
    end
    self.transform = transform
    local rawImageGo = GameObject("RawImage")
    rawImageGo:AddComponent(RectTransform)
    local rawImageTrans = rawImageGo.transform
    self.rawImageTrans = rawImageTrans
    UtilsBase.UISetParent(rawImageTrans, transform)
    self.rawImage = rawImageGo:AddComponent(RawImage)
    self.width = transform.sizeDelta.x
    self.height = transform.sizeDelta.y
    rawImageTrans.sizeDelta = Vector2(self.width, self.height)
end

function LRTModel:__release()
    if self.renderTexture then
        RenderTexture.ReleaseTemporary(self.renderTexture)
        self.renderTexture = nil
    end
end

function LRTModel:StaticInit()
    local rootTrans = GameObject.Find("Preview").transform
    LRTModel.rootTrans = rootTrans
    LRTModel.X = 0
    LRTModel.cameraTemplate = AssetLoader:GetInstance():Load(string.format(AssetDefine.UI_PREFAB_PATH, "PreviewCamera"))
end

function LRTModel:InitCamera()
    if self.cameraGo then
        return
    end
    local cameraGo = GameObject.Instantiate(LRTModel.cameraTemplate)
    self.cameraGo = cameraGo
    self.cameraTrans = cameraGo.transform
    cameraGo.name = "PreviewCamera"
    local cameraTrans = cameraGo.transform
    cameraTrans:SetParent(LRTModel.rootTrans)
    cameraTrans.localEulerAngles = Vector3One
    cameraTrans.localScale = Vector3One
    cameraTrans.localPosition = Vector3(LRTModel.X, 0, 0)
    LRTModel.X = LRTModel.X + 20
end

function LRTModel:InitRenderTexture()
    if self.renderTexture then
        return
    end
    local camera = self.cameraGo:GetComponent(Camera)
    self.renderTexture = RenderTexture.GetTemporary(self.width * LRTModel.RT_SCALE, self.height * LRTModel.RT_SCALE, 24)
    self.rawImage.texture = self.renderTexture
    camera.targetTexture = self.renderTexture
end

function LRTModel:SetData(loaderData, offsetY, scale, rotation)
    self.loaderData = loaderData
    self:InitCamera()
    self:InitRenderTexture()
    if self.modelGo then
        -- 如果卡顿的原因是TempAlloc.Overflow，试试开启下面这句
        -- self.modelGo:GetComponent(Animation).enabled = false
        GameObject.Destroy(self.modelGo)
        self.modelGo = nil
    end
    local modelGo = ModelLoader:GetInstance():Load(loaderData)
    self.modelGo = modelGo
    local modelTrans = modelGo.transform
    UtilsBase.SetLayer(modelTrans, "UIModel")
    modelTrans:SetParent(LRTModel.rootTrans)
    local config = ModelConfigHelper.GetConfig(loaderData.modelId)
    modelTrans.localScale = Vector3One * scale / config.uiScale
    modelTrans.localEulerAngles = rotation or Vector3(0, 180, 0)
    modelTrans.localPosition = self.cameraTrans.localPosition + Vector3(0, offsetY, LRTModel.MODEL_Z)
end
