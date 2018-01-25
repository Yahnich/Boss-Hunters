alchemist_alchemists_greed = class({})

function alchemist_alchemists_greed:GetIntrinsicModifierName()
	return "modifier_alchemist_alchemists_greed_passive"
end

modifier_alchemist_alchemists_greed_passive = class({})
LinkLuaModifier("modifier_alchemist_alchemists_greed_passive", "heroes/hero_alchemist/alchemist_alchemists_greed", 0)

function modifier_alchemist_alchemists_greed_passive:OnCreated()
	self.goldonhit = self:GetTalentSpecialValueFor("gold_per_hit")
end

function modifier_alchemist_alchemists_greed_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_alchemist_alchemists_greed_passive:IsHidden()
	return true
end

function modifier_alchemist_alchemists_greed_passive:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() then
		self:GetAbility():SetCooldown()
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local excess = self.goldonhit - math.floor(self.goldonhit)
		if caster:IsIllusion() then
			local player = caster:GetPlayerOwnerID()
			caster = PlayerResource:GetSelectedHeroEntity(player)
		end
		if excess > 0 then
			caster.greedRemainder = caster.greedRemainder or 0
			caster.greedRemainder = caster.greedRemainder + excess
		end
		self.goldonhit = math.floor(self.goldonhit)
		if caster.greedRemainder >= 1 then
			self.goldonhit = self.goldonhit + caster.greedRemainder
			caster.greedRemainder = 0
		end
        local totalgold = caster:GetGold() + self.goldonhit
        caster:SetGold(0 , false)
        caster:SetGold(totalgold, true)
		if caster:HasScepter() and caster:IsRealHero() then
			for _,hero in pairs ( caster:FindFriendlyUnitsInRange(caster:GetAbsOrigin(), 1200) ) do
				if hero:IsRealHero() then
					local gold = hero:GetGold() + self.goldonhit
					hero:SetGold(0 , false)
					hero:SetGold(gold , true)
				end
			end
		end
	end
end