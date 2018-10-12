boss_broodmother_infest = class({})

function boss_broodmother_infest:OnAbilityPhaseStart()
	ParticleManager:FireLinearWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetCaster():GetAbsOrigin() + CalculateDirection( self:GetCursorPosition(), self:GetCaster():GetAbsOrigin() ) * self:GetTrueCastRange(), self:GetSpecialValueFor("width"))
	return true
end

function boss_broodmother_infest:OnSpellStart()
	local caster = self:GetCaster()
	
	local vDir = CalculateDirection(self:GetCursorPosition(), caster)
	local distance = self:GetSpecialValueFor("distance")
	local speed = self:GetSpecialValueFor("speed")
	local width = self:GetSpecialValueFor("width")
	local endPos = caster:GetAbsOrigin() + vDir * distance
	
	local projFX = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_web_cast.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( projFX, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( projFX, 1, endPos )
	ParticleManager:SetParticleControl( projFX, 2, Vector(speed, 0, 0) )
	
	local position = caster:GetAbsOrigin()
	local distTraveled = 0
	local speedTick = speed * FrameTime()
	
	EmitSoundOn("Hero_Broodmother.SpawnSpiderlingsCast", caster)
	
	Timers:CreateTimer(FrameTime(), function()
		distTraveled = distTraveled + speedTick
		position = position + vDir * speedTick
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(position, width) ) do
			if enemy:TriggerSpellAbsorb(self) then return end
			self:OnInfestHit(enemy)
			ParticleManager:ClearParticle(projFX)
			return nil
		end
		if distTraveled < distance then
			return FrameTime()
		else
			self:OnInfestMiss(position)
			ParticleManager:ClearParticle(projFX)
			return nil
		end
	end)
end

function boss_broodmother_infest:OnInfestHit(target)
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage_on_hit")
	local spidersHit = self:GetSpecialValueFor("spiders_on_hit")
	self:SpawnSpiderlings( spidersHit, target:GetAbsOrigin() )
	self:DealDamage( caster, target, damage )
	EmitSoundOn("Hero_Broodmother.SpawnSpiderlingsImpact", target)
end

function boss_broodmother_infest:OnInfestMiss(position)
	local spidersMiss = self:GetSpecialValueFor("spiders_on_miss")
	self:SpawnSpiderlings( spidersMiss, position )
end

function boss_broodmother_infest:SpawnSpiderlings(amount, position)
	if amount > 0 then
		for i = 1, amount do
			local spiderling = CreateUnitByName("npc_dota_creature_spiderling", position + RandomVector(150), true, self, nil, self:GetCaster():GetTeam())
		end
	end
end