local _table_insert = table.insert
local _math_ceil = math.ceil

TimerNode = TimerNode or BaseClass()

function TimerNode:__init(delay, interval, handler)
    self:Reset(delay, interval, handler)
end

function TimerNode:Reset(delay, interval, handler)
    self.delay = delay
    self.interval = interval
    self.handler = handler
    self.next = nil
    self.expireTime = nil
end

function TimerNode:SetId(id)
    self.id = id
end

function TimerNode:CalcExpireTime()
    if self.delay > 0 then
        self.expireTime = LTimer.realtimeSinceStartup + self.delay
        self.delay = 0
    elseif self.interval > 0 then
        self.expireTime = LTimer.realtimeSinceStartup + self.interval
    else
        self.expireTime = nil
    end
end

function TimerNode:GetSlot()
    return _math_ceil(self.expireTime / 10)
end

TimerList = TimerList or BaseClass()
function TimerList:__init()
    self:Reset()
end

function TimerList:Reset()
    self.head = nil
    self.tail = nil
end

function TimerList:Add(timerNode)
    if self.head == nil then
        self.head = timerNode
        self.tail = timerNode
    else
        self.tail.next = timerNode
    end
    timerNode.next = nil
end

LTimer = LTimer or BaseClass()

function LTimer:GetInstance()
    if self._instance == nil then
        self._instance = LTimer.New()
    end
    return self._instance
end

function LTimer:__init()
    self.id = 0
    self.nodePool = ClassPool.New(TimerNode)
    self.listPool = ClassPool.New(TimerList)
    self.slotDict = {}
    self.handlerDict = {}
    self.addTimerNodeList = {}
end

function LTimer:__release()
end

function LTimer:_GetId()
    self.id = self.id + 1
    return self.id
end

function LTimer:Add(delay, interval, handler)
    local timerNode = self.nodePool:Get(delay, interval, handler)
    timerNode:SetId(self:_GetId())
    --把回调和定时器的耦合解开，实现伪取消定时器效果
    --好处是没有取消定时器时候的遍历，在非频繁取消定时器的系统对性能有帮助？
    self.handlerDict[timerNode.id] = handler
    timerNode:CalcExpireTime()
    if timerNode.expireTime ~= nil then
        self:InsertSlot(timerNode)
    end
    return timerNode.id
end

function LTimer:InsertSlot(timerNode)
    local slot = timerNode:GetSlot()
    if self.slotDict[slot] == nil then
        self.slotDict[slot] = self.listPool:Get()
    end
    local list = self.slotDict[slot]
    list:Add(timerNode)
end

function LTimer:Remove(id)
    --把回调和定时器的耦合解开，实现伪取消定时器效果
    --好处是没有取消定时器时候的遍历，在非频繁取消定时器的系统对性能有帮助？
    self.handlerDict[id] = nil
end

function LTimer:Update(deltaTime)
    local now = LTimer.realtimeSinceStartup
    for slot, list in pairs(self.slotDict) do
        if now >= slot then
            self.slotDict[slot] = nil
            local timerNode = list.head
            while(timerNode ~= nil) do
                local id = timerNode.id
                local handler = self.handlerDict[id]
                if handler then
                    local result = _xpcall(handler, LTimer.ErrorLog)
                    if result then
                        _table_insert(self.addTimerNodeList, timerNode)
                    end
                else
                    --被伪取消了
                end
                timerNode = timerNode.next
            end
            self.listPool:Recycle(list)
        end
    end
    for i = 1, #self.addTimerNodeList do
        local timerNode = self.addTimerNodeList[i]
        self.addTimerNodeList[i] = nil
        timerNode:CalcExpireTime()
        if timerNode.expireTime ~= nil then
            self:InsertSlot(timerNode)
        else
            self.nodePool:Recycle(timerNode)
        end
    end
end

function LTimer.ErrorLog(errinfo)
    pError("定时器出错了" .. tostring(errinfo))
end
