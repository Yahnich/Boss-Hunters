wk_crit = class({})
LinkLuaModifier("modifier_wk_crit_passive", "heroes/hero_wraith_king/wk_crit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wk_skeletons_charges", "heroes/hero_wraith_king/wk_skeletons", LUA_MODIFIER_MOTION_NONE)

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

function modifier_wk_crit_passive:OnCreated()
	self:OnRefresh()
end

function modifier_wk_crit_passive:OnRefresh()
	self.crit_chance = self:GetTalentSpecialValueFor("crit_chance")
	self.crit_dmg = self:GetTalentSpecialValueFor("crit_mult")
	self.distance = self:GetTalentSpecialValueFor("cleave_distance")
	self.width = self:GetTalentSpecialValueFor("cleave_width")
	if IsServer() then
		self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_wk_crit_passive:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_wk_crit_passive:GetModifierCriticalDamage(params)
	local caster = self:GetCaster()
	if not caster:PassivesDisabled() and self:RollPRNG( self.crit_chance ) then
		local velocity = caster:GetForwardVector() * 1000

		local ability = caster:FindAbilityByName("wk_skeletons")
		if ability and ability:IsTrained() then
			ability:IncrementCharge()
		end

		self:GetAbility().target = params.target
		params.target:EmitSound( "Hero_SkeletonKing.CriticalStrike" )
		self:GetAbility():FireLinearProjectile("particles/vampiric_shockwave.vpcf", velocity, self.distance, self.width, {}, false, false, 0)
		return self.crit_dmg
	end
end

function modifier_wk_crit_passive:IsHidden()
	return true
end