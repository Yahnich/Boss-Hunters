function overload_check_order( keys )
	local caster = keys.caster
	local ability = keys.ability
	local usedability = keys.event_ability
	if (usedability:GetCooldown(-1) <= 0 or usedability:GetName() == "item_shadow_amulet") and not (usedability:GetName() == "storm_spirit_static_remnant_ebf" or usedability:GetName() == "storm_spirit_ball_lightning") then return end
	local stacks = caster:GetModifierStackCount("modifier_overload_damage_datadriven",caster)
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_overload_damage_datadriven", {} )
	local adder = 1
	if caster:HasTalent("special_bonus_unique_storm_spirit") then adder = 2 end
	caster:SetModifierStackCount("modifier_overload_damage_datadriven", caster, stacks+adder)
end

function overload_reducestacks( keys )
	local caster = keys.caster
	local ability = keys.ability
	if keys.target:IsMagicImmune() then return end
	local stacks = caster:GetModifierStackCount("modifier_overload_damage_datadriven",caster)
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_overload_damage_datadriven", {} )
	caster:SetModifierStackCount("modifier_overload_damage_datadriven", caster, stacks-1)
	if stacks-1 < 1 then
		caster:RemoveModifierByName("modifier_overload_damage_datadriven")
	end
end

function overload_damage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function DynamoTick( keys )
	local caster = keys.caster
	local ability = keys.ability
	local overload = caster:FindAbilityByName("storm_spirit_overload_ebf")
	local stacks = caster:GetModifierStackCount("modifier_overload_damage_datadriven",caster)
	overload:ApplyDataDrivenModifier( caster, caster, "modifier_overload_damage_datadriven", {} )
	local adder = 1
	if caster:HasTalent("special_bonus_unique_storm_spirit") then adder = 2 end
	caster:SetModifierStackCount("modifier_overload_damage_datadriven", caster, stacks+adder)
	if caster:GetMana() < ability:GetManaCost(-1) then
		ability:OnToggle()
	end
end

function RefreshDynamo( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("storm_spirit_electric_dynamo_active") and ability:GetToggleState() == 1 then
		caster:RemoveModifierByName("storm_spirit_electric_dynamo_active")
		ability:ApplyDataDrivenModifier( caster, caster, "storm_spirit_electric_dynamo_active", {} )
	end
end

function HandleDynamo( keys )
	local caster = keys.caster
	local ability = keys.ability
	local tick = ability:GetTalentSpecialValueFor("tick_rate")
	if ability:GetToggleState() == true then
		ability:ApplyDataDrivenModifier(caster, caster, "storm_spirit_electric_dynamo_active", {} )
		local stacks = caster:GetModifierStackCount("modifier_overload_damage_datadriven",caster)
		local adder = 1
		if caster:HasTalent("special_bonus_unique_storm_spirit") then adder = 2 end
		caster:SetModifierStackCount("modifier_overload_damage_datadriven", caster, stacks+adder)
		ability:StartCooldown(tick)
	else
		caster:RemoveModifierByName("storm_spirit_electric_dynamo_active")
		ability:StartCooldown(tick)
	end
end

storm_spirit_static_remnant_ebf = class({})

if IsServer() then
	function storm_spirit_static_remnant_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		
		local forwardVec = ( point - caster:GetAbsOrigin() ):Normalized()
		local dummy = CreateUnitByName( caster:GetName(), caster:GetAbsOrigin(), false, caster, nil, caster:GetTeamNumber() )
		dummy:AddNewModifier(caster, self, "modifier_storm_spirit_static_remnant_dummy", {duration = self:GetDuration()})
		EmitSoundOn( "Hero_StormSpirit.StaticRemnantPlant", caster )
		dummy:SetHullRadius( 0 )
		dummy:SetForwardVector( forwardVec )
		dummy:MakeIllusion()
		Timers:CreateTimer( function()

			local newLoc = dummy:GetAbsOrigin() + ( forwardVec * ( caster:GetIdealSpeed() * 2.5 * 0.03 ) )
			dummy:SetAbsOrigin( newLoc )
			

			if ( dummy:GetAbsOrigin() - point ):Length2D() <= 50 then
				return nil
			else
				return 0.03
			end
		end)
	end
end

LinkLuaModifier( "modifier_storm_spirit_static_remnant_dummy", "lua_abilities/heroes/storm_spirit.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_storm_spirit_static_remnant_dummy = class({})

function modifier_storm_spirit_static_remnant_dummy:OnCreated()
	self.radius = self:GetAbility():GetSpecialValueFor("static_remnant_radius")
	self.damage = self:GetAbility():GetSpecialValueFor("static_remnant_damage")
	self.delay = self:GetAbility():GetSpecialValueFor("static_remnant_delay")
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

function modifier_storm_spirit_static_remnant_dummy:OnIntervalThink()
	local units = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	if not self.activated then 
		self.activated = true
		self:StartIntervalThink(0.03)
	end
	if #units > 0 then
		self:Destroy()
	end
end

function modifier_storm_spirit_static_remnant_dummy:OnDestroy()
	if IsServer() then
		local units = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
		for _,unit in pairs(units) do
			ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
		end
		EmitSoundOn( "Hero_StormSpirit.StaticRemnantExplode", self:GetParent() )
		self:GetParent():RemoveSelf()
	end
end

function modifier_storm_spirit_static_remnant_dummy:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}
	return state
end

function modifier_storm_spirit_static_remnant_dummy:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			}
	return funcs
end

function modifier_storm_spirit_static_remnant_dummy:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function modifier_storm_spirit_static_remnant_dummy:GetEffectName()
	return "particles/units/heroes/hero_stormspirit/stormspirit_static_remnant.vpcf"
end