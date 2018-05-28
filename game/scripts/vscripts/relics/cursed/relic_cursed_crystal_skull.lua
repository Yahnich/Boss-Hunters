relic_cursed_crystal_skull = class(relicBaseClass)

function relic_cursed_crystal_skull:OnCreated()
	self:SetStackCount(0)
	self.total_armor = self:GetParent():GetPhysicalArmorValue() or 0
	self.magic_resistance = ( 1 / ( 1 - self:GetParent():GetMagicalArmorValue() ) - 1 ) * 100 or 0
	self:StartIntervalThink(0.3)
end

function relic_cursed_crystal_skull:OnIntervalThink()
	self.total_armor = 0
	self.magic_resistance = 0
	self.total_armor = self:GetParent():GetPhysicalArmorValue() or 0
	self.magic_resistance = ( 1 / ( 1 - self:GetParent():GetMagicalArmorValue() ) - 1 ) * 100 or 0
	if IsServer() then
		local enemies = self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), 450 )
		if #enemies > 0 then 
			self:SetStackCount(1) 
		else
			self:SetStackCount(0)
		end
	end
end

function relic_cursed_crystal_skull:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = not self:IsHidden()}
end

function relic_cursed_crystal_skull:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end

function relic_cursed_crystal_skull:GetModifierPhysicalArmorBonus()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return (self.total_armor or 0) * (-1) end
end

function relic_cursed_crystal_skull:GetModifierMagicalResistanceBonus()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return (self.magic_resistance or 0) * (-1) end
end

function relic_cursed_crystal_skull:GetModifierInvisibilityLevel()
	if not self:IsHidden() then
		return 45
	end
end

function relic_cursed_crystal_skull:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function relic_cursed_crystal_skull:IsHidden()
	return self:GetStackCount() ~= 0
end