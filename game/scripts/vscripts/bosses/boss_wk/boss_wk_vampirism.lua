boss_wk_vampirism = class({})

function boss_wk_vampirism:GetIntrinsicModifierName()
	return "modifier_boss_wk_vampirism"
end

modifier_boss_wk_vampirism = class({})
LinkLuaModifier("modifier_boss_wk_vampirism", "bosses/boss_wk/boss_wk_vampirism", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_wk_vampirism:OnCreated()
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
end

function modifier_boss_wk_vampirism:OnRefresh()
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
end

function modifier_boss_wk_vampirism:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_wk_vampirism:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and self:GetParent():GetHealth() > 0 and not self:GetParent():PassivesDisabled() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		local lifesteal = self.lifesteal
		if params.inflictor then 
			ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
		end
		ParticleManager:FireParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
		local flHeal = params.damage * lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end

function modifier_boss_wk_vampirism:IsHidden()
	return true
end