relic_cursed_grey_fox_tunic = class(relicBaseClass)

function relic_cursed_grey_fox_tunic:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function relic_cursed_grey_fox_tunic:GetModifierPhysicalArmorBonus()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return -10 end
end

function relic_cursed_grey_fox_tunic:GetModifierEvasion_Constant()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return -15 end
end


function relic_cursed_grey_fox_tunic:OnAttackLanded(params)
	local parent = self:GetParent()
	if params.attacker == parent then
		parent:AddGold(2)
	end
end