modifier_attack_speed_handler = class({})

function modifier_attack_speed_handler:OnCreated()
	self.attackspeed = 0
end

function modifier_attack_speed_handler:OnStackCountChanged()
	local attackSpeed = self:GetStackCount()
	-- check sign
	if attackSpeed % 10 == 0 then
		self.attackspeed = math.floor( attackSpeed / 10 )
	else
		self.attackspeed = math.floor( attackSpeed / 10 ) * (-1)
	end
end
	
function modifier_attack_speed_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_attack_speed_handler:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_attack_speed_handler:IsHidden()
	return true
end

function modifier_attack_speed_handler:IsPurgable()
	return false
end

function modifier_attack_speed_handler:RemoveOnDeath()
	return false
end

function modifier_attack_speed_handler:IsPermanent()
	return true
end

function modifier_attack_speed_handler:AllowIllusionDuplicate()
	return true
end

function modifier_attack_speed_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end