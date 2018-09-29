-- original formula = ( (13.9) * (1 + (x * (0.0135) ) ) ) = ( (13.9) * (1 + (x * (0.0225) ) ) ) * y

modifier_mana_regen_throttle = class({})

function modifier_mana_regen_throttle:OnCreated()
	self:SetStackCount(0)
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function modifier_mana_regen_throttle:OnIntervalThink()
	local int = self:GetParent():GetIntellect()
	self:SetStackCount( 0 )
	if IsServer() then self:GetParent():CalculateStatBonus() end
	local result = ( ( self:GetParent():GetManaRegen() - ( self:GetParent():GetBaseManaRegen() + self:GetParent():GetBonusManaRegen() ) ) * 0.25 ) / self:GetParent():GetManaRegenMultiplier()
	self:SetStackCount( math.ceil( result * 100 ) )
	if IsServer() then self:GetParent():CalculateStatBonus() end
end

function modifier_mana_regen_throttle:OnDestroy()
	self:SetStackCount( 0 )
	if IsServer() then self:GetParent():CalculateStatBonus() end
end


function modifier_mana_regen_throttle:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end

function modifier_mana_regen_throttle:GetModifierConstantManaRegen(params)
	return - self:GetStackCount() / 100
end

function modifier_mana_regen_throttle:IsHidden()
	return true
end

function modifier_mana_regen_throttle:IsPurgable()
	return false
end

function modifier_mana_regen_throttle:RemoveOnDeath()
	return false
end

function modifier_mana_regen_throttle:IsPermanent()
	return true
end

function modifier_mana_regen_throttle:AllowIllusionDuplicate()
	return true
end

function modifier_mana_regen_throttle:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end