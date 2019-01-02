ModelConfigHelper = ModelConfigHelper or {}

function ModelConfigHelper.GetConfig(id)
    local config = ModelConfig.data[id]
    if config == nil then
        pError(string.format("ModelConfig.data 无法获取配置 id:%s", id))
    end
    return config
end

--获取模型站立高度
function ModelConfigHelper.GetModelStandHeight(id)
    return ModelConfigHelper.GetConfig(id).standHeight
end
