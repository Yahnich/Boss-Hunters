modifier_attack_animation_tweak = class({})

function modifier_attack_animation_tweak:OnAttackStart(params)
	if IsServer() and params.attacker == self:GetParent() then
		self:GetParent():RemoveGesture(ACT_DOTA_ATTACK)
		self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, (1 + self:GetParent():GetIncreasedAttackSpeed()) )
	end
end

function modifier_attack_animation_tweak:IsHidden()
	return true
end

function modifier_attack_animation_tweak:RemoveOnDeath()
	return false
end

function modifier_attack_animation_tweak:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,
	}

	return funcs
end