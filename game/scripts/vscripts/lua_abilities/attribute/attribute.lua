lua_attribute_bonus = class({})


LinkLuaModifier( "lua_attribute_bonus_modifier", "lua_abilities/attribute/lua_attribute_bonus_modifier.lua", LUA_MODIFIER_MOTION_NONE )

function lua_attribute_bonus:GetIntrinsicModifierName()
	return "lua_attribute_bonus_modifier"
end

function lua_attribute_bonus:OnHeroLevelUp()
	local strength = self:GetModifierBonusStats_All(0, self:GetCaster():GetStrengthGain())
	local agility = self:GetModifierBonusStats_All(1, self:GetCaster():GetAgilityGain())
	local intellect = self:GetModifierBonusStats_All(2, self:GetCaster():GetIntellectGain())
	self:GetCaster():SetBaseStrength(self:GetCaster():GetBaseStrength() + strength )
	self:GetCaster():SetBaseAgility(self:GetCaster():GetBaseAgility() + agility ) 
	self:GetCaster():SetBaseIntellect(self:GetCaster():GetBaseIntellect() + intellect )
end

function lua_attribute_bonus:GetModifierBonusStats_All(nType, nBonus)
	local nLevel = self:GetCaster()	:GetLevel()
	local nStats = (1.07^nLevel * nBonus + nLevel^0.3 * 10) / 2
	if self:GetCaster():GetPrimaryAttribute() == nType then 
		return math.floor(nStats * 1.2)
	else
		return math.floor(nStats)
	end
end