UIEffectLoader = UIEffectLoader or BaseClass()

function UIEffectLoader.GetInstance()
    if UIEffectLoader._instance == nil then
        UIEffectLoader._instance = UIEffectLoader.New()
    end
    return UIEffectLoader._instance
end

function UIEffectLoader:__init()
end

function UIEffectLoader:Load(effectId)
    local path = string.format(AssetDefine.EFFECT_PREFAB_PATH, effectId)
    local prefab = AssetLoader.GetInstance():Load(path)
    local go = GameObject.Instantiate(prefab)
    go.name = effectId
    return go
end