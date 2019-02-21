--LMIScrollView Is Short For Multiple Item Scroll View
-- 多元素滚动布局组件
LMIScrollView = LMIScrollView or BaseClass()

function LMIScrollView:__init(transform, itemTypeList)
    self.gameObject = transform.gameObject
    self.itemTypeList = itemTypeList
    self.gapVertical = 0

    self.itemDict = nil
    self.itemPoolListDict = {}
    self.ItemSelectEvent = LocalEvent.New()
    self.eventNameList = nil

    self:_InitComponent(transform)
    self:_InitTemplate()
end

function LMIScrollView:_InitComponent(transform)
     local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
    scrollRect.onValueChanged:AddListener(function(value) self:_OnValueChanged(value) end)
    local maskTrans = transform:Find(LDefine.MASK_NAME)
    self.maskHeight = maskTrans.sizeDelta.y
    self.contentTrans = maskTrans:Find(LDefine.CONTENT_NAME)
end

function LMIScrollView:_InitTemplate()
    self.itemTypeDict = {}
    self.width = 0
    for i = 1, #self.itemTypeList do
        local itemType = self.itemTypeList[i]
        local trans = self.contentTrans:Find(LDefine.ITEM_NAME .. "_" .. i)
        trans.gameObject:SetActive(false)
        self.itemTypeDict[i] = {
            itemType = itemType,
            template = trans.gameObject,
            width = trans.sizeDelta.x,
            height = trans.sizeDelta.y,
        }
        if trans.sizeDelta.x > self.width then
            self.width = trans.sizeDelta.x
        end
    end
end

function LMIScrollView:__release()
    UtilsBase.CancelTween(self, "focusTweenId")
    UtilsBase.ReleaseField(self, "ItemSelectEvent")
    UtilsBase.ReleaseTable(self, "eventNameList")
    UtilsBase.ReleaseTable(self, "itemDict")
    for key, itemPoolList in pairs(self.itemPoolListDict) do
        for i = 1, #itemPoolList do
            itemPoolList[i]:Release()
        end
    end
    self.itemPoolListDict = nil
end

-- public function --
function LMIScrollView:SetGap(gapVertical)
    self.gapVertical = gapVertical
end

function LMIScrollView:AddItemEvent(eventName)
    if self.eventNameList == nil then
        self.eventNameList = {}
    end
    table.insert(self.eventNameList, eventName)
    self[eventName] = LocalEvent.New()
end

function LMIScrollView:SetCommonData(commonData)
    self.commonData = commonData
    for _, item in pairs(self.itemDict) do
        item:SetCommonData(commonData)
    end
end

-- dataList的结构为
-- {
--     {type = itemType, data = data},
--     {type = itemType, data = data},
--     {type = itemType, data = data},
-- }
function LMIScrollView:SetData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData
    self:_InitData(dataList)

    self.startIndex = self:_GetStartIndex()
    self.endIndex = self:_GetEndIndex()
    self:_PushUnUsedItem()
    if not self:_IsDataListEmpty() then
        if self.itemDict == nil then self.itemDict = {} end
        for index = self.startIndex, self.endIndex do
            local item = self:_GetItem(index)
            item:SetActive(true)
            item:SetData(self.dataList[index], commonData)
            item:SetPosition(Vector2(0, self.yList[index]))
            self.itemDict[index] = item
        end 
    end
    self:_AdjustContentPosition()
end

function LMIScrollView:ResetPosition()
    self.contentTrans.anchoredPosition = Vector2.zero
    self.scrollRect:StopMovement()
end

function LMIScrollView:Focus(index, tweenMove)
    if not self.yList[index] then
        return
    end
    self.scrollRect:StopMovement()
    local targetY = -self.yList[index]
    local maxY = self.height - self.maskHeight
    if targetY > maxY then
        targetY = maxY
    end
    if tweenMove then
        self.focusTweenId = Tween.GetInstance():MoveLocalY(self.contentTrans.gameObject, targetY, 0.3, function()
            self.focusTweenId = nil
        end).id
    else
        UtilsUI.SetAnchoredY(self.contentTrans, targetY)
    end
end

-- public function end --

function LMIScrollView:_InitData(dataList)
    local y = 0
    self.yList = {}
    if dataList then
        for i = 1, #dataList do
            local data = dataList[i]
            local type = data.type
            table.insert(self.yList, y)
            y = y - self.itemTypeDict[type].height - self.gapVertical
        end
    end
    self.contentTrans.sizeDelta = Vector2(self.width, -y)
    self.height = -y
end

function LMIScrollView:_OnValueChanged(value)
    if self:_IsDataListEmpty() then
        return
    end
    if self.startIndex ~= self:_GetStartIndex() or
        self.endIndex ~= self:_GetEndIndex() then
        self:_Update()
    end
end

function LMIScrollView:_Update()
    self.startIndex = self:_GetStartIndex()
    self.endIndex = self:_GetEndIndex()
    self:_PushUnUsedItem()
    for index = self.startIndex, self.endIndex do
        local item, getWay = self:_GetItem(index)
        if getWay ~= LDefine.GetItemWay.exist then
            item:SetActive(true)
            item:SetData(self.dataList[index], self.commonData)
            item:SetPosition(Vector2(0, self.yList[index]))
            self.itemDict[index] = item
        end
    end
end

function LMIScrollView:_GetIndexByY(targetY)
    if self:_IsDataListEmpty() then
        return 0
    end
    local startIndex = 1
    local endIndex = #self.dataList
    if endIndex <= startIndex then
        return 1
    end
    local result
    while true do
        local mid = math.floor((startIndex + endIndex) / 2)
        local itemType = self.dataList[mid].type
        local y = self.yList[mid]
        local height = self.itemTypeDict[itemType].height
        if y > targetY and targetY >= (y - height) then
            result = mid
            break
        end
        if targetY >= y then
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

function LMIScrollView:_GetData(index)
    if self.dataList then
        return self.dataList[index]
    end
end

function LMIScrollView:_IsDataListEmpty()
    return self.dataList == nil or next(self.dataList) == nil
end

function LMIScrollView:_GetItem(index)
    local itemType = self.dataList[index].type
    if self.itemDict and self.itemDict[index] then
        local item = self.itemDict[index]
        if item:GetItemType() == itemType then
            return item, LDefine.GetItemWay.exist
        else
            self:_PushPool(item)
        end
    elseif self.itemPoolListDict[itemType] and #self.itemPoolListDict[itemType] > 0 then
        local itemPoolList = self.itemPoolListDict[itemType]
        local item = table.remove(itemPoolList)
        item:InitFromCache(index) 
        return item, LDefine.GetItemWay.cache
    end
    local itemConfig = self.itemTypeDict[itemType]
    local go = GameObject.Instantiate(itemConfig.template)
    go.transform:SetParent(self.contentTrans, false)
    local item = itemConfig.itemType.New(go)
    item:SetIndex(index)
    item:SetItemType(itemType)
    item.ItemSelectEvent:AddListener(function(index, item) self.ItemSelectEvent:Dispatcher(index, item) end)
    if self.eventNameList then
        for i = 1, #self.eventNameList do
            local eventName = self.eventNameList[i]
            item[eventName]:AddListener(function(...) self[eventName]:Dispatcher(...) end)
        end
    end
    return item, LDefine.GetItemWay.new
end

function LMIScrollView:_GetStartIndex()
    return self:_GetIndexByY(self:_GetMaskTop())
end

function LMIScrollView:_GetEndIndex()
    return self:_GetIndexByY(self:_GetMaskBottom()) 
end

function LMIScrollView:_GetMaskTop()
    return -self.contentTrans.anchoredPosition.y
end

function LMIScrollView:_GetMaskBottom()
    return -self.contentTrans.anchoredPosition.y - self.maskHeight 
end

function LMIScrollView:_PushPool(item)
    item:SetActive(false)
    self.itemDict[item.index] = nil
    local itemType = item:GetItemType()
    if self.itemPoolListDict[itemType] == nil then
        self.itemPoolListDict[itemType] = {}
    end
    table.insert(self.itemPoolListDict[itemType], item)
end

function LMIScrollView:_PushUnUsedItem()
    if self.itemDict then
        for index, item in pairs(self.itemDict) do
            if index < self.startIndex or
                index > self.endIndex then
                self:_PushPool(item)
            else
                local data = self:_GetData(index)
                if data == nil or data.type ~= item:GetItemType() then
                    self:_PushPool(item)
                end
            end
        end
    end
end

function LMIScrollView:_AdjustContentPosition()
    local maxY = self.height - self.maskHeight
    maxY = maxY < 0 and 0 or maxY
    if self.contentTrans.anchoredPosition.y > maxY then
        UtilsUI.SetAnchoredY(self.contentTrans, maxY)
    end
end