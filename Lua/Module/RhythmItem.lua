RhythmItem = RhythmItem or BaseClass()

function RhythmItem:__init(config, objectPool)
    self:Reset(config, objectPool)
end

function RhythmItem:Reset(config, objectPool)
    self.config = config
    self.objectPool = objectPool
    self.gameObject = objectPool:Get()
end

function RhythmItem:PushBack()
    self.objectPool:PushBack(self.gameObject)
    self.gameObject = nil
end

function RhythmItem:__release()
    self.objectPool = nil
    self.gameObject = nil
end

function RhythmItem:SetData()
end
