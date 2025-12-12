alchemist_alchemists_greed = class({})

function alchemist_alchemists_greed:GetIntrinsicModifierName()
	return "modifier_alchemist_alchemists_greed_handler"
end

modifier_alchemist_alchemists_greed_handler = class({})
LinkLuaModifier("modifier_alchemist_alchemists_greed_handler", "heroes/hero_alchemist/alchemist_alchemists_greed", 0)

function modifier_alchemist_alchemists_greed_handler:OnCreated()
	self.minionGold = self:GetSpecialValueFor("minion_gold")
	self.monsterGold = self:GetSpecialValueFor("monster_gold")
	self.bossGold = self:GetSpecialValueFor("boss_gold")
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_alchemist_alchemists_greed_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_alchemist_alchemists_greed_handler:IsHidden()
	return true
end

function modifier_alchemist_alchemists_greed_handler:OnDeath(params)
	local caster = self:GetCaster()
	if not params.unit:IsSameTeam( caster )  and caster:IsRealHero() and CalculateDistance( params.unit, caster ) < self.radius then
		local gold = self.monsterGold
		if params.unit:IsMinion() then
			gold = self.minionGold
		elseif params.unit:IsBoss() then
			gold = self.bossGold
		end
		caster:AddGold( gold )
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

