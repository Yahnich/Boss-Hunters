relic_unique_longbow = class(relicBaseClass)

function relic_unique_longbow:OnCreated()
	if IsServer() then
		self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_RANGED_ATTACK )
		self:GetParent():SetRangedProjectileName( "particles/base_attacks/generic_projectile.vpcf" )
	end
end

function relic_unique_longbow:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function relic_unique_longbow:GetModifierAttackRangeBonus()
	return 200
end