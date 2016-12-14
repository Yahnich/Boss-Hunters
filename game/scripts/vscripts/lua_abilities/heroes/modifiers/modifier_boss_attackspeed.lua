modifier_boss_attackspeed = class({})

function modifier_boss_attackspeed:IsHidden()
	return true
end

function modifier_boss_attackspeed:OnCreated()
	if IsServer() then
		self:SetStackCount(math.floor(GameRules.gameDifficulty + 0.5))
	end
end

function modifier_boss_attackspeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
	return funcs
end

--------------------------------------------------------------------------------
	function modifier_boss_attackspeed:GetModifierAttackSpeedBonus_Constant( params )
		return 200* (1 + (self:GetStackCount() - 1)* 0.15)
	end

	function modifier_boss_attackspeed:GetModifierMoveSpeedBonus_Constant( params )
		return (self:GetStackCount() - 1) * 15
	end

	function modifier_boss_attackspeed:GetModifierPercentageCooldown( params )
		return self:GetStackCount()*5
	end

	function modifier_boss_attackspeed:GetModifierConstantManaRegen( params )
		return self:GetStackCount()*2.5
	end

	function modifier_boss_attackspeed:GetModifierManaBonus( params )
		return self:GetStackCount()*250
	end



