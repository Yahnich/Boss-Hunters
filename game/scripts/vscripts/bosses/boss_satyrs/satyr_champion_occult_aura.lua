satyr_champion_occult_aura = class({})

function satyr_champion_occult_aura:GetIntrinsicModifierName()
	return "modifier_satyr_champion_occult_aura"
end

modifier_satyr_champion_occult_aura = class({})
LinkLuaModifier("modifier_satyr_champion_occult_aura", "bosses/boss_satyrs/satyr_champion_occult_aura", LUA_MODIFIER_MOTION_NONE)
function modifier_satyr_champion_occult_aura:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_satyr_champion_occult_aura:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_satyr_champion_occult_aura:IsAura()
	return true
end

function modifier_satyr_champion_occult_aura:GetAuraEntityReject(entity)
	return entity == self:GetParent()
end

function modifier_satyr_champion_occult_aura:GetModifierAura()
	return "modifier_satyr_champion_occult_aura_buff"
end

function modifier_satyr_champion_occult_aura:GetAuraRadius()
	return self.radius
end

function modifier_satyr_champion_occult_aura:GetAuraDuration()
	return 0.5
end

function modifier_satyr_champion_occult_aura:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_satyr_champion_occult_aura:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_satyr_champion_occult_aura:IsHidden()
	return true
end

modifier_satyr_champion_occult_aura_buff = class({})
LinkLuaModifier("modifier_satyr_champion_occult_aura_buff", "bosses/boss_satyrs/satyr_champion_occult_aura", LUA_MODIFIER_MOTION_NONE)

function modifier_satyr_champion_occult_aura_buff:OnCreated()
	self.regen = self:GetSpecialValueFor("hp_regen")
end

function modifier_satyr_champion_occult_aura_buff:OnRefresh()
	self.regen = self:GetSpecialValueFor("hp_regen")
end

function modifier_satyr_champion_occult_aura_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_satyr_champion_occult_aura_buff:GetModifierConstantHealthRegen()
	return self.regen
end