modifier_attacker_area_damage = class(talentBaseClass)

function modifier_attacker_area_damage:OnCreated()
	self:OnRefresh()
end

function modifier_attacker_area_damage:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Attacker", "AREA_DAMAGE" )
	self.value = tonumber(self.values[self.tier])
	self:GetParent():HookInModifier( "GetModifierAreaDamage", self )
end

function modifier_attacker_area_damage:OnDestroy()
	self:GetParent():HookOutModifier( "GetModifierAreaDamage", self )
end

function modifier_attacker_area_damage:GetModifierAreaDamage()
	return self.value
end