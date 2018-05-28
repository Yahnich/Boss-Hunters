relic_cursed_pale_blood = class(relicBaseClass)

function relic_cursed_pale_blood:OnCreated()
	if IsServer() then
		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.35 )
		self:GetParent():CalculateStatBonus()
		self:StartIntervalThink(0.15)
	end
end

function relic_cursed_pale_blood:OnIntervalThink()
	if IsServer() then
		self:SetStackCount( 0 )
		self:GetParent():CalculateStatBonus()

		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.35 )
		self:GetParent():CalculateStatBonus()
	end
end

function relic_cursed_pale_blood:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function relic_cursed_pale_blood:GetModifierExtraHealthBonus()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return self:GetStackCount() * (-1) end
end

function relic_cursed_pale_blood:OnTakeDamage(params)
	if params.attacker == self:GetParent() and self:GetParent():GetHealthDeficit() > params.damage and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		params.attacker:HealEvent(params.damage * 0.30, nil, params.attacker)
	end
end