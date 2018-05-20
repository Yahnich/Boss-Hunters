relic_unique_inversion_stone = class({})

if IsServer() then
	function relic_unique_inversion_stone:OnCreated()
		local parent = self:GetParent()
		self:SetStackCount( parent:GetStrength() + parent:GetIntellect() + parent:GetAgility() - parent:GetPrimaryStatValue() * 2 )
		self:StartIntervalThink(0.33)
	end

	function relic_unique_inversion_stone:OnIntervalThink()
		local parent = self:GetParent()
		self:SetStackCount( parent:GetStrength() + parent:GetIntellect() + parent:GetAgility() - parent:GetPrimaryStatValue() * 2 )
	end
end

function relic_unique_inversion_stone:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end

function relic_unique_inversion_stone:GetModifierBaseAttack_BonusDamage(params)
	return self:GetStackCount()
end 

function relic_unique_inversion_stone:IsHidden()
	return true
end

function relic_unique_inversion_stone:IsPurgable()
	return false
end

function relic_unique_inversion_stone:RemoveOnDeath()
	return false
end

function relic_unique_inversion_stone:IsPermanent()
	return true
end

function relic_unique_inversion_stone:AllowIllusionDuplicate()
	return true
end

function relic_unique_inversion_stone:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end


