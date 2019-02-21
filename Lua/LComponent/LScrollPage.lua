LScrollPage = LScrollPage or BaseClass()

function LScrollPage:__init(transform, itemType, row, column, direction)
    self.itemType = itemType
    self.row = row or 1
    self.column = column or 1
    self.itemLayoutDirection = direction or LDefine.Direction.horizontal
    self.gapHorizontal = 0
    self.gapVertical = 0
    self.paddingLeft = 0
    self.paddingRight = 0
    self.paddingTop = 0
    self.paddingBottom = 0
    self.perPageCount = self.row * self.column

    self.transform = transform
    self.contentTrans = transform:Find(LDefine.MASK_NAME .. "/" .. LDefine.CONTENT_NAME)
    self:_InitTemplateItem()
    self:_InitMask(transform:Find(LDefine.MASK_NAME))
    self:_InitScrollRect(transform)
    self:_InitDragEvent(transform)

    self.itemDict = {}
    self.itemPoolList = {}
    self.currentPage = 1
    self.dynamicCurrentPage = self.currentPage
    self.ItemSelectEvent = LocalEvent.New()
end

function LScrollPage:_InitMask(transform)
    self.mask = transform:GetComponent(Mask)
    self.maskImage = UtilsUI.GetImage(transform)
    self:_CalcMaskSize()
end

function LScrollPage:_CalcMaskSize()
    local maskWidth = self.paddingLeft + self.paddingRight + self.column * self.itemWidth + (self.column - 1) * self.gapHorizontal
    local maskHeight = self.paddingTop + self.paddingBottom + self.row * self.itemHeight + (self.row - 1) * self.gapVertical
    self.maskWidth = maskWidth
    self.maskHeight = maskHeight
    self.mask.transform.sizeDelta = Vector2(maskWidth, maskHeight)
end

function LScrollPage:_InitTemplateItem()
    local template = self.contentTrans:Find(LDefine.ITEM_NAME).gameObject
    self.template = template
    self.itemWidth = template.transform.sizeDelta.x
    self.itemHeight = template.transform.sizeDelta.y
    self.template:SetActive(false)
end

function LScrollPage:_InitScrollRect(transform)
    local scrollRect = transform:GetComponent(ScrollRect)
    self.scrollRect = scrollRect
    self.scrollRect.onValueChanged:AddListener(function() self:_OnValueChanged() end)
    scrollRect.inertia = false
    if scrollRect.vertical then
        self.pageLayoutDirection = LDefine.Direction.vertical
    else
        self.pageLayoutDirection = LDefine.Direction.horizontal
    end
end

function LScrollPage:_InitDragEvent(transform)
    local dragEvent = transform.gameObject:AddComponent(DragEvent)
    dragEvent.onBeginDrag:AddListener(function(value) self:_OnBeginDragEvent() end)
    dragEvent.onEndDrag:AddListener(function(value) self:_OnEndDragEvent() end)
end

function LScrollPage:__release()
    UtilsBase.ReleaseField(self, "ItemSelectEvent")
    UtilsBase.ReleaseTable(self, "eventNameList")
    UtilsBase.CancelTween(self, "tweenId")
    UtilsBase.ReleaseTable(self, "itemDict")
    UtilsBase.ReleaseTable(self, "itemPoolList")
end

function LScrollPage:_OnBeginDragEvent()
    UtilsBase.CancelTween(self, "tweenId")
    self.beginDragPosition = self.contentTrans.anchoredPosition
end

function LScrollPage:_OnEndDragEvent()
    local endDragPosition = self.contentTrans.anchoredPosition
    local page
    if self:_PageHorizontalLayout() then
        page = math.ceil(-endDragPosition.x / self.maskWidth)
        if endDragPosition.x < self.beginDragPosition.x then --鼠标向左拉动
            page = page + 1
        end
    else
        page = math.ceil(endDragPosition.y / self.maskHeight)
        if endDragPosition.y > self.beginDragPosition.y then --鼠标向上拉动
            page = page + 1
        end
    end
    page = Mathf.Clamp(page, 1, self.totalPage)
    self.currentPage = page
    self:_TweenMove(page)
end

function LScrollPage:_OnValueChanged()
    local dynamicCurrentPage = self:_GetDynamicCurrentPage()
    if self.dynamicCurrentPage ~= dynamicCurrentPage then
        self.dynamicCurrentPage = dynamicCurrentPage
        self.currentPage = self.dynamicCurrentPage
        self:_Update()
    end
end

-- public function
function LScrollPage:SetGap(gapHorizontal, gapVertical)
    self.gapHorizontal = gapHorizontal or 0
    self.gapVertical = gapVertical or 0
    self:_CalcMaskSize()
end

function LScrollPage:SetPadding(paddingLeft, paddingRight, paddingTop, paddingBottom)
    self.paddingLeft = paddingLeft or 0
    self.paddingRight = paddingRight or 0
    self.paddingTop = paddingTop or 0
    self.paddingBottom = paddingBottom or 0
    self:_CalcMaskSize()
end

function LScrollPage:AddItemEvent(eventName)
    if self.eventNameList == nil then
        self.eventNameList = {}
    end
    table.insert(self.eventNameList, eventName)
    self[eventName] = LocalEvent.New()
end

function LScrollPage:InitCurrentPage(page)
    self.initPage = page
end

function LScrollPage:SetCurrentPage(page, tween)
    local page = Mathf.Clamp(page, 1, self.totalPage)
    self.currentPage = page
    if tween then
        self:_TweenMove(page)
    else
        if self:_PageHorizontalLayout() then
            UtilsUI.SetAnchoredX(self.contentTrans, self:_GetTargetPosition(page).x)
        else
            UtilsUI.SetAnchoredY(self.contentTrans, self:_GetTargetPosition(page).y)
        end
        self.dynamicCurrentPage = self:_GetDynamicCurrentPage()
        self:_Update()
    end
end

function LScrollPage:GetTotalPage()
    return self.totalPage
end

function LScrollPage:SetData(dataList, commonData)
    self.dataList = dataList
    self.commonData = commonData
    if dataList == nil or next(dataList) == nil then
        self.initPage = nil
        self:_EmptyCacheItemList()
        self.contentTrans.sizeDelta = Vector2(0, 0)
        return
    end
    local initPage = self.initPage
    self.initPage = nil
    self.totalPage = math.ceil(#dataList / self.perPageCount)
    if initPage then
        self.currentPage = initPage
    end
    self.currentPage = math.min(self.currentPage, self.totalPage)

    local startIndex, endIndex = self:_GetIndexRange(self.currentPage)
    self:_HideOutRangeList(startIndex, endIndex)
    for index = startIndex, endIndex do
        local item = self:_GetItem(index)
        item:SetActive(true)
        item:SetData(dataList[index], commonData)
        self.itemDict[index] = item
    end
    self:_Layout()
    self:_CalculateSize()
    if initPage then
        self:SetCurrentPage(self.currentPage)
    end
    if self:_PageHorizontalLayout() then
        if (math.abs(self.contentTrans.localPosition.x)) > math.abs(self:_GetTargetPosition(self.totalPage).x) then
            UtilsUI.SetAnchoredX(self.contentTrans, self:_GetTargetPosition(self.totalPage).x)
        end
    else
        if (math.abs(self.contentTrans.localPosition.y)) > math.abs(self:_GetTargetPosition(self.totalPage).y) then
            UtilsUI.SetAnchoredY(self.contentTrans, self:_GetTargetPosition(self.totalPage).y)
        end
    end
end

-- private function
function LScrollPage:_TweenMove(page)
    if self:_PageHorizontalLayout() then
        self.tweenId = Tween.GetInstance():MoveLocalX(self.contentTrans.gameObject, self:_GetTargetPosition(page).x, 0.3).id
    else
        self.tweenId = Tween.GetInstance():MoveLocalY(self.contentTrans.gameObject, self:_GetTargetPosition(page).y, 0.3).id
    end
end

function LScrollPage:_CalculateSize()
    if self:_PageHorizontalLayout() then
        self.contentTrans.sizeDelta = Vector2(self.totalPage * self.maskWidth, self.maskHeight)
    else
        self.contentTrans.sizeDelta = Vector2(self.maskWidth, self.totalPage * self.maskHeight)
    end
end

function LScrollPage:_GetTargetPosition(page)
    if self:_PageHorizontalLayout() then
        return Vector2(-(page - 1) * self.maskWidth, 0)
    else
        return Vector2(0, (page - 1) * self.maskHeight)
    end
end

function LScrollPage:_HideOutRangeList(startIndex, endIndex)
    for index, item in pairs(self.itemDict) do
        if index < startIndex or endIndex < index then
            item:SetActive(false)
            self.itemDict[index] = nil
            table.insert(self.itemPoolList, item)
        end
    end
end

function LScrollPage:_GetIndexRange(currentPage)
    local startIndex = (currentPage - 2) * self.perPageCount + 1
    local endIndex = (currentPage + 1) * self.perPageCount
    return math.max(startIndex, 1), math.min(endIndex, #self.dataList)
end

function LScrollPage:_Layout()
    for index, item in pairs(self.itemDict) do
        local page = math.floor((index - 1) / self.perPageCount)
        local pageIndex = (index - 1) % self.perPageCount + 1
        local x, y
        local offset
        if self:_PageHorizontalLayout() then
            offset = Vector2(page * self.maskWidth, 0)
        else
            offset = Vector2(0, -page * self.maskHeight)
        end
        if self:_ItemHorizontalLayout() then
            column = (pageIndex - 1) % self.column + 1
            row = math.floor((pageIndex - 1) / self.column) + 1
        else
            row = (pageIndex - 1) % self.row + 1
            column = math.floor((pageIndex - 1) / self.row) + 1
        end
        x = self.paddingLeft + (column - 1) * (self.itemWidth + self.gapHorizontal)
        y = self.paddingTop + (row - 1) * (self.itemHeight + self.gapVertical)
        item:SetPosition(Vector2(x, -y) + offset)
    end
end

function LScrollPage:_EmptyCacheItemList()
    for index, item in pairs(self.itemDict) do
        item:SetActive(false)
        self.itemDict[index] = nil
    end
end

function LScrollPage:_Update()
    local startIndex, endIndex = self:_GetIndexRange(self.dynamicCurrentPage)
    self:_HideOutRangeList(startIndex, endIndex)
    for index = startIndex, endIndex do
        local item, getWay = self:_GetItem(index)
        item:SetActive(true)
        if getWay ~= LDefine.GetItemWay.exist then
            item:SetData(self.dataList[index], self.commonData)
        end
        self.itemDict[index] = item
    end
    self:_Layout()
end

function LScrollPage:_GetDynamicCurrentPage()
    local page
    if self:_PageHorizontalLayout() then
        page = math.ceil((-self.contentTrans.anchoredPosition.x + self.maskWidth / 2) / self.maskWidth)
    else
        page = math.ceil((self.contentTrans.anchoredPosition.y + self.maskHeight / 2) / self.maskHeight)
    end
    return Mathf.Clamp(page, 1, self.totalPage)
end

function LScrollPage:_GetItem(index)
    if self.itemDict[index] then
        return self.itemDict[index], LDefine.GetItemWay.exist
    elseif self.itemPoolList and #self.itemPoolList > 0 then
        item = table.remove(self.itemPoolList)
        item:InitFromCache(index) 
        return item, LDefine.GetItemWay.cache
    end
    local go = GameObject.Instantiate(self.template)
    go.transform:SetParent(self.contentTrans, false)
    local item = self.itemType.New(go)
    item:SetIndex(index)
    item.ItemSelectEvent:AddListener(function(index, item) self.ItemSelectEvent:Dispatcher(index, item) end)
    if self.eventNameList then
        for i = 1, #self.eventNameList do
            local eventName = self.eventNameList[i]
            item[eventName]:AddListener(function(...) self[eventName]:Dispatcher(...) end)
        end
    end
    return item, LDefine.GetItemWay.new
end

function LScrollPage:_ItemHorizontalLayout()
    return self.itemLayoutDirection == LDefine.Direction.horizontal
end

function LScrollPage:_PageHorizontalLayout()
    return self.pageLayoutDirection == LDefine.Direction.horizontal
end
