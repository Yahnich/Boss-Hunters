relic_cursed_icon_of_envy = class(relicBaseClass)

function relic_cursed_icon_of_envy:IncreaseEnvy()
	for _, pIDtable in pairs( CustomNetTables:GetTableValue("game_info", "relic_drops") ) do
		if pIDtable["1"] then
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