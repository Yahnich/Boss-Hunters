relic_unique_anaerobic_ring = class(relicBaseClass)

function relic_unique_anaerobic_ring:OnCreated()	
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function relic_unique_anaerobic_ring:OnIntervalThink()
	if not GameRules:IsDaytime() then
		self:SetStackCount(0)
	else
		self:SetStackCount(1)
	end
end

function relic_unique_anaerobic_ring:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE }
end

function relic_unique_anaerobic_ring:GetModifierHealthRegenPercentage()
	if self:GetStackCount() == 0 then return 2 end
end

function relic_unique_anaerobic_ring:IsHidden()
	return self:GetStackCount() == 1
end
