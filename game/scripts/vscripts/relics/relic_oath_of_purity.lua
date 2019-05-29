relic_oath_of_purity = class(relicBaseClass)

function relic_oath_of_purity:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function relic_oath_of_purity:OnIntervalThink()
	local parent = self:GetParent()
	local stacks = 0
	for _, modifier in ipairs( parent:FindAllModifiers() ) do
		if ( modifier.IsDebuff and modifier:IsDebuff() ) or (modifier:GetCaster() and parent:GetTeam() ~= modifier:GetCaster():GetTeam()) then
			stacks = stacks + 1
		end
	end
	self:SetStackCount(stacks)
	self:GetParent():CalculateStatBonus()
end

function relic_oath_of_purity:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function relic_oath_of_purity:GetModifierBonusStats_Strength()
	return 10 * self:GetStackCount()
end

function relic_oath_of_purity:GetModifierBonusStats_Agility()
	return 10 * self:GetStackCount()
end

function relic_oath_of_purity:GetModifierBonusStats_Intellect()
	return 10 * self:GetStackCount()
end

function relic_oath_of_purity:IsHidden()
	return false
end