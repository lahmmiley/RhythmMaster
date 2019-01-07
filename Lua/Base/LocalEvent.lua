--局部事件
local _table_insert = table.insert
local _pairs = pairs
local _xpcall = xpcall

LocalEvent = LocalEvent or BaseClass()

function LocalEvent:__init()
    self.handlers = nil
    self.args = nil
end

function LocalEvent:__release()
    self:RemoveAll()
end

function LocalEvent:Add(handler)
    self:AddListener(handler)
end

function LocalEvent:AddListener(handler)
    if self.handlers == nil then
        self.handlers = {}
    end
    for k, v in _pairs(self.handlers) do
        if v == handler then
            return
        end
    end
    _table_insert(self.handlers, handler)
end

function LocalEvent:Remove(handler)
    self:RemoveListener(handler)
end

function LocalEvent:RemoveListener(handler)
    if self.handlers then
        for k, v in _pairs(self.handlers) do
            if v == handler then
                self.handlers[k] = nil
                break
            end
        end
    end
end

function LocalEvent:RemoveAll()
    self.handlers = nil
end

function LocalEvent:Dispatcher(args1, args2, args3, args4, args5)
    if args5 ~= nil then
        pError("LocalEvent:Dispatcher不支持超过4个参数，如需要请在LocalEvent中调整")
    end
    if self.handlers then
        for _, handler in _pairs(self.handlers) do
            _xpcall(handler, LocalEvent.ErrorLog, args1, args2, args3, args4)
        end
    end
end

function LocalEvent.ErrorLog(errinfo)
    pError("LocalEvent:Dispatcher出错了" .. tostring(errinfo))
end
