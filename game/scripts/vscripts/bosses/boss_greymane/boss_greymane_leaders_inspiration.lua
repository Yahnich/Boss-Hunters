boss_greymane_leaders_inspiration = class({})

function boss_greymane_leaders_inspiration:GetIntrinsicModifierName()
	return "modifier_boss_greymane_leaders_inspiration"
end

modifier_boss_greymane_leaders_inspiration = class({})
LinkLuaModifier( "modifier_boss_greymane_leaders_inspiration", "bosses/boss_greymane/boss_greymane_leaders_inspiration", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_greymane_leaders_inspiration:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_greymane_leaders_inspiration:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_greymane_leaders_inspiration:IsAura()
	return not self:GetCaster():PassivesDisabled()
end

function modifier_boss_greymane_leaders_inspiration:GetModifierAura()
	return "modifier_boss_greymane_leaders_inspiration_buff"
end

function modifier_boss_greymane_leaders_inspiration:GetAuraRadius()
	return self.radius
end

function modifier_boss_greymane_leaders_inspiration:GetAuraDuration()
	return 0.5
end

function modifier_boss_greymane_leaders_inspiration:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_boss_greymane_leaders_inspiration:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_greymane_leaders_inspiration:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_boss_greymane_leaders_inspiration:IsHidden()
	return true
end

modifier_boss_greymane_leaders_inspiration_buff = class({})
LinkLuaModifier( "modifier_boss_greymane_leaders_inspiration_buff", "bosses/boss_greymane/boss_greymane_leaders_inspiration", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_greymane_leaders_inspiration_buff:OnCreated()
	self.as = self:GetSpecialValueFor("as_per_hp")
	self.boss_as = self:GetSpecialValueFor("greymane_as_per_hp")
end

function modifier_boss_greymane_leaders_inspiration_buff:OnRefresh()
	self.as = self:GetSpecialValueFor("as_per_hp")
	self.boss_as = self:GetSpecialValueFor("greymane_as_per_hp")
end

function modifier_boss_greymane_leaders_inspiration_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_boss_greymane_leaders_inspiration_buff:GetModifierAttackSpeedBonus_Constant()
	local hpPct = (100 - self:GetCaster():GetHealthPercent())
	local attackspeed = 0
	if self:GetParent() == self:GetCaster() then
		attackspeed = hpPct * self.boss_as
	else
		attackspeed = hpPct * self.as
	end
	return attackspeed
end