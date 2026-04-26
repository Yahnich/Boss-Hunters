abaddon_mist_reaver = class({})

function abaddon_mist_reaver:IsStealable()
	return true
end

function abaddon_mist_reaver:IsHiddenWhenStolen()
	return false
end

function abaddon_mist_reaver:OnToggle()
	local caster = self:GetCaster()
	if self:IsToggled() then
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
	if IsServer() then
		self:StartIntervalThink(self.immolate_tick)
	end
end

function modifier_abaddon_mist_reaver_active:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	
	local damage = self.immolate_damage * self.immolate_tick
	ability:DealDamage( caster, caster, damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NON_LETHAL } )
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.immolate_aoe ) ) do
		ability:DealDamage( caster, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL} )
	end
end

function modifier_abaddon_mist_reaver_active:GetEffectName()
	return "particles/econ/events/fall_2021/radiance_owner_fall_2021.vpcf"
end