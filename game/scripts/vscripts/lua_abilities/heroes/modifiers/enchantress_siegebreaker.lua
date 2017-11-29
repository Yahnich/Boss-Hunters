modifier_enchantress_siegebreaker = class({})


function modifier_enchantress_siegebreaker:OnCreated( kv )
	self.attackrange = self:GetAbility():GetSpecialValueFor( "bonus_attack_range" )
	self.projectilespeed = self:GetAbility():GetSpecialValueFor( "bonus_projectile_speed" )
	self.damageamp = self:GetAbility():GetSpecialValueFor( "damage_amp" )
	self.selfslow = self:GetAbility():GetSpecialValueFor( "moveslow" )
end

--------------------------------------------------------------------------------

function modifier_enchantress_siegebreaker:OnRefresh( kv )
	self.attackrange = self:GetAbility():GetSpecialValueFor( "bonus_attack_range" )
	self.projectilespeed = self:GetAbility():GetSpecialValueFor( "bonus_projectile_speed" )
	self.damageamp = self:GetAbility():GetSpecialValueFor( "damage_amp" )
	if IsServer() then
		self.selfslow = self:GetAbility():GetTalentSpecialValueFor( "moveslow" )
	end
end

--------------------------------------------------------------------------------

function modifier_enchantress_siegebreaker:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_enchantress_siegebreaker:GetModifierProjectileSpeedBonus( params )
	return self.projectilespeed
end

------------------------------------------------------------------------------

function modifier_enchantress_siegebreaker:GetModifierTotalDamageOutgoing_Percentage( params )
	return self.damageamp
end

------------------------------------------------------------------------------

function modifier_enchantress_siegebreaker:GetModifierAttackRangeBonus( params )
	return self.attackrange
end

------------------------------------------------------------------------------

function modifier_enchantress_siegebreaker:GetModifierMoveSpeed_Absolute( params )
	return self.selfslow
end

