modifier_defender_armor = class(talentBaseClass)

function modifier_defender_armor:OnCreated()
	self:OnRefresh()
end

function modifier_defender_armor:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Defender", "ARMOR" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_defender_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_defender_armor:GetModifierPhysicalArmorBonus()
	return self.value
end