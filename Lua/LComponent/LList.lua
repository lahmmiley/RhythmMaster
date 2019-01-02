LList = LList or BaseClass()

function LList:__init(transform, itemType, row, column, direction)
    self.transform = transform
    self.gameObject = transform.gameObject
    self.itemType = itemType
    self.row = row or UtilsBase.INT32_MAX
    self.column = column or UtilsBase.INT32_MAX
    self.layoutDirection = direction or LDefine.Direction.horizontal
    self.gapHorizontal = 0
    self.gapVertical = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0

    self:_InitItem(transform:Find(LDefine.ITEM_NAME))

    self.cacheList = {}
    self.itemList = {}
    self.ItemSelectEvent = LocalEvent.New()
end

function LList:_InitItem(transform)
    self.template = transform.gameObject
    self.template:SetActive(false)
end

function LList:__release()
    UtilsBase.ReleaseField(self, "ItemSelectEvent")
    UtilsBase.ReleaseTable(self, "cacheList")
    UtilsBase.ReleaseTable(self, "eventNameList")
end

function LList:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
end

function LList:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
end

function LList:AddItemEvent(eventName)
    if self.eventNameList == nil then
        self.eventNameList = {}
    end
    table.insert(self.eventNameList, eventName)
    self[eventName] = LocalEvent.New()
end

function LList:SetData(dataList, commonData)
    if dataList then
        for index, data in ipairs(dataList) do
            local item = self:_GetItem(index)
            item:SetActive(true)
            item:SetData(data, commonData)
            self.itemList[index] = item
        end
    end
    self:_HideCacheList(dataList)
    self:Layout()
end

function LList:Layout()
    if next(self.itemList) == nil then
        self.transform.sizeDelta = Vector2(0, 0)
        return
    end
    local x = self.paddingLeft
    local y = -self.paddingTop
    local pageXMin = self.paddingLeft
    local pageXMax = self.paddingLeft
    local pageYMax = -self.paddingTop
    local xMax = x
    local yMin = y
    local pageColumnMax
    local pageRowMax
    --超过一页之后是从左往右排序
    for index, item in ipairs(self.itemList) do
        local size = item:GetSize()
        item:SetPosition(Vector2(x, y))
        if self:_GetPageIndex(index) == 1 then
            pageColumnMax, pageRowMax = self:_CalcPageInfo(#self.itemList, index)
        end

        local borderX = x + size.x
        local borderY = y - size.y
        if borderX > pageXMax then pageXMax = borderX end
        if borderX + self.paddingRight > xMax then
            xMax = borderX + self.paddingRight
        end
        if borderY - self.paddingBottom < yMin then
            yMin = borderY - self.paddingBottom
        end

        if self:_GetPageRow(index) == pageRowMax and self:_GetPageColumn(index) == pageColumnMax then --下一页第一个Item
            x = pageXMax + self.gapHorizontal
            y = pageYMax
            pageXMin = x
        else
            x, y = self:_CalcNextItemPosition(index, x, y, size, pageXMin, pageYMax, pageColumnMax, pageRowMax)
        end
    end
    self.transform.sizeDelta = Vector2(xMax, -yMin)
end

function LList:GetSize()
    return self.transform.sizeDelta
end

function LList:SetActive(active)
    self.gameObject:SetActive(active)
end

function LList:GetItemCount()
    return #self.itemList
end

function LList:GetItem(index)
    return self.itemList[index]
end

function LList:GetItemList()
    return self.itemList
end

-- private function --
function LList:_CalcPageInfo(totalLength, pageEndIndex)
    if self:_IsHorizontalLayout() then
        local pageLength = (#self.itemList - pageEndIndex + 1)
        local pageColumnMax = pageLength > self.column and self.column or pageLength
        local pageRowMax = math.floor((pageLength - 1) / self.column) + 1
        if pageRowMax > self.row then
            pageRowMax = self.row
        end
        return pageColumnMax, pageRowMax
    else
        local pageLength = (#self.itemList - pageEndIndex + 1)
        local pageRowMax = pageLength > self.row and self.row or pageLength
        local pageColumnMax = math.floor((pageLength - 1) / self.row) + 1
        if pageColumnMax > self.column then
            pageColumnMax = self.column
        end
        return pageColumnMax, pageRowMax
    end
end

function LList:_CalcNextItemPosition(index, x, y, size, pageXMin, pageYMax, pageColumnMax, pageRowMax)
    if self:_IsHorizontalLayout() then
        if self:_GetPageColumn(index) == pageColumnMax then
            y = y - size.y - self.gapVertical
            x = pageXMin
        else
            x = x + size.x + self.gapHorizontal
        end
    else
        if self:_GetPageRow(index) == pageRowMax then
            y = pageYMax
            x = x + size.x + self.gapHorizontal
        else
            y = y - size.y - self.gapVertical
        end
    end
    return x, y
end

function LList:_GetItem(index)
    local item = self.cacheList[index]
    if item == nil then
        local go = GameObject.Instantiate(self.template)
        go.name = LDefine.ITEM_NAME .. tostring(index)
        go.transform:SetParent(self.transform, false)
        item = self.itemType.New(go)
        item:SetIndex(index)
        self.cacheList[index] = item
        item.ItemSelectEvent:AddListener(function(index, item) self.ItemSelectEvent:Dispatcher(index, item) end)
        if self.eventNameList then
            for i = 1, #self.eventNameList do
                local eventName = self.eventNameList[i]
                item[eventName]:AddListener(function(...) self[eventName]:Dispatcher(...) end)
            end
        end
    end
    return item
end

function LList:_HideCacheList(dataList)
    local startIndex = dataList and (#dataList + 1) or 1
    for i = startIndex, #self.cacheList do
        self.itemList[i] = nil
        self.cacheList[i]:SetActive(false)
    end
end

function LList:_IsHorizontalLayout()
    return self.layoutDirection == LDefine.Direction.horizontal
end

function LList:_GetPageRow(index)
    local index = self:_GetPageIndex(index)
    if self:_IsHorizontalLayout() then
        return math.floor((index - 1) / self.column) + 1
    else
        return (index - 1) % self.row + 1
    end
end

function LList:_GetPageColumn(index)
    local index = self:_GetPageIndex(index)
    if self:_IsHorizontalLayout() then
        return (index - 1) % self.column + 1
    else
        return math.floor((index - 1) / self.row) + 1
    end
end

function LList:_GetPageIndex(index)
    return (index - 1) % (self.row * self.column) + 1
end
