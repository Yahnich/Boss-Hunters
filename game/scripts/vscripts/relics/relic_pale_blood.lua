relic_pale_blood = class(relicBaseClass)

function relic_pale_blood:OnCreated()
	self:GetParent():HookInModifier("GetModifierExtraHealthBonusPercentage", self)
end

function relic_pale_blood:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierExtraHealthBonusPercentage", self)
end

function relic_pale_blood:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function relic_pale_blood:GetModifierExtraHealthBonusPercentage()
	if not self:GetParent():HasModifier("relic_ritual_candle") then return -25 end
end

function relic_pale_blood:OnTakeDamage(params)
	if params.attacker == self:GetParent() 
	and params.attacker ~= params.unit
	and self:GetParent():GetHealthDeficit() > params.damage 
	and self:GetParent():GetHealth() > 0
	and not (  HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) 
			or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) 
			or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) )
	then
		params.attacker:HealEvent(params.damage * 0.30, nil, params.attacker)
	end
end