boss_alpha_wolf_aura = class({})

function boss_alpha_wolf_aura:GetIntrinsicModifierName()
	return "modifier_boss_alpha_wolf_aura"
end

modifier_boss_alpha_wolf_aura = class({})
LinkLuaModifier("modifier_boss_alpha_wolf_aura", "bosses/boss_wolves/boss_alpha_wolf_aura", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_alpha_wolf_aura:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_alpha_wolf_aura:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_alpha_wolf_aura:IsAura()
	return true
end

function modifier_boss_alpha_wolf_aura:GetModifierAura()
	return "modifier_boss_alpha_wolf_aura_buff"
end

function modifier_boss_alpha_wolf_aura:GetAuraRadius()
	return self.radius
end

function modifier_boss_alpha_wolf_aura:GetAuraDuration()
	return 0.5
end

function modifier_boss_alpha_wolf_aura:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_boss_alpha_wolf_aura:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_alpha_wolf_aura:IsHidden()    
	return true
end

modifier_boss_alpha_wolf_aura_buff = class({})
LinkLuaModifier("modifier_boss_alpha_wolf_aura_buff", "boss", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_alpha_wolf_aura_buff:OnCreated()
	self.dmg = self:GetSpecialValueFor("damage")
	self.armor = self:GetSpecialValueFor("armor")
end

function modifier_boss_alpha_wolf_aura_buff:OnRefresh()
	self.dmg = self:GetSpecialValueFor("damage")
	self.armor = self:GetSpecialValueFor("armor")
end

function modifier_boss_alpha_wolf_aura_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_boss_alpha_wolf_aura_buff:GetModifierBaseDamageOutgoing_Percentage()
	return self.dmg
end

function modifier_boss_alpha_wolf_aura_buff:GetModifierPhysicalArmorBonus()
	return self.armor
end