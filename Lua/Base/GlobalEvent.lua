--全局事件
local _table_insert = table.insert
local _pairs = pairs
local _xpcall = xpcall

GlobalEvent = GlobalEvent or BaseClass()

function GlobalEvent:__init()
    if GlobalEvent.Instance then
        pError("不可以对单例对象重复实例化")
        return
    end
    GlobalEvent.Instance = self
    self.eventDict = {}
end

function GlobalEvent:Add(eventId, handler)
    if self.eventDict[eventId] == nil then
        self.eventDict[eventId] = {}
    end
    local handlers = self.handlers
    for k, v in _pairs(handlers) do
        if v == handler then
            return
        end
    end
    _table_insert(handlers, handler)
end

function GlobalEvent:Remove(eventId, handler)
    local handlers = self.eventDict[eventId]
    if handlers then
        for k, v in _pairs(handlers) do
            if v == handler then
                self.handlers[k] = nil
                break
            end
        end
    end
end

function GlobalEvent:RemoveAll(eventId)
    self.eventDict[eventId] = nil
end

function GlobalEvent:Dispatcher(args1, args2, args3, args4, args5)
    if args5 ~= nil then
        pError("GlobalEvent:Dispatcher不支持超过4个参数，如需要请在GlobalEvent中调整")
    end
    local handlers = self.eventDict[name]
    if handlers then
        for _, handler in _pairs(handlers) do
            local call = function() handler(args1, args2, args3, args4) end
            _xpcall(call, function(errinfo)
                pError("GlobalEvent:Dispatcher出错了" .. tostring(errinfo))
            end)
        end
    end
end