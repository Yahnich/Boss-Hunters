boss_evil_guardian_hell_on_earth = class({})

function boss_evil_guardian_hell_on_earth:GetIntrinsicModifierName()
	return "modifier_boss_evil_guardian_hell_on_earth_handler"
end

function boss_evil_guardian_hell_on_earth:CreateEvilPool(position, radius, damage, duration)
	local caster = self:GetCaster()
	local tPos = position
	local tRadius = radius
	local tDur = duration
	local tDmg = damage

	local pFX = ParticleManager:CreateParticle("particles/units/bosses/boss_evil_guardian/boss_evil_guardian_hell_on_earth.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pFX, 0, tPos )
	ParticleManager:SetParticleControl(pFX, 1, Vector(radius,1,1) )
	
	Timers:CreateTimer(function()
		if not caster or caster:IsNull() then ParticleManager:ClearParticle(pFX) end
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(tPos, tRadius) ) do
			self:DealDamage(caster, enemy, enemy:GetMaxHealth() * tDmg)
		end
		if tDur > 0 then
			tDur = tDur - 1
			return 1
		else
			ParticleManager:ClearParticle(pFX)
		end
	end)
end

modifier_boss_evil_guardian_hell_on_earth_handler = class({})
LinkLuaModifier("modifier_boss_evil_guardian_hell_on_earth_handler", "bosses/boss_evil_guardian/boss_evil_guardian_hell_on_earth", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_evil_guardian_hell_on_earth_handler:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
	self.delay = self:GetSpecialValueFor("pool_creation_delay")
	self.radius = self:GetSpecialValueFor("radius")
	self.damagePct = self:GetSpecialValueFor("hp_pct_damage") / 100
	if IsServer() then self:StartIntervalThink(self.delay) end
end

function modifier_boss_evil_guardian_hell_on_earth_handler:OnIntervalThink()
	local parent = self:GetParent()
	for _, enemy in ipairs( parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), -1, {type = DOTA_UNIT_TARGET_HERO, flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})) do
		local position = enemy:GetAbsOrigin()
		ParticleManager:FireWarningParticle(position, self.radius)
		Timers:CreateTimer(1, function() self:GetAbility():CreateEvilPool(position, self.radius, self.damagePct, self.duration) end)
	end
end

function modifier_boss_evil_guardian_hell_on_earth_handler:IsHidden()
	return true
end