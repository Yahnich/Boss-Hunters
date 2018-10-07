spectre_dispersion_bh = class({})
--------------------------------------------------------------------------------

function spectre_dispersion_bh:GetIntrinsicModifierName()
    return "modifier_spectre_dispersion_aura"
end

modifier_spectre_dispersion_aura = class({})
LinkLuaModifier( "modifier_spectre_dispersion_aura", "heroes/hero_spectre/spectre_dispersion_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_spectre_dispersion_aura:OnCreated()
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_spectre_dispersion_2")
end

function modifier_spectre_dispersion_aura:OnRefresh()
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_spectre_dispersion_2")
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_aura:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_aura:GetModifierAura()
	return "modifier_spectre_dispersion_buff"
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_aura:GetAuraRadius()
	return self.radius
end

function modifier_spectre_dispersion_aura:GetAuraDuration()
	return 0.5
end

--------------------------------------------------------------------------------
function modifier_spectre_dispersion_aura:IsPurgable()
    return false
end

function modifier_spectre_dispersion_aura:IsHidden()
	return true
end



modifier_spectre_dispersion_buff = class({})
LinkLuaModifier( "modifier_spectre_dispersion_buff", "heroes/hero_spectre/spectre_dispersion_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function modifier_spectre_dispersion_buff:DeclareFunctions(params)
local funcs = {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_buff:OnCreated( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "damage_reflection_pct" )
	self.max_range = self:GetAbility():GetSpecialValueFor( "max_radius" )
	self.min_range = self:GetAbility():GetSpecialValueFor( "min_radius" )
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_buff:OnRefresh( kv )
    self.reflect = self:GetAbility():GetSpecialValueFor( "damage_reflection_pct" )
	self.max_range = self:GetAbility():GetSpecialValueFor( "max_radius" )
	self.min_range = self:GetAbility():GetSpecialValueFor( "min_radius" )
end

--------------------------------------------------------------------------------

function modifier_spectre_dispersion_buff:GetModifierIncomingDamage_Percentage(params)
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
			local talent = hero:HasTalent("special_bonus_unique_spectre_dispersion_1")
			for _,unit in pairs(units) do
				local distance = (unit:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
				local dmgmod = 1 - (distance/self.max_range)
				local dmg = params.original_damage * reflect_damage
				if distance <= self.min_range or talent then dmgmod = 1 end
				
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

function modifier_spectre_dispersion_buff:IsHidden()
	return self:GetCaster() == self:GetParent()
end