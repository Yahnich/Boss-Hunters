function PerformAttacks(keys)
	local caster = keys.caster
	local target = keys.target
	
	caster:PerformAttack(target, true, true, true, false, false, false, true)
end

--[[Author: YOLOSPAGHETTI
	Date: February 4, 2016
	Riki backstabs the target]]
function ProcBackstab(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local cloak_and_dagger = caster:FindAbilityByName("cloak_and_dagger_ebf")
	if ability:IsStolen() then
		local riki = caster.target
		cloak_and_dagger = riki:FindAbilityByName("cloak_and_dagger_ebf")
	end
	local ability_level = cloak_and_dagger:GetLevel()

	local agility_damage_multiplier = cloak_and_dagger:GetTalentSpecialValueFor("agility_damage")
	if ability_level > 0 then
		-- Play the sound on the victim.
		EmitSoundOn(keys.sound, keys.target)
		-- Create the back particle effect.
		local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, target) 
		-- Set Control Point 1 for the backstab particle; this controls where it's positioned in the world. In this case, it should be positioned on the victim.
		ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
		-- Apply extra backstab damage based on Riki's agility
		 
		local armormult = (100 - target:GetMagicalArmorValue())/100
		if target:GetMagicalArmorValue() >= 100 then armormult = (100 - target:GetBaseMagicalResistanceValue())/100 end
		local damageType = DAMAGE_TYPE_PURE
		if target:GetMagicalArmorValue() == 0 then damageType = DAMAGE_TYPE_MAGICAL end
		print(caster:GetAgility() * agility_damage_multiplier * armormult)
		local backstabdmg = caster:GetAgility() * agility_damage_multiplier * armormult
		ApplyDamage({victim = target, attacker = caster, damage = backstabdmg/get_aether_multiplier(caster), damage_type = damageType, ability = keys.ability})
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 4, 2016
	Riki's model is hidden]]
function RemoveModel(keys)
	local caster = keys.caster
	
	caster:AddNoDraw()	
end

--[[Author: YOLOSPAGHETTI
	Date: February 4, 2016
	Riki's model is redrawn]]
function DrawModel(keys)
	local caster = keys.caster

	caster:RemoveNoDraw()
end

function CheckBackstab(params)
	local ability = params.ability
	local agility_damage_multiplier = ability:GetTalentSpecialValueFor("agility_damage")
	if params.attacker:HasModifier("modifier_banish") then agility_damage_multiplier = 0 end

	-- The y value of the angles vector contains the angle we actually want: where units are directionally facing in the world.
	local victim_angle = params.target:GetAnglesAsVector().y
	local origin_difference = params.target:GetAbsOrigin() - params.attacker:GetAbsOrigin()

	-- Get the radian of the origin difference between the attacker and Riki. We use this to figure out at what angle the victim is at relative to Riki.
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	
	-- Convert the radian to degrees.
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
	attacker_angle = attacker_angle + 180.0
	
	-- Finally, get the angle at which the victim is facing Riki.
	local result_angle = attacker_angle - victim_angle
	result_angle = math.abs(result_angle)
	local armormult = (100 - params.target:GetMagicalArmorValue())/100
	if armormult >= 100 then armormult = (100 -  params.target:GetBaseMagicalResistanceValue())/100 end
	local damageType = DAMAGE_TYPE_PURE
	if  params.target:GetMagicalArmorValue() == 0 then damageType = DAMAGE_TYPE_MAGICAL end
	-- Check for the backstab angle.
	if result_angle >= (180 - (ability:GetTalentSpecialValueFor("backstab_angle") / 2)) and result_angle <= (180 + (ability:GetTalentSpecialValueFor("backstab_angle") / 2)) then 
		-- Play the sound on the victim.
		EmitSoundOn(params.sound, params.target)
		-- Create the back particle effect.
		local particle = ParticleManager:CreateParticle(params.particle, PATTACH_ABSORIGIN_FOLLOW, params.target) 
		-- Set Control Point 1 for the backstab particle; this controls where it's positioned in the world. In this case, it should be positioned on the victim.
		ParticleManager:SetParticleControlEnt(particle, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true) 
		-- Apply extra backstab damage based on Riki's agility
		ApplyDamage({victim = params.target, attacker = params.attacker, damage = params.attacker:GetAgility() * agility_damage_multiplier * armormult, damage_type = damageType})
	else
		--EmitSoundOn(params.sound2, params.target)
		-- uncomment this if regular (non-backstab) attack has no sound
	end
end
