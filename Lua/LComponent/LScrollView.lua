LScrollView = LScrollView or BaseClass()

function LScrollView:__init(transform, itemType, row, column)
    self.gameObject = transform.gameObject
    self.itemType = itemType
    self.row = row or UtilsBase.INT32_MAX
    self.column = column or UtilsBase.INT32_MAX
    self.gapHorizontal = 0
    self.gapVertical = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0
    self.ItemSelectEvent = LocalEvent.New()
    self.ReachBottomEvent = LocalEvent.New()
    self.eventNameList = nil

    self.contentTrans = transform:Find(LDefine.MASK_NAME .."/" .. LDefine.CONTENT_NAME)
    self:_InitMask(transform:Find(LDefine.MASK_NAME))
    self:_InitTemplateItem()
    self:_InitScrollRect(transform)

    self.itemDict = nil
    self.itemPoolList = {}
    self.startIndex = nil
    self.endIndex = nil
end

function LScrollView:_InitMask(transform)
    local mask = transform:GetComponent(Mask)
    self.mask = mask
    self.maskWidth = mask.transform.sizeDelta.x
    self.maskHeight = mask.transform.sizeDelta.y
end

function LScrollView:_InitTemplateItem(transform)
    local template = self.contentTrans:Find(LDefine.ITEM_NAME).gameObject
    self.template = template
    template:SetActive(false)
end

function LScrollView:_InitScrollRect(transform)
    local scrollRect = transform:GetComponent(LScrollRect)
    self.scrollRect = scrollRect
    self.scrollRect.onValueChanged:AddListener(function(value) self:_OnValueChanged(value) end)
    if scrollRect.vertical then
        self.scrollDirection = LDefine.Direction.vertical
    else
        self.scrollDirection = LDefine.Direction.horizontal
    end
end

function LScrollView:__release()
    UtilsBase.ReleaseField(self, "ItemSelectEvent")
    UtilsBase.ReleaseField(self, "ReachBottomEvent")
    UtilsBase.ReleaseTable(self, "itemDict")
    UtilsBase.ReleaseTable(self, "itemPoolList")
    UtilsBase.ReleaseTable(self, "eventNameList")
end

-- public function
function LScrollView:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
    if self.gapHorizontal < 0 or self.gapVertical < 0 then
        pError("不支持gap小于0")
    end
end

function LScrollView:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
    if self.paddingLeft < 0 or
        self.paddingRight < 0 or
        self.paddingTop < 0 or
        self.paddingBottom < 0 then
        pError("不支持padding小于0")
    end
end

function LScrollView:AddItemEvent(eventName)
    if self.eventNameList == nil then
        self.eventNameList = {}
    end
    table.insert(self.eventNameList, eventName)
    self[eventName] = LocalEvent.New()
end

-- SetStartIndex之后需要调用SetData才生效
function LScrollView:SetStartIndex(index)
    self.startIndex = self:_GetStartIndex(index)
end

function LScrollView:_GetSetDataStartPosition(startIndex)
    local isFirst = startIndex == 1
    local x = self.paddingLeft
    local y = -self.paddingTop
    if not isFirst then
        if self:_IsVerticalScroll() then
            y = 0
        else
            x = 0
        end
    end
    return x, y
end

function LScrollView:SetData(dataList, commonData)
    self:_InitData(dataList, commonData)
    if dataList == nil then
        self:_ClearItemDict()
        self:_CalcSize()
        return
    end
    local startIndex = self.startIndex or 1
    if startIndex > #dataList then
        startIndex = 1
    end
    local x, y = self:_GetSetDataStartPosition(startIndex)
    if self.itemDict == nil then self.itemDict = {} end
    local endIndex = #dataList
    for index = startIndex, #dataList do
        local item = self:_GetItem(index)
        self.itemDict[index] = item
        item:SetActive(true)
        item:SetData(self.dataList[index], commonData)
        item:SetPosition(Vector2(x, y))
        local size = item:GetSize()
        if self:_IsVerticalScroll() then
            if self:_IsColumnMax(index) then
                y = y - (size.y + self.gapVertical)
                x = self.paddingLeft
            else
                x = x + size.x + self.gapHorizontal
            end
        else
            if self:_IsRowMax(index) then
                y = -self.paddingTop
                x = x + size.x + self.gapHorizontal
            else
                y = y - (size.y + self.gapVertical)
            end
        end
        if self:_EndOutMask(x, y) then
            endIndex = index
            break
        end
    end
    self.startIndex = startIndex
    self.endIndex = endIndex
    for index in pairs(self.itemDict) do
        if index < self.startIndex or index > self.endIndex then
            self:_PushPool(index)
        end
    end
    self:_CalcSize()
end

function LScrollView:_OnValueChanged(value)
    if self.dataList == nil or next(self.dataList) == nil then
        return
    end
    if not self:_ContentContainMask() then
        while(self:_CanAddAtStart()) do
            self:_RemoveEndOutMask()
            self:_AddAtStart()
        end
        while(self:_CanAddAtEnd()) do
            self:_RemoveStartOutMask()
            self:_AddAtEnd()
        end
    end
    self:_FireReachBottomEvent(value)
end

function LScrollView:_CanAddAtStart()
    return self.startIndex > 1 and self:_ContentStartInMask()
end

--AAS is short for AddAtStart
function LScrollView:_GetAASStartPosition(isFirst)
    local x = 0
    local y = 0
    if self:_IsVerticalScroll() then
        x = self.paddingLeft
        if isFirst then
            y = -self.paddingTop
        end
    else
        y = -self.paddingTop
        if isFirst then
            x = self.paddingLeft
        end
    end
    return x, y
end

--AAS is short for AddAtStart
function LScrollView:_AASCreateLine(addStartIndex, addEndIndex, x, y)
    local size
    for index = addStartIndex, addEndIndex do
        local item = self:_GetItem(index)
        item:SetActive(true)
        item:SetData(self.dataList[index], self.commonData)
        item:SetPosition(Vector2(x, y))
        size = item:GetSize()
        if not self:_IsVerticalScroll() then
            y = y - (size.y + self.gapVertical)
        else
            x = x + size.x + self.gapHorizontal
        end
        self.itemDict[index] = item
    end
    return size
end

--AAS is short for AddAtStart
function LScrollView:_AddAtStartTranslate(size, isFirst)
    local offset
    if self:_IsVerticalScroll() then
        local offsetY = -(size.y + self.gapVertical)
        if isFirst then
            offsetY = offsetY - self.paddingTop
        end
        offset = Vector2(0, offsetY)
    else
        local offsetX = size.x + self.gapHorizontal
        if isFirst then
            offsetX = offsetX + self.paddingLeft
        end
        offset = Vector2(offsetX, 0)
    end

    for index = self.startIndex, self.endIndex do
        local item = self.itemDict[index]
        item:Translate(offset)
    end
    self.scrollRect:ContentTranslate(-offset)
end

function LScrollView:_AddAtStart()
    local addEndIndex = self.startIndex - 1
    local addStartIndex = self:_GetStartIndex(addEndIndex)
    local isFirst = addStartIndex == 1
    local x, y = self:_GetAASStartPosition(isFirst)
    local size = self:_AASCreateLine(addStartIndex, addEndIndex, x, y)
    self:_AddAtStartTranslate(size, isFirst)
    self.startIndex = addStartIndex
    self:_CalcSize()
end

function LScrollView:_CanAddAtEnd()
    return self.endIndex < #self.dataList and self:_ContentEndInMask()
end

function LScrollView:_AddAtEndCreateLine(x, y)
    local addStartIndex = self.endIndex + 1
    local addEndIndex = self:_GetEndIndex(addStartIndex)
    if addEndIndex > #self.dataList then
        addEndIndex = #self.dataList
    end
    for index = addStartIndex, addEndIndex do
        local item = self:_GetItem(index)
        item:SetActive(true)
        item:SetData(self.dataList[index], self.commonData)
        item:SetPosition(Vector2(x, y))
        if self:_IsVerticalScroll() then
            x = x + item:GetSize().x + self.gapHorizontal
        else
            y = y - (item:GetSize().y + self.gapVertical)
        end
        self.itemDict[index] = item
    end
    return addEndIndex
end

function LScrollView:_AddAtEnd()
    local endLineStartIndex = self:_GetStartIndex(self.endIndex)
    local endItem = self.itemDict[endLineStartIndex]
    local endPosition = endItem:GetPosition()
    local size = endItem:GetSize()
    local x = endPosition.x
    local y = endPosition.y
    if self:_IsVerticalScroll() then
        x = self.paddingLeft
        y = y - (size.y + self.gapVertical)
    else
        y = -self.paddingTop
        x = x + size.x + self.gapHorizontal
    end
    self.endIndex = self:_AddAtEndCreateLine(x, y)
    self:_CalcSize()
end

function LScrollView:_RemoveStartOutMask()
    local startIndex = self.startIndex
    local startItem = self.itemDict[startIndex]
    if self:_IsOutOfMask(startItem) then
        local endIndex = self:_GetEndIndex(startIndex)
        if endIndex > #self.dataList then
            endIndex = #self.dataList
        end
        for index = startIndex, endIndex do
            self:_PushPool(index)
        end

        local size = startItem:GetSize()
        local isFirst = startIndex == 1
        local offset
        if self:_IsVerticalScroll() then
            local y = size.y + self.gapVertical
            if isFirst then y = y + self.paddingTop end
            offset = Vector2(0, y)
        else
            local x = -(size.x + self.gapHorizontal)
            if isFirst then x = x - self.paddingLeft end
            offset = Vector2(x, 0)
        end

        self.startIndex = endIndex + 1
        for index = self.startIndex, self.endIndex do
            local item = self.itemDict[index]
            item:Translate(offset)
        end
        self.scrollRect:ContentTranslate(-offset)
        self:_CalcSize()
        return true
    end
    return false
end

function LScrollView:_RemoveEndOutMask()
    local endIndex = self.endIndex
    local item = self.itemDict[endIndex]
    if self:_IsOutOfMask(item) then
        local startIndex = self:_GetStartIndex(endIndex)
        for index = startIndex, endIndex do
            self:_PushPool(index)
        end

        self.endIndex = startIndex - 1
        self:_CalcSize()
        return true
    end
    return false
end

function LScrollView:_FireReachBottomEvent(value)
    if self.endIndex == #self.dataList then
        if self:_IsVerticalScroll() then
            if value.y < -0.1 then
                if not self.reachBottomFire then
                    self.ReachBottomEvent:Dispatcher()
                    self.reachBottomFire = true
                end
            else
                self.reachBottomFire = false
            end
        else
            if value.x > 1.1 then
                if not self.reachBottomFire then
                    self.ReachBottomEvent:Dispatcher()
                    self.reachBottomFire = true
                end
            else
                self.reachBottomFire = false
            end
        end
    end
end

function LScrollView:_InitData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData
    local length = dataList and #dataList or 0
    if self:_IsVerticalScroll() then
        self.columnMax = length > self.column and self.column or length
        self.rowMax = math.floor((length - 1) / self.column) + 1
    else
        self.rowMax = length > self.row and self.row or length
        self.columnMax = math.floor((length - 1) / self.row) + 1
    end
end

function LScrollView:_CalcSize()
    if self.dataList == nil or next(self.dataList) == nil then
        self.contentTrans.sizeDelta = Vector2(0, 0)
        return
    end
    local right = UtilsBase.INT32_MIN
    local bottom = UtilsBase.INT32_MAX
    local startItem = self.itemDict[self.startIndex]
    local position = startItem:GetPosition()
    local left = position.x
    local top = position.y
    if self.startIndex == 1 then
        left = 0
        top = 0
    else
        if self:_IsVerticalScroll() then
            left = left - self.paddingLeft
        else
            top = top + self.paddingTop
        end
    end

    local currentColumnMax
    local currentRowMax
    if self:_IsVerticalScroll() then
        currentColumnMax = self.columnMax
        currentRowMax = self:_GetRow(self.endIndex)
    else
        currentColumnMax = self:_GetColumn(self.endIndex)
        currentRowMax = self.rowMax
    end

    for index = self.startIndex, self.endIndex do
        local item = self.itemDict[index]
        local position = item:GetPosition()
        local size = item:GetSize()
        if self:_GetColumn(index) == currentColumnMax then
            local padding = 0
            if self:_IsColumnMax(index) then
                padding = self.paddingRight
            end
            if (position.x + size.x + padding) > right then
                right = position.x + size.x + padding
            end
        end
        if self:_GetRow(index) == currentRowMax then
            local padding = 0
            if self:_IsRowMax(index) then
                padding = self.paddingBottom
            end
            if (position.y - size.y - padding) < bottom then
                bottom = position.y - size.y - padding
            end
        end
    end

    self.contentTrans.sizeDelta = Vector2(right - left, top - bottom)
end

function LScrollView:_IsOutOfMask(item)
    local position = item:GetPosition()
    if self:_IsVerticalScroll() then
        local top = position.y + self.gapVertical
        local bottom = position.y - item:GetSize().y - self.gapVertical
        if self:_BelowMaskBottom(top) or self:_AboveMaskTop(bottom) then
            return true
        end
    else
        local left = position.x - self.gapHorizontal
        local right = position.x + item:GetSize().x + self.gapHorizontal
        if self:_LessThanMaskLeft(right) or self:_GreaterThanMaskRight(left) then
            return true
        end
    end
    return false
end

function LScrollView:_GetItem(index)
    local item
    if self.itemDict and self.itemDict[index] then
        item = self.itemDict[index]
    elseif self.itemPoolList and #self.itemPoolList > 0 then
        item = table.remove(self.itemPoolList)
        item:InitFromCache(index)
    else
        local go = GameObject.Instantiate(self.template)
        go.transform:SetParent(self.contentTrans, false)
        item = self.itemType.New(go)
        item.ItemSelectEvent:AddListener(function(index, item)
            self.ItemSelectEvent:Dispatcher(index, item)
        end)
        if self.eventNameList then
            for i = 1, #self.eventNameList do
                local eventName = self.eventNameList[i]
                item[eventName]:AddListener(function(...) self[eventName]:Dispatcher(...) end)
            end
        end
        item:SetIndex(index)
    end
    return item
end

function LScrollView:_PushPool(index)
    local item = self.itemDict[index]
    table.insert(self.itemPoolList, item)
    item:SetActive(false)
    self.itemDict[index] = nil
end

function LScrollView:_ClearItemDict()
    if self.itemDict ~= nil then
        for index in pairs(self.itemDict) do
            self:_PushPool(index)
        end
    end
end

function LScrollView:_GetContentBound()
    return 0, self.contentTrans.sizeDelta.x, 0, -self.contentTrans.sizeDelta.y
end

function LScrollView:_GetMaskTop()
    return -self.contentTrans.anchoredPosition.y
end

function LScrollView:_GetMaskLeft()
    return -self.contentTrans.anchoredPosition.x
end

function LScrollView:_GetMaskBottom()
    return -self.contentTrans.anchoredPosition.y - self.maskHeight 
end

function LScrollView:_GetMaskRight()
    return -self.contentTrans.anchoredPosition.x + self.maskWidth
end

function LScrollView:_AboveMaskBottom(y)
    return y >= self:_GetMaskBottom()
end

function LScrollView:_GreaterThanMaskLeft(x)
    return x >= self:_GetMaskLeft()
end

function LScrollView:_BelowMaskTop(y)
    return y <= self:_GetMaskTop()
end

function LScrollView:_LessThanMaskRight(x)
    return x <= self:_GetMaskRight()
end

function LScrollView:_BelowMaskBottom(y)
    return y < self:_GetMaskBottom()
end

function LScrollView:_LessThanMaskLeft(x)
    return x < self:_GetMaskLeft()
end

function LScrollView:_AboveMaskTop(y)
    return y > self:_GetMaskTop()
end

function LScrollView:_GreaterThanMaskRight(x)
    return x > self:_GetMaskRight()
end

function LScrollView:_IsVerticalScroll()
    return self.scrollDirection == LDefine.Direction.vertical
end

function LScrollView:_ContentContainMask()
    local left, right, top, bottom = self:_GetContentBound()
    if self:_IsVerticalScroll() then
        return self:_AboveMaskTop(top) and self:_BelowMaskBottom(bottom)
    else
        return self:_LessThanMaskLeft(left) and self:_GreaterThanMaskRight(right)
    end
end

function LScrollView:_ContentStartInMask()
    local left, right, top, bottom = self:_GetContentBound()
    if self:_IsVerticalScroll() then
        return self:_BelowMaskTop(top)
    else
        return self:_GreaterThanMaskLeft(left)
    end
end

function LScrollView:_ContentEndInMask()
    local left, right, top, bottom = self:_GetContentBound()
    if self:_IsVerticalScroll() then
        return self:_AboveMaskBottom(bottom)
    else
        return self:_LessThanMaskRight(right)
    end
end

function LScrollView:_EndOutMask(x, y)
    if self:_IsVerticalScroll() then
        return self:_BelowMaskBottom(y)
    else
        return self:_GreaterThanMaskRight(x)
    end
end

function LScrollView:_IsRowMax(index)
    return self:_GetRow(index) == self.rowMax
end

function LScrollView:_IsColumnMax(index)
    return self:_GetColumn(index) == self.columnMax
end

function LScrollView:_GetRow(index)
    if self:_IsVerticalScroll() then
        return math.floor((index - 1) / self.column) + 1
    else
        return (index - 1) % self.row + 1
    end
end

function LScrollView:_GetColumn(index)
    if self:_IsVerticalScroll() then
        return (index - 1) % self.column + 1
    else
        return math.floor((index - 1) / self.row) + 1
    end
end

function LScrollView:_GetStartIndex(index)
    if self:_IsVerticalScroll() then
        return (self:_GetRow(index) - 1) * self.column + 1
    else
        return (self:_GetColumn(index) - 1) * self.row + 1
    end
end

function LScrollView:_GetEndIndex(index)
    if self:_IsVerticalScroll() then
        return self:_GetRow(index) * self.column
    else
        return self:_GetColumn(index) * self.row
    end
end