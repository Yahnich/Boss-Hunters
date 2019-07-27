boss_slardar_splash_zone = class({})

function boss_slardar_splash_zone:GetCastRange( target, position )
	return self:GetSpecialValueFor("radius")
end

function boss_slardar_splash_zone:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCaster():GetAbsOrigin(), self:GetTrueCastRange() )
	return true
end

function boss_slardar_splash_zone:OnSpellStart(bForced)
	local caster = self:GetCaster()
	local position = caster:GetAbsOrigin()
	local radius = self:GetSpecialValueFor("radius")
	local poolRadius = self:GetSpecialValueFor("pool_radius")
	
	local damage1 = self:GetSpecialValueFor("initial_damage")
	local stun1 = self:GetSpecialValueFor("initial_stun")
	local damage2 = self:GetSpecialValueFor("second_damage")
	local stun2 = self:GetSpecialValueFor("second_stun")
	
	local delay = self:GetSpecialValueFor("delay")
	local knockup = self:GetSpecialValueFor("knockup")
	local poolDur = self:GetSpecialValueFor("pool_duration")
	local stun2 = self:GetSpecialValueFor("second_stun")
	
	
	caster:EmitSound("Hero_Slardar.Slithereen_Crush")
	ParticleManager:FireParticle("particles/units/heroes/hero_slardar/slardar_crush.vpcf", PATTACH_ABSORIGIN, caster, {[0] = position, [1] = Vector(radius, radius, radius)} )
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		self:DealDamage( caster, enemy, damage2 )
		self:Stun(enemy, stun1)
	end
	
	EmitSoundOnLocationWithCaster(position, "Ability.pre.Torrent", caster)

    local pFX = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", PATTACH_WORLDORIGIN, nil)
                    ParticleManager:SetParticleControl(pFX, 0, position)
	
    Timers:CreateTimer(self:GetTalentSpecialValueFor("delay"), function()
		ParticleManager:ClearParticle(pFX)
        StopSoundOn("Ability.pre.Torrent", caster)
        EmitSoundOnLocationWithCaster(position, "Ability.Torrent", caster)
        ParticleManager:FireParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_WORLDORIGIN, nil, {[0]=position})
		for i = 0, 4 do
			local newPos = position + RotateVector2D(caster:GetForwardVector(), ToRadians(72 * i) ) * 225
			ParticleManager:FireParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_WORLDORIGIN, nil, {[0]=newPos})
		end
        local enemies = caster:FindEnemyUnitsInRadius(position, radius)
        for _,enemy in ipairs(enemies) do
            enemy:ApplyKnockBack(enemy:GetAbsOrigin(), stun2, stun2, 0, knockup, caster, self)
            self:DealDamage(caster, enemy, damage2, {damage_type = DAMAGE_TYPE_MAGICAL})
        end
    end)
	local pool = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_water_puddle.vpcf", PATTACH_WORLDORIGIN, nil)
                    ParticleManager:SetParticleControl(pool, 0, position)
                    ParticleManager:SetParticleControl(pool, 1, Vector(poolRadius,1,1) )
	Timers:CreateTimer(0.25, function()
		poolDur = poolDur - 0.25
		for _,ally in ipairs( caster:FindAllUnitsInRadius(position, poolRadius) ) do
            local modifier = ally:AddNewModifier( caster, self, "modifier_in_water", {duration = 0.5} )
        end
		if poolDur > 0 then
			return 0.25
		else
			ParticleManager:ClearParticle(pool)
			caster.submergeLoc = nil
		end
	end)
	caster.submergeLoc = position
end