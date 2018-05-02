relic_cursed_unchanging_globe = class({})

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
	return self.int
end

function relic_cursed_unchanging_globe:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		local delayedCD = params.ability:IsDelayedCooldown()
		params.ability:Refresh()
		if delayedCD then
			params.ability:StartDelayedCooldown(false, 9)
		else
			params.ability:StartCooldown(9)
		end
	end
end

function relic_cursed_unchanging_globe:IsHidden()
	return true
end

function relic_cursed_unchanging_globe:IsPurgable()
	return false
end

function relic_cursed_unchanging_globe:RemoveOnDeath()
	return false
end

function relic_cursed_unchanging_globe:IsPermanent()
	return true
end

function relic_cursed_unchanging_globe:AllowIllusionDuplicate()
	return true
end

function relic_cursed_unchanging_globe:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end