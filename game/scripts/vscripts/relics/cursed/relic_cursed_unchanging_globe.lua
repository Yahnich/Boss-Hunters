relic_cursed_unchanging_globe = class(relicBaseClass)

function relic_cursed_unchanging_globe:OnCreated()
	self.mana = 10 - self:GetParent():GetMaxMana()
	self:StartIntervalThink(0)
end

function relic_cursed_unchanging_globe:OnIntervalThink()	
	self.mana = 10 - self:GetParent():GetMaxMana() + self.mana
end

function relic_cursed_unchanging_globe:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_MANA_BONUS }
end

function relic_cursed_unchanging_globe:GetModifierManaBonus()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return self.mana end
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