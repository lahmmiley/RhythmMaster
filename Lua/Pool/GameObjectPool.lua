local _table_insert = table.insert
local _table_remove = table.remove

GameObjectPool = GameObjectPool or BaseClass()

function GameObjectPool:__init(template, parent)
    self.gameObjectList = {}
    self.template = template
    self.parent = parent
end

function GameObjectPool:__release()
    self.gameObjectList = nil
end

function GameObjectPool:Get()
    if #self.gameObjectList > 0 then
        local gameObject = _table_remove(self.gameObjectList)
        return gameObject
    end
    return GameObject.Instantiate(self.template)
end

function GameObjectPool:Recycle(gameObject)
    local transform = gameObject.transform
    transform:SetParent(self.parent)
    _table_insert(self.gameObjectList, gameObject)
end
