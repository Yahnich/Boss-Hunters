relic_unique_longbow = class(relicBaseClass)

function relic_unique_longbow:OnCreated()
	if IsServer() then
		self:GetParent().originalAttackCapability = self:GetParent():GetAttackCapability()
		self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_RANGED_ATTACK )
		if self:GetParent():originalAttackCapability() ~= DOTA_UNIT_CAP_RANGED_ATTACK then self:GetParent():SetRangedProjectileName( "particles/base_attacks/generic_projectile.vpcf" ) end
	end
end

function relic_unique_longbow:OnDestroy()
	if IsServer() then
		self:GetParent():SetAttackCapability( self:GetParent().originalAttackCapability )
		if self:GetParent():originalAttackCapability() ~= DOTA_UNIT_CAP_RANGED_ATTACK then self:GetParent():SetRangedProjectileName( "" ) end
	end
end

function relic_unique_longbow:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS}
end

function relic_unique_longbow:GetModifierAttackRangeBonus()
	return 200
end

function relic_unique_longbow:GetModifierProjectileSpeedBonus()
	return 900
end