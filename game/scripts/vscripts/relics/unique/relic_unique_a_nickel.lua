relic_unique_a_nickel = class({})

function relic_unique_a_nickel:OnCreated()
	if IsServer() then
		self:GetParent():AddGold(1500)
	end
end

function relic_unique_a_nickel:IsHidden()
	return true
end

function relic_unique_a_nickel:IsPurgable()
	return false
end

function relic_unique_a_nickel:RemoveOnDeath()
	return false
end

function relic_unique_a_nickel:IsPermanent()
	return true
end

function relic_unique_a_nickel:AllowIllusionDuplicate()
	return true
end

function relic_unique_a_nickel:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end