modifier_nuker_area_damage = class(talentBaseClass)

function modifier_nuker_area_damage:OnCreated()
	self:OnRefresh()
end

function modifier_nuker_area_damage:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Nuker", "AREA_DAMAGE" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_nuker_area_damage:GetModifierAreaDamage()
	return self.value
end