LTreeNode = LTreeNode or BaseClass(LItem)

function LTreeNode:__init(gameObject, key)
    self:SetKey(key)
end

function LTreeNode:GetKey()
    return self.key
end

function LTreeNode:SetKey(key)
    self.key = key
    self.gameObject.name = "Item" .. key
end

function LTreeNode:InitFromCache(key)
    self:SetKey(key)
end

function LTreeNode:OnClick()
    self.ItemSelectEvent:Dispatcher(self.key, self)
end