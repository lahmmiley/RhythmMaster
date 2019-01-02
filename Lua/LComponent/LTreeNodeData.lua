LTreeNodeData = LTreeNodeData or BaseClass()

function LTreeNodeData:__init(data, depth, key)
    self.data = data
    self.depth = depth
    self.key = key
    if data == nil then --root
        self.expand = true
    else
        self.expand = data.expand
    end
    self.childList = nil
    self.parent = nil
    self.order = nil
    self.position = nil
end

function LTreeNodeData:__release()
end

function LTreeNodeData:GetKey()
    return self.key
end

function LTreeNodeData:SetOrder(order)
    self.order = order
end

function LTreeNodeData:SetParent(parent)
    self.parent = parent
end

function LTreeNodeData:SetPosition(position)
    self.position = position
end

function LTreeNodeData:GetPosition()
    return self.position
end

function LTreeNodeData:GetY()
    return self.position.y
end

function LTreeNodeData:AddChild(child)
    if self.childList == nil then
        self.childList = {}
    end
    table.insert(self.childList, child)
end

function LTreeNodeData:HaveChild()
    return self.childList ~= nil
end

function LTreeNodeData:GetChildList()
    return self.childList
end
