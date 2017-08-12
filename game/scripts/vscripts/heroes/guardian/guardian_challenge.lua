guardian_challenge = class({})

function guardian_challenge:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_Sven.StormBolt", target)
	ParticleManager:FireParticle("particles/heroes/guardian/guardian_challenge.vpcf", PATTACH_POINT_FOLLOW, target, {[2] = Vector(target:GetHullSize(),target:GetHullSize(),target:GetHullSize())})
	target:AddNewModifier(caster, self, "modifier_guardian_challenge_debuff", {duration = self:GetTalentSpecialValueFor("debuff_duration")})
end

modifier_guardian_challenge_debuff = class({})
LinkLuaModifier("modifier_guardian_challenge_debuff", "heroes/guardian/guardian_challenge.lua", 0)

function modifier_guardian_challenge_debuff:OnCreated()
	self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
	self.attackslow = self:GetAbility:GetTalentSpecialValueFor("attackspeed_slow")
	self.moveslow = self:GetAbility:GetTalentSpecialValueFor("movespeed_slow")
	if IsServer() then
		if self:GetCaster():HasTalent("guardian_challenge_talent_1") then self:StartIntervalThink(0.1) end
	end
end

function modifier_guardian_challenge_debuff:OnRefresh()
	self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
	self.attackslow = self:GetAbility:GetTalentSpecialValueFor("attackspeed_slow")
	self.moveslow = self:GetAbility:GetTalentSpecialValueFor("movespeed_slow")
end

function modifier_guardian_challenge_debuff:OnIntervalThink()
	local direction = (self:GetCaster():GetOrigin()-self:GetParent():GetOrigin()):Normalized()
	local distance = (self:GetCaster():GetOrigin()-self:GetParent():GetOrigin()):Length2D()
	if distance < 500 then
		ExecuteOrderFromTable({
			UnitIndex = self:GetParent():entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = (-direction)*distance
		})
	else
		self:GetParent():Stop()
		self:GetParent():Hold()
	end
end

function modifier_guardian_challenge_debuff:OnDestroy()
	self:GetAbility():EndDelayedCooldown()
end

function modifier_guardian_challenge_debuff:CheckState()
	if self:GetCaster():HasTalent("guardian_challenge_talent_1") then
		local state = { [MODIFIER_STATE_SILENCED] = true,
						[MODIFIER_STATE_DISARMED] = true}
		return state
	end
end

function modifier_guardian_challenge_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_guardian_challenge_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.attackslow
end

function modifier_guardian_challenge_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.moveslow
end

function modifier_guardian_challenge_debuff:GetEffectName()
	return ""
end

function modifier_guardian_challenge_debuff:GetTauntTarget()
	if self:GetCaster():HasTalent("guardian_challenge_talent_1") then
		return nil
	else
		return self:GetCaster()
	end
end