GlobalEvent = {}

--利用元表避免第一次加载时就创建所有全局事件
setmetatable(GlobalEvent, {__index = function(t, k)
    t[k] = LocalEvent.New(),
end})

--为了避免重名，每个全局事件都需要在这里加注释
--frameUpdate