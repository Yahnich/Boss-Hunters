mars_bulwark_lua = class({})

function mars_bulwark_lua:IsStealable()
	return false
end

function mars_bulwark_lua:IsHiddenWhenStolen()
	return false
end

function mars_bulwark_lua:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier( caster, self, "modifier_mars_bulwark_toggle", {})
	else
		caster:RemoveModifierByName("modifier_mars_bulwark_toggle") 
	end
end

function mars_bulwark_lua:GetIntrinsicModifierName()
	return "modifier_mars_bulwark_lua"
end

modifier_mars_bulwark_toggle = class(toggleModifierBaseClass)
LinkLuaModifier( "modifier_mars_bulwark_toggle", "heroes/hero_mars/mars_bulwark_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_mars_bulwark_toggle:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
	self.threat = self:GetSpecialValueFor("threat_amp")
	self.projectile_chance = self:GetSpecialValueFor("projectile_redirect")
end

function modifier_mars_bulwark_toggle:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true}
end

function modifier_mars_bulwark_toggle:DeclareFunctions()
	return {MODIFIER_PROPERTY_DISABLE_TURNING,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
			MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
			}
end

function modifier_mars_bulwark_toggle:GetModifierDisableTurning()
	return 1
end

function modifier_mars_bulwark_toggle:GetModifierIgnoreCastAngle()
	return 1
end

function modifier_mars_bulwark_toggle:GetActivityTranslationModifiers()
	return "bulwark"
end

function modifier_mars_bulwark_toggle:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end

function modifier_mars_bulwark_toggle:GetTrackingProjectileRedirectChance( event )
	return self.projectile_chance
end

function modifier_mars_bulwark_toggle:Bonus_ThreatGain()
	return self.threat
end

modifier_mars_bulwark_lua = class({})
LinkLuaModifier( "modifier_mars_bulwark_lua", "heroes/hero_mars/mars_bulwark_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_mars_bulwark_lua:OnCreated()
	if IsServer() then
		self.physical_damage_reduction = self:GetSpecialValueFor("physical_damage_reduction")
		self.forward_angle = self:GetSpecialValueFor("forward_angle")
		self.physical_damage_reduction_side = self:GetSpecialValueFor("physical_damage_reduction_side") / 100
		self.side_angle = self:GetSpecialValueFor("side_angle")
	end
end

function modifier_mars_bulwark_lua:IsPurgable()
	return false
end

function modifier_mars_bulwark_lua:IsPurgeException()
	return false
end

function modifier_mars_bulwark_lua:IsDebuff()
	return false
end

function modifier_mars_bulwark_lua:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, 
			MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE, }
end

function modifier_mars_bulwark_lua:GetModifierPhysical_ConstantBlock( params )
	if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		local damageBlock = self:GetSpecialValueFor("physical_damage_reduction")
		local blocked = false
		if params.attacker:IsAtAngleWithEntity(params.target, self.forward_angle, true) then
			ParticleManager:FireParticle("particles/units/heroes/hero_mars/mars_shield_of_mars.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target, {[0] = "attach_hitloc"})
			EmitSoundOn("Hero_Mars.Shield.Block", params.target)
			blocked = true
		elseif params.attacker:IsAtAngleWithEntity(params.target, self.side_angle, true) then
			ParticleManager:FireParticle("particles/units/heroes/hero_mars/mars_shield_of_mars_small.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target, {[0] = "attach_hitloc"})
			EmitSoundOn("Hero_Mars.Shield.BlockSmall", params.target)
			damageBlock = damageBlock * self.physical_damage_reduction_side
			blocked = true
		end
		if blocked then
			params.target:StartGesture( ACT_DOTA_OVERRIDE_ABILITY_2 )
			return damageBlock
		end
	end
end

function modifier_mars_bulwark_lua:GetModifierOverrideAbilitySpecial(params)
	if params.ability == self:GetAbility() then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "physical_damage_reduction" then
			return 1
		end
	end
end

function modifier_mars_bulwark_lua:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability == self:GetAbility() then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "physical_damage_reduction" then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			local totalValue = flBaseValue + params.ability:GetSpecialValueFor("dmg_reduction_lvl") * (caster:GetLevel() - 1)
			return totalValue
		end
	end
end

function modifier_mars_bulwark_lua:IsHidden()
	return true
end