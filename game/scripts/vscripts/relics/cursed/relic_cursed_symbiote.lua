relic_cursed_symbiote = class(relicBaseClass)

function relic_cursed_symbiote:OnCreated()
	if IsServer() then
		self:SetStackCount( self:GetParent():GetBonusManaRegen() + self:GetParent():GetBaseManaRegen( ) )
		self:StartIntervalThink(0.33)
	end
end

function relic_cursed_symbiote:OnIntervalThink()
	self:SetStackCount( self:GetParent():GetBonusManaRegen() + self:GetParent():GetBaseManaRegen( ) )
end

function relic_cursed_symbiote:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELLS_REQUIRE_HP, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function relic_cursed_symbiote:GetModifierSpellsRequireHP()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return 1 end
end

function relic_cursed_symbiote:GetModifierHealthBonus()
	return self:GetParent():GetMaxMana()
end

function relic_cursed_symbiote:GetModifierConstantHealthRegen()
	return self:GetStackCount()
end