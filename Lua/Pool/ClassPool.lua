local _table_insert = table.insert
local _table_remove = table.remove

ClassPool = ClassPool or BaseClass()

function ClassPool:__init(class)
    self.class = class
    self.poolList = {}
end

function ClassPool:Get(...)
    if #self.poolList > 0 then
        local item = _table_remove(self.poolList)
        item:Reset(...)
        return item
    end
    return self.class.New(...)
end

function ClassPool:PushBack(data)
    _table_insert(self.poolList, data)
end
