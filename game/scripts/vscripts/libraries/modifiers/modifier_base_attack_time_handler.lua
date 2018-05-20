modifier_base_attack_time_handler = class({})

if IsServer() then
	function modifier_base_attack_time_handler:OnCreated()
		self.baseAttackTime = self:GetParent():GetBaseAttackTime()
		self:SetStackCount( self.baseAttackTime * 10 )
		self:StartIntervalThink(0.1)
	end

	function modifier_base_attack_time_handler:OnIntervalThink()
		local baseAttackTime = self.baseAttackTime * 10
		for _, modifier in ipairs( self:GetParent():FindAllModifiers() ) do
			if modifier.GetBaseAttackTime_Bonus and modifier:GetBaseAttackTime_Bonus() then
				baseAttackTime = baseAttackTime + (modifier:GetBaseAttackTime_Bonus() * 10) 
			end
		end
		self:SetStackCount( baseAttackTime )
	end
end
	
function modifier_base_attack_time_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT}
end

function modifier_base_attack_time_handler:GetModifierBaseAttackTimeConstant()
	return self:GetStackCount() / 10
end

function modifier_base_attack_time_handler:IsHidden()
	return true
end

function modifier_base_attack_time_handler:IsPurgable()
	return false
end

function modifier_base_attack_time_handler:RemoveOnDeath()
	return false
end

function modifier_base_attack_time_handler:IsPermanent()
	return true
end

function modifier_base_attack_time_handler:AllowIllusionDuplicate()
	return true
end

function modifier_base_attack_time_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end