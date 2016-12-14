require("libraries/utility")

function SpellEcho(keys)
	local caster = keys.caster
	local ability = keys.ability
	local echo = ability.echo
	local delay = ability:GetTalentSpecialValueFor("delay")
	local no_echo = {["shredder_chakram"] = true,
					 ["shredder_chakram_return"] = true,
					 ["shredder_chakram_2"] = true,
					 ["shredder_return_chakram_2"] = true,
					 ["arc_warden_tempest_double"] = true,
					 ["alchemist_unstable_concoction"] = true,
					 ["alchemist_unstable_concoction_throw"] = true,
					 ["vengefulspirit_nether_swap"] = true,
					 ["juggernaut_omni_slash"] = true,
					 ["rubick_telekinesis_land"] = true,
					 ["antimage_blink"] = true,
					 ["queenofpain_blink"] = true,
					 ["phoenix_icarus_dive"] = true,
					 ["phoenix_icarus_dive_stop"] = true,
					 ["phoenix_fire_spirits"] = true,
					 ["phoenix_sun_ray_stop"] = true,
					 ["phoenix_sun_ray"] = true,
					 ["phoenix_sun_ray_toggle_move"] = true,
					 ["phoenix_supernova"] = true,
					 ["phoenix_launch_fire_spirit"] = true,
					 ["juggernaut_ronin_slice"] = true
					}
	if echo and ability.echotarget and caster:IsRealHero() then
		if not no_echo[ echo:GetName() ] then
			if ability:IsCooldownReady() and not echo:IsChanneling() and GameRules:GetGameTime() > ability.echotime+delay+echo:GetCastPoint() then
				local target = ability.echotarget
				local cooldown = ability:GetCooldown(ability:GetLevel()-1)*get_octarine_multiplier(caster)
				local target_type = ability.type
					if target_type == DOTA_ABILITY_BEHAVIOR_POINT then
						caster:SetCursorPosition(target)
					elseif target_type == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
						caster:SetCursorCastTarget(target)
					elseif target_type == DOTA_ABILITY_BEHAVIOR_NO_TARGET then
						caster:SetCursorTargetingNothing(true)
					end
				local echo_effect = ParticleManager:CreateParticle("particles/rubick_spell_echo.vpcf", PATTACH_ABSORIGIN , caster)
				ParticleManager:SetParticleControl(echo_effect, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(echo_effect, 1, Vector(1,0,0))
				caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)
				if echo:GetChannelTime() > 0 and target_type ~= DOTA_ABILITY_BEHAVIOR_NO_TARGET then
					local player = caster:GetPlayerID()
					local spawnloc = target
					if target_type == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
						spawnloc = target:GetAbsOrigin()
					end
					local echoUnit = CreateUnitByName(caster:GetUnitName(), spawnloc, false, caster, nil, caster:GetTeamNumber())
					while echoUnit:GetLevel() < caster:GetLevel() do
						echoUnit:HeroLevelUp(false)
					end
					echoUnit:AddAbility(echo:GetName())
					local stats = echoUnit:AddAbility("lua_attribute_bonus")
					stats:SetLevel(caster:FindAbilityByName("lua_attribute_bonus"):GetLevel())
					echoUnit:SwapAbilities("rubick_empty1", echo:GetName(), false,true)
					echoUnit:AddNewModifier(echoUnit, nil, 'modifier_invulnerable', {})
					echoUnit:AddNewModifier(echoUnit, nil, 'modifier_item_phase_boots_active', {})
					echoUnit:AddNewModifier(echoUnit, nil, 'modifier_terrorblade_conjureimage', {})
					if caster:HasModifier('modifier_item_ultimate_scepter') then
                                                    echoUnit:AddNewModifier(echoUnit, nil, 'modifier_item_ultimate_scepter', {
                                                        bonus_all_stats = 0,
                                                        bonus_health = 0,
                                                        bonus_mana = 0
                                                    })
                    end
					echoUnit:SetMana(echo:GetManaCost(-1)+1)
                    local echoAb = echoUnit:FindAbilityByName(echo:GetName())
					echoAb:SetLevel(echo:GetLevel())
					echoUnit:StartGesture(ACT_DOTA_CHANNEL_ABILITY_5)
                    if echoAb then
						echoAb:SetLevel(echo:GetLevel())
						if target_type == DOTA_ABILITY_BEHAVIOR_POINT then
							echoUnit:Interrupt()
							order = 
								{
									UnitIndex = echoUnit:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
									Position = target,
									AbilityIndex = echoAb:entindex(),
									Queue = true
								}
							ExecuteOrderFromTable(order)
							ability:StartCooldown(cooldown)
						elseif target_type == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
							echoUnit:Interrupt()
							local order = 
								{
									UnitIndex = echoUnit:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
									TargetIndex = target:entindex(),
									AbilityIndex = echoAb:entindex(),
									Queue = true
								}
							ExecuteOrderFromTable(order)
							ability:StartCooldown(cooldown)
						end
					end
					Timers:CreateTimer(echo:GetChannelTime()/2, function()
																echoUnit:Stop()
																echoUnit:Interrupt()  
																echoUnit:InterruptChannel()
																local order = 
																	{
																		UnitIndex = echoUnit:entindex(),
																		OrderType = DOTA_UNIT_ORDER_STOP,
																		Queue = false
																	}
																ExecuteOrderFromTable(order)
																Timers:CreateTimer(0.5, function()
																echoUnit:RemoveSelf()
																end)
																end)
				else 
					echo:OnSpellStart()
					ability:StartCooldown(cooldown)
				end
			elseif not ability:IsCooldownReady() then
				ability.echo = nil
				ability.type = nil
				ability.echotarget = nil
			end
		end
	end
end
