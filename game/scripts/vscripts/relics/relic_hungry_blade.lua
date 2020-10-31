relic_hungry_blade = class(relicBaseClass)

function relic_hungry_blade:OnCreated()
	if IsServer() then
		self:SetDuration(6, true)
		self:StartIntervalThink(6)
	end
end

function relic_hungry_blade:OnIntervalThink()
	if self.firstAttack and RoundManager:IsRoundGoing() and RoundManager:GetCurrentEvent() and not RoundManager:GetCurrentEvent():IsEvent() and not self:GetParent():HasModifier("relic_ritual_candle") then
		self:SetDuration(-1, true)
		self:StartIntervalThink(0.33)
		local damage = self:GetParent():GetHealth() * (5 * 0.33) / 100
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NON_LETHAL})
	else
		self:SetDuration(6, true)
		self:StartIntervalThink(0.33)
		self.firstAttack = false
	end
end

function relic_hungry_blade:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_EVENT_ON_DEATH, }
end

function relic_hungry_blade:GetModifierPreAttack_BonusDamage()
	return 75
end

function relic_hungry_blade:GetModifierAttackSpeedBonus_Constant()
	return 75
end

function relic_hungry_blade:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self.firstAttack = true
		self:SetDuration(6, true)
		self:StartIntervalThink(6)
	end
end

function relic_hungry_blade:OnDeath(params)
	if params.unit == self:GetParent() then
		self.firstAttack = false
		self:SetDuration(6, true)
		self:StartIntervalThink(0.33)
	end
end

function relic_hungry_blade:IsDebuff()
	return self:GetDuration() == -1 and not self:GetParent():HasModifier("relic_ritual_candle")
end

function relic_hungry_blade:IsHidden()
	return self:GetParent():HasModifier("relic_ritual_candle")
end