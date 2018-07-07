relic_unique_antique_pouch = class(relicBaseClass)

function relic_unique_antique_pouch:OnCreated()
	if IsServer() then
		self:LookRelics()
		self:StartIntervalThink(0.33)
	end
end

function relic_unique_antique_pouch:OnIntervalThink()
	self:LookRelics()
end


function relic_unique_antique_pouch:LookRelics()
	local relics = 0
	local hero = self:GetParent()
	for entindex, relicName in pairs(hero.ownedRelics) do
		if relicName ~= "relic_unique_antique_pouch" then
			relics = relics + 1
		end
	end
	self:SetStackCount(relics)
end

function relic_unique_antique_pouch:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function relic_unique_antique_pouch:GetModifierBonusStats_Strength()
	return 3 * self:GetStackCount()
end

function relic_unique_antique_pouch:GetModifierBonusStats_Agility()
	return 3 * self:GetStackCount()
end

function relic_unique_antique_pouch:GetModifierBonusStats_Intellect()
	return 3 * self:GetStackCount()
end