modifier_spectre_dispersion_ebf = class({})

--------------------------------------------------------------------------------
function modifier_spectre_dispersion_ebf:DeclareFunctions(params)
local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_spectre_dispersion_ebf:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_ebf:OnCreated( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "damage_reflection_pct" )
	self.max_range = self:GetAbility():GetSpecialValueFor( "max_radius" )
	self.min_range = self:GetAbility():GetSpecialValueFor( "min_radius" )
	print("test")
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_ebf:OnRefresh( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "damage_reflection_pct" )
	self.max_range = self:GetAbility():GetSpecialValueFor( "max_radius" )
	self.min_range = self:GetAbility():GetSpecialValueFor( "min_radius" )
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_ebf:OnTakeDamage(params)
    local hero = self:GetParent()
    local dmg = params.damage
	local dmgtype = params.damage_type
	local attacker = params.attacker
    local nHeroHeal = self.reflect / 100
	if attacker and attacker:GetTeamNumber()  ~= hero:GetTeamNumber() then
		if params.unit == hero and hero:GetHealth() >= 1 then
			hero:SetHealth(hero:GetHealth()+dmg*nHeroHeal)
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
				local dmg = dmg*nHeroHeal
				if distance > self.min_range then dmgmod = 1 end
				self:GetAbility().damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
				ApplyDamage({victim = unit, attacker = hero, damage = dmg*dmgmod/get_aether_multiplier(hero), damage_flags = DOTA_DAMAGE_FLAG_HPLOSS, damage_type = DAMAGE_TYPE_PURE, ability = self:GetAbility()})
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_dispersion.vpcf",PATTACH_POINT_FOLLOW,unit)
				ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 1, hero:GetAbsOrigin())
			end
		end
	end
end