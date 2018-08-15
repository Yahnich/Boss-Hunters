boss_wk_culling_blow = class({})

function boss_wk_culling_blow:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_boss_wk_culling_blow", {})
end

function boss_wk_culling_blow:OnProjectileHit(target, position)
	if target then
		self:DealDamage(self:GetCaster(), target, target:GetMaxHealth() * self:GetSpecialValueFor("max_hp_damage") / 100, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
	end
end

modifier_boss_wk_culling_blow = class({})
LinkLuaModifier("modifier_boss_wk_culling_blow", "bosses/boss_wk/boss_wk_culling_blow", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_wk_culling_blow:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

function modifier_boss_wk_culling_blow:GetModifierPreAttack_CriticalStrike()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_SkeletonKing.CriticalStrike")
	if caster:HasModifier("modifier_boss_wk_reincarnation_enrage") then
		self:GetAbility():FireLinearProjectile("particles/heroes/wraith/wraith_life_strikewave.vpcf", caster:GetForwardVector() * 300, 1200, 200)
	end
	self:Destroy()
	return self:GetSpecialValueFor("critical")
end

function modifier_boss_wk_culling_blow:GetActivityTranslationModifiers()
	return "wraith_spin"
end