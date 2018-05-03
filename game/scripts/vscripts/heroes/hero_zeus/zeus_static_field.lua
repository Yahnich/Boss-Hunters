zeus_static_field = class({})
LinkLuaModifier( "modifier_zeus_static_field", "heroes/hero_zeus/zeus_static_field.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zeus_static_field_static_charge", "heroes/hero_zeus/zeus_static_field.lua" ,LUA_MODIFIER_MOTION_NONE )

function zeus_static_field:GetIntrinsicModifierName()
    return "modifier_zeus_static_field"
end

modifier_zeus_static_field = class({})
function modifier_zeus_static_field:IsPassive()
	return true
end
function modifier_zeus_static_field:IsHidden()
	return true
end

function modifier_zeus_static_field:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end

if IsServer() then
	function modifier_zeus_static_field:OnCreated()
		self.radius = self:GetAbility():GetTalentSpecialValueFor("radius")
		self.hpdamage = self:GetAbility():GetTalentSpecialValueFor("damage_health_pct") / 100
		self.pct_per_stack = self:GetAbility():GetTalentSpecialValueFor("pct_per_stack") / 100
		self.stack_duration = self:GetAbility():GetTalentSpecialValueFor("stack_duration")
	end

	function modifier_zeus_static_field:OnAbilityFullyCast(params)
		if params.unit ~= self:GetParent() then return end
		if self:GetParent():HasAbility(params.ability:GetName()) then -- check if caster has ability
			local ability = self:GetAbility()
			local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
			for i,unit in ipairs(units) do
				-- Attaches the particle
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
				ParticleManager:SetParticleControl(particle,0,unit:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(particle)
				-- Plays the sound on the unit
				EmitSoundOn("Hero_Zuus.StaticField", unit)
				if not unit:HasModifier("modifier_zeus_static_field_static_charge") then 
					local modifier = unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_zeus_static_field_static_charge", {duration = self.stack_duration})
					modifier:SetStackCount(1)
				else
					local modifier = unit:FindModifierByName("modifier_zeus_static_field_static_charge")
					modifier:IncrementStackCount()
					modifier:SetDuration(modifier:GetDuration(), true)
				end
				local damage_health_pct = self.hpdamage + unit:FindModifierByName("modifier_zeus_static_field_static_charge"):GetStackCount() * self.pct_per_stack
				-- Deals the damage based on the unit's current health
				self:GetAbility():DealDamage(self:GetCaster(), unit, unit:GetHealth() * damage_health_pct, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
			end
		end
	end
end

modifier_zeus_static_field_static_charge = class({})