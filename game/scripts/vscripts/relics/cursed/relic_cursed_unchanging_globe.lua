relic_cursed_unchanging_globe = class(relicBaseClass)

function relic_cursed_unchanging_globe:OnCreated()
	self.int = 10 - self:GetParent():GetIntellect()
	self:StartIntervalThink(0)
end

function relic_cursed_unchanging_globe:OnIntervalThink()	
	self.int = 10 - self:GetParent():GetIntellect() + self.int
end

function relic_cursed_unchanging_globe:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function relic_cursed_unchanging_globe:GetModifierBonusStats_Intellect()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return self.int end
end

function relic_cursed_unchanging_globe:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.ability:GetName() ~= "item_tombstone" then
		local delayedCD = params.ability:IsDelayedCooldown()
		params.ability:Refresh()
		if delayedCD then
			params.ability:StartDelayedCooldown(false, 9)
		else
			params.ability:StartCooldown(9)
		end
	end
end