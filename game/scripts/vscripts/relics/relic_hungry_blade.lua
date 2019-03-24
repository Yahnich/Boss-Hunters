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
		local damage = self:GetParent():GetMaxHealth() * (5 * 0.33) / 100
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL})
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
	if IsClient() then
		if not self:GetParent():HasModifier("relic_ritual_candle") and self:GetDuration() == -1 then 
			return -5 
		end
	end
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