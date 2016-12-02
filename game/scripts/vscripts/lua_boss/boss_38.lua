LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )

function CalculateDamage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage_taken = keys.DamageTaken
	local backtrack_time = keys.BacktrackTime
	local remember_interval = keys.Interval
	if not caster:IsAlive() then return end
	if not caster.index then caster.index = 0 end
	-- Temporary damage array and index
	if not ability.tempList then  ability.tempList = {} end
	if not ability.tempList[caster:GetUnitName()] then ability.tempList[caster:GetUnitName()] = {} end
	local casterTable = {}
	casterTable["health"] = caster:GetHealth()
	casterTable["mana"] = caster:GetMana()
	casterTable["position"] = caster:GetAbsOrigin()
	table.insert(ability.tempList[caster:GetUnitName()],casterTable)
	enemies = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  9999,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_HERO,
                                  DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                  FIND_ANY_ORDER,
                                  false)
	for _,enemy in pairs(enemies) do
		if not ability.tempList[enemy:GetName()] then ability.tempList[enemy:GetName()] = {} end
		local enemyTable = {}
		enemyTable["health"] = enemy:GetHealth()
		enemyTable["mana"] = enemy:GetMana()
		enemyTable["position"] = enemy:GetAbsOrigin()
		table.insert(ability.tempList[enemy:GetName()],enemyTable)
	end
	
	local maxindex = backtrack_time/remember_interval
	if #ability.tempList[caster:GetUnitName()] > maxindex then
		table.remove(ability.tempList[caster:GetUnitName()],1)
		for _,enemy in pairs(enemies) do
			table.remove(ability.tempList[enemy:GetName()],1)
		end
	end
end

function RemoveDamage ( keys )
	local target = keys.target
	local ability = keys.ability
	
	local health = ability.tempList[target:GetUnitName()][1]["health"]
	local mana = ability.tempList[target:GetUnitName()][1]["mana"]
	local position = ability.tempList[target:GetUnitName()][1]["position"]

	target:Interrupt()
	
	-- Adds damage to caster's current health
	particle_ground = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_timelapse.vpcf", PATTACH_ABSORIGIN  , target)
    ParticleManager:SetParticleControl(particle_ground, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_ground, 1, position) --radius
    ParticleManager:SetParticleControl(particle_ground, 2, position) --ammount of particle
	
	target:SetHealth(health)
	target:SetMana(mana)
	ProjectileManager:ProjectileDodge(target)
	FindClearSpaceForUnit(target, position, true)
end

function Reflection( event )
	----- Conjure Image  of the target -----
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local unit_name = target:GetUnitName()
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", -1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", -1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", -1 )

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	illusion:SetPhysicalArmorBaseValue(target:GetAgility()*0.08 + target:GetPhysicalArmorBaseValue())
	-- Level Up the unit to the targets level
	local targetLevel = target:GetLevel()
	for i=1,targetLevel-1 do
		illusion:HeroLevelUp(false)
	end

	-- Set the skill points to 0 and learn the skills of the target
	illusion:SetAbilityPoints(0)

	-- Recreate the items of the target
	for itemSlot=0,5 do
		local item = target:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(caster, ability, "modifier_terrorblade_conjureimage", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

	-- Apply Invulnerability modifier
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_reflection_invulnerability", nil)
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_reflection_nodamage", nil)

	-- Force Illusion to attack Target
	illusion:SetForceAttackTarget(target)

	-- Emit the sound, so the destroy sound is played after it dies
	illusion:EmitSound("Hero_Terrorblade.Reflection")
	
	Timers:CreateTimer(0.5, function()
        illusion:RemoveModifierByName("modifier_reflection_nodamage")
		illusion:SetMaxHealth(target:GetMaxHealth())
		illusion:SetHealth(target:GetMaxHealth())
    end)
	
	Timers:CreateTimer(duration-0.1, function()
        if illusion:IsAlive() then
			target:ForceKill(true)
			illusion:ForceKill(true)
			UTIL_Remove( illusion )
		end
		
    end)
	
	local messageinfo = {
    message = "Kill the illusion or your ally will die!",
    duration = 2
    }
    FireGameEvent("show_center_message",messageinfo)
	
end

function ReflectionCast( event )

	local caster = event.caster
	local target = event.target
	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_reflection_cast.vpcf"

	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControl(particle, 3, Vector(1,0,0))
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end



function Chronosphere( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	caster.chronoactive = true
	-- Special Variables
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
	ability.maxradius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", (ability:GetLevel() - 1))
	ability.speed = ability.maxradius*0.1/duration
	ability.radius = 0
	ability.position = caster:GetOrigin()
	

	-- Dummy
	local dummy_modifier = keys.dummy_aura
	local dummy = CreateUnitByName("npc_dummy_blank", ability.position, false, caster, caster, caster:GetTeam())
	dummy:AddNewModifier(caster, nil, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {duration = duration})
	
	ability.dummy = dummy
	
	-- Vision
	AddFOWViewer(caster:GetTeamNumber(),  ability.position, vision_radius, duration, false)
	
	ability.chrono = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_ABSORIGIN  , dummy)
    ParticleManager:SetParticleControl(ability.chrono, 0, ability.position)
    ParticleManager:SetParticleControl(ability.chrono, 1, Vector(ability.radius,ability.radius,ability.radius)) --radius
	ParticleManager:SetParticleControl(ability.chrono, 6, ability.position)
	ParticleManager:SetParticleControl(ability.chrono, 10, ability.position)

	-- Timer to remove the dummy
	Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle(ability.chrono, false)
		ParticleManager:ReleaseParticleIndex(ability.chrono)
		dummy:ForceKill(true)
		UTIL_Remove(dummy)
		ability.radius = Vector(0,0,0)
		ability.speed = 0
		caster.chronoactive = false
		 
	end)
end

function ChronosphereAura( keys )
	local caster = keys.caster
	local ability = keys.ability
	if not ability then return end
	local ability_level = ability:GetLevel() - 1
	-- Ability variables
	local aura_modifier = keys.aura_modifier
	local ignore_void = ability:GetLevelSpecialValueFor("ignore_void", ability_level)
	local voiddamage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local duration = ability:GetLevelSpecialValueFor("aura_interval", ability_level)
	if ability.radius < ability.maxradius then ability.radius = ability.radius + ability.speed end
	
    ParticleManager:SetParticleControl(ability.chrono, 1, Vector(ability.radius,ability.radius,ability.radius)) --radius

	
	local units = FindUnitsInRadius(caster:GetTeam(),
                                  ability.position,
                                  nil,
                                  ability.radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_HERO,
                                  DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                  FIND_ANY_ORDER,
                                  false)
	for _,unit in pairs(units) do
		unit:InterruptMotionControllers(false)
		ability:ApplyDataDrivenModifier(caster, unit, aura_modifier, {duration = duration})
		local newhp = unit:GetHealth()*0.98
		unit:SetHealth(newhp)
		ApplyDamage({victim = unit, attacker = caster, damage = voiddamage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
		
	end
	if (caster:GetAbsOrigin() - ability.position):Length2D() <= ability.radius then
		caster:AddNewModifier(caster, ability, "modifier_faceless_void_chronosphere_speed", {duration = duration})
	else
		caster:RemoveModifierByName("modifier_faceless_void_chronosphere_speed")
	end
end

function ChronoMessage( keys )
	local caster = keys.caster
	local messageinfo = {
    message = "The Boss is casting Overtime, run away!",
    duration = 2
    }
	FireGameEvent("show_center_message",messageinfo)
end

function Yesteryear( keys )
	print("startrefresh")
	local caster = keys.caster
	for i = 0, caster:GetAbilityCount() - 1 do
        local ability = caster:GetAbilityByIndex( i )
        if ability and ability ~= keys.ability then
            ability:EndCooldown()
        end
    end
	local heal = (caster:GetMaxHealth() - caster:GetHealth())/2
	caster:Heal(heal, caster)
	caster:SetMana(caster:GetMaxMana())
end

function YesteryearMessage( keys )
	local caster = keys.caster
	local messageinfo = {
    message = "The Boss is channeling Yesteryear! Stop him!",
    duration = 2
    }
	Timers:CreateTimer(2.0, function()
        caster.trigger = false
    end)
	if not caster.trigger then
		FireGameEvent("show_center_message",messageinfo)
		caster.trigger = true
	end
end

function Weaken(keys)
		local previous_stack_count = 0
		local duration = keys.ability:GetLevelSpecialValueFor("duration", -1)
		if keys.target:HasModifier("weakendebuff") then
			previous_stack_count = keys.target:GetModifierStackCount("weakendebuff", keys.caster)
			
			--We have to remove and replace the modifier so the duration will refresh.
			keys.target:RemoveModifierByNameAndCaster("weakendebuff", keys.caster)
		end
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "weakendebuff", {duration = duration})
		keys.target:SetModifierStackCount("weakendebuff", keys.caster, previous_stack_count + 1)
end