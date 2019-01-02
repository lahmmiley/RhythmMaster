ModelLoaderData = ModelLoaderData or BaseClass()

function ModelLoaderData:__init(modelId, skinId, animationId)
    self.modelId = modelId
    self.skinId = skinId
    self.animationId = animationId
end

function ModelLoaderData:GetModelPath()
    return string.format(AssetDefine.VEHICLE_PREFAB_PATH, self.modelId)
end

function ModelLoaderData:GetSkinPath()
    return string.format(AssetDefine.VEHICLE_SKIN_PATH, self.skinId)
end

function ModelLoaderData:GetAnimationPathList()
    local result = {}
    for _, name in pairs(AssetDefine.ANIMATION_NAME_DICT) do
        local path = string.format(AssetDefine.VEHICLE_ANIMATION_PATH, self.animationId .. "/" .. name)
        table.insert(result, path)
    end
    return result
end
