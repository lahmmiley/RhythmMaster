ModelLoader = ModelLoader or BaseClass()

function ModelLoader:GetInstance()
    if self._instance == nil then
        self._instance = ModelLoader.New()
    end
    return self._instance
end

function ModelLoader:__init()
end

function ModelLoader:Load(loaderData)
    local prefab = AssetLoader:GetInstance():Load(loaderData:GetModelPath())
    local go = GameObject.Instantiate(prefab)
    go.name = loaderData.modelId
    self:SetSkin(loaderData, go.transform)
    self:SetAnimation(loaderData, go)
    return go
end

function ModelLoader:SetSkin(loaderData, transform)
    local renderer = transform:Find("Mesh_body"):GetComponent(Renderer)
    local mpb = MaterialPropertyBlock()
    renderer:GetPropertyBlock(mpb)
    local skin = AssetLoader:GetInstance():Load(loaderData:GetSkinPath())
    local textureId = Shader.PropertyToID("_MainTex")
    mpb:SetTexture(textureId, skin)
    renderer:SetPropertyBlock(mpb)
end

function ModelLoader:SetAnimation(loaderData, go)
    local animation = go:GetComponent(Animation)
    local animationPathList = loaderData:GetAnimationPathList()
    for i = 1, #animationPathList do
        local path = animationPathList[i]
        local clip = AssetLoader:GetInstance():Load(path)
        local clipName = clip.name
        animation:AddClip(clip, clipName)
    end
    
    local playName = AssetDefine.ANIMATION_NAME_DICT[1]
    animation:Play(playName)
end
