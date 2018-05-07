relic_cursed_icon_of_envy = class({})

function relic_cursed_icon_of_envy:IncreaseEnvy()
	for _, pIDtable in pairs( CustomNetTables:GetTableValue("game_info", "relic_drops") ) do
		if pIDtable[1] then
			self:IncrementStackCount()
		end
	end
end

function relic_cursed_icon_of_envy:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function relic_cursed_icon_of_envy:GetModifierBonusStats_Strength()
	return -20 + 5 * self:GetStackCount()
end

function relic_cursed_icon_of_envy:GetModifierBonusStats_Agility()
	return -20 + 5 * self:GetStackCount()
end

function relic_cursed_icon_of_envy:GetModifierBonusStats_Intellect()
	return -20 + 5 * self:GetStackCount()
end

function relic_cursed_icon_of_envy:IsDebuff()
	return self:GetStackCount() <= 4
end

function relic_cursed_icon_of_envy:IsHidden()
	return true
end

function relic_cursed_icon_of_envy:IsPurgable()
	return false
end

function relic_cursed_icon_of_envy:RemoveOnDeath()
	return false
end

function relic_cursed_icon_of_envy:IsPermanent()
	return true
end

function relic_cursed_icon_of_envy:AllowIllusionDuplicate()
	return true
end

function relic_cursed_icon_of_envy:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end