relic_cursed_pale_blood = class({})

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
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function relic_cursed_pale_blood:GetModifierHealthBonus()
	return self:GetStackCount() * (-1)
end

function relic_cursed_pale_blood:OnTakeDamage(params)
	if params.attacker == self:GetParent() and self:GetParent():GetHealthDeficit() > params.damage and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		params.attacker:HealEvent(params.damage * 0.30, nil, params.attacker)
	end
end


function relic_cursed_pale_blood:IsHidden()
	return true
end

function relic_cursed_pale_blood:IsPurgable()
	return false
end

function relic_cursed_pale_blood:RemoveOnDeath()
	return false
end

function relic_cursed_pale_blood:IsPermanent()
	return true
end

function relic_cursed_pale_blood:AllowIllusionDuplicate()
	return true
end

function relic_cursed_pale_blood:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end