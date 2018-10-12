relic_cursed_iron_maiden = class(relicBaseClass)

function relic_cursed_iron_maiden:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function relic_cursed_iron_maiden:GetModifierIncomingDamage_Percentage()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return 50 end
end

function relic_cursed_iron_maiden:OnTakeDamage(params)
	local parent = self:GetParent()
	if params.unit == parent then
		local ability = self:GetAbility()
		for _, ally in ipairs( parent:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), 900 ) ) do
			if ally ~= parent then
				ally:HealEvent( params.damage, ability, parent )
			end
		end
	end
end