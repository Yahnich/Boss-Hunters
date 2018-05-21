relic_unique_chlorophyl_cloak = class(relicBaseClass)

function relic_unique_chlorophyl_cloak:OnCreated()	
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function relic_unique_chlorophyl_cloak:OnIntervalThink()
	if GameRules:IsDaytime() then
		self:SetStackCount(0)
	else
		self:SetStackCount(1)
	end
end

function relic_unique_chlorophyl_cloak:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function relic_unique_chlorophyl_cloak:GetModifierMoveSpeedBonus_Constant()
	if self:GetStackCount() == 0 then return 15 end
end

function relic_unique_chlorophyl_cloak:GetModifierPhysicalArmorBonus()
	if self:GetStackCount() == 0 then return 10 end
end

function relic_unique_chlorophyl_cloak:GetModifierMagicalResistanceBonus()
	if self:GetStackCount() == 0 then return 15 end
end

function relic_unique_chlorophyl_cloak:IsHidden()
	return self:GetStackCount() == 1
end