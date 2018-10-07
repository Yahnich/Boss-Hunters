spectre_dispersion_bh = class({})
LinkLuaModifier( "modifier_spectre_dispersion_bh", "heroes/hero_spectre/spectre_dispersion_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function spectre_dispersion_bh:GetIntrinsicModifierName()
    return "modifier_spectre_dispersion_bh"
end

modifier_spectre_dispersion_bh = class({})

--------------------------------------------------------------------------------
function modifier_spectre_dispersion_bh:DeclareFunctions(params)
local funcs = {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end

function modifier_spectre_dispersion_bh:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_bh:OnCreated( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "damage_reflection_pct" )
	self.max_range = self:GetAbility():GetSpecialValueFor( "max_radius" )
	self.min_range = self:GetAbility():GetSpecialValueFor( "min_radius" )
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_bh:OnRefresh( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "damage_reflection_pct" )
	self.max_range = self:GetAbility():GetSpecialValueFor( "max_radius" )
	self.min_range = self:GetAbility():GetSpecialValueFor( "min_radius" )
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_bh:GetModifierIncomingDamage_Percentage(params)
    local hero = self:GetParent()
	local dmgtype = params.damage_type
	local attacker = params.attacker
    local reflect_damage = self.reflect / 100
	if attacker and attacker:GetTeamNumber()  ~= hero:GetTeamNumber() then
		if hero:GetHealth() >= 1 then
			local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), 
			hero:GetAbsOrigin(), 
			hero, 
			self.max_range, 
			self:GetAbility():GetAbilityTargetTeam(), 
			self:GetAbility():GetAbilityTargetType(), 
			self:GetAbility():GetAbilityTargetFlags(), 
			FIND_ANY_ORDER, 
			false)
			for _,unit in pairs(units) do
				local distance = (unit:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
				local dmgmod = 1 - (distance/self.max_range)
				local dmg = params.original_damage * reflect_damage
				if distance <= self.min_range then dmgmod = 1 end
				self:GetAbility().damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
				ApplyDamage({victim = unit, attacker = hero, damage = dmg*dmgmod, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = dmgtype, ability = self:GetAbility()})
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_dispersion.vpcf",PATTACH_POINT_FOLLOW,unit)
				ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 1, hero:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(particle)
			end
		end
	end
	return self.reflect * (-1)
end