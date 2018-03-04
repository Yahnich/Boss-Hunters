boss_broodmother_parasitic_injection = class({})

function boss_broodmother_parasitic_injection:GetIntrinsicModifierName()
	return "modifier_boss_broodmother_parasitic_injection_passive"
end

function boss_broodmother_parasitic_injection:SpawnSpiderlings(amount, position)
	if amount > 0 then
		for i = 1, amount do
			local spiderling = CreateUnitByName("npc_dota_creature_spiderling", position + RandomVector(150), true, self, nil, self:GetCaster():GetTeam())
		end
	end
end

modifier_boss_broodmother_parasitic_injection_passive = class({})
LinkLuaModifier("modifier_boss_broodmother_parasitic_injection_passive", "bosses/boss_broodmother/boss_broodmother_parasitic_injection", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_broodmother_parasitic_injection_passive:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_broodmother_parasitic_injection_passive:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_broodmother_parasitic_injection_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss_broodmother_parasitic_injection_passive:OnAttackLanded(params)
	if params.attacker == self:GetParent() and params.target and params.target.AddAbility then
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_boss_broodmother_parasitic_injection_debuff", {duration = self.duration})
	end
end

function modifier_boss_broodmother_parasitic_injection_passive:IsHidden()
	return true
end

modifier_boss_broodmother_parasitic_injection_debuff = class({})
LinkLuaModifier("modifier_boss_broodmother_parasitic_injection_debuff", "bosses/boss_broodmother/boss_broodmother_parasitic_injection", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_broodmother_parasitic_injection_debuff:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
	self.spiders_on_death = self:GetSpecialValueFor("spiders_on_death")
end

function modifier_boss_broodmother_parasitic_injection_debuff:OnRefresh()
	self.slow = self:GetSpecialValueFor("slow")
	self.spiders_on_death = self:GetSpecialValueFor("spiders_on_death")
end

function modifier_boss_broodmother_parasitic_injection_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_DEATH}
end

function modifier_boss_broodmother_parasitic_injection_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_boss_broodmother_parasitic_injection_debuff:OnDeath(params)
	if params.unit == self:GetParent() then
		self:GetAbility():SpawnSpiderlings(self.spiders_on_death, params.unit:GetAbsOrigin())
	end
end

function modifier_boss_broodmother_parasitic_injection_debuff:GetEffectName()
	return "particles/units/heroes/hero_broodmother/broodmother_spiderlings_debuff.vpcf"
end