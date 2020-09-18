relic_hylophage = class(relicBaseClass)

function relic_hylophage:OnCreated()	
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(12)
	end
end

function relic_hylophage:OnIntervalThink()
	self:SetStackCount(CutTreesInRadius(self:GetParent():GetAbsOrigin(), 600, {ability = self:GetAbility(), caster = self:GetParent()}))
	self:SetDuration(12.1, true)
end

function relic_hylophage:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function relic_hylophage:GetModifierConstantHealthRegen()
	return 5 * self:GetStackCount()
end

function relic_hylophage:IsHidden()
	return false
end