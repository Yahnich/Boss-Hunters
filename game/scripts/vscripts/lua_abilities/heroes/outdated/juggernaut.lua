
function InitializeRonin(keys)
	local caster = keys.caster
	caster.critmult = keys.ability:GetTalentSpecialValueFor( "critical_bonus")
	caster.critchance = keys.ability:GetTalentSpecialValueFor( "critical_chance")
end

function QuickParry(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.attacker
	if not ability:IsCooldownReady() then return end
	ability:StartCooldown(ability:GetCooldown(-1))
	caster:SetHealth(caster:GetHealth() + keys.damage)
	if ability:IsStolen() then
		local juggernaut = caster.target
		caster.critchance = juggernaut.critchance
		caster.critmult = juggernaut.critmult
	end
	if not caster.critchance then caster.critchance = 0 end
	local critmult = 1
	if RollPercentage(caster.critchance) then
		critmult = caster.critmult/100
		particle_slash = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_ABSORIGIN  , target)
	end
	local damage = ability:GetAbilityDamage()
	local damageTable = {victim = target,
                        attacker = caster,
                        damage = damage*critmult,
                        ability = keys.ability,
                        damage_type = DAMAGE_TYPE_PURE,
                        }
    ApplyDamage(damageTable)
end
	
function BladeDance( keys )
	local caster = keys.caster
	local target = keys.target

	-- Ability variables
	local victim_angle = target:GetAnglesAsVector()
	local victim_forward_vector = target:GetForwardVector()
	
	-- Angle and positioning variables
	local victim_angle_rad = (victim_angle.y)*math.pi/180
	local victim_position = target:GetAbsOrigin()
	local original_position = caster:GetAbsOrigin()
	local dir = victim_position - original_position
	local attacker_new = Vector(victim_position.x + dir.x+math.random(-50,50), victim_position.y + dir.y+math.random(-50,50), 0)
	

		
	-- Set Juggernaut at random position
	caster:SetAbsOrigin(attacker_new)
	FindClearSpaceForUnit(caster, attacker_new, true)
	local find_victim = target:GetAbsOrigin() - caster:GetAbsOrigin()
	caster:SetForwardVector(-dir)
	-- Attack order
	order = 
	{
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = ability,
		Queue = true
	}

	particle_slash = ParticleManager:CreateParticle("particles/econ/items/juggernaut/bladekeeper_omnislash/dc_juggernaut_omni_slash_rope.vpcf", PATTACH_ABSORIGIN  , keys.caster)
    ParticleManager:SetParticleControl(particle_slash, 0, original_position)
    ParticleManager:SetParticleControl(particle_slash, 2, original_position) --radius
    ParticleManager:SetParticleControl(particle_slash, 3, attacker_new) --ammount of particle
    Timers:CreateTimer(0.3,function()
        ParticleManager:DestroyParticle(particle_slash,true)
    end)
		
	ExecuteOrderFromTable(order)
end


function RoninSlice( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local modifier = keys.modifier
	-- Distance calculations
	local speed = ability:GetTalentSpecialValueFor("speed")
	local distance = (target_point - caster_location):Length2D()
	local direction = (target_point - caster_location):Normalized()
	local duration = distance/speed

	-- Saving the data in the ability
	ability.distance = distance
	ability.speed = speed * 1/30 -- 1/30 is how often the motion controller ticks
	ability.direction = direction
	ability.traveled_distance = 0

	-- Apply the invlunerability modifier to the caster
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
end

function RoninSliceDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetTalentSpecialValueFor("damage") + caster:GetAverageTrueAttackDamage(caster)
	local critmult = 1
	particle_slash = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN  , target)
	local critcheck = math.random(100)
	if ability:IsStolen() then
		local juggernaut = caster.target
		caster.critchance = juggernaut.critchance
		caster.critmult = juggernaut.critmult
	end
	if not caster.critchance then caster.critchance = 0 end
	if critcheck < caster.critchance then
		critmult = caster.critmult/100
		particle_slash = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_ABSORIGIN  , target)
	end
	local damageTable = {victim = target,
                        attacker = caster,
                        damage = damage*critmult,
                        ability = keys.ability,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        }
    ApplyDamage(damageTable)
	-- Apply the invlunerability modifier to the caster
end

function JuggernautMotion( keys )
	local caster = keys.target
	local ability = keys.ability
	-- Move the caster while the distance traveled is less than the original distance upon cast
	local original_position = caster:GetAbsOrigin()
	if ability.traveled_distance < ability.distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.direction * ability.speed)
		local new_position = caster:GetAbsOrigin()
		ability.traveled_distance = ability.traveled_distance + ability.speed
		particle_slash = ParticleManager:CreateParticle("particles/econ/items/juggernaut/bladekeeper_omnislash/dc_juggernaut_omni_slash_rope.vpcf", PATTACH_ABSORIGIN  , keys.caster)
		ParticleManager:SetParticleControl(particle_slash, 0, original_position)
		ParticleManager:SetParticleControl(particle_slash, 2, original_position) --radius
		ParticleManager:SetParticleControl(particle_slash, 3, new_position)
	else
		-- Remove the motion controller once the distance has been traveled
		caster:InterruptMotionControllers(false)
		ParticleManager:DestroyParticle(particle_slash,true)
		local duration = ability:GetTalentSpecialValueFor("duration")
		local modifier = "modifier_ronin_strength"
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
		caster:RemoveModifierByName("modifier_ronin_slice_move")
	end
end