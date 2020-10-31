relic_crystal_skull = class(relicBaseClass)

function relic_crystal_skull:OnCreated()
	self:StartIntervalThink(0.3)
end

function relic_crystal_skull:OnIntervalThink()
	if IsServer() then
		local enemies = self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), 450 )
		if #enemies > 0 then 
			self:SetStackCount(1) 
		else
			self:SetStackCount(0)
		end
	end
end

function relic_crystal_skull:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = not self:IsHidden()}
end

function relic_crystal_skull:DeclareFunctions()
	return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end


function relic_crystal_skull:GetModifierInvisibilityLevel()
	if not self:IsHidden() then
		return 45
	end
end

function relic_crystal_skull:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function relic_crystal_skull:IsHidden()
	return self:GetStackCount() ~= 0
end