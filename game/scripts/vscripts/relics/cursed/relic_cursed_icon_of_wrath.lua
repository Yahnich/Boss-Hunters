relic_cursed_icon_of_wrath = class({})

function relic_cursed_icon_of_wrath:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function relic_cursed_icon_of_wrath:GetModifierIncomingDamage_Percentage(params)
	self:GetAbility():DealDamage( self:GetParent(), params.attacker, self:GetParent():GetPrimaryStatValue(), {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION} )
	return 25
end

function relic_cursed_icon_of_wrath:IsHidden()
	return true
end

function relic_cursed_icon_of_wrath:IsPurgable()
	return false
end

function relic_cursed_icon_of_wrath:RemoveOnDeath()
	return false
end

function relic_cursed_icon_of_wrath:IsPermanent()
	return true
end

function relic_cursed_icon_of_wrath:AllowIllusionDuplicate()
	return true
end

function relic_cursed_icon_of_wrath:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end