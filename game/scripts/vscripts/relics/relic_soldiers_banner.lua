relic_soldiers_banner = class(relicBaseClass)

function relic_soldiers_banner:OnCreated()
	if IsServer() then
		self:GetParent().originalAttackCapability = self:GetParent():GetAttackCapability()
		self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )
	end
end

function relic_soldiers_banner:OnDestroy()
	if IsServer() then
		self:GetParent():SetAttackCapability( self:GetParent().originalAttackCapability )
	end
end

function relic_soldiers_banner:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function relic_soldiers_banner:GetModifierAttackRangeOverride()
	return 150
end

function relic_soldiers_banner:GetModifierPhysicalArmorBonus()
	return 6
end

function relic_soldiers_banner:GetModifierMoveSpeedBonus_Percentage()
	return 15
end