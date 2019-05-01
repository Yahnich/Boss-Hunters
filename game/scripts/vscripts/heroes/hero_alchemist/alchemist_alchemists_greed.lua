alchemist_alchemists_greed = class({})

function alchemist_alchemists_greed:GetCooldown(iLvl)
	local cd = self.BaseClass.GetCooldown(self, iLvl)
	return cd
end

function alchemist_alchemists_greed:GetIntrinsicModifierName()
	return "modifier_alchemist_alchemists_greed_handler"
end

modifier_alchemist_alchemists_greed_handler = class({})
LinkLuaModifier("modifier_alchemist_alchemists_greed_handler", "heroes/hero_alchemist/alchemist_alchemists_greed", 0)

function modifier_alchemist_alchemists_greed_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_alchemist_alchemists_greed_handler:IsHidden()
	return true
end

function modifier_alchemist_alchemists_greed_handler:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() then
		self:GetAbility():SetCooldown()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		
		self.goldonhit = self:GetTalentSpecialValueFor("gold_per_hit")
		if caster:HasScepter() then self.goldonhit = self:GetTalentSpecialValueFor("scepter_gold_per_hit") end
		self.alliedgold = self:GetTalentSpecialValueFor("scepter_allied_gold")
		local excess = self.goldonhit - math.floor(self.goldonhit)
		if caster:IsIllusion() then
			local player = caster:GetPlayerOwnerID()
			caster = PlayerResource:GetSelectedHeroEntity(player)
		end
		self.greedRemainder = self.greedRemainder or 0
		if excess > 0 then
			self.greedRemainder = self.greedRemainder + excess
		end
		self.goldonhit = math.floor(self.goldonhit)
		if self.greedRemainder >= 1 then
			self.goldonhit = self.goldonhit + self.greedRemainder
			self.alliedgold = self.alliedgold + self.greedRemainder
			self.greedRemainder = 0
		end
        caster:AddGold(self.goldonhit)
		if caster:HasTalent("special_bonus_unique_alchemist_alchemists_greed_2") and RoundManager:IsRoundGoing() then
			local talent = self:GetCaster():AddNewModifier(caster, self, "modifier_alchemist_alchemists_greed_talent", {})
			if talent then
				talent:SetStackCount( talent:GetStackCount() + self.goldonhit )
			end
		end
		if caster:HasScepter() and caster:IsRealHero() then
			for _,hero in ipairs ( caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), -1) ) do
				if hero:IsRealHero() and hero ~= caster then
					hero:AddGold(self.alliedgold)
				end
			end
		end
	end
end

modifier_alchemist_alchemists_greed_talent = class({})
LinkLuaModifier("modifier_alchemist_alchemists_greed_talent", "heroes/hero_alchemist/alchemist_alchemists_greed", 0)

function modifier_alchemist_alchemists_greed_talent:OnCreated(kv)
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function modifier_alchemist_alchemists_greed_talent:OnEventFinished(args)
	self:Destroy()
end

function modifier_alchemist_alchemists_greed_talent:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function modifier_alchemist_alchemists_greed_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_alchemist_alchemists_greed_talent:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

function modifier_alchemist_alchemists_greed_talent:IsHidden()
	return true
end

function modifier_alchemist_alchemists_greed_talent:IsPurgable()
	return false
end

