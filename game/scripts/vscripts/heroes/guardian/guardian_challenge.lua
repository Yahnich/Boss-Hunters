guardian_challenge = class({})

function guardian_challenge:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_Sven.StormBolt", target)
	ParticleManager:FireParticle("particles/heroes/guardian/guardian_challenge.vpcf", PATTACH_POINT_FOLLOW, target, {[2] = Vector(target:GetHullRadius(),target:GetHullRadius(),target:GetHullRadius())})
	target:AddNewModifier(caster, self, "modifier_guardian_challenge_debuff", {duration = self:GetTalentSpecialValueFor("debuff_duration")})
end

modifier_guardian_challenge_debuff = class({})
LinkLuaModifier("modifier_guardian_challenge_debuff", "heroes/guardian/guardian_challenge.lua", 0)

function modifier_guardian_challenge_debuff:OnCreated()
	self.attackslow = self:GetAbility():GetTalentSpecialValueFor("attackspeed_slow")
	self.moveslow = self:GetAbility():GetTalentSpecialValueFor("movespeed_slow")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), true)
		if self:GetCaster():HasTalent("guardian_challenge_talent_1") then self:StartIntervalThink(0.1) end
	end
end

function modifier_guardian_challenge_debuff:OnRefresh()
	self.attackslow = self:GetAbility():GetTalentSpecialValueFor("attackspeed_slow")
	self.moveslow = self:GetAbility():GetTalentSpecialValueFor("movespeed_slow")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), true)
	end
end

function modifier_guardian_challenge_debuff:OnIntervalThink()
	local direction = (self:GetCaster():GetOrigin()-self:GetParent():GetOrigin()):Normalized()
	local distance = (self:GetCaster():GetOrigin()-self:GetParent():GetOrigin()):Length2D()
	if distance < 500 then
		ExecuteOrderFromTable({
			UnitIndex = self:GetParent():entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = self:GetParent():GetOrigin() + (-direction)*150
		})
	else
		self:GetParent():Stop()
		self:GetParent():Hold()
	end
end

function modifier_guardian_challenge_debuff:OnDestroy()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
	end
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
	return "particles/heroes/guardian/guardian_challenge_debuff.vpcf"
end

function modifier_guardian_challenge_debuff:GetTauntTarget()
	if self:GetCaster():HasTalent("guardian_challenge_talent_1") then
		return nil
	else
		return self:GetCaster()
	end
end