TimerHeap = TimerHeap or BaseClass()
local _table_insert = table.insert

function TimerHeap:__init()
    if TimerHeap.Instance then
        pError("不可以对单例对象重复实例化")
        return
    end
    TimerHeap.Instance = self
    self.dict = {}
    self.id = 0
end

function TimerHeap:__release()
end

function TimerHeap:_GetId()
    self.id = self.id + 1
    return self.id
end

function TimerHeap:Add(delay, interval, handler, args1, args2, args3, args4, args5)
    local timerNode = TimerNode.New(delay, interval, handler, args1, args2, args3, args4, args5)
    local id = self:_GetId()
    self.dict[id] = timerNode
    self:CalcRunTime(timerNode)
end

function TimerHeap:CalcRunTime(timerNode)
    if timerNode.delay > 0 then
        timerNode.runTime = TimerHeap.realtimeSinceStartup + timerNode.delay
    else
    end
end

function TimerHeap:Remove()
end

function TimerHeap:Update()
end

TimerNode = TimerNode or {}

function TimerNode.New(delay, interval, handler, args1, args2, args3, args4, args5)
    if args5 ~= nil then
        pError("TimerNode 暂不支持回调超过4个函数，如需要请在TimerNode中调整")
    end
    local result = {
        delay = delay,
        interval = interval,
        handler = handler,
        args1 = args1,
        args2 = args2,
        args3 = args3,
        args4 = args4,
        args5 = args5,
    }
    return result
end
