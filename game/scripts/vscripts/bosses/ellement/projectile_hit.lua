function projectile_hit(keys)
	local target = keys.target
	local caster = keys.caster
	local wind = caster.invocation_power_wind
	local ice = caster.invocation_power_ice
	local fire = caster.invocation_power_fire
	local ability_level = keys.ability:GetLevel() - 1
	if keys.target:GetUnitName() ~= "npc_dota_boss36" then
		local lastskill = keys.caster.last_used_skill

		if lastskill == "arcana_laser" then
			local target = keys.target
		    local caster = keys.caster
		    local damage_Hit = keys.caster:GetAverageTrueAttackDamage(caster)*(fire)

		    local damageTableHit = {victim = target,
		                        attacker = caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_PURE,
		                        }
		    ApplyDamage(damageTableHit)
		end

		if lastskill == "Heavy_Ice_Projectile" then
			local target = keys.target
		    local caster = keys.caster
		    local damage_Hit = ((keys.caster:GetLevel()^0.5)*(ice+wind)^4*(1+fire)) + (1000 * 2^ability_level)
			print(damage_Hit, "Heavy_Ice_Projectile")
		    local damageTableHit = {victim = target,
		                        attacker = caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)

		    keys.ability:ApplyDataDrivenModifier(keys.caster, target, "ice_freeze_display", {duration = (ice/5)})
	                keys.ability:ApplyDataDrivenModifier(keys.caster, target, "ice_freeze", {duration = (ice/5)})
	                local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , target)
	                ParticleManager:SetParticleControl(ice_freeze_effect, 0, target:GetAbsOrigin())
	                ParticleManager:SetParticleControl(ice_freeze_effect, 1, target:GetAbsOrigin())
	                Timers:CreateTimer((ice/5),function()
	        	ParticleManager:DestroyParticle(ice_freeze_effect, false)
	        end)
		end

		if lastskill == "IceFlame_Ball" then
			local target = keys.target
		    local caster = keys.caster
		    local fire = caster.invocation_power_fire
		    local ice = caster.invocation_power_ice
		    local damage_Hit = (keys.caster:GetLevel()^0.5)*(ice+fire)^4 + (1000 * 2^ability_level)
			print(damage_Hit, "IceFlame_Ball")
		    local damageTableHit = {victim = target,
		                        attacker = caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)

		    local damage_AoE = (caster:GetLevel()^0.9)*fire^4*2 + ice^4 + ((ice+fire)*40)^2 + (1000 * 2^ability_level)
		    local radius = 500
		    local nearbyUnits = FindUnitsInRadius(target:GetTeam(),
		                              target:GetAbsOrigin(),
		                              nil,
		                              500,
		                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		                              DOTA_UNIT_TARGET_ALL,
		                              DOTA_UNIT_TARGET_FLAG_NONE,
		                              FIND_ANY_ORDER,
		                              false)
		    for _,unit in pairs(nearbyUnits) do
		            local damageTableAoe = {victim = unit,
		                        attacker = caster,
		                        ability = keys.ability,
		                        damage = damage_AoE,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		            ApplyDamage(damageTableAoe)
	            	Fire_Dot(keys,caster, unit,math.floor(((fire)^2*((keys.caster:GetLevel()^0.6/2)^2)*25 + (333 * 2^ability_level))))
	            	keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "iceflame_display", {duration = 5})
	                keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "slow_modifier", {duration = 5})
	                unit:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*(25) ) )

	                ice_flame_debuff_effect = ParticleManager:CreateParticle("particles/ice_flame_debuff.vpcf", PATTACH_ABSORIGIN , unit)
	                ParticleManager:SetParticleControl(ice_flame_debuff_effect, 0, unit:GetAbsOrigin())
	                ParticleManager:SetParticleControl(ice_flame_debuff_effect, 1, unit:GetAbsOrigin())

	                Timers:CreateTimer(5,function()
				            ParticleManager:DestroyParticle( ice_flame_debuff_effect, false)
				    end)
		    end

			ProjectileManager:DestroyLinearProjectile(keys.caster.projectile_table[1])
			fire_spear_explosion_effect = ParticleManager:CreateParticle("particles/ice_ball_explosion.vpcf", PATTACH_ABSORIGIN , target)
			target:EmitSound("Hero_Techies.Suicide")
			ParticleManager:SetParticleControl(fire_spear_explosion_effect, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(fire_spear_explosion_effect, 5, target:GetAbsOrigin())
			Timers:CreateTimer(5,function()
                        ParticleManager:DestroyParticle( fire_spear_explosion_effect , false)
                end)
		end

		if lastskill == "fire_ball" then
			local target = keys.target
		    local caster = keys.caster
		    local fire = caster.invocation_power_fire
		    local wind = caster.invocation_power_wind
		    local damage_Hit = (keys.caster:GetLevel()^0.5)*fire^4 * (1+ice^1.5) * (1+wind) + (1000 * 2^ability_level)
			print(damage_Hit, "fire_ball")
		    local damageTableHit = {victim = target,
		                        attacker = caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)

		    local damage_AoE = (caster:GetLevel()^0.9)*fire^4 * (1+ice^1.5) * (1+wind) + (1000 * 2^ability_level)
		    local radius = 250*ice
		    local nearbyUnits = FindUnitsInRadius(target:GetTeam(),
		                              target:GetAbsOrigin(),
		                              nil,
		                              500,
		                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		                              DOTA_UNIT_TARGET_ALL,
		                              DOTA_UNIT_TARGET_FLAG_NONE,
		                              FIND_ANY_ORDER,
		                              false)
		    for _,unit in pairs(nearbyUnits) do
		            local damageTableAoe = {victim = unit,
		                        attacker = caster,
		                        damage = damage_AoE,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		            ApplyDamage(damageTableAoe)
		            keys.ability:ApplyDataDrivenModifier(caster, unit, "fire_dot_display", {duration = 5+1})
	            	Fire_Dot(keys,caster, unit,math.floor((fire/3)^2*((keys.caster:GetLevel()^0.6)*25 + (333 * 2^ability_level))))

		    end

			ProjectileManager:DestroyLinearProjectile(keys.caster.projectile_table[1])
			fire_spear_explosion_effect = ParticleManager:CreateParticle("particles/fire_ball_explosion.vpcf", PATTACH_ABSORIGIN , target)
			target:EmitSound("Hero_Techies.Suicide")
			ParticleManager:SetParticleControl(fire_spear_explosion_effect, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(fire_spear_explosion_effect, 5, target:GetAbsOrigin())
			Timers:CreateTimer(5,function()
                        ParticleManager:DestroyParticle( fire_spear_explosion_effect , false)
                end)
		end

		if lastskill == "steam_tempest" then

			local fire = keys.caster.invocation_power_fire
			local ice = keys.caster.invocation_power_ice
			local damage_Hit = ( ((keys.caster:GetLevel()^0.5)*(ice^3*2 + fire^3*3)*1.5 + (ice+fire)*200)*2 + (1000 * 2^ability_level) ) / caster.projectilesElementalist
			print(damage_Hit, "steam_tempest")
			keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = 6})
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "slow_modifier_display", {duration = 6})
	        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "slow_modifier", {duration = 6})
	        keys.target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*3) )

	       	Fire_Dot(keys,keys.caster, keys.target,math.floor((fire/3*wind/2*ice)^2*((keys.caster:GetLevel()^0.6/2))*10 + (333 * 2^ability_level)),5+1)
		    local damageTableHit = {victim = keys.target,
		                        attacker = keys.caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
			keys.duration = 0.2
			keys.distance = 100
			keys.range = (ice + fire)*200 +100
			keys.height = 0
			keys.modifier = "modifier_knockback_wind"
			ApplyKnockback(keys)

		end

		if lastskill == "steam_trail" then

			local fire = keys.caster.invocation_power_fire
			local ice = keys.caster.invocation_power_ice
			local damage_Hit = ((keys.caster:GetLevel()^0.8)*(ice^4 + fire^4)*5 + (ice+fire)*2000 + (1000 * 2^ability_level)) / caster.projectilesElementalist
			print(damage_Hit, "steam_trail")
			keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = fire/2})
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "slow_modifier_display", {duration = ice/2})
	        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "slow_modifier", {duration = ice/2})
	        keys.target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*3) )

	       	Fire_Dot(keys,keys.caster, keys.target,math.floor((fire/3+ice/2+wind/2)^2.5*((keys.caster:GetLevel()^0.6/2))*10 + (333 * 2^ability_level)),fire/2)
		    local damageTableHit = {victim = keys.target,
		                        attacker = keys.caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
			keys.duration = 0.2
			keys.distance = 100
			keys.range = (ice + fire)*200 +100
			keys.height = 0
			keys.modifier = "modifier_knockback_wind"
			ApplyKnockback(keys)
		end

		if lastskill == "water_stream" or lastskill == "water_tempest" then

			local fire = keys.caster.invocation_power_fire
			local ice = keys.caster.invocation_power_ice
			local damage_Hit = (keys.caster:GetLevel()^0.5)*((ice)^4 + (fire)^4)*2 + (ice*fire)*1000 + (1000 * 2^ability_level)
			print(damage_Hit, lastskill)
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "slow_modifier_display", {duration = 11})
	        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "slow_modifier", {duration = 11})
	        keys.target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*10) )



	        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "armor_debuff_display", {duration = 11})
	        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "armor_debuff", {duration = 11})
	        keys.target:SetModifierStackCount( "armor_debuff", keys.ability, math.floor(keys.target:GetPhysicalArmorBaseValue()*.01*(10 + ice) ) )





		    local damageTableHit = {victim = keys.target,
		                        attacker = keys.caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
			keys.duration = 0.2
			keys.distance = 50
			keys.range = (ice + fire)*200 +100
			keys.height = 0
			keys.modifier = "modifier_knockback_wind"
			ApplyKnockback(keys)
		end

		if lastskill == "wind_stream" then
			local wind = keys.caster.invocation_power_wind
			local damage_Hit = (keys.caster:GetLevel()^0.5)*wind^4*3 + (wind)*1000 + (1000 * 2^ability_level)
		    print(damage_Hit, "wind_stream")
			local damageTableHit = {victim = keys.target, 
		                        attacker = keys.caster,
		                        damage = damage_Hit,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
			keys.duration = (wind/3) * 0.2
			keys.distance = (wind*100)
			keys.range = (wind*400)
			keys.height = 0
			keys.modifier = "modifier_knockback_wind"
			ApplyKnockback(keys)
		end

		if lastskill == "Blizzard" then
			local wind = keys.caster.invocation_power_wind
			local ice = keys.caster.invocation_power_ice
			local damage_Hit = (keys.caster:GetLevel()^0.5)*(ice+wind)^4 * 0.3 + (ice+wind)*250 + (1000 * 2^ability_level)
			print(damage_Hit, "Blizzard")
			keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier_display", {duration = 5+(wind/4)})
	        keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier", {duration = 5+(ice/2)+(wind/3)})
	        target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*30) )

	       	keys.ability:ApplyDataDrivenModifier(keys.caster, target, "ice_freeze_display", {duration = (ice/5)+(wind/4)})
	                keys.ability:ApplyDataDrivenModifier(keys.caster, target, "ice_freeze", {duration = (ice/5)+(wind/4)})
	                local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , target)
	                ParticleManager:SetParticleControl(ice_freeze_effect, 0, target:GetAbsOrigin())
	                ParticleManager:SetParticleControl(ice_freeze_effect, 1, target:GetAbsOrigin())
	                Timers:CreateTimer((ice/5)+(wind/4),function()
	                    ParticleManager:DestroyParticle(ice_freeze_effect, false)
	                end)

		    local damageTableHit = {victim = keys.target,
		                        attacker = keys.caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
			keys.distance = 0
			keys.duration = (wind/4)
			keys.range = (wind*500)
			keys.height = 280
			keys.modifier = "modifier_knockback_wind"
			ApplyKnockback(keys)
		end

		if lastskill == "Ice_Tornado" then

			local target = keys.target
			local caster = keys.caster
			local wind = keys.caster.invocation_power_wind
			local ice = keys.caster.invocation_power_ice
			local damage_Hit = (keys.caster:GetLevel()^0.8)*(ice+wind+fire)^4 + (ice+wind+fire)*500 + (1000 * 2^ability_level)
			print(damage_Hit, "Ice_Tornado")
			keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier_display", {duration = 5+(wind/4)})
	        keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier", {duration = 5+(wind/4)})
	        target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*20) )

	        keys.ability:ApplyDataDrivenModifier(keys.caster, target, "ice_freeze_display", {duration = 3+(ice/5)+(wind/4)})
	                keys.ability:ApplyDataDrivenModifier(keys.caster, target, "ice_freeze", {duration = 3+(ice/5)+(wind/4)})
	                local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , target)
	                ParticleManager:SetParticleControl(ice_freeze_effect, 0, target:GetAbsOrigin())
	                ParticleManager:SetParticleControl(ice_freeze_effect, 1, target:GetAbsOrigin())
	                Timers:CreateTimer((ice/5)+(wind/4),function()
	                    ParticleManager:DestroyParticle(ice_freeze_effect, false)
	                end)



		    local damageTableHit = {victim = keys.target,
		                        attacker = keys.caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
			keys.duration = (wind/4)
			keys.distance = 0
			keys.range = (wind*500)
			keys.height = 280
			keys.modifier = "modifier_knockback_wind"
			ApplyKnockback(keys)
		end

		if lastskill == "Fire_Tempest" then
			local target = keys.target
			local caster = keys.caster
			local wind = keys.caster.invocation_power_wind
			local fire = keys.caster.invocation_power_fire
			local damage_Hit = (keys.caster:GetLevel()^0.5)*(fire+wind)^4 + (fire+wind)*1000 + (1000 * 2^ability_level)
			print(damage_Hit, "Fire_Tempest")
			keys.duration = (wind/4)
			keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = 3+(wind/4)})

	       	Fire_Dot(keys,keys.caster, keys.target,math.floor((fire)^2*((keys.caster:GetLevel()^0.6)) + (333 * 2^ability_level)),3+(wind/4))
		    local damageTableHit = {victim = keys.target,
		                        attacker = keys.caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
		    keys.duration = (wind/4)
			keys.distance = 0
			keys.range = (wind*500)
			keys.height = 280
			keys.modifier = "modifier_knockback_wind"
			ApplyKnockback(keys)
		end

		if lastskill == "Fire_Tornado" then

			local target = keys.target
			local caster = keys.caster
			local wind = keys.caster.invocation_power_wind
			local fire = keys.caster.invocation_power_fire
			local damage_Hit = (keys.caster:GetLevel()^0.5)*(fire+wind)^4*0.5 + (fire+wind)*1000 + (1000 * 2^ability_level)
			print(damage_Hit, "Fire_Tornado")
			keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = 5+(wind/4)})
	        Fire_Dot(keys,keys.caster, keys.target,math.floor((fire)^2*((keys.caster:GetLevel()^0.6/2))*40 + (333 * 2^ability_level)),5+(wind/4))

		    local damageTableHit = {victim = keys.target,
		                        attacker = keys.caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
			keys.duration = (wind/4)
			keys.distance = 0
			keys.range = (wind*500)
			keys.height = 280
			keys.modifier = "modifier_knockback_wind"
			ApplyKnockback(keys)
		end

		if lastskill == "Turnado" then

			local wind = keys.caster.invocation_power_wind
			local damage_Hit = (keys.caster:GetLevel()^0.5)*wind^3*5 + (wind)*1000 + (1000 * 2^ability_level)
			print(damage_Hit, "Turnado")
		    local damageTableHit = {victim = keys.target,
		                        attacker = keys.caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
			keys.duration = (wind/6)
			keys.distance = 0
			keys.range = (wind*200)
			keys.height = 280
			keys.modifier = "modifier_knockback_wind"
			ApplyKnockback(keys)
		end

		if lastskill == "Tempest" then

			local wind = keys.caster.invocation_power_wind
			local damage_Hit = (keys.caster:GetLevel()^0.5)*wind^3*5 + (wind)*500 + (1000 * 2^ability_level)
			print(damage_Hit, "Tempest")
		    local damageTableHit = {victim = keys.target,
		                        attacker = keys.caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
			keys.duration = (wind/6)
			keys.distance = 0
			keys.range = (wind*200)
			keys.height = 280
			keys.modifier = "modifier_knockback_wind"
			ApplyKnockback(keys)
		end

		if lastskill == "fire_spear" then
			local target = keys.target
		    local caster = keys.caster
		    local fire = caster.invocation_power_fire
		    local damage_Hit = (keys.caster:GetLevel()^0.8)*fire^4*4 + (fire+2)*500 + (1000 * 2^ability_level)
		    print(damage_Hit, "fire_spear")
		    local damageTableHit = {victim = target,
		                        attacker = caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
		    keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = 5})

	        Fire_Dot(keys,keys.caster, keys.target,math.floor((fire/3)^2*((keys.caster:GetLevel()^0.6/2))*25 + (333 * 2^ability_level)))
		end

		if lastskill == "iceshard2" then
			local target = keys.target
		    local caster = keys.caster
		    local ice = caster.invocation_power_ice
		    local wind = caster.invocation_power_wind
		    local damage_Hit = (keys.caster:GetLevel()^0.5)*wind^4*1.25 + (ice+wind)*250 + (1000 * 2^ability_level)
			print(damage_Hit, "iceshard2")
		    local damageTableHit = {victim = target,
		                        attacker = caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
		    keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier_display", {duration = 5})
	        keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier", {duration = 5})
	        target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*10) )
	        local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , target)
	        ParticleManager:SetParticleControl(ice_freeze_effect, 0, keys.target:GetAbsOrigin())
	    	ParticleManager:SetParticleControl(ice_freeze_effect, 1, keys.target:GetAbsOrigin())
	                Timers:CreateTimer((ice/5),function()
	                    ParticleManager:DestroyParticle(ice_freeze_effect, false)
	                end)
		end

		if lastskill == "iceshard1" then
			local target = keys.target
		    local caster = keys.caster
		    local ice = caster.invocation_power_ice
		    local wind = caster.invocation_power_wind
		    local damage_Hit = (keys.caster:GetLevel()^0.5)*wind^4*10 + (ice+wind)*200 + (1000 * 2^ability_level)
			print(damage_Hit, "iceshard1")
		    local damageTableHit = {victim = target,
		                        attacker = caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
		    keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier_display", {duration = wind*5})
	        keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier", {duration = wind*5})
	        target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*20) )
	        local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , target)
	        ParticleManager:SetParticleControl(ice_freeze_effect, 0, keys.target:GetAbsOrigin())
	    	ParticleManager:SetParticleControl(ice_freeze_effect, 1, keys.target:GetAbsOrigin())
	                Timers:CreateTimer((ice/5),function()
	                    ParticleManager:DestroyParticle(ice_freeze_effect, false)
	                end)
		end

		if lastskill == "multiple_fire_spear" then
			local target = keys.target
		    local caster = keys.caster
		    local fire = caster.invocation_power_fire
		    local damage_Hit = (keys.caster:GetLevel()^0.5)*fire^4*4 + (fire)*250 + (1000 * 2^ability_level)
			print(damage_Hit, "multiple_fire_spear")
		    local damageTableHit = {victim = target,
		                        attacker = caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)
		    keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = 5})

	        Fire_Dot(keys,keys.caster, keys.target,math.floor((fire/3)^2*((keys.caster:GetLevel()^0.6/2))*25 + (333 * 2^ability_level)))
		end

		if lastskill == "explosive_fire_spear" then
			local target = keys.target
		    local caster = keys.caster
		    local fire = caster.invocation_power_fire
		    local damage_Hit = (keys.caster:GetLevel()^0.5)*fire^4*4 + (fire)*2000 + (1000 * 2^ability_level)
			print(damage_Hit, "explosive_fire_spear hit")
		    local damageTableHit = {victim = target,
		                        attacker = caster,
		                        damage = damage_Hit,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		    ApplyDamage(damageTableHit)

		    local damage_AoE = (caster:GetLevel()^0.9)*fire^4*0.5 + (1000 * 2^ability_level)
			print(damage_AoE, "explosive_fire_spear aoe")
		    local radius = 500 + 25*fire
		    local nearbyUnits = FindUnitsInRadius(target:GetTeam(),
		                              target:GetAbsOrigin(),
		                              nil,
		                              radius,
		                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		                              DOTA_UNIT_TARGET_ALL,
		                              DOTA_UNIT_TARGET_FLAG_NONE,
		                              FIND_ANY_ORDER,
		                              false)
		    for _,unit in pairs(nearbyUnits) do
		            local damageTableAoe = {victim = unit,
		                        attacker = caster,
		                        damage = damage_AoE,
		                        ability = keys.ability,
		                        damage_type = DAMAGE_TYPE_MAGICAL,
		                        }
		            ApplyDamage(damageTableAoe)
		            keys.ability:ApplyDataDrivenModifier(caster, unit, "fire_dot_display", {duration = 5})
	            	keys.ability:ApplyDataDrivenModifier(caster, unit, "fire_dot", {duration = 5})
	            	Fire_Dot(keys,caster, unit,math.floor((fire/3)^2*((keys.caster:GetLevel()^0.6/2))*25 + (333 * 2^ability_level)))

		    end

			ProjectileManager:DestroyLinearProjectile(keys.caster.projectile_table[1])
			fire_spear_explosion_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion_second.vpcf", PATTACH_OVERHEAD_FOLLOW , target)
			target:EmitSound("Hero_Techies.Suicide")
			ParticleManager:SetParticleControl(fire_spear_explosion_effect, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(fire_spear_explosion_effect, 3, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(fire_spear_explosion_effect, 5, target:GetAbsOrigin())
		end
	end

end

function Fire_Dot(keys,caster,target,Damage,duration)
	if duration == nil then
		duration = 5
	end
	local damageTableDOT = {victim = target,
	                    attacker = caster,
	                    damage = Damage,
	                    ability = keys.ability,
	                    damage_type = DAMAGE_TYPE_MAGICAL,
	                    }
	local begin_time = GameRules:GetGameTime()

	Timers:CreateTimer(1.00,function()
   			if GameRules:GetGameTime() <= begin_time+duration then
	   			ApplyDamage(damageTableDOT)
	   			return 1.00
	   		else
	   			return
	   		end
   		end)
end
