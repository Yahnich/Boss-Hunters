boss_evil_guardian_end_of_days = class({})

function boss_evil_guardian_end_of_days:OnAbilityPhaseStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_status_immunity", {duration = self:GetCastPoint() - 0.01})
	ParticleManager:FireWarningParticle(self:GetCaster():GetAbsOrigin(), 1200)
	return true
end

function boss_evil_guardian_end_of_days:OnSpellStart()
	local caster = self:GetCaster()

	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1, {type = DOTA_UNIT_TARGET_HERO} ) ) do
		self:CreateTrap(enemy:GetAbsOrigin())
	end
end

function boss_evil_guardian_end_of_days:CreateTrap(position)
	local razeFX = ParticleManager:CreateParticle("particles/doom_ring_D.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( razeFX, 0, position )
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("stun_duration")
	local radius = self:GetSpecialValueFor("raze_radius")
	local delay = self:GetSpecialValueFor("raze_delay")
	Timers:CreateTimer(delay, function()
		ParticleManager:ClearParticle( razeFX )
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			enemy:AddNewModifier(caster, self, "modifier_boss_evil_guardian_end_of_days_stun", {duration = duration})
		end
	end)
end

modifier_boss_evil_guardian_end_of_days_stun = class({})
LinkLuaModifier("modifier_boss_evil_guardian_end_of_days_stun", "bosses/boss_evil_guardian/boss_evil_guardian_end_of_days", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_evil_guardian_end_of_days_stun:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom_ring.vpcf"
end

function modifier_boss_evil_guardian_end_of_days_stun:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_boss_evil_guardian_end_of_days_stun:IsPurgable()
	return true
end

function modifier_boss_evil_guardian_end_of_days_stun:IsStunDebuff()
	return true
end

function modifier_boss_evil_guardian_end_of_days_stun:IsPurgeException()
	return true
end