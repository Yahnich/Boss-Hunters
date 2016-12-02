if not skinwalker_fortress_form then skinwalker_fortress_form = class({}) end
if not skinwalker_predator_form then skinwalker_predator_form = class({}) end
if not skinwalker_human_form then skinwalker_human_form = class({}) end

LinkLuaModifier( "modifier_skinwalker_fortress_form", "lua_abilities/heroes/skinwalker.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_skinwalker_predator_form", "lua_abilities/heroes/skinwalker.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_skinwalker_predator_form_bleed", "lua_abilities/heroes/skinwalker.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_skinwalker_human_form", "lua_abilities/heroes/skinwalker.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function skinwalker_fortress_form:OnSpellStart()
	self:GetCaster():RemoveModifierByName("modifier_skinwalker_predator_form")
	self:GetCaster():RemoveModifierByName("modifier_skinwalker_human_form")
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_skinwalker_fortress_form", {})
	self:GetCaster():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	if self:IsStolen() then return end
	self:GetCaster():SwapAbilityIndexes(3, "skinwalker_charge_fortress")
	self:GetCaster():SwapAbilityIndexes(4, "skinwalker_kickback_fortress")
	self:GetCaster():SwapAbilityIndexes(5, "skinwalker_call_of_nature_fortress")
end

function skinwalker_fortress_form:OnUpgrade()
	self.on = self:GetCaster():HasModifier("modifier_skinwalker_fortress_form")
	self:GetCaster():RemoveModifierByName("modifier_skinwalker_fortress_form")
	if self.on then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_skinwalker_fortress_form", {})
	end
	if IsServer() then
		self:GetCaster():FindAbilityByName("skinwalker_charge_fortress"):SetLevel(self:GetLevel())
		self:GetCaster():FindAbilityByName("skinwalker_kickback_fortress"):SetLevel(self:GetLevel())
	end
end

function skinwalker_predator_form:OnSpellStart()
	self:GetCaster():RemoveModifierByName("modifier_skinwalker_fortress_form")
	self:GetCaster():RemoveModifierByName("modifier_skinwalker_human_form")
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_skinwalker_predator_form", {})
	self:GetCaster():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	if self:IsStolen() then return end
	self:GetCaster():SwapAbilityIndexes(3, "skinwalker_lunge_predator")
	self:GetCaster():SwapAbilityIndexes(4, "skinwalker_maul_predator")
	self:GetCaster():SwapAbilityIndexes(5, "skinwalker_call_of_nature_predator")
end

function skinwalker_predator_form:OnUpgrade()
	self.on = self:GetCaster():HasModifier("modifier_skinwalker_predator_form")
	self:GetCaster():RemoveModifierByName("modifier_skinwalker_predator_form")
	if self.on then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_skinwalker_predator_form", {})
	end
	if IsServer() then
		self:GetCaster():FindAbilityByName("skinwalker_lunge_predator"):SetLevel(self:GetLevel())
		self:GetCaster():FindAbilityByName("skinwalker_maul_predator"):SetLevel(self:GetLevel())
	end
end

function skinwalker_human_form:OnSpellStart()
	self:GetCaster():RemoveModifierByName("modifier_skinwalker_predator_form")
	self:GetCaster():RemoveModifierByName("modifier_skinwalker_fortress_form")
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_skinwalker_human_form", {})
	self:GetCaster():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	if self:IsStolen() then return end
	self:GetCaster():SwapAbilityIndexes(3, "skinwalker_moonray_human")
	self:GetCaster():SwapAbilityIndexes(4, "skinwalker_solarbolt_human")
	self:GetCaster():SwapAbilityIndexes(5, "skinwalker_call_of_nature_human")
end

function skinwalker_human_form:GetIntrinsicModifierName()
	return "modifier_skinwalker_human_form"
end

function skinwalker_human_form:OnUpgrade()
	self.on = self:GetCaster():HasModifier("modifier_skinwalker_human_form")
	self:GetCaster():RemoveModifierByName("modifier_skinwalker_human_form")
	if self.on then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_skinwalker_human_form", {})
	end
	if IsServer() then
		self:GetCaster():FindAbilityByName("skinwalker_solarbolt_human"):SetLevel(self:GetLevel())
		self:GetCaster():FindAbilityByName("skinwalker_moonray_human"):SetLevel(self:GetLevel())
	end
end

if not modifier_skinwalker_fortress_form then modifier_skinwalker_fortress_form = class({}) end
if not modifier_skinwalker_predator_form then modifier_skinwalker_predator_form = class({}) end
if not modifier_skinwalker_human_form then modifier_skinwalker_human_form = class({}) end

function modifier_skinwalker_fortress_form:OnCreated()
	self.bonushp = self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_skinwalker_fortress_form:OnRefresh()
	self.bonushp = self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_skinwalker_fortress_form:RemoveOnDeath()
	return false
end

function modifier_skinwalker_fortress_form:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_skinwalker_fortress_form:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_RESPAWN,
	}
	return funcs
end

function modifier_skinwalker_fortress_form:GetModifierHealthBonus()
	return self.bonushp
end

function modifier_skinwalker_fortress_form:GetModifierMoveSpeedBonus_Constant()
	return -20
end

function modifier_skinwalker_fortress_form:GetModifierModelChange()
	return "models/creeps/neutral_creeps/n_creep_thunder_lizard/n_creep_thunder_lizard_big.vmdl"
end

function modifier_skinwalker_fortress_form:OnRespawn()
	self:GetCaster():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
end

------------------------------------------------------------------------------------------------------
if not modifier_skinwalker_predator_form_bleed then modifier_skinwalker_predator_form_bleed = class({}) end
------------------------------------------------------------------------------------------------------

function modifier_skinwalker_predator_form:OnCreated()
	self.attackspeed = self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
	self.chance = self:GetAbility():GetSpecialValueFor("bleed_chance")
	self.duration = self:GetAbility():GetSpecialValueFor("bleed_duration")
end

function modifier_skinwalker_predator_form:OnRefresh()
	self.attackspeed = self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
	self.chance = self:GetAbility():GetSpecialValueFor("bleed_chance")
	self.duration = self:GetAbility():GetSpecialValueFor("bleed_duration")
end

function modifier_skinwalker_predator_form:RemoveOnDeath()
	return false
end

function modifier_skinwalker_predator_form:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_skinwalker_predator_form:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_RESPAWN,
	}
	return funcs
end

function modifier_skinwalker_predator_form:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_skinwalker_predator_form:OnAttackLanded(params)
	if params.attacker == self:GetCaster() then
		if RollPercentage(self.chance) then
			local modifier = params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_skinwalker_predator_form_bleed", {duration = self.duration})
			modifier:SetStackCount(modifier:GetStackCount() + 1)
			params.target.bleedTable = params.target.bleedTable or {}
			table.insert(params.target.bleedTable, GameRules:GetGameTime())
		end
	end
end

function modifier_skinwalker_predator_form:GetModifierModelChange()
	return "models/creeps/neutral_creeps/n_creep_worg_large/n_creep_worg_large.vmdl"
end

function modifier_skinwalker_predator_form:OnRespawn()
	self:GetCaster():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
end

function modifier_skinwalker_predator_form_bleed:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("bleed_damage")
	self.expireTime = self:GetAbility():GetSpecialValueFor("bleed_duration")
	self.tickrate = 0.1
	if IsServer() then
		self:StartIntervalThink(self.tickrate)
	end
end

function modifier_skinwalker_predator_form_bleed:OnIntervalThink()
	if #self:GetParent().bleedTable > 0 then
		for i = #self:GetParent().bleedTable, 1, -1 do
			if self:GetParent().bleedTable[i] + self.expireTime < GameRules:GetGameTime() then
				table.remove(self:GetParent().bleedTable, i)
				
			end
		end
		self:SetStackCount(#self:GetParent().bleedTable)
	end
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage * self.tickrate * self:GetStackCount(), damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
end

function modifier_skinwalker_predator_form_bleed:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

function modifier_skinwalker_human_form:OnCreated()
	self.manaregen = self:GetAbility():GetSpecialValueFor("base_mana_regen")
	self.range = self:GetAbility():GetSpecialValueFor("bonus_range")
end

function modifier_skinwalker_human_form:OnRefresh()
	self.manaregen = self:GetAbility():GetSpecialValueFor("base_mana_regen")
end

function modifier_skinwalker_human_form:RemoveOnDeath()
	return false
end

function modifier_skinwalker_human_form:IsHidden()
	return true
end
--------------------------------------------------------------------------------

function modifier_skinwalker_human_form:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASE_MANA_REGEN,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_RESPAWN,
	}
	return funcs
end

function modifier_skinwalker_human_form:GetModifierBaseRegen()
	return self.manaregen
end

function modifier_skinwalker_human_form:GetModifierAttackRangeBonus()
	return self.range
end

function modifier_skinwalker_human_form:OnRespawn()
	self:GetCaster():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function LevelUpAbility(keys)
	local caster = keys.caster
	local this_ability = keys.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name1 = keys.ability_name1
	local ability_handle1 = caster:FindAbilityByName(ability_name1)	
	local ability_level1 = ability_handle1:GetLevel()
	
	local ability_name2 = keys.ability_name2
	local ability_handle2 = caster:FindAbilityByName(ability_name2)	
	local ability_level2 = ability_handle2:GetLevel()

	-- Check to not enter a level up loop
	if ability_level1 ~= this_abilityLevel then
		ability_handle1:SetLevel(this_abilityLevel)
	end
	if ability_level2 ~= this_abilityLevel then
		ability_handle2:SetLevel(this_abilityLevel)
	end
end

function MoonRay(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local damage = ability:GetSpecialValueFor("heal_damage")
	if target:HasModifier("modifier_solarbolt_moon_bonus") then damage = damage*1.4 end
	if target:GetTeamNumber() == caster:GetTeamNumber() then
		target:Heal(damage, caster)
		SendOverheadEventMessage( target, OVERHEAD_ALERT_HEAL , target, damage, caster )
	else
		SendOverheadEventMessage( target, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE , target, damage, caster )
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
	end
	ability:ApplyDataDrivenModifier(caster, target, "modifier_moonray_sun_bonus", {duration = ability:GetSpecialValueFor("duration")})
end

function SolarBolt(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local damage = ability:GetSpecialValueFor("healdamage")
	if target:HasModifier("modifier_moonray_sun_bonus") then damage = damage*1.4 end
	if target:GetTeamNumber() == caster:GetTeamNumber() then
		target:Heal(damage, caster)
		SendOverheadEventMessage( target, OVERHEAD_ALERT_HEAL , target, damage, caster )
	else
		SendOverheadEventMessage( target, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE , target, damage, caster )
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
	end
	ability:ApplyDataDrivenModifier(caster, target, "modifier_solarbolt_moon_bonus", {duration = ability:GetSpecialValueFor("duration")})
end

function RootDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local damage = ability:GetAbilityDamage()
	if target:GetTeamNumber() == caster:GetTeamNumber() then
		target:Heal(damage, caster)
		SendOverheadEventMessage( target, OVERHEAD_ALERT_HEAL , target, damage, caster )
	else
		SendOverheadEventMessage( target, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE , target, damage, caster )
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
	end
	ability:ApplyDataDrivenModifier(caster, target, "modifier_solarbolt_moon_bonus", {duration = ability:GetSpecialValueFor("duration")})
end

function ApplyRoot(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target:GetTeamNumber() == caster:GetTeamNumber() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_skinwalker_call_of_nature_human_root_ally", {duration = ability:GetSpecialValueFor("root_duration")})
	else
		ability:ApplyDataDrivenModifier(caster, target, "modifier_skinwalker_call_of_nature_human_root", {duration = ability:GetSpecialValueFor("root_duration")})
	end
end

function Stampede(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function StampedeArmor(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability:IsHidden() and caster:HasModifier("modifier_stampede_armor_bonus") then
		caster:RemoveModifierByName("modifier_stampede_armor_bonus")
	elseif not  ability:IsHidden() and not caster:HasModifier("modifier_stampede_armor_bonus") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_stampede_armor_bonus", {})
	end
end

function Devastate(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local critdamage = ability:GetSpecialValueFor("critical_damage") / 100
	caster:RemoveModifierByName("critical_strike_h")
	caster:RemoveModifierByName("critical_strike_2")
	local damage_dealt = critdamage * caster:GetAverageTrueAttackDamage(target)
	SendOverheadEventMessage( target, OVERHEAD_ALERT_CRITICAL , target, damage_dealt, caster )
	ApplyDamage({victim = target, attacker = caster, damage = damage_dealt, damage_type = ability:GetAbilityDamageType(), ability = ability})
	local predator = caster:FindAbilityByName("skinwalker_predator_form")
	for i = 1, ability:GetSpecialValueFor("bleed_stacks") do
		if target:IsAlive() then
			local modifier = target:FindModifierByName("modifier_skinwalker_predator_form_bleed")
			if not modifier then
				modifier = target:AddNewModifier( caster, predator, "modifier_skinwalker_predator_form_bleed", {duration = 2})
				modifier:SetStackCount(1)
			else
				modifier:SetDuration(2, true)
				modifier:SetStackCount(modifier:GetStackCount() + 1)
			end
			target.bleedTable = target.bleedTable or {}
			table.insert(target.bleedTable, GameRules:GetGameTime())
		end
	end
end

function DevastateSpeed(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability:IsHidden() and caster:HasModifier("modifier_devastate_movespeed_bonus") then
		caster:RemoveModifierByName("modifier_devastate_movespeed_bonus")
	elseif not  ability:IsHidden() and not caster:HasModifier("modifier_devastate_movespeed_bonus") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_devastate_movespeed_bonus", {})
	end
end

function Charge(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local skewer_speed = ability:GetLevelSpecialValueFor("charge_speed", ability:GetLevel() - 1)
	local range = ability:GetLevelSpecialValueFor("charge_distance", ability:GetLevel() - 1)
	local point = ability:GetCursorPosition()
	
	-- Distance and direction variables
	local vector_distance = point - caster:GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	local direction = (vector_distance):Normalized()
	
	-- If the caster targets over the max range, sets the distance to the max
	if distance > range then
		point = caster:GetAbsOrigin() + range * direction
		distance = range
	end
	
	-- Total distance to travel
	ability.distance = distance
	
	-- Distance traveled per interval
	ability.speed = skewer_speed/30
	
	-- The direction to travel
	ability.direction = direction
	
	-- Distance traveled so far
	ability.traveled_distance = 0
	
	-- Applies the disable modifier
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_charge_movement", {})
end

function ChargeMotion(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	-- Move the target while the distance traveled is less than the original distance upon cast
	if (ability.traveled_distance < ability.distance) and ability.distance > 150 then
		target:SetAbsOrigin(target:GetAbsOrigin() + ability.direction * ability.speed)
		ability.traveled_distance = ability.traveled_distance + ability.speed
	else
		-- Remove the motion controller once the distance has been traveled
		target:InterruptMotionControllers(true)
		target:RemoveModifierByName("modifier_charge_movement")
	end
end

function ChargeDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function Turmoil(keys)
	-- Variables
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	-- Damage
	if attacker:GetTeamNumber() ~= caster:GetTeamNumber() then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_turmoil_bonus_damage", {})
		caster:PerformAttack(attacker, true, true, true, true, false)
		caster:RemoveModifierByName("modifier_turmoil_bonus_damage")
	end
end

function Lunge( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local ability_level = ability:GetLevel() - 1	

	-- Clears any current command and disjoints projectiles
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	-- Ability variables
	ability.leap_direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	ability.leap_distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	ability.leap_speed = ability:GetLevelSpecialValueFor("leap_speed", ability_level) * 1/30
	ability.leap_traveled = 0
	ability.leap_z = 0
	ability.target = target
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function LungeHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability
	local target = ability.target
	
	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		caster:InterruptMotionControllers(true)
		local predator = caster:FindAbilityByName("skinwalker_predator_form")
		for i = 1, ability:GetSpecialValueFor("bleed_stacks") do
			if target:IsAlive() then
				local modifier = target:FindModifierByName("modifier_skinwalker_predator_form_bleed")
				if not modifier then
					modifier = target:AddNewModifier( caster, predator, "modifier_skinwalker_predator_form_bleed", {duration = 2})
					modifier:SetStackCount(1)
				else
					modifier:SetDuration(2, true)
					modifier:SetStackCount(modifier:GetStackCount() + 1)
				end
				target.bleedTable = target.bleedTable or {}
				table.insert(target.bleedTable, GameRules:GetGameTime())
			end
		end
		target:EmitSound("Hero_Bloodseeker.BloodRite")
	end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function LungeVertical( keys )
	local caster = keys.target
	local ability = keys.ability
	if ability.leap_traveled < ability.leap_distance/2 then
		ability.leap_z = ability.leap_z + ability.leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	else
		ability.leap_z = ability.leap_z - ability.leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	end
end

function ApplyBleed(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local predator = caster:FindAbilityByName("skinwalker_predator_form")
	for i = 1, ability:GetSpecialValueFor("bleed_stacks") do
		if target:IsAlive() then
			local modifier = target:FindModifierByName("modifier_skinwalker_predator_form_bleed")
			if not modifier then
				modifier = target:AddNewModifier( caster, predator, "modifier_skinwalker_predator_form_bleed", {duration = 2})
				modifier:SetStackCount(1)
			else
				modifier:SetDuration(2, true)
				modifier:SetStackCount(modifier:GetStackCount() + 1)
			end
			target.bleedTable = target.bleedTable or {}
			table.insert(target.bleedTable, GameRules:GetGameTime())
		end
	end
end