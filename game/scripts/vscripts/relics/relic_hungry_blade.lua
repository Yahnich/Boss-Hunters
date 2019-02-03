relic_hungry_blade = class(relicBaseClass)

function relic_hungry_blade:OnCreated()
	if IsServer() then
		self:SetDuration(6, true)
		self:StartIntervalThink(6)
	end
end

function relic_hungry_blade:OnIntervalThink()
	if RoundManager:IsRoundGoing() and RoundManager:GetCurrentEvent() and not RoundManager:GetCurrentEvent():IsEvent() then
		self:SetDuration(-1, true)
		self:StartIntervalThink(0.33)
	else
		self:SetDuration(6, true)
		self:StartIntervalThink(0.33)
	end
end

function relic_hungry_blade:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,  MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE }
end

function relic_hungry_blade:GetModifierPreAttack_BonusDamage()
	return 100
end

function relic_hungry_blade:GetModifierAttackSpeedBonus()
	return 100
end

function relic_hungry_blade:GetModifierHealthRegenPercentage()
	if not self:GetParent():HasModifier("relic_ritual_candle") and self:GetDuration() == -1 then return -5 end
end


function relic_hungry_blade:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetParent():HasModifier("relic_ritual_candle") then return -15 end
end

function relic_hungry_blade:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:SetDuration(6, true)
		self:StartIntervalThink(6)
	end
end

function relic_hungry_blade:IsDebuff()
	return self:GetDuration() == -1
end

function relic_hungry_blade:IsHidden()
	return false
end