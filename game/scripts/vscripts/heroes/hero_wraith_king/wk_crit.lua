wk_crit = class({})
LinkLuaModifier("modifier_wk_crit_passive", "heroes/hero_wraith_king/wk_crit", LUA_MODIFIER_MOTION_NONE)

function wk_crit:IsStealable()
    return false
end

function wk_crit:IsHiddenWhenStolen()
    return false
end

function wk_crit:GetIntrinsicModifierName()
	return "modifier_wk_crit_passive"
end

function wk_crit:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget and hTarget ~= self.target then
		local damage = caster:GetAttackDamage() * self:GetTalentSpecialValueFor("cleave_damage")/100
		self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	end
end

modifier_wk_crit_passive = class({})
function modifier_wk_crit_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_wk_crit_passive:GetModifierPreAttack_CriticalStrike(params)
	local caster = self:GetCaster()
	if self:RollPRNG( self:GetTalentSpecialValueFor("crit_chance") ) then
		local velocity = caster:GetForwardVector() * 1000
		local distance = self:GetTalentSpecialValueFor("cleave_distance")
		local width = self:GetTalentSpecialValueFor("cleave_width")

		self:GetAbility().target = params.target

		self:GetAbility():FireLinearProjectile("particles/vampiric_shockwave.vpcf", velocity, distance, width, {}, false, false, 0)
		return self:GetTalentSpecialValueFor("crit_mult")
	end
end

function modifier_wk_crit_passive:IsHidden()
	return true
end