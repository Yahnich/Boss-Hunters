modifier_attack_speed_handler = class({})
INTERNAL_ATTACK_SPEED_CAP = 500

if IsServer() then
	function modifier_attack_speed_handler:OnCreated()
		self:SetStackCount( 0 )
		self:StartIntervalThink(0.33)
	end

	function modifier_attack_speed_handler:OnIntervalThink()
		local parent = self:GetParent()
		local returnAttackSpeed = 0
		local attackSpeedPct = 1
		local bonusAttackSpeedCap = 0
		self:SetStackCount( 0 )
		parent:CalculateStatBonus()
		-- Get attack speed from agility and check if it needs to be capped
		local attackSpeed = parent:GetAttackSpeed()
		for _, modifier in ipairs( parent:FindAllModifiers() ) do
			if modifier.GetModifierAttackSpeedBonus and modifier:GetModifierAttackSpeedBonus() then
				returnAttackSpeed = returnAttackSpeed + (modifier:GetModifierAttackSpeedBonus() or 0)
			end
			if modifier.GetModifierAttackSpeedBonusPercentage and modifier:GetModifierAttackSpeedBonusPercentage() then
				attackSpeedPct = attackSpeedPct + (modifier:GetModifierAttackSpeedBonusPercentage() or 0) / 100
			end
			if modifier.GetModifierAttackSpeedLimitBonus and modifier:GetModifierAttackSpeedLimitBonus() then
				bonusAttackSpeedCap = bonusAttackSpeedCap + (modifier:GetModifierAttackSpeedLimitBonus() or 0) / 100
			end
		end
		local maxAttackSpeed = (INTERNAL_ATTACK_SPEED_CAP + bonusAttackSpeedCap ) - attackSpeed
		returnAttackSpeed = math.min( returnAttackSpeed * attackSpeedPct, maxAttackSpeed )
		-- attach sign value at the end so we can modulo subtract it
		if returnAttackSpeed > 0 then
			returnAttackSpeed = returnAttackSpeed.."0"
		else
			returnAttackSpeed = returnAttackSpeed.."1"
		end
		self:SetStackCount( tonumber(returnAttackSpeed) )
		parent:CalculateStatBonus()
	end
end
	
function modifier_attack_speed_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_attack_speed_handler:GetModifierAttackSpeedBonus_Constant()
	local attackSpeed = self:GetStackCount()
	-- check sign
	if attackSpeed % 10 == 0 then
		return math.floor( attackSpeed / 10 )
	else
		return math.floor( attackSpeed / 10 ) * (-1)
	end
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