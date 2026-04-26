abaddon_mist_reaver = class({})

function abaddon_mist_reaver:IsStealable()
	return true
end

function abaddon_mist_reaver:IsHiddenWhenStolen()
	return false
end

function abaddon_mist_reaver:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		self:GetAbility._bonusAOEDamage = 0
		caster:AddNewModifier( caster, self, "modifier_abaddon_mist_reaver_active", {} )
	else
		caster:RemoveModifierByName("modifier_abaddon_mist_reaver_active")
	end
end

modifier_abaddon_mist_reaver_active = class(toggleModifierBaseClass)
LinkLuaModifier("modifier_abaddon_mist_reaver_active", "heroes/hero_abaddon/abaddon_mist_reaver", LUA_MODIFIER_MOTION_NONE)

function modifier_abaddon_mist_reaver_active:OnCreated()
	self:OnRefresh()
end

function modifier_abaddon_mist_reaver_active:OnRefresh()
	self.immolate_damage = self:GetSpecialValueFor("immolate_damage")
	self.immolate_aoe = self:GetSpecialValueFor("immolate_aoe")
	self.immolate_tick = self:GetSpecialValueFor("immolate_tick")
	
	self.damage_resistance = self:GetSpecialValueFor("damage_resistance")
	if IsServer() then
		self:StartIntervalThink(self.immolate_tick)
	end
end

function modifier_abaddon_mist_reaver_active:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	
	local damage = self.immolate_damage * self.immolate_tick
	ability:DealDamage( caster, caster, damage + self:GetAbility()._bonusAOEDamage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NON_LETHAL } )
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.immolate_aoe ) ) do
		ability:DealDamage( caster, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL} )
	end
end

function modifier_abaddon_mist_reaver_active:GetEffectName()
	return "particles/econ/events/fall_2021/radiance_owner_fall_2021.vpcf"
end

function modifier_abaddon_mist_reaver_active:IsAura()
	return self.damage_resistance > 0
end

function modifier_abaddon_mist_reaver_active:GetModifierAura()
	return "modifier_abaddon_mist_reaver_cloak_of_fog"
end

function modifier_abaddon_mist_reaver_active:GetAuraRadius()
	return self.immolate_aoe
end

function modifier_abaddon_mist_reaver_active:GetAuraEntityReject(entity)
	return entity == self:GetParent()
end

function modifier_abaddon_mist_reaver_active:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_abaddon_mist_reaver_active:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

modifier_abaddon_mist_reaver_cloak_of_fog = class({})
LinkLuaModifier("modifier_abaddon_mist_reaver_cloak_of_fog", "heroes/hero_abaddon/abaddon_borrowed_time", LUA_MODIFIER_MOTION_NONE)

function modifier_abaddon_mist_reaver_cloak_of_fog:OnCreated()
	self:OnRefresh()
end

function modifier_abaddon_mist_reaver_cloak_of_fog:OnRefresh()
	self.redirect = self:GetSpecialValueFor("damage_resistance")
end

function modifier_abaddon_mist_reaver_cloak_of_fog:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_abaddon_mist_reaver_cloak_of_fog:GetModifierIncomingDamage_Percentage(params)
	if params.damage < 0 then return end
	local parent = self:GetParent()
	self:GetAbility._bonusAOEDamage = self:GetAbility()._bonusAOEDamage + params.damage * self.redirect / 100
	return -self.redirect
end

function modifier_abaddon_mist_reaver_cloak_of_fog:IsHidden()
	return true
end