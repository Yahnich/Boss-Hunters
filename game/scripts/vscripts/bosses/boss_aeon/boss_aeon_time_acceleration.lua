boss_aeon_time_acceleration = class({})

function boss_aeon_time_acceleration:GetIntrinsicModifierName()
	return "modifier_boss_aeon_time_acceleration"
end

modifier_boss_aeon_time_acceleration = class({})
LinkLuaModifier("modifier_boss_aeon_time_acceleration", "bosses/boss_aeon/boss_aeon_time_acceleration", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aeon_time_acceleration:OnCreated()
	self.dmg = self:GetTalentSpecialValueFor("bonus_damage")
	self.ms = self:GetTalentSpecialValueFor("bonus_ms")
	if IsServer() then
		self:StartIntervalThink( self:GetTalentSpecialValueFor("growth_rate") )
	end
end

function modifier_boss_aeon_time_acceleration:OnRefresh()
	self.dmg = self:GetTalentSpecialValueFor("bonus_damage")
	self.ms = self:GetTalentSpecialValueFor("bonus_ms")
	if IsServer() then
		self:StartIntervalThink( self:GetTalentSpecialValueFor("growth_rate") )
	end
end

function modifier_boss_aeon_time_acceleration:OnIntervalThink()
	self:IncrementStackCount()
end

function modifier_boss_aeon_time_acceleration:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_aeon_time_acceleration:GetModifierBaseDamageOutgoing_Percentage()
	return self.dmg * self:GetTalentSpecialValueFor()
end

function modifier_boss_aeon_time_acceleration:GetModifierMoveSpeedBonus_Percentage()
	return self.ms * self:GetTalentSpecialValueFor()
end