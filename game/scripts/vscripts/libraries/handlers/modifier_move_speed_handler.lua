modifier_move_speed_handler = class({})
INTERNAL_MOVESPEED_CAP = 550
if IsServer() then
	function modifier_move_speed_handler:OnCreated()
		self:SetStackCount( INTERNAL_MOVESPEED_CAP )
		self:StartIntervalThink(0.33)
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_bloodseeker_thirst", {})
	end

	function modifier_move_speed_handler:OnIntervalThink()
		local parent = self:GetParent()
		local msLimitMod = 0
		local bonusMS = 0
		local bonusMSUnique = 0
		local bonusMSPCT = 0
		local bonusMSPCTUnique = 0
		local hasteSpeed = 0
		for _, modifier in ipairs( parent:FindAllModifiers() ) do
			if modifier.GetMoveSpeedLimitBonus and modifier:GetMoveSpeedLimitBonus() then
				msLimitMod = msLimitMod + modifier:GetMoveSpeedLimitBonus()
			end
			-- if modifier.GetMoveSpeedLimitBonus and modifier:GetMoveSpeedLimitBonus() then
				-- msLimitMod = msLimitMod + modifier:GetMoveSpeedLimitBonus()
			-- end
			-- if modifier.GetMoveSpeedLimitBonus and modifier:GetMoveSpeedLimitBonus() then
				-- msLimitMod = msLimitMod + modifier:GetMoveSpeedLimitBonus()
			-- end
			-- if modifier.GetMoveSpeedLimitBonus and modifier:GetMoveSpeedLimitBonus() then
				-- msLimitMod = msLimitMod + modifier:GetMoveSpeedLimitBonus()
			-- end
			-- if modifier.GetMoveSpeedLimitBonus and modifier:GetMoveSpeedLimitBonus() then
				-- msLimitMod = msLimitMod + modifier:GetMoveSpeedLimitBonus()
			-- end
			-- if modifier.GetMoveSpeedLimitBonus and modifier:GetMoveSpeedLimitBonus() then
				-- msLimitMod = msLimitMod + modifier:GetMoveSpeedLimitBonus()
			-- end
			-- if modifier.GetMoveSpeedLimitBonus and modifier:GetMoveSpeedLimitBonus() then
				-- msLimitMod = msLimitMod + modifier:GetMoveSpeedLimitBonus()
			-- end
		end
		local newLimit = INTERNAL_MOVESPEED_CAP + msLimitMod
		self:SetStackCount( 0 )
		self:SetStackCount( math.min( parent:GetIdealSpeed(), newLimit ) )
	end
	
	function modifier_move_speed_handler:OnDestroy()
		self:GetParent():RemoveModifierByName("modifier_bloodseeker_thirst")
	end
end
	
function modifier_move_speed_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE}
end

function modifier_move_speed_handler:GetModifierMoveSpeed_Absolute()
	return self:GetStackCount()
end

function modifier_move_speed_handler:IsHidden()
	return true
end

function modifier_move_speed_handler:IsPurgable()
	return false
end

function modifier_move_speed_handler:RemoveOnDeath()
	return false
end

function modifier_move_speed_handler:IsPermanent()
	return true
end

function modifier_move_speed_handler:AllowIllusionDuplicate()
	return true
end

function modifier_move_speed_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end