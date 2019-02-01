modifier_move_speed_handler = class({})

INTERNAL_MOVESPEED_CAP = 550

if IsServer() then
	function modifier_move_speed_handler:OnCreated()
		local parent = self:GetParent()
		local newLimit = INTERNAL_MOVESPEED_CAP
		local msStacks = math.min( parent:GetIdealSpeed(), newLimit )
		self:SetStackCount( msStacks )
		self.msModifiers = self.msModifiers or {}
		parent:CalculateStatBonus()
		self:StartIntervalThink(0.33)
	end
	
	function modifier_move_speed_handler:OnIntervalThink()
		local parent = self:GetParent()
		local msLimitMod = 0
		self:SetStackCount(0)
		parent:CalculateStatBonus()
		for id, modifier in ipairs( self.msModifiers ) do
			if modifier and not modifier:IsNull() then
				local bonus = modifier:GetMoveSpeedLimitBonus()
				if bonus then
					msLimitMod = msLimitMod + bonus
				end
			else
				table.remove(self.msModifiers, id)
			end
		end
		local newLimit = INTERNAL_MOVESPEED_CAP + msLimitMod
		local msStacks = math.min( parent:GetIdealSpeed(), newLimit )
		local evasionStacks = math.max( 0, math.floor( ( 1 - msStacks / math.min( newLimit, parent:GetIdealSpeedNoSlows() ) ) * 1000 ) )
		if parent:IsStunned() or parent:IsRooted() then evasionStacks = 999 end
		if self.evasion:GetStackCount() ~= evasionStacks then 
			self.evasion:SetStackCount( evasionStacks )
		end
		if self:GetStackCount() ~= msStacks then 
			self:SetStackCount( msStacks )
		end
		parent:CalculateStatBonus()
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