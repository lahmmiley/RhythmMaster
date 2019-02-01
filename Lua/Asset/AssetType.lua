AssetType = AssetType or {}

AssetType = {
    uiPrefab = 1,           --UI预设
    effect = 2,             --特效
    vehiclePrefab = 3,      --载具预设
    vehicleSkin = 4,        --载具贴图
    vehicleAnimation = 5,   --载具动作
    music = 6,              --音乐
    sound = 7,              --UI音效
}

--path assetPath 为特定资源的路径
--logicPath为资源的逻辑路径，在游戏中保证唯一性
--physicalPath为资源的物理路径，在系统中保证唯一性
--path + assetType = logicPath
--logicPath 依据不同的操作系统会对应不同的physicalPath
AssetType.ToLogicPath = function(path, assetType)
    if assetType == AssetType.uiPrefab then
        return string.format("UI/%s", path)
    elseif assetType == AssetType.effect then
        return string.format("Effect/Prefab/%s", path)
    elseif assetType == AssetType.vehiclePrefab then
        return string.format("Unit/Vehicle/Prefab/%s", path)
    elseif assetType == AssetType.vehicleSkin then
        return string.format("Unit/Vehicle/Skin/%s", path)
    elseif assetType == AssetType.vehicleAnimation then
        return string.format("Unit/Vehicle/Animation/%s", path)
    elseif assetType == AssetType.music then
        return string.format("Music/%s", path)
    else
        pError("找不到类型:" .. tostring(assetType))
    end
end
