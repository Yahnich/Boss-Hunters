modifier_defensive_armor = class(talentBaseClass)

function modifier_defensive_armor:OnCreated()
	self:OnRefresh()
end

function modifier_defensive_armor:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Defensive", "ARMOR" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_defensive_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_defensive_armor:GetModifierPhysicalArmorBonus()
	return self.value
end