-- 事件系统
local _table_insert = table.insert
local _pairs = pairs
local _xpcall = xpcall

LocalEvent = LocalEvent or BaseClass()

function LocalEvent:__init()
    self.handlers = nil
    self.args = nil
    self.handlerList = {}
end

function LocalEvent:__release()
    self:RemoveAll()
end

function LocalEvent:AddListener(handler)
    self:Add(handler)
end

function LocalEvent:AddOnceListener(handler)
    self:AddOnce(handler)
end

function LocalEvent:Add(handler)
    if self.handlers == nil then
        self.handlers = {}
    end
    for k,v in _pairs(self.handlers) do
        if v == handler then
            return
        end
    end
    _table_insert(self.handlers, handler)
end

function LocalEvent:RemoveListener(handler)
    self:Remove(handler)
end
function LocalEvent:Remove(handler)
    if not handler then
        self.handlers = nil
    else
        if self.handlers then
            for k, v in _pairs(self.handlers) do
                if v == handler then
                    self.handlers[k] = nil
                    return k
                end
            end
        end
    end
end

function LocalEvent:RemoveAll()
    self:Remove()
end

function LocalEvent:Dispatcher(args1, args2, args3, args4, args5)
    if args5 ~= nil then
        pError("LocalEvent:Dispatcher目持超过4个参数，需要在LocalEvent.lua中调整")
    end
    if self.handlers then
        for _, func in _pairs(self.handlers) do
            local call = function() func(args1, args2, args3, args4) end
            _xpcall(call, function(errinfo)
                pError("LocalEvent:Dispatcher出错了" .. tostring(errinfo).."\n"..debug.traceback())
            end)
        end
    end
end