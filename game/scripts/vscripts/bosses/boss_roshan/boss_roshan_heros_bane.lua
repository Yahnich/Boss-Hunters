boss_roshan_heros_bane = class({})

function boss_roshan_heros_bane:GetIntrinsicModifierName()
	return "modifier_boss_roshan_heros_bane"
end

modifier_boss_roshan_heros_bane = class({})
LinkLuaModifier( "modifier_boss_roshan_heros_bane", "bosses/boss_roshan/boss_roshan_heros_bane", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_roshan_heros_bane:OnCreated()
	self.amp = self:GetSpecialValueFor("dmg_amp")
	self.red = self:GetSpecialValueFor("dmg_red")
	self.radius = self:GetSpecialValueFor("radius")
	if IsServer() then
		self:StartIntervalThink(0.25)
	end
end

function modifier_boss_roshan_heros_bane:OnRefresh()
	self.amp = self:GetSpecialValueFor("dmg_amp")
	self.red = self:GetSpecialValueFor("dmg_red")
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_roshan_heros_bane:OnIntervalThink()
	local heroes = 0
	local units = self:GetCaster():FindEnemyUnitsInRadius( self:GetCaster():GetAbsOrigin(), self.radius )
	for _, unit in ipairs( units ) do
		if unit:IsHero() then
			heroes = heroes + 1
		end
	end
	self.heroes = heroes
	self.units = #units
end

function modifier_boss_roshan_heros_bane:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function modifier_boss_roshan_heros_bane:GetModifierTotalDamageOutgoing_Percentage()
	return self.amp * (self.units or 0)
end

function modifier_boss_roshan_heros_bane:GetModifierIncomingDamage_Percentage()
	return self.red * (self.heroes or 0)
end

function modifier_boss_roshan_heros_bane:IsHidden()
	return true
end