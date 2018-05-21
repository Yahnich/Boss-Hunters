relic_cursed_hungry_blade = class(relicBaseClass)

function relic_cursed_hungry_blade:OnCreated()
	if IsServer() then
		self:StartIntervalThink(6)
		self:SetDuration(6, true)
	end
end
function relic_cursed_hungry_blade:OnIntervalThink()
	self:StartIntervalThink(0.33)
	if GameRules:IsRoundGoing() then
		ApplyDamage({victim = self:GetParent(), attacker = self:GetParent(), damage = self:GetParent():GetMaxHealth() * 0.05 * 0.33, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NON_LETHAL})
	end
end

function relic_cursed_hungry_blade:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function relic_cursed_hungry_blade:GetModifierPreAttack_BonusDamage()
	return 100
end

function relic_cursed_hungry_blade:GetModifierAttackSpeedBonus_Constant()
	return 100
end

function relic_cursed_hungry_blade:GetModifierMoveSpeedBonus_Percentage()
	return -15
end

function relic_cursed_hungry_blade:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:StartIntervalThink(6)
		self:SetDuration(6, true)
	end
end

function relic_cursed_hungry_blade:IsDebuff()
	return self:GetDuration() == 0
end