bh_jinada = class({})
LinkLuaModifier("modifier_bh_jinada_handler", "heroes/hero_bounty_hunter/bh_jinada", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bh_jinada_maim", "heroes/hero_bounty_hunter/bh_jinada", LUA_MODIFIER_MOTION_NONE)

function bh_jinada:IsStealable()
	return false
end

function bh_jinada:IsHiddenWhenStolen()
	return false
end

function bh_jinada:GetIntrinsicModifierName()
	return "modifier_bh_jinada_handler"
end

modifier_bh_jinada_handler = class({})

function modifier_bh_jinada_handler:IsHidden() return true end

function modifier_bh_jinada_handler:OnCreated()
	self.crit_damage = self:GetTalentSpecialValueFor("crit_multiplier")
end

function modifier_bh_jinada_handler:OnRefresh()
	self.crit_damage = 0
end

function modifier_bh_jinada_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
			MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_bh_jinada_handler:GetModifierPreAttack_CriticalStrike(params)
	if IsServer() then
		if self:GetAbility():IsCooldownReady() then
			return self:GetTalentSpecialValueFor("crit_multiplier")
		end
	end
end

function modifier_bh_jinada_handler:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetCaster()
		local attacker = params.attacker
		local target = params.target
		local ability = self:GetAbility()

		if attacker == caster and ability:IsCooldownReady() then
			EmitSoundOn("Hero_BountyHunter.Jinada", target)

			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
						ParticleManager:ReleaseParticleIndex(nfx)

			target:AddNewModifier(caster, ability, "modifier_bh_jinada_maim", {Duration = self:GetTalentSpecialValueFor("duration")})
			ability:SetCooldown()
		end
	end
end

modifier_bh_jinada_maim = class({})
function modifier_bh_jinada_maim:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_bh_jinada_maim:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("slow_ms")
end

function modifier_bh_jinada_maim:GetModifierAttackSpeedBonus_Constant()
	return self:GetTalentSpecialValueFor("slow_as")
end

function modifier_bh_jinada_maim:GetEffectName()
	return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf"
end

function modifier_bh_jinada_maim:GetStatusEffectName()
	return "particles/units/heroes/hero_bounty_hunter/status_effect_bounty_hunter_jinda_slow.vpcf"
end

function modifier_bh_jinada_maim:StatusEffectPriority()
	return 10
end

function modifier_bh_jinada_maim:IsDebuff()
	return true
end