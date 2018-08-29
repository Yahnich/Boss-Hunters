relic_unique_reinforced_bar = class(relicBaseClass)

if IsServer() then
	function relic_unique_reinforced_bar:OnCreated()
		self:StartIntervalThink(0.33)
	end
	
	function relic_unique_reinforced_bar:OnIntervalThink()
		stacks = 0
		for _, modifier in ipairs( self:GetParent():FindAllModifiers() ) do
			if modifier.GetModifierPhysicalArmorBonus and (modifier:GetModifierPhysicalArmorBonus() or 0) ~= 0 and modifier ~= self then
				stacks = stacks + 1
			end
		end
		self:SetStackCount(stacks)
	end
end

function relic_unique_reinforced_bar:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function relic_unique_reinforced_bar:GetModifierPhysicalArmorBonus()
	return 2 * self:GetStackCount()
end

function relic_unique_reinforced_bar:IsHidden()
	return false
end