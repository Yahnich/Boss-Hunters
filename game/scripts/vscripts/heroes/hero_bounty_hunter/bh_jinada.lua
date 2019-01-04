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

function bh_jinada:TriggerJinada(target, bShuriken)
	local caster = self:GetCaster()
	EmitSoundOn("Hero_BountyHunter.Jinada", target)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(nfx)
	if bShuriken then
		target:AddNewModifier(caster, self, "modifier_bh_jinada_maim_shuriken", {Duration = self:GetTalentSpecialValueFor("duration")})
		caster:AddGold( self:GetTalentSpecialValueFor("gold_steal") * 2)
	else
		target:AddNewModifier(caster, self, "modifier_bh_jinada_maim", {Duration = self:GetTalentSpecialValueFor("duration")})
		caster:AddGold( self:GetTalentSpecialValueFor("gold_steal") )
	end
	
	self:SetCooldown()
end

modifier_bh_jinada_handler = class({})

function modifier_bh_jinada_handler:IsHidden() return true end

function modifier_bh_jinada_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_bh_jinada_handler:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetCaster()
		local attacker = params.attacker
		local target = params.target
		local ability = self:GetAbility()

		if attacker == caster and ability:IsCooldownReady() then
			ability:TriggerJinada(target)
		end
	end
end

modifier_bh_jinada_maim = class({})

function modifier_bh_jinada_maim:GetModifierStatusResistanceStacking()
	return self:GetTalentSpecialValueFor("sr_red")
end

function modifier_bh_jinada_maim:GetModifierAttackSpeedBonus()
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


modifier_bh_jinada_maim_shuriken = class({})

function modifier_bh_jinada_maim_shuriken:GetModifierStatusResistanceStacking()
	return self:GetTalentSpecialValueFor("sr_red") * 2
end

function modifier_bh_jinada_maim_shuriken:GetModifierAttackSpeedBonus()
	return self:GetTalentSpecialValueFor("slow_as") * 2
end

function modifier_bh_jinada_maim_shuriken:GetEffectName()
	return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf"
end

function modifier_bh_jinada_maim_shuriken:GetStatusEffectName()
	return "particles/units/heroes/hero_bounty_hunter/status_effect_bounty_hunter_jinda_slow.vpcf"
end

function modifier_bh_jinada_maim_shuriken:StatusEffectPriority()
	return 10
end

function modifier_bh_jinada_maim_shuriken:IsDebuff()
	return true
end