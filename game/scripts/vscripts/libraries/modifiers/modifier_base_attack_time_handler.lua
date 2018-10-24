modifier_base_attack_time_handler = class({})

if IsServer() then
	function modifier_base_attack_time_handler:OnCreated()
		self.baseAttackTime = self:GetParent():GetBaseAttackTime()
		self:SetStackCount( self.baseAttackTime * 100 )
		self:StartIntervalThink(0.1)
	end

	function modifier_base_attack_time_handler:OnIntervalThink()
		local baseAttackTime = self.baseAttackTime * 100
		self:SetStackCount( baseAttackTime )
		self:GetParent():CalculateStatBonus()
		for _, modifier in ipairs( self:GetParent():FindAllModifiers() ) do
			if modifier.GetBaseAttackTime_Bonus and modifier:GetBaseAttackTime_Bonus() then
				baseAttackTime = baseAttackTime + (modifier:GetBaseAttackTime_Bonus() * 100) 
			end
		end
		self:SetStackCount( math.min( math.max( math.floor(baseAttackTime), 10 ), 1000 ) )
	end
end
	
function modifier_base_attack_time_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT}
end

function modifier_base_attack_time_handler:GetModifierBaseAttackTimeConstant()
	return self:GetStackCount() / 100
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