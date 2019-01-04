boss_apotheosis_decimate = class({})

function boss_apotheosis_decimate:OnSpellStart()
	local caster = self:GetCaster()
	
	self.nFX = ParticleManager:CreateParticle("particles/units/bosses/boss_apotheosis/boss_apotheosis_decimate_channel_dial.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( self.nFX, 1, caster:GetAbsOrigin() + Vector(0,0,125) )
	ParticleManager:SetParticleControl( self.nFX, 9, Vector(150,1,1) )
	ParticleManager:SetParticleControl( self.nFX, 11, Vector( self:GetChannelTime() + 0.1,0,10 ) )
	ParticleManager:FireWarningParticle( caster:GetAbsOrigin(), 600 )
	caster:EmitSound("Hero_Invoker.SunStrike.Charge")
end

function boss_apotheosis_decimate:OnChannelFinish(bInterrupt)
	local caster = self:GetCaster()
	if not bInterrupt then
		local casterPos = caster:GetAbsOrigin()
		
		local min_beams = self:GetSpecialValueFor("min_sunstrikes")
		local radius = self:GetSpecialValueFor("radius")
		local hero_beams = self:GetSpecialValueFor("sunstrikes_per_hero")
		Timers:CreateTimer(0.1, function()	
			self:CreateFlare( casterPos + ActualRandomVector(1200, 150), radius )
			min_beams = min_beams - 1
			if min_beams > 0 then
				return 0.1
			end
		end)
		
		for _, hero in ipairs( caster:FindEnemyUnitsInRadius( casterPos, -1, {type = DOTA_UNIT_TARGET_HERO} ) ) do
			local heroPos = hero:GetAbsOrigin()
			for i = 1, hero_beams do
				self:CreateFlare( heroPos + ActualRandomVector(radius * 1.5), radius )
			end
		end
	end
	caster:StopSound("Hero_Invoker.Cataclysm.Charge")
	ParticleManager:DestroyParticle( self.nFX, true )
	ParticleManager:ReleaseParticleIndex( self.nFX )
end

function boss_apotheosis_decimate:CreateFlare(position, radius)
	local caster = self:GetCaster()
	local casterPos = caster:GetAbsOrigin()
	local damage = self:GetSpecialValueFor("damage")
	local delay = self:GetSpecialValueFor("delay")
	ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_team.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
	Timers:CreateTimer(delay + RandomFloat( 0.1, 0.4 ), function()
		for _, hero in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			self:DealDamage( caster, hero, damage )
		end
		ParticleManager:FireParticle("particles/invoker_sun_strikev2.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
		EmitSoundOnLocationWithCaster( position, "Hero_Invoker.Cataclysm.Ignite", caster )
	end)
end