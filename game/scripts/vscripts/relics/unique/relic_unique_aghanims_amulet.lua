relic_unique_aghanims_amulet = class({})

function relic_unique_aghanims_amulet:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_item_ultimate_scepter_consumed", {})
	end
end

function relic_unique_aghanims_amulet:IsHidden()
	return true
end

function relic_unique_aghanims_amulet:IsPurgable()
	return false
end

function relic_unique_aghanims_amulet:RemoveOnDeath()
	return false
end

function relic_unique_aghanims_amulet:IsPermanent()
	return true
end

function relic_unique_aghanims_amulet:AllowIllusionDuplicate()
	return true
end

function relic_unique_aghanims_amulet:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end