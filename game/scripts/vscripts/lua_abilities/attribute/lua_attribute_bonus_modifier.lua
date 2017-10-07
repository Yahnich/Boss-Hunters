lua_attribute_bonus_modifier = class({})

function lua_attribute_bonus_modifier:OnCreated()
	self.agiamp = 50
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function lua_attribute_bonus_modifier:RemoveOnDeath()
	return false
end

function lua_attribute_bonus_modifier:OnIntervalThink()
	if self:GetParent():GetHealth() < 1 then
		self:GetParent():ForceKill(true)
	end
end

function lua_attribute_bonus_modifier:GetModifierBonusStats_All(nType, nBonus)
	local nLevel = self:GetCaster()	:GetLevel()
	local nStats = (1.07^nLevel * nBonus + nLevel^0.3 * 10) / 2
	if self:GetCaster():GetPrimaryAttribute() == nType then 
		return math.floor(nStats * 1.2)
	else
		return math.floor(nStats)
	end
end



function lua_attribute_bonus_modifier:IsHidden()
	return true
end

function lua_attribute_bonus_modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function lua_attribute_bonus_modifier:AllowIllusionDuplicate()
	return true
end