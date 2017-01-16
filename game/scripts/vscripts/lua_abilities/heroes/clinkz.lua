function StrafeAttack(keys)
	local caster = keys.caster
	local radius = caster:GetAttackRange()+caster:GetAttackRangeBuffer()
	local counter = 1
	if caster:HasScepter() then
		counter = keys.ability:GetTalentSpecialValueFor("targets_scepter")
	end
	local units = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
	for _, unit in pairs( units ) do
		caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 3)
		if counter > 0 then
			caster:PerformAttack(unit, true, true, true, false, true)
			counter = counter - 1
		end
	end
end

function Blink(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local ability = keys.ability
	local range = keys.range + get_aether_range(caster)

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)
	
	local blinkIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_windwalk.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(blinkIndex, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(blinkIndex, 1, caster:GetAbsOrigin())
	Timers:CreateTimer( 0.5, function()
		ParticleManager:DestroyParticle( blinkIndex, false )
		return nil
		end
	)
end

function ParticleControl(keys)
	local caster = keys.caster
	local blinkIndex = ParticleManager:CreateParticle("particles/clinkz_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(blinkIndex, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(blinkIndex, 3, caster:GetAbsOrigin())
		Timers:CreateTimer(0.1, function()
			ParticleManager:DestroyParticle( blinkIndex, false )
			return nil
			end
		)
end

function DeathPact( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local duration = ability:GetTalentSpecialValueFor( "duration")
	local target_health = target:GetHealth()
	
	
	-- Health Gain
	local health_gain_pct = ability:GetTalentSpecialValueFor( "hp_percent") * 0.01
	local max_hp = ability:GetTalentSpecialValueFor("max_hp") / 100 * caster:GetMaxHealth()
	local health_gain = math.floor(target_health * health_gain_pct)
	if health_gain > max_hp then health_gain = max_hp end

	local health_modifier = "modifier_death_pact_health"
	caster:RemoveModifierByName(health_modifier)
	ability:ApplyDataDrivenModifier(caster, caster, health_modifier, { duration = duration })
	caster:SetModifierStackCount( health_modifier, ability, health_gain )

	-- Damage Gain
	local damage_gain_pct = ability:GetTalentSpecialValueFor( "damage_percent") * 0.01
	local max_dmg = ability:GetTalentSpecialValueFor("max_dmg") / 100 * caster:GetAverageBaseDamage()
	local damage_gain = math.floor(target_health * damage_gain_pct)
	if damage_gain > max_dmg then damage_gain = max_dmg end

	local damage_modifier = "modifier_death_pact_damage"
	caster:RemoveModifierByName(damage_modifier)
	ability:ApplyDataDrivenModifier(caster, caster, damage_modifier, { duration = duration })
	caster:SetModifierStackCount( damage_modifier, ability, damage_gain )
	local damageTable = {victim = target, attacker = caster, damage = health_gain/get_aether_multiplier(caster), damage_type = DAMAGE_TYPE_PURE, ability = ability}

	ApplyDamage(damageTable)
	caster:Heal( health_gain, caster)
	caster.death_pact_health = health_gain
end

-- Keeps track of the casters health
function DeathPactHealth( event )
	local caster = event.caster
	caster.OldHealth = caster:GetHealth()
end

-- Sets the current health to the old health
function SetCurrentHealth( event )
    local caster = event.caster
    if caster:IsAlive() then
        caster:SetHealth(caster.OldHealth)
    end
end