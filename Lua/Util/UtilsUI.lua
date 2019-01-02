-- --------------------------------
-- UI工具类
-- --------------------------------
UtilsUI = UtilsUI or BaseClass()

function UtilsUI.SetPivot(rect, newPivot)
    local sizeDelta = rect.sizeDelta
    local oldPivot = rect.pivot
    rect.pivot = newPivot
    local oldPosition = rect.anchoredPosition
    local newX = oldPosition.x + sizeDelta.x * (newPivot.x - oldPivot.x)
    local newY = oldPosition.y + sizeDelta.y * (newPivot.y - oldPivot.y)
    rect.anchoredPosition = Vector2(newX, newY)
end

function UtilsUI.GetRectTransform(transform, path)
    if path == nil or path == "" then
        return transform:GetComponent(RectTransform)
    end
    return transform:Find(path):GetComponent(RectTransform)
end

function UtilsUI.GetText(transform, path)
    if path == nil or path == "" then
        return transform:GetComponent(Text)
    end
    return transform:Find(path):GetComponent(Text)
end

function UtilsUI.GetImage(transform, path)
    if path == nil or path == "" then
        return transform:GetComponent(Image)
    end
    return transform:Find(path):GetComponent(Image)
end

function UtilsUI.GetButton(transform, path)
    if path == nil or path == "" then
        return transform:GetComponent(Button)
    end
    return transform:Find(path):GetComponent(Button)
end

function UtilsUI.GetInput(transform, path)
    if path == nil or path == "" then
        return transform:GetComponent(InputField)
    end
    return transform:Find(path):GetComponent(InputField)
end

function UtilsUI.GetScrollRect(transform, path)
    if path == nil or path == "" then
        return transform:GetComponent(ScrollRect)
    end
    return transform:Find(path):GetComponent(ScrollRect)
end

function UtilsUI.GetSlider(transform, path)
    if path == nil or path == "" then
        return transform:GetComponent(Slider)
    end
    return transform:Find(path):GetComponent(Slider)
end

function UtilsUI.GetToggle(transform, path)
    if path == nil or path == "" then
        return transform:GetComponent(Toggle)
    end
    return transform:Find(path):GetComponent(Toggle)
end

function UtilsUI.AddButtonListener(transform, path, callback)
    UtilsUI.GetButton(transform, path).onClick:AddListener(callback)
end

function UtilsUI.RemoveButtonListener(transform, path, callback)
    UtilsUI.GetButton(transform, path).onClick:RemoveListener(callback)
end

function UtilsUI.GetCanvasGroup(transform, path)
    if path == nil or path == "" then
        return transform:GetComponent(CanvasGroup)
    end
    return transform:Find(path):GetComponent(CanvasGroup)
end

function UtilsUI.SetWidth(rect, width)
    local sizeDelta = rect.sizeDelta
    rect.sizeDelta = Vector2(width, sizeDelta.y)
end

function UtilsUI.SetHeight(rect, height)
    local sizeDelta = rect.sizeDelta
    rect.sizeDelta = Vector2(sizeDelta.x, height)
end

function UtilsUI.SetPreferredWidth(text)
    local sizeDelta = text.transform.sizeDelta
    text.transform.sizeDelta = Vector2(text.preferredWidth, sizeDelta.y)
end

function UtilsUI.SetPreferredHeight(text)
    local sizeDelta = text.transform.sizeDelta
    text.transform.sizeDelta = Vector2(sizeDelta.x, text.preferredHeight)
end

function UtilsUI.SetAnchoredX(transform, x)
     local position = transform.anchoredPosition
    transform.anchoredPosition = Vector2(x, position.y)
end

function UtilsUI.SetAnchoredY(transform, y)
    local position = transform.anchoredPosition
    transform.anchoredPosition = Vector2(position.x, y)
end

function UtilsUI.SetX(transform, x)
    local lx, ly, lz = transform.localPosition.x, transform.localPosition.y, transform.localPosition.z
    transform.localPosition = Vector3(x, ly, lz)
end

function UtilsUI.SetY(transform, y)
    local lx, ly, lz = transform.localPosition.x, transform.localPosition.y, transform.localPosition.z
    transform.localPosition = Vector3(lx, y, lz)
end

function UtilsUI.SetZ(transform, z)
    local lx, ly, lz = transform.localPosition.x, transform.localPosition.y, transform.localPosition.z
    transform.localPosition = Vector3(lx, ly, z)
end
