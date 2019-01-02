LRadarChart = LRadarChart or BaseClass()

function LRadarChart:__init(transform, radius)
    self.transform = transform
    self.gameObject = transform.gameObject
    self.radius = radius
    self.lMesh = self.gameObject:GetComponent(LMesh)
    self.lMesh:Init(radius)
    self.valueList = nil
    self.color = nil
end

function LRadarChart:SetColor(color)
    self.lMesh:SetColor(color)
end

function LRadarChart:SetData(valueList, color)
    self.lMesh:SetData(valueList)
end
