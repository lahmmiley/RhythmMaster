UIEffectLoader = UIEffectLoader or BaseClass()

function UIEffectLoader:GetInstance()
    if self._instance == nil then
        self._instance = UIEffectLoader.New()
    end
    return self._instance
end

function UIEffectLoader:__init()
end

function UIEffectLoader:Load(effectId)
    local path = string.format(AssetDefine.EFFECT_PREFAB_PATH, effectId)
    local prefab = AssetLoader:GetInstance():Load(path)
    local go = GameObject.Instantiate(prefab)
    go.name = effectId
    return go
end