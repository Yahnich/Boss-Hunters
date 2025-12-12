rubick_echo = class({})
LinkLuaModifier("modifier_rubick_echo_handle", "heroes/hero_rubick/rubick_echo", LUA_MODIFIER_MOTION_NONE)

function rubick_echo:IsStealable()
    return false
end

function rubick_echo:IsHiddenWhenStolen()
    return false
end

function rubick_echo:GetIntrinsicModifierName()
	return "modifier_rubick_echo_handle"
end

function rubick_echo:SpellEcho(hAbility, vLocation, hTarget)
	local caster = self:GetCaster()
	local echoed_ability = hAbility

	local target = hTarget
	local position = vLocation

	if not echoed_ability then return end

	local delay = self:GetSpecialValueFor("delay")

	--99% of this is because its a waste of a cooldown for echo because
	--it often times will just refresh a buff/debuff that you just applied.
	--Otherwise its aoes that dont stack, or the ability is a bit too complex for it be echoed right
	local no_echo = {["abaddon_borrowed_time_ebf"] = true,
					 ["abyssal_underlord_abyssal_expulsion"] = true,
					 ["alchemist_acid_spray_ebf"] = true,
					 ["alchemist_chemical_rage_ebf"] = true,
					 ["antimage_blink_bh"] = true,
					 ["arc_warden_magnetic_field_bh"] = true,
					 ["axe_forced_shout"] = true,
					 ["axe_blood_hunger"] = true,
					 ["bane_enfeeble_ebf"] = true,
					 ["bane_nightmare_prison"] = true,
					 ["batrider_lasso"] = true,
					 ["bs_bloodrage"] = true,
					 ["bs_devils_blood"] = true,
					 ["bs_rupture"] = true,
					 ["bh_tree_hook"] = true,
					 ["bh_shadow_walk"] = true,
					 ["bh_track"] = true,
					 ["brewmaster_drunken_haze_ebf"] = true,
					 ["brewmaster_primal_avatar"] = true,
					 ["broodmother_web"] = true,
					 ["broodmother_hunger"] = true,
					 ["centaur_champions_presence"] = true,
					 ["centaur_stampede_ebf"] = true,
					 ["chaos_knight_reality_rift_ebf"] = true,
					 ["chaos_knight_phantasm_ebf"] = true,
					 ["chen_penitence_ebf"] = true,
					 ["chen_angel_persuasion"] = true,
					 ["clinkz_strafe_bh"] = true,
					-- ["clinkz_pact"] = true,
					 ["clinkz_burning_army_bh"] = true,
					 ["crystal_maiden_frostbite_bh"] = true,
					 ["ds_shell"] = true,
					 ["ds_surge"] = true,
					 ["ds_replica"] = true,
					 ["dw_shadow"] = true,
					 ["dazzle_shallow_grave_bh"] = true,
					 ["dazzle_weave_bh"] = true,
					 ["death_prophet_ghastly_haunting"] = true,
					 ["death_prophet_spirit_siphon_bh"] = true,
					 ["death_prophet_exorcism_bh"] = true,
					 ["disruptor_kinetic_charge"] = true,
					 ["doom_apocalypse"] = true,
					 ["doom_scorched_earth_ebf"] = true,
					 ["dragon_knight_intervene"] = true,
					 ["dragon_knight_elder_dragon_berserker"] = true,
					 ["drow_ranger_drows_teachings"] = true,
					 ["earthshaker_enchant_totem_ebf"] = true,
					 ["earthshaker_crater_impact"] = true,
					 ["ember_fist"] = true,
					 ["ember_remnant"] = true,
					 ["ember_remnant_jump"] = true,
					 ["ember_shield"] = true,
					 ["enchantress_untouchable_bh"] = true,
					 ["enchantress_enchant_bh"] = true,
					 ["enchantress_attendants"] = true,
					 ["enigma_malefice_bh"] = true,
					 ["espirit_rock_pull"] = true,
					 ["espirit_magnetize"] = true,
					 ["faceless_time_walk"] = true,
					 ["faceless_clock_stopper"] = true,
					 ["faceless_chrono"] = true,
					 ["furion_tree_jail"] = true,
					 ["furion_sprout_tp"] = true,
					 ["furion_tree_ant"] = true,
					 ["gyro_bombing_run"] = true,
					 ["huskar_unleash_vitality"] = true,
					 ["juggernaut_ronins_wind"] = true,
					 ["juggernaut_dance_of_blades"] = true,
					 ["juggernaut_mirror_blades"] = true,
					 ["juggernaut_quickparry"] = true,
					 ["kotl_blind"] = true,
					 ["kotl_chakra_magic"] = true,
					 ["kotl_power_leak"] = true,
					 ["kotl_recall"] = true,
					 ["kotl_spirit"] = true,
					 ["kunkka_captains_rum"] = true,
					 ["kunkka_xmarks_bh"] = true,
					 ["legion_commander_unbreakable_morale"] = true,
					 ["legion_commander_war_fury"] = true,
					 ["leshrac_pulse_nova_bh"] = true,
					 ["lifestealer_assimilate_bh"] = true,
					 ["lifestealer_assimilate_exit"] = true,
					 ["lifestealer_rage_bh"] = true,
					 ["lifestealer_flesh_wounds"] = true,
					 ["lifestealer_rend"] = true,
					 ["lion_frogger"] = true,
					 ["luna_eclipse_bh"] = true,
					 ["lycan_summon_wolves_bh"] = true,
					 ["lycan_shapeshift_bh"] = true,
					 ["lycan_howl_bh"] = true,
					 ["mag_charge"] = true,
					 ["mag_empower"] = true,
					 ["mag_magnet"] = true,
					 ["medusa_gaze"] = true,
					 ["medusa_shield"] = true,
					 ["mirana_celestial_jump"] = true,
					 ["mirana_stardust_reflection"] = true,
					 ["mk_command"] = true,
					 ["mk_spring"] = true,
					 ["mk_tree"] = true,
					 ["morph_agi_morph"] = true,
					 ["morph_morph"] = true,
					 ["morph_str_morph"] = true,
					 ["naga_siren_liquid_form"] = true,
					 ["naga_siren_water_snare"] = true,
					 ["naga_siren_song_of_the_siren_bh"] = true,
					 ["necrophos_ghost_shroud_bh"] = true,
					 ["night_stalker_crippling_fear_bh"] = true,
					 ["night_stalker_hunter_in_the_night_bh"] = true,
					 ["night_stalker_dark_ascension_bh"] = true,
					 ["night_stalker_void_bh"] = true,
					 ["nyx_harden_carapace"] = true,
					 ["nyx_vendetta"] = true,
					 ["ogre_magi_bloodlust_bh"] = true,
					 ["omniknight_guardian_angel_bh"] = true,
					 ["omniknight_heavenly_grace_bh"] = true,
					 ["oracle_promise"] = true,
					 ["oracle_fates"] = true,
					 ["obsidian_destroyer_astral_isolation"] = true,
					 ["pango_shield"] = true,
					 ["pango_swift_dash"] = true,
					 ["pango_ball"] = true,
					 ["phenx_dive"] = true,
					 ["phenx_egg"] = true,
					 ["phenx_ray"] = true,
					 ["phenx_spirits"] = true,
					 ["puck_phase_shift_ebf"] = true,
					 ["pudge_hook_lua"] = true,
					 ["pudge_chain_storm"] = true,
					 ["pugna_decrepify_bh"] = true,
					 ["pugna_lifedrain_bh"] = true,
					 ["queenofpain_blink_bh"] = true,
					 ["rattletrap_battery_assault_ebf"] = true,
					 ["rattletrap_reactive_shielding"] = true,
					 ["rattletrap_automated_artillery"] = true,
					 ["razor_static_link_bh"] = true,
					 ["riki_dance"] = true,
					 ["riki_traded_tricks"] = true,
					 ["rubick_lift"] = true,
					 ["rubick_steal"] = true,
					 ["rubick_echo"] = true,
					 ["sand_burrow"] = true,
					 ["sand_tremors"] = true,
					 ["sand_sandstorm"] = true,
					 ["sd_demonic_purge"] = true,
					 ["shadow_fiend_requiem"] = true,
					 ["shadow_shaman_ignited_voodoo"] = true,
					 ["silencer_last_word_bh"] = true,
					 ["silencer_global_silence_bh"] = true,
					 ["skywrath_seal"] = true,
					 ["slardar_amplify_damage_bh"] = true,
					 ["slardar_sprint_bh"] = true,
					 ["slark_pounce_ebf"] = true,
					 ["slark_acrobatics"] = true,
					 ["slark_shadow_dance_ebf"] = true,
					 ["sb_charge"] = true,
					 ["sb_haste"] = true,
					 ["ss_ball_lightning"] = true,
					 ["ss_electric_vortex"] = true,
					 ["sven_gods_strength_bh"] = true,
					 ["sven_valiant_charge"] = true,
					 ["sven_warcry_bh"] = true,
					 ["ta_meld"] = true,
					 ["ta_refract"] = true,
					 ["ta_trap"] = true,
					 ["tech_drastic"] = true,
					 ["tech_suicide"] = true,
					 ["terrorblade_metamorphosis_bh"] = true,
					 ["tinker_rearm_ebf"] = true,
					 ["tiny_toss_bh"] = true,
					 ["tiny_tree_bh"] = true,
					 ["treant_little_tree"] = true,
					 ["treant_overgrowth_bh"] = true,
					 ["treant_living_armor_bh"] = true,
					 ["treant_great_protector"] = true,
					 ["troll_warlord_battle_trance_bh"] = true,
					 ["troll_warlord_berserkers_rage_bh"] = true,
					 ["undying_summon_zombies"] = true,
					 ["undying_flesh_golem_bh"] = true,
					 ["ursa_enrage_bh"] = true,
					 ["ursa_fury_swipes_bh"] = true,
					 ["ursa_lunge"] = true,
					 ["ursa_overpower_bh"] = true,
					 ["vengefulspirit_haunt"] = true,
					 ["vengefulspirit_swap"] = true,
					 ["viper_nethertoxin_bh"] = true,
					 ["visage_cloak"] = true,
					 ["visage_familiars"] = true,
					 ["visage_stone"] = true,
					 ["warlock_corruption_curse"] = true,
					 ["warlock_sacrifice"] = true,
					 ["warlock_summon_imp"] = true,
					 ["weaver_fabric_tear"] = true,
					 ["weaver_shukuchi_bh"] = true,
					 ["weaver_time"] = true,
					 ["windrunner_windrun_bh"] = true,
					 ["witch_doctor_death_ward_bh"] = true,
					 ["witch_doctor_voodoo_restoration_bh"] = true,
					 ["wk_skeletons"] = true,
					 ["wk_vamp"] = true,
					 ["winterw_arctic_sting"] = true,
					 ["winterw_ice_shell"] = true,
					 ["winterw_winters_kiss"] = true,
					 ["zeus_olympus_calls"] = true
					}

	if not no_echo[ echoed_ability:GetAbilityName() ] then
		if not echoed_ability:IsChanneling() and not echoed_ability:IsItem() then
			self:UseResources(false, false, true)

			Timers:CreateTimer(0.5, function()
				local target_type = echoed_ability:GetBehavior()

				--Does the behavior includes Point cast
				if HasBit(target_type, DOTA_ABILITY_BEHAVIOR_POINT) then
					caster:SetCursorPosition(position)

				--Does the behavior includes target unit
				elseif HasBit(target_type, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
					if target then
						caster:SetCursorCastTarget(target)
					end

				--Does the behavior includes no target
				elseif HasBit(target_type, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
					caster:SetCursorTargetingNothing(true)
				end

				local echo_effect = ParticleManager:CreateParticle("particles/rubick_spell_echo.vpcf", PATTACH_ABSORIGIN , caster)
									ParticleManager:SetParticleControl(echo_effect, 0, caster:GetAbsOrigin())
									ParticleManager:SetParticleControl(echo_effect, 1, Vector(1,0,0))
									ParticleManager:ReleaseParticleIndex(echo_effect)
				
				echoed_ability:OnSpellStart()
			end)
		end
	end
end

modifier_rubick_echo_handle = class({})
function modifier_rubick_echo_handle:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_rubick_echo_handle:OnAbilityExecuted(params)
	if IsServer() then
		local parent = self:GetParent()
		local echo_ability = params.ability
		local ability = self:GetAbility()
		local unit = params.unit

		local cursorPos = ability:GetCursorPosition()
		local cursorTar = ability:GetCursorTarget()

		if unit == parent and ability:IsCooldownReady() then
			ability:SpellEcho(echo_ability, cursorPos, cursorTar)
		end
	end
end

function modifier_rubick_echo_handle:IsDebuff()
	return false
end

function modifier_rubick_echo_handle:IsHidden()
	return true
end

function modifier_rubick_echo_handle:IsPurgable()
	return false
end

function modifier_rubick_echo_handle:IsPurgeException()
	return false
end