local _table_insert = table.insert
local _table_remove = table.remove

ClassPool = ClassPool or BaseClass()

function ClassPool:__init(class)
    self.class = class
    self.classList = {}
end

function ClassPool:__release()
    self.class = nil
    self.classList = nil
end

function ClassPool:Get(...)
    if #self.classList > 0 then
        local item = _table_remove(self.classList)
        if item.Reset then
            item:Reset(...)
        end
        return item
    end
    return self.class.New(...)
end

function ClassPool:Recycle(data)
    if data.Recycle then
        data:Recycle()
    end
    _table_insert(self.classPoolList, data)
end
