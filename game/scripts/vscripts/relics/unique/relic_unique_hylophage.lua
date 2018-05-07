relic_unique_hylophage = class({})

function relic_unique_hylophage:OnCreated()	
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(12)
	end
end

function relic_unique_hylophage:OnIntervalThink()
	self:SetStackCount(CutTreesInRadius(self:GetParent():GetAbsOrigin(), 600))
	self:SetDuration(12.1, true)
end

function relic_unique_hylophage:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function relic_unique_hylophage:GetModifierConstantHealthRegen()
	return 5 * self:GetStackCount()
end

function relic_unique_hylophage:IsHidden()
	return false
end

function relic_unique_hylophage:IsPurgable()
	return false
end

function relic_unique_hylophage:DestroyOnExpire()
	return false
end

function relic_unique_hylophage:RemoveOnDeath()
	return false
end

function relic_unique_hylophage:IsPermanent()
	return true
end

function relic_unique_hylophage:AllowIllusionDuplicate()
	return true
end

function relic_unique_hylophage:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end