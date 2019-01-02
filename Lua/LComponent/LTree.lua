LTree = LTree or BaseClass()

function LTree:__init(transform, defaultItemType, itemTypeDict)
    self.defaultItemType = defaultItemType
    self.itemTypeDict = itemTypeDict
    self.gapHorizontal = 0
    self.gapVertical = 0

    self.onItemSelect = function(key, node) self:_OnItemSelect(key, node) end
    self.NodeSelectEvent = LocalEvent.New()
    self.LeafSelectEvent = LocalEvent.New()

    self.nodeDict = {}
    self.defaultNodePoolList = {}
    self.nodePoolListDict = {}
    self.orderList = nil
    self.nodeDataDict = nil

    self:_InitComponent(transform)
end

function LTree:__release()
    UtilsBase.ReleaseField(self, "NodeSelectEvent")
    UtilsBase.ReleaseField(self, "LeafSelectEvent")
    UtilsBase.ReleaseTable(self, "nodeDict")
    UtilsBase.ReleaseTable(self, "defaultNodePoolList")
    for _, itemPoolList in pairs(self.nodePoolListDict) do
        for i = 1, #itemPoolList do
            itemPoolList[i]:Release()
        end
    end
    self.nodePoolListDict = nil
end

function LTree:_InitComponent(transform)
     local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
    self.scrollRect.onValueChanged:AddListener(function(value) self:_OnValueChanged(value) end)
    local maskTrans = transform:Find(LDefine.MASK_NAME)
    local mask = maskTrans:GetComponent(Mask)
    self.maskWidth = mask.transform.sizeDelta.x
    self.maskHeight = mask.transform.sizeDelta.y
    self.contentTrans = maskTrans:Find(LDefine.CONTENT_NAME)
    self:_InitTemplate()
end

function LTree:_InitTemplate()
    local itemTrans = self.contentTrans:Find(LDefine.ITEM_NAME)
    self.defaultItemWidth = itemTrans.sizeDelta.x
    self.defaultItemHeight = itemTrans.sizeDelta.y
    self.defaultTemplate = itemTrans.gameObject
    self.defaultTemplate:SetActive(false)
    if self.itemTypeDict then
        self.depthDict = {}
        for depth, itemType in pairs(self.itemTypeDict) do
            local trans = self.contentTrans:Find(LDefine.ITEM_NAME .. "_" .. depth)
            trans.gameObject:SetActive(false)
            self.depthDict[depth] = {
                itemType = itemType,
                template = trans.gameObject,
                width = trans.sizeDelta.x,
                height = trans.sizeDelta.y,
            }
        end
    end
end

-- public function
function LTree.GetRootNodeData()
    return LTreeNodeData.New(nil, 0, string.Empty)
end

function LTree.InitTree(nodeData, dataList, defaultDataType, dataTypeDict)
    if nodeData == nil or dataList == nil then
        return
    end
    local depth = nodeData.depth + 1
    local key = nodeData:GetKey()
    local dataType = defaultDataType or LTreeNodeData
    if dataTypeDict and dataTypeDict[depth] then
        dataType = dataTypeDict[depth]
    end
    for i = 1, #dataList do
        local data = dataList[i]
        local childKey
        if key == string.Empty then
            childKey = tostring(i)
        else
            childKey = key .. "_" .. i
        end
        local childNodeData = dataType.New(data, depth, childKey)
        childNodeData:SetParent(nodeData)
        nodeData:AddChild(childNodeData)
        if data.dataList then
            LTree.InitTree(childNodeData, data.dataList, defaultDataType, dataTypeDict)
        end
    end
end

--调试接口
function LTree.Dump(nodeData)
    if nodeData.data then
        print(nodeData:GetKey() .. ":" .. nodeData.data.name .. ":" .. tostring(nodeData.expand))
    end
    if nodeData:HaveChild() then
        local childList = nodeData:GetChildList()
        for i = 1, #childList do
            local childNodeData = childList[i]
            LTree.Dump(childNodeData)
        end
    end
end

function LTree:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
end

function LTree:Focus(key)
    local nodeData = self.nodeDataDict[tostring(key)]
    if nodeData then
        self:_SetContentY(-nodeData:GetY())
    end
end

function LTree:GetNode(key)
    return self.nodeDict[key]
end

function LTree:SetData(rootNodeData, commonData)
    self.rootNodeData = rootNodeData
    self.commonData = commonData
    self.orderList = {}
    self.nodeDataDict = {}
    local maxX, minY = self:_TreeToList(rootNodeData, 0, 0)
    self.contentTrans.sizeDelta = Vector2(maxX, -minY)

    self:_UpdateTree()
end
-- public function end

function LTree:_OnValueChanged(value)
    local startIndex = self:_GetIndexByY(self:_GetMaskTop())
    local endIndex = self:_GetIndexByY(self:_GetMaskBottom())
    if startIndex ~= self.startIndex or
        endIndex ~= self.endIndex then
        self:_UpdateTree()
    end
end

function LTree:_TreeToList(nodeData, maxX, minY)
    if nodeData:HaveChild() and nodeData.expand then
        local childList = nodeData:GetChildList()
        for i = 1, #childList do
            local childNodeData = childList[i]
            self.nodeDataDict[childNodeData:GetKey()] = childNodeData
            table.insert(self.orderList, childNodeData)
            childNodeData:SetOrder(#self.orderList)
            local x = (childNodeData.depth - 1) * self.gapHorizontal
            childNodeData:SetPosition(Vector2(x, minY))
            minY = minY - self:_GetItemHeight(childNodeData.depth) - self.gapVertical
            local width = x + self:_GetItemWidth(childNodeData.depth)
            if width > maxX then
                maxX = width
            end
            maxX, minY = self:_TreeToList(childNodeData, maxX, minY)
        end
    end
    return maxX, minY
end

function LTree:_UpdateTree()
    if #self.orderList > 0 then
        self.startIndex = self:_GetIndexByY(self:_GetMaskTop())
        self.endIndex = self:_GetIndexByY(self:_GetMaskBottom())
        self:_PushUnUsedToPool()
        for i = self.startIndex, self.endIndex do
            local nodeData = self.orderList[i]
            local node = self:_GetNode(nodeData)
            node:SetPosition(nodeData:GetPosition())
            node:SetActive(true)
            node:SetData(nodeData, self.commonData)
        end
    else
        for key, node in pairs(self.nodeDict) do
            self:_PushPool(node)
        end
    end
end

function LTree:_PushUnUsedToPool()
    self.usedKeyDict = {}
    for i = self.startIndex, self.endIndex do
        local nodeData = self.orderList[i]
        self.usedKeyDict[nodeData:GetKey()] = true
    end

    for key, node in pairs(self.nodeDict) do
        local nodeData = node.nodeData
        if not self.usedKeyDict[nodeData:GetKey()] then
            self:_PushPool(node)
        end
    end
end

function LTree:_GetIndexByY(y)
    local startIndex = 1
    local endIndex = #self.orderList
    if endIndex <= startIndex then
        return startIndex
    end
    local result
    while true do
        local mid = math.floor((startIndex + endIndex) / 2)
        local nodeData = self.orderList[mid]
        local nodeY = nodeData:GetY()
        if nodeY > y and y >= (nodeY - self:_GetItemHeight(nodeData.depth)) then
            result = mid
            break
        end
        if y >= nodeY then
            endIndex = mid - 1
        else
            startIndex = mid + 1
        end
        if endIndex - startIndex <= 0 then
            result = startIndex
            break
        end
    end
    return result
end

function LTree:_OnItemSelect(key, node)
    local nodeData = node.nodeData
    if nodeData:HaveChild() then
        nodeData.expand = not nodeData.expand
        self:SetData(self.rootNodeData, self.commonData)
        nodeData = self.nodeDataDict[key]
        if nodeData.expand then
            local childHeight = self:_GetChildHeight(nodeData, 0)
            local itemHeight = self:_GetItemHeight(nodeData.depth)
            if self:_BelowMaskBottom(node:GetPosition().y - childHeight - itemHeight) then
                local maskTop = self:_GetMaskTop()
                local maxOffsetY = maskTop - nodeData:GetY()
                local maskBottom = self:_GetMaskBottom()
                local offsetY = math.min(maxOffsetY, maskBottom - (node:GetPosition().y - childHeight - itemHeight))
                self:_SetContentY(self.contentTrans.anchoredPosition.y + offsetY)
            end
        end
        self.NodeSelectEvent:Dispatcher(self.rootNodeData, key, self.nodeDict[key])
    else
        self.LeafSelectEvent:Dispatcher(self.rootNodeData, key, node)
    end
end

function LTree:_SetContentY(y)
    local sizeDelta = self.contentTrans.sizeDelta
    UtilsUI.SetAnchoredY(self.contentTrans, math.max(0, math.min(y, sizeDelta.y - self.maskHeight)))
end

function LTree:_GetNode(nodeData)
    local key = nodeData:GetKey()
    local depth = nodeData.depth
    if self.nodeDict[key] then
        local node = self.nodeDict[key]
        return node
    else
        if self.depthDict and self.depthDict[depth] then
            if self.nodePoolListDict[depth] and #self.nodePoolListDict[depth] > 0 then
                local nodePoolList = self.nodePoolListDict[depth]
                local node = table.remove(nodePoolList)
                node:InitFromCache(key)
                self.nodeDict[key] = node
                return node
            end
        elseif #self.defaultNodePoolList > 0 then
            local node = table.remove(self.defaultNodePoolList)
            node:InitFromCache(key)
            self.nodeDict[key] = node
            return node
        end
    end
    local template = self.defaultTemplate
    local itemType = self.defaultItemType
    if self.depthDict and self.depthDict[depth] then
        template = self.depthDict[depth].template
        itemType = self.depthDict[depth].itemType
    end
    local go = GameObject.Instantiate(template)
    go.transform:SetParent(self.contentTrans, false)
    local node = itemType.New(go, nodeData:GetKey())
    node.ItemSelectEvent:AddListener(self.onItemSelect)
    self.nodeDict[key] = node
    return node
end

function LTree:_PushPool(node)
    self.nodeDict[node:GetKey()] = nil
    node:SetActive(false)
    local depth = node.nodeData.depth
    if self.depthDict and self.depthDict[depth] then
        if self.nodePoolListDict[depth] == nil then
            self.nodePoolListDict[depth] = {}
        end
        table.insert(self.nodePoolListDict[depth], node)
    else
        table.insert(self.defaultNodePoolList, node)
    end
end

function LTree:_GetChildHeight(nodeData, height)
    if nodeData.expand and nodeData:HaveChild() then
        local childLength = #nodeData.childList
        height = height + (childLength - 1) * self.gapVertical + childLength * self:_GetItemHeight(nodeData.depth + 1)
        for i = 1, childLength do
            local child = nodeData.childList[i]
            height = self:_GetChildHeight(child, height)
        end
    end
    return height
end

function LTree:_GetItemHeight(depth)
    return self.depthDict and self.depthDict[depth] and self.depthDict[depth].height or self.defaultItemHeight
end

function LTree:_GetItemWidth(depth)
    return self.depthDict and self.depthDict[depth] and self.depthDict[depth].width or self.defaultItemWidth
end

function LTree:_GetMaskTop()
    return -self.contentTrans.anchoredPosition.y
end

function LTree:_GetMaskBottom()
    return -self.contentTrans.anchoredPosition.y - self.maskHeight 
end

function LTree:_BelowMaskBottom(y)
    return y < self:_GetMaskBottom()
end