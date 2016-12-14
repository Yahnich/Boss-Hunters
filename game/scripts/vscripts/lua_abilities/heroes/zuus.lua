LinkLuaModifier( "modifier_zuus_static_field_ebf", "lua_abilities/heroes/zuus.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zuus_static_field_ebf_static_charge", "lua_abilities/heroes/zuus.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if zuus_static_field_ebf == nil then zuus_static_field_ebf = class({}) end

function zuus_static_field_ebf:GetIntrinsicModifierName()
    return "modifier_zuus_static_field_ebf"
end

--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_zuus_static_field_ebf				
--------------------------------------------------------------------------------------------------------
if modifier_zuus_static_field_ebf == nil then modifier_zuus_static_field_ebf = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_zuus_static_field_ebf:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_zuus_static_field_ebf:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_zuus_static_field_ebf:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end

function modifier_zuus_static_field_ebf:OnCreated()
	self.radius = self:GetAbility():GetTalentSpecialValueFor("radius")
	self.hpdamage = self:GetAbility():GetTalentSpecialValueFor("damage_health_pct") / 100
	self.pct_per_stack = self:GetAbility():GetTalentSpecialValueFor("pct_per_stack") / 100
	self.stack_duration = self:GetAbility():GetTalentSpecialValueFor("stack_duration")
end

function modifier_zuus_static_field_ebf:OnAbilityFullyCast(params)
	if IsServer() then
		if params.unit ~= self:GetParent() then return end
		if self:GetParent():HasAbility(params.ability:GetName()) then -- check if caster has ability
			local ability = self:GetAbility()
			local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
			for i,unit in ipairs(units) do
				-- Attaches the particle
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
				ParticleManager:SetParticleControl(particle,0,unit:GetAbsOrigin())
				-- Plays the sound on the unit
				EmitSoundOn("sounds/weapons/hero/zuus/static_field.vsnd", unit)
				if not unit:HasModifier("modifier_zuus_static_field_ebf_static_charge") then 
					local modifier = unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_zuus_static_field_ebf_static_charge", {duration = self.stack_duration})
					modifier:SetStackCount(1)
				else
					local modifier = unit:FindModifierByName("modifier_zuus_static_field_ebf_static_charge")
					modifier:IncrementStackCount()
					modifier:SetDuration(modifier:GetDuration(), true)
				end
				local damage_health_pct = self.hpdamage + unit:FindModifierByName("modifier_zuus_static_field_ebf_static_charge"):GetStackCount() * self.pct_per_stack
				-- Deals the damage based on the unit's current health
				ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = unit:GetHealth() * damage_health_pct, damage_type = ability:GetAbilityDamageType(), ability = ability})
			end
		end
	end
end

if modifier_zuus_static_field_ebf_static_charge == nil then modifier_zuus_static_field_ebf_static_charge = class({}) end


function StaticAegis(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local particleCaster = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start_bolt_parent.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(particleCaster, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleCaster, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
	for i,unit in ipairs(units) do
		local particleUnit = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, unit)
		-- Raise 1000 if you increase the camera height above 1000
		ParticleManager:SetParticleControl(particleUnit, 0, Vector(unit:GetAbsOrigin().x,unit:GetAbsOrigin().y,unit:GetAbsOrigin().z + unit:GetBoundingMaxs().z ))
		ParticleManager:SetParticleControl(particleUnit, 1, Vector(unit:GetAbsOrigin().x,unit:GetAbsOrigin().y,1000 ))
		ParticleManager:SetParticleControl(particleUnit, 2, Vector(unit:GetAbsOrigin().x,unit:GetAbsOrigin().y,unit:GetAbsOrigin().z + unit:GetBoundingMaxs().z ))
		-- Plays the sound on the unit
		EmitSoundOn(keys.sound, unit)
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_thundergods_wrath_datadriven", {duration = ability:GetTalentSpecialValueFor("buff_duration")})
	end
end

function StaticAegisAttacked(keys)
	local caster = keys.caster
	local target = keys.attacker
	local victim = keys.target
	local ability = keys.ability
	if caster:HasScepter() then
		if RollPercentage( ability:GetTalentSpecialValueFor("scepter_proc_chance") ) then
			caster:SetCursorCastTarget(target)
			local bolt = caster:FindAbilityByName("zuus_lightning_bolt")
			bolt:OnSpellStart()
		end
	end
	if RollPercentage( ability:GetTalentSpecialValueFor("heal_proc_chance") ) then
		local heal = victim:GetMaxHealth() * ability:GetTalentSpecialValueFor("self_heal") / 100
		victim:Heal(heal, caster)
		SendOverheadEventMessage( caster, OVERHEAD_ALERT_HEAL , caster, heal, caster )
	end
	local particleStrike = ParticleManager:CreateParticle(keys.particle, PATTACH_POINT_FOLLOW, victim)
		ParticleManager:SetParticleControlEnt(particleStrike, 0, victim, PATTACH_POINT_FOLLOW, "attach_hitloc", victim:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particleStrike, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ApplyDamage({victim = target, attacker = victim, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
	EmitSoundOn("Item.Maelstrom.Chain_Lightning", target)
end

