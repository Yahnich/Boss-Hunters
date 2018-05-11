zeus_static_field = class({})
LinkLuaModifier( "modifier_zeus_static_field", "heroes/hero_zeus/zeus_static_field.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zeus_static_field_static_charge", "heroes/hero_zeus/zeus_static_field.lua" ,LUA_MODIFIER_MOTION_NONE )

function zeus_static_field:GetIntrinsicModifierName()
    return "modifier_zeus_static_field"
end

function zeus_static_field:ApplyStaticShock(target)
	if not target:IsAlive() then return end
	-- Attaches the particle
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle,0,target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle)
	-- Plays the sound on the target
	EmitSoundOn("Hero_Zuus.StaticField", target)
	local stacks = target:AddNewModifier(self:GetCaster(), self, "modifier_zeus_static_field_static_charge", {duration = self.stack_duration}):GetStackCount()
	local damage_health_pct = self.hpdamage + stacks * self.pct_per_stack
	-- Deals the damage based on the target's current health
	self:DealDamage(self:GetCaster(), target, target:GetHealth() * damage_health_pct, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
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
		self:GetAbility().hpdamage = self:GetAbility():GetTalentSpecialValueFor("damage_health_pct") / 100
		self:GetAbility().pct_per_stack = self:GetAbility():GetTalentSpecialValueFor("pct_per_stack") / 100
		self:GetAbility().stack_duration = self:GetAbility():GetTalentSpecialValueFor("stack_duration")
	end

	function modifier_zeus_static_field:OnAbilityFullyCast(params)
		if params.unit ~= self:GetParent() then return end
		if self:GetParent():HasAbility(params.ability:GetName()) then -- check if caster has ability
			local ability = self:GetAbility()
			local caster = self:GetCaster()
			local units = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius )
			for i,unit in ipairs(units) do
				self:GetAbility():ApplyStaticShock(unit)
			end
		end
	end
end

modifier_zeus_static_field_static_charge = class({})

if IsServer() then
	function modifier_zeus_static_field_static_charge:OnCreated()
		self:SetStackCount(1)
	end
	function modifier_zeus_static_field_static_charge:OnRefresh()
		self:IncrementStackCount()
	end
end