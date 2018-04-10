function SlarkFunction(keys)
    local modifierName_caster = "steal_c"
    local modifierName_target = "steal_t"
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local level = ability:GetLevel()-1
    local cool_duration = ability:GetTalentSpecialValueFor("cooldown_duration")
	if caster:HasScepter() then
		cool_duration = 0
	end
    local duration = ability:GetTalentSpecialValueFor("duration")
    if caster:IsIllusion() == false and ability:IsCooldownReady() then
        if target:HasModifier( modifierName_target ) then
            local current_stack = target:GetModifierStackCount( modifierName_target, ability )
            ability:ApplyDataDrivenModifier( caster, target, modifierName_target, {duration = duration} )
            target:SetModifierStackCount( modifierName_target, ability, current_stack + 1 )
        else
            ability:ApplyDataDrivenModifier( caster, target, modifierName_target, {duration = duration})
            target:SetModifierStackCount( modifierName_target, ability, 1)
        end
        if caster:HasModifier( modifierName_caster ) then
            local current_stack = caster:GetModifierStackCount( modifierName_caster, ability )
            ability:ApplyDataDrivenModifier( caster, caster, modifierName_caster, {duration = duration} )
            caster:SetModifierStackCount( modifierName_caster, ability, current_stack + 1 )
        else
            ability:ApplyDataDrivenModifier( caster, caster, modifierName_caster, {duration = duration})
            caster:SetModifierStackCount( modifierName_caster, ability, 1)
        end
        ability:StartCooldown(cool_duration)
		Timers:CreateTimer(duration, function() 
			caster:SetModifierStackCount( modifierName_caster, ability, caster:GetModifierStackCount( modifierName_caster, ability ) - 1 ) 
			if target and not target:IsNull() then target:SetModifierStackCount( modifierName_target, ability, target:GetModifierStackCount( modifierName_target, ability ) - 1 ) end
		end)
    end
end

function PounceHealth( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability.caster_hp_old = ability.caster_hp_old or caster:GetMaxHealth()
	ability.caster_hp = ability.caster_hp or caster:GetMaxHealth()

	ability.caster_hp_old = ability.caster_hp
	ability.caster_hp = caster:GetHealth()
end

--[[Author: Pizzalol
	Date: 14.02.2016.
	Negates incoming damage]]
function PounceHeal( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()-1
	if ability:IsCooldownReady() and not caster:HasModifier(keys.modifier) and keys.attacker ~= caster then
		caster:StartGesture(ACT_DOTA_SLARK_POUNCE)
		local hpDiff = math.abs(caster:GetHealth() - ability.caster_hp_old)
		caster:SetHealth(ability.caster_hp_old)
		caster:HealEvent(hpDiff, ability, caster)
		ability:StartCooldown( ability:GetCooldown(ability_level)*get_octarine_multiplier(caster) )

		-- Ability variables
		if not ability:GetAutoCastState() or keys.damage > ability.caster_hp_old then
			caster:Stop()
			ProjectileManager:ProjectileDodge(caster)
			ability.leap_direction = keys.attacker:GetForwardVector()
			ability.leap_distance = keys.distance
			ability.leap_speed = ability:GetTalentSpecialValueFor("pounce_speed") / 30
			ability.leap_traveled = 0
			ability.leap_z = 0
			local duration = ability.leap_distance/(ability.leap_speed*30)
			ability:ApplyDataDrivenModifier( caster, caster, keys.modifier, {duration = duration} )
			
			particle_ground = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_splash.vpcf", PATTACH_ABSORIGIN  , keys.caster)
			ParticleManager:SetParticleControl(particle_ground, 0, caster:GetAbsOrigin()) --ammount of particle
			ParticleManager:SetParticleControl(particle_ground, 3, caster:GetAbsOrigin()) 
			particle_ground2 = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_start.vpcf", PATTACH_ABSORIGIN  , keys.caster)
			ParticleManager:SetParticleControl(particle_ground2, 0, caster:GetAbsOrigin()) --ammount of particle
			particle_trail = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW  , keys.caster)
			ParticleManager:SetParticleControl(particle_trail, 0, caster:GetAbsOrigin()) --ammount of particle
			ParticleManager:SetParticleControl(particle_trail, 1, Vector(1,0,0)) 
		end
	end 
end

function Pounce( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()-1
	if not caster:HasModifier(keys.modifier) then
		caster:StartGesture(ACT_DOTA_SLARK_POUNCE)
		caster:Stop()
		ProjectileManager:ProjectileDodge(caster)
		ability.leap_direction = caster:GetForwardVector()
		ability.leap_distance = keys.distance
		ability.leap_speed = ability:GetTalentSpecialValueFor("pounce_speed") / 30
		ability.leap_traveled = 0
		ability.leap_z = 0
		local duration = ability.leap_distance/(ability.leap_speed*30)
		ability:ApplyDataDrivenModifier( caster, caster, keys.modifier, {duration = duration} )
		
		particle_ground = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_splash.vpcf", PATTACH_ABSORIGIN  , keys.caster)
		ParticleManager:SetParticleControl(particle_ground, 0, caster:GetAbsOrigin()) --ammount of particle
		ParticleManager:SetParticleControl(particle_ground, 3, caster:GetAbsOrigin()) 
		particle_ground2 = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_start.vpcf", PATTACH_ABSORIGIN  , keys.caster)
		ParticleManager:SetParticleControl(particle_ground2, 0, caster:GetAbsOrigin()) --ammount of particle
		particle_trail = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_pounce_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW  , keys.caster)
		ParticleManager:SetParticleControl(particle_trail, 0, caster:GetAbsOrigin()) --ammount of particle
		ParticleManager:SetParticleControl(particle_trail, 1, Vector(1,0,0)) 
		
	end 
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function PounceHorizontal( keys )
	local caster = keys.target
	local ability = keys.ability
	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		caster:InterruptMotionControllers(true)
	end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function PounceVertical( keys )
	local caster = keys.target
	local ability = keys.ability
		if ability.leap_traveled < ability.leap_distance/2 then
		-- Go up
		-- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
		ability.leap_z = ability.leap_z + 2*ability.leap_speed/math.log(ability.leap_distance/2 - ability.leap_traveled)
		-- Set the new location to the current ground location + the memorized z point
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	else
		-- Go down
		ability.leap_z = ability.leap_z - 2*ability.leap_speed/math.log(ability.leap_distance - (ability.leap_traveled-ability.leap_distance/2))
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	end
	
end