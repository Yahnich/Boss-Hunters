relic_silver_knife = class(relicBaseClass)

if IsServer() then
	function relic_silver_knife:OnCreated()
		self:StartIntervalThink(0.33)
	end
	
	function relic_silver_knife:OnIntervalThink()
		stacks = 0
		for _, modifier in ipairs( self:GetParent():FindAllModifiers() ) do
			-- check if exists and if returns nil default to 0 value
			if ( modifier.GetModifierPreAttack_BonusDamage 			and (modifier:GetModifierPreAttack_BonusDamage() or 0) > 0 )
			or ( modifier.GetModifierBaseAttack_BonusDamage 		and (modifier:GetModifierBaseAttack_BonusDamage() or 0) > 0 )
			or ( modifier.GetModifierBaseDamageOutgoing_Percentage 	and (modifier:GetModifierBaseDamageOutgoing_Percentage() or 0) > 0 )
			or ( modifier.GetModifierDamageOutgoing_Percentage 		and (modifier:GetModifierDamageOutgoing_Percentage() or 0) > 0 )
			and modifier ~= self then
				stacks = stacks + 1
			end
		end
		self:SetStackCount(stacks)
	end
end

function relic_silver_knife:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function relic_silver_knife:GetModifierPreAttack_BonusDamage()
	return 15 * self:GetStackCount()
end

function relic_silver_knife:IsHidden()
	return false
end