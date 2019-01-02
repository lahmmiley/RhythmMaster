UIEffectLoader = UIEffectLoader or BaseClass()

function UIEffectLoader:__init()
    if UIEffectLoader.Instance then
        pError("重复生成单例")
        return
    end
    UIEffectLoader.Instance = self
end

function UIEffectLoader:Load(effectId)
    local path = string.format(AssetDefine.EFFECT_PREFAB_PATH, effectId)
    local prefab = AssetLoader.Instance:Load(path)
    local go = GameObject.Instantiate(prefab)
    go.name = effectId
    return go
end