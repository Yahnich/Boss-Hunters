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
	return {MODIFIER_EVENT_ON_SPENT_MANA, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function relic_cursed_symbiote:OnSpentMana(params)
	if params.unit == self:GetParent() then
		ApplyDamage({victim = params.unit, attacker = params.unit, damage = params.cost, ability = params.ability, damage_type = DAMAGE_TYPE_PURE})
		params.unit:GiveMana(params.cost)
	end
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