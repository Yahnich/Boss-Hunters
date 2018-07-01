event_buff_demon_shrine = class(relicBaseClass)

function event_buff_demon_shrine:OnCreated()
	if IsServer() then
		self:GetParent():AddGold(2000)
	end
end

function event_buff_demon_shrine:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			}
end

function event_buff_demon_shrine:GetModifierPhysicalArmorBonus()
	return -10
end

function event_buff_demon_shrine:GetModifierMagicalResistanceBonus()
	return -20
end