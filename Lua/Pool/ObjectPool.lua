local _table_insert = table.insert
local _table_remove = table.remove

ObjectPool = ObjectPool or BaseClass()

function ObjectPool:__init(template)
    self.objectList = {}
    self.template = template
end

function ObjectPool:__release()
    self.objectList = nil
end

function ObjectPool:Get()
    if #self.objectList > 0 then
        local object = _table_remove(self.objectList)
        return object
    end
    return GameObject.Instantiate(self.template)
end

function ObjectPool:PushBack(object)
    _table_insert(self.objectList, object)
end
