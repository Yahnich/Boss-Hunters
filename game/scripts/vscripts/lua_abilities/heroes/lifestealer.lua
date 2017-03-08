function IncreaseStackCount( keys )
    -- Variables
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local modifier_name = keys.modifier_counter_name
    local dur = ability:GetDuration()

    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)

    -- if the unit does not already have the counter modifier we apply it with a stackcount of 1
    -- else we increase the stack and refresh the counters duration
    if not modifier then
        ability:ApplyDataDrivenModifier(caster, target, modifier_name, {duration=dur})
        target:SetModifierStackCount(modifier_name, caster, 1)
    else
        modifier:IncrementStackCount()
        modifier:SetDuration(dur, true)
    end
end

--[[
    Author: Bude
    Date: 30.09.2015
    Decreases stack count on the visual modifier 
    This is called whenever the debuff modifier runs out
]]
function DecreaseStackCount(keys)
    --Variables
    local caster = keys.caster
    local target = keys.target
    local modifier_name = keys.modifier_counter_name
    local count = target:GetModifierStackCount(modifier_name, caster)
	local modifier = target:FindModifierByName(modifier_name)
	if modifier then
		modifier:DecrementStackCount()
		if modifier:GetStackCount() == 0 then
			target:RemoveModifierByName(modifier_name)
		end
	end
end

function HealDamage(keys)
	local caster = keys.caster
    local target = keys.target
	local ability = keys.ability
    local modifier_name = keys.modifier_counter_name
	
	local heal = ability:GetAbilityDamage() * ability:GetTalentSpecialValueFor("heal")/100

	caster:Heal(heal, caster)
	ApplyDamage({ victim = target, attacker = caster, damage = ability:GetAbilityDamage()/get_aether_multiplier(caster), damage_type = ability:GetAbilityDamageType(), ability = ability })
end

life_stealer_hunger = class({})

function life_stealer_hunger:GetIntrinsicModifierName()
	return "modifier_life_stealer_hunger"
end

LinkLuaModifier( "modifier_life_stealer_hunger", "lua_abilities/heroes/lifestealer.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_life_stealer_hunger = class({})

function modifier_life_stealer_hunger:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.maxdamage = self:GetAbility():GetSpecialValueFor("max_damage_amp")
	self.mindamage = self:GetAbility():GetSpecialValueFor("max_lifesteal") / 100
	self.maxlifesteal = self:GetAbility():GetSpecialValueFor("min_damage_amp")
	self.minlifesteal = self:GetAbility():GetSpecialValueFor("min_lifesteal") / 100
	self.currentlifesteal = self.minlifesteal
	self:SetStackCount(self.mindamage)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_life_stealer_hunger:OnRefresh()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.maxdamage = self:GetAbility():GetSpecialValueFor("max_damage_amp")
	self.maxlifesteal = self:GetAbility():GetSpecialValueFor("max_lifesteal") / 100
	self.mindamage = self:GetAbility():GetSpecialValueFor("min_damage_amp")
	self.minlifesteal = self:GetAbility():GetSpecialValueFor("min_lifesteal") / 100
	self.currentlifesteal = self.minlifesteal
end

function modifier_life_stealer_hunger:OnIntervalThink()
	local allUnits = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	local maxHP = 1
	for _,unit in pairs(allUnits) do
		maxHP = maxHP + unit:GetMaxHealth()
	end
	local hungerUnits = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	local currHP = 0
	for _,unit in pairs(hungerUnits) do
		currHP = currHP + unit:GetHealth()
	end
	local diffDmg = self.maxdamage - self.mindamage
	local diffLs = self.maxlifesteal - self.minlifesteal
	local newStacks = math.floor(self.mindamage + diffDmg * currHP/maxHP)
	self.currentlifesteal = self.minlifesteal + diffLs * currHP/maxHP
	self:SetStackCount(newStacks)
end

function modifier_life_stealer_hunger:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED,
				MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
			}
	return funcs
end

function modifier_life_stealer_hunger:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			local flHeal = params.original_damage * (1 - params.target:GetPhysicalArmorReduction() / 100 ) * self.currentlifesteal
			params.attacker:Heal(flHeal, params.attacker)
			local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
				ParticleManager:SetParticleControlEnt(lifesteal, 0, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(lifesteal, 1, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(lifesteal)
		end
	end
end

function modifier_life_stealer_hunger:GetModifierDamageOutgoing_Percentage()
	return self:GetStackCount()
end

function modifier_life_stealer_hunger:IsHidden()
	return true
end

