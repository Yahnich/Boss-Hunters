-- main class declaration

item_tempest_staff = class ({})

function item_tempest_staff:GetIntrinsicModifierName()
	return "modifier_item_tempest_staff_passive"
end

-- starting function for getting all the passive variables to the game, the function naming is consistent. 
-- there is no real way to rename or prevent duplication of item_tempest_staff. 
-- without this format the item in game will not provide any of the bonuses and abilities listed.


LinkLuaModifier("modifier_item_tempest_staff_passive", "items/item_tempest_staff", LUA_MODIFIER_MOTION_NONE)

modifier_item_tempest_staff_passive = class({})

-- new function and class declaration
-- linking to an external text file to get string numbers


function modifier_item_tempest_staff_passive:OnCreated()
	self.bonus_evasion = self:GetSpecialValueFor("bonus_evasion")
	self.bonus_strength = self:GetSpecialValueFor("bonus_strength")
	self.bonus_intellect = self:GetSpecialValueFor("bonus_intellect")
	self.bonus_movespeed = self:GetSpecialValueFor("bonus_movespeed")
end

-- function declarations to modify character statistics
-- evasion and movement speed changes are less noticeable than the other functions in text

function modifier_item_tempest_staff_passive:DeclareFunctions()
	
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_EVASION_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}

end

-- getters for the numbers used in the statistics change on the hero

function modifier_item_tempest_staff_passive:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed
end

function modifier_item_tempest_staff_passive:GetModifierEvasion_Constant()
	return self.bonus_evasion
end

function modifier_item_tempest_staff_passive:GetModifierBonusStats_Strength()
	return self.bonus_strength
end

function modifier_item_tempest_staff_passive:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end

-- for hiding a passive icon
-- usually if a buff is present there will be a circle with the item icon or a placeholder icon for it
-- the buff icon would provide information summary of its statistic benefits
-- this is not needed for this item since it is not an aura, so the information becomes redundant

function modifier_item_tempest_staff_passive:IsHidden()
	return true
end

-- required for multiple attributes modified

function modifier_item_tempest_staff_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- casting handler.
-- the purpose is to identify what the user targets with the staffs' ability

function item_tempest_staff:OnSpellStart()
	local caster = self:GetCaster()
	if self:GetCursorTarget():GetTeam() == self:GetCaster():GetTeam() then
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_tempest_staff_active_ally", {Duration = self:GetSpecialValueFor("active_duration")})
	else
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_tempest_staff_active_enemy", {Duration = self:GetSpecialValueFor("active_duration")})
	end
end

-- cast on ally functions
-- gives the listed benefits to an ally or the user if they target themself

modifier_item_tempest_staff_active_ally = class({})
LinkLuaModifier("modifier_item_tempest_staff_active_ally", "items/item_tempest_staff", LUA_MODIFIER_MOTION_NONE)

function modifier_item_tempest_staff_active_ally:OnCreated()
	self.active_movespeed = self:GetSpecialValueFor("active_movespeed")
	self.active_attackspeed = self:GetSpecialValueFor("active_attackspeed")
end

-- removing the benefits after the duration has expired

function modifier_item_tempest_staff_active_ally:OnDestroy()
	if IsServer() then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 128, true)
	end
end

-- giving the status of "flying" movement type
-- removes collisions that are impassible e.g. cliffs, units

function modifier_item_tempest_staff_active_ally:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] =  true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] =  true,}
end

-- handling movement limits
-- this is to prevent absurd movement speed from other item interactions that give move speed

function modifier_item_tempest_staff_active_ally:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
			MODIFIER_PROPERTY_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_MOVESPEED_MAX,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

-- getting the values and effects to apply to the casted target

function modifier_item_tempest_staff_active_ally:GetModifierMoveSpeed_AbsoluteMin()
	return self.active_movespeed
end

function modifier_item_tempest_staff_active_ally:GetModifierMoveSpeed_Limit()
	return self.active_movespeed
end

function modifier_item_tempest_staff_active_ally:GetModifierMoveSpeedBonus_Special_Boots()
	return self.active_movespeed
end

function modifier_item_tempest_staff_active_ally:GetModifierMoveSpeed_Max()
	return self.active_movespeed
end

function modifier_item_tempest_staff_active_ally:GetModifierAttackSpeedBonus_Constant()
	return self.active_attackspeed
end

-- this is an effect on the target for the duration

function modifier_item_tempest_staff_active_ally:GetEffectName()
	return "particles/econ/events/ti6/phase_boots_ti6.vpcf"
end

-- casted on enemy functions
-- gives the target the rooted and disarmed property with a visual indicator of a tornadow surrounding the target

modifier_item_tempest_staff_active_enemy = class({})

LinkLuaModifier("modifier_item_tempest_staff_active_enemy", "items/item_tempest_staff", LUA_MODIFIER_MOTION_NONE)

function modifier_item_tempest_staff_active_enemy:CheckState()

	return {[MODIFIER_STATE_DISARMED] = true, 
			[MODIFIER_STATE_ROOTED] = true}

end

-- the effect, credit to Sidearms for making the effect real quick.

function modifier_item_tempest_staff_active_enemy:GetEffectName()
	return "particles/heroes/sylph/sylph_cyclone.vpcf"
end