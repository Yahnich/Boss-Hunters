relic_cursed_symbiote = class({})

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
	return 1
end

function relic_cursed_symbiote:GetModifierHealthBonus()
	return self:GetParent():GetMaxMana()
end

function relic_cursed_symbiote:GetModifierConstantHealthRegen()
	return self:GetStackCount()
end

function relic_cursed_symbiote:IsHidden()
	return true
end

function relic_cursed_symbiote:IsPurgable()
	return false
end

function relic_cursed_symbiote:RemoveOnDeath()
	return false
end

function relic_cursed_symbiote:IsPermanent()
	return true
end

function relic_cursed_symbiote:AllowIllusionDuplicate()
	return true
end

function relic_cursed_symbiote:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end