pugna_power_vacuum = class({})

function pugna_power_vacuum:GetIntrinsicModifierName()
	return "modifier_pugna_power_vacuum"
end

modifier_pugna_power_vacuum = class({})
LinkLuaModifier("modifier_pugna_power_vacuum", "heroes/hero_pugna/pugna_power_vacuum", LUA_MODIFIER_MOTION_NONE)

function modifier_pugna_power_vacuum:OnCreated()
	self.boss = self:GetTalentSpecialValueFor("boss_lifesteal") / 100
	self.mob = self:GetTalentSpecialValueFor("mob_lifesteal") / 100
end

function modifier_pugna_power_vacuum:OnRefresh()
	self.boss = self:GetTalentSpecialValueFor("boss_lifesteal") / 100
	self.mob = self:GetTalentSpecialValueFor("mob_lifesteal") / 100
end

function modifier_pugna_power_vacuum:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_pugna_power_vacuum:OnTakeDamage(params)
	if params.attacker == self:GetParent() 
	and params.unit ~= self:GetParent() 
	and self:GetParent():GetHealth() > 0 
	and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) )
	and params.inflictor then
		local flHeal = params.damage * self.mob
		if params.unit:IsRoundBoss() then
			flHeal = params.damage * self.boss
		end
		ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
		if params.attacker:GetHealth() < params.attacker:GetMaxHealth() then
			params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
		else
			params.attacker:GiveMana( flHeal )
		end
	end
end

function modifier_pugna_power_vacuum:IsHidden()
	return true
end