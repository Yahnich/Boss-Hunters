relic_unique_lunar_needle = class(relicBaseClass)

function relic_unique_lunar_needle:OnCreated()
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
end

function relic_unique_lunar_needle:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function relic_unique_lunar_needle:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self:GetParent():GetHealth() > 0 and self:GetParent():IsRealHero() and not params.inflictor then
		local flHeal = params.damage * 0.15
		for _, ally in ipairs( self:GetParent():FindFriendlyUnitsInRadius( params.target:GetAbsOrigin(), 900 ) ) do
			ally:HealEvent(flHeal, self:GetAbility(), params.attacker)
		end
	end
end