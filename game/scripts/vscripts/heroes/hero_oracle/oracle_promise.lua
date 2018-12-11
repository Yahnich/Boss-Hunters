oracle_promise = class({})
LinkLuaModifier("modifier_oracle_promise", "heroes/hero_oracle/oracle_promise", LUA_MODIFIER_MOTION_NONE)

function oracle_promise:IsStealable()
    return true
end

function oracle_promise:IsHiddenWhenStolen()
    return false
end

function oracle_promise:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetTalentSpecialValueFor("duration")
	
	EmitSoundOn("Hero_Oracle.FalsePromise.Cast", caster)
	EmitSoundOn("Hero_Oracle.FalsePromise.Target", target)
	EmitSoundOn("Hero_Oracle.FalsePromise.FP", target)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_cast.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_ABSORIGIN, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 2, caster, PATTACH_ABSORIGIN, "attach_attack1", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)

	target:AddNewModifier(caster, self, "modifier_oracle_promise", {Duration = self:GetTalentSpecialValueFor("duration")})
	if target:GetTeam() == caster:GetTeam() then
		target:Purge(false, true, false, true, false)
	else
		target:Purge(true, false, false, true, false)
	end

	self:StartDelayedCooldown(duration)
end

modifier_oracle_promise = class({})
function modifier_oracle_promise:OnCreated(table)
	self.invs = 0 
	self.state = {}

	if self:GetCaster():HasTalent("special_bonus_unique_oracle_promise_1") then
		self.invs = 1
		self.state = {[MODIFIER_STATE_INVISIBLE] = true}
		self:GetParent():Stop()
		self:GetParent():SetThreat(0)
	end

	if IsServer() then
		self.damage = 0
		self.heal = 0

		local caster = self:GetCaster()
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
	end
end

function modifier_oracle_promise:OnRefresh(table)
	self.invs = 0 
	self.state = {}

	if self:GetCaster():HasTalent("special_bonus_unique_oracle_promise_1") then
		self.invs = 1
		self.state = {[MODIFIER_STATE_INVISIBLE] = true}
		self:GetParent():Stop()
		self:GetParent():SetThreat(0)
	end

	if IsServer() then
		self.damage = 0
		self.heal = 0
	end
end

function modifier_oracle_promise:DeclareFunctions()
	local funcs = { MODIFIER_EVENT_ON_TAKEDAMAGE,
					MODIFIER_EVENT_ON_HEAL_RECEIVED,
					MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
					MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
					MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
					MODIFIER_PROPERTY_DISABLE_HEALING,
					MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
	return funcs
end

function modifier_oracle_promise:CheckState()
	return self.state
end

function modifier_oracle_promise:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_oracle_promise:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_oracle_promise:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_oracle_promise:GetAbsoluteNoDamagePure()
	return 1
end

function modifier_oracle_promise:OnTakeDamage(params)
	if IsServer() then
		local parent = self:GetParent()
		local unit = params.unit

		if unit == parent then
			self.damage = self.damage + params.damage
			self.heal = self.heal - params.damage
		end
	end
end

function modifier_oracle_promise:OnHealReceived(params)
	if IsServer() then
		local parent = self:GetParent()
		local unit = params.unit

		if unit == parent then
			self.heal = self.heal + params.gain
		end
	end
end

function modifier_oracle_promise:GetDisableHealing()
	return 1
end

function modifier_oracle_promise:GetModifierInvisibilityLevel()
    return self.invs
end

function modifier_oracle_promise:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		if self.heal >= self.damage then
			EmitSoundOn("Hero_Oracle.FalsePromise.Healed", parent)

			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_heal.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_ABSORIGIN, "attach_hitloc", parent:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(nfx)

			parent:HealEvent(self.heal, self:GetAbility(), caster, false)
		else
			EmitSoundOn("Hero_Oracle.FalsePromise.Damaged", parent)
			
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_false_promise_dmg.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_ABSORIGIN, "attach_hitloc", parent:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(nfx)

			self:GetAbility():DealDamage(caster, parent, self.damage, {damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS}, OVERHEAD_ALERT_DAMAGE)
		end

		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_oracle_promise:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_false_promise_indicator.vpcf"
end

function modifier_oracle_promise:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_oracle_promise:IsDebuff()
	return false
end

function modifier_oracle_promise:IsPurgable()
	return false
end

function modifier_oracle_promise:IsPurgeException()
	return false
end

function modifier_oracle_promise:GetEffectName()
    return "particles/generic_hero_status/status_invisibility_start.vpcf"
end