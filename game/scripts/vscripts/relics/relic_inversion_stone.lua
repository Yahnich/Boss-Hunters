relic_inversion_stone = class(relicBaseClass)

if IsServer() then
	function relic_inversion_stone:OnCreated()
		local parent = self:GetParent()
		self:SetStackCount( (parent:GetStrength() + parent:GetIntellect() + parent:GetAgility() - parent:GetPrimaryStatValue() ) / 2 )
		self:StartIntervalThink(0.33)
	end

	function relic_inversion_stone:OnIntervalThink()
		local parent = self:GetParent()
		self:SetStackCount( (parent:GetStrength() + parent:GetIntellect() + parent:GetAgility() - parent:GetPrimaryStatValue() ) / 2 )
	end
end

function relic_inversion_stone:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end

function relic_inversion_stone:GetModifierBaseAttack_BonusDamage(params)
	return self:GetStackCount()
end 