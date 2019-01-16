RhythmItem = RhythmItem or BaseClass()

RhythmItem.ColorRed = Color(1, 0, 0)
RhythmItem.ColorBlue = Color(0, 0, 1)
RhythmItem.ItemWidth = 64

function RhythmItem:__init(template)
    self.gameObject = GameObject.Instantiate(template)
    self.gameObject:SetActive(true)
    local transform = self.gameObject.transform
    self.transform = transform
    self.image = UtilsUI.GetImage(transform)
end

function RhythmItem:SetParent(parent, position)
    self.transform:SetParent(parent)
    self.transform.localScale = Vector3One
    self.transform.anchoredPosition3D = position
    self.x = position.x
end

function RhythmItem:SetActive(active)
    self.gameObject:SetActive(active)
end

function RhythmItem:Recycle()
    self.transform.anchoredPosition3D = Vector3OutOfView
end

function RhythmItem:GetX()
    return self.x
end

function RhythmItem:__release()
    self.gameObjectPool = nil
    self.gameObject = nil
end

function RhythmItem:SetData(config)
    self.gameObject.name = "Item" .. tostring(config.id)
    if config.type == 1 then
        self.image.color = RhythmItem.ColorRed
    else
        self.image.color = RhythmItem.ColorBlue
    end
end
