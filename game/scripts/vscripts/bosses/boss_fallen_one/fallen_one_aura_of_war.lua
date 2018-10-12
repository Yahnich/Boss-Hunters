fallen_one_aura_of_war = class({})

function fallen_one_aura_of_war:GetIntrinsicModifierName()
	return "modifier_fallen_one_aura_of_war"
end

modifier_fallen_one_aura_of_war = class({})
LinkLuaModifier("modifier_fallen_one_aura_of_war", "bosses/boss_fallen_one/fallen_one_aura_of_war", LUA_MODIFIER_MOTION_NONE)
function modifier_fallen_one_aura_of_war:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_fallen_one_aura_of_war:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_fallen_one_aura_of_war:IsAura()
	return not self:GetParent():PassivesDisabled()
end

function modifier_fallen_one_aura_of_war:GetAuraEntityReject(entity)
	return entity == self:GetParent()
end

function modifier_fallen_one_aura_of_war:GetModifierAura()
	return "modifier_fallen_one_aura_of_war_buff"
end

function modifier_fallen_one_aura_of_war:GetAuraRadius()
	return self.radius
end

function modifier_fallen_one_aura_of_war:GetAuraDuration()
	return 0.5
end

function modifier_fallen_one_aura_of_war:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_fallen_one_aura_of_war:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_fallen_one_aura_of_war:IsHidden()
	return true
end

modifier_fallen_one_aura_of_war_buff = class({})
LinkLuaModifier("modifier_fallen_one_aura_of_war_buff", "bosses/boss_fallen_one/fallen_one_aura_of_war", LUA_MODIFIER_MOTION_NONE)

function modifier_fallen_one_aura_of_war_buff:OnCreated()
	self.damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_fallen_one_aura_of_war_buff:OnRefresh()
	self.damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_fallen_one_aura_of_war_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_fallen_one_aura_of_war_buff:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage
end

function modifier_fallen_one_aura_of_war_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end