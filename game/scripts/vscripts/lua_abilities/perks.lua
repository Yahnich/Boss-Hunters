require( "libraries/Timers" )

function ReduceCD(keys)
	local ability = keys.ability
	local usedability = keys.event_ability
	local movementlist = {["item_blink"] = true,
						  ["item_force_staff"] = true,
						  ["item_force_boots"] = true,
						  ["item_blink_boots"] = true,
						  ["item_butterfly"] = true,
						  ["item_butterfly2"] = true,
						  ["item_butterfly3"] = true,
						  ["item_butterfly4"] = true,
						  ["item_butterfly5"] = true,
						  ["weaver_shukuchi"] = true,
						  ["phantom_lancer_doppelwalk"] = true,
						  ["spectre_spectral_dagger"] = true,
						  ["shredder_timber_chain"] = true,
						  ["lycan_shapeshift"] = true,
						  ["morphling_waveform"] = true,
						  ["treant_natures_guise"] = true,
						  ["queenofpain_blink"] = true,
						  ["antimage_blink"] = true,
						  ["furion_teleportation"] = true,
						  ["sandking_burrowstrike"] = true,
						  ["weaver_time_lapse"] = true,
						  ["mirana_leap"] = true,
						  ["rattletrap_hookshot"] = true,
						  ["centaur_stampede"] = true,
						  ["magnataur_skewer"] = true,
						  ["riki_blink_strike"] = true,
						  ["batrider_firefly"] = true,
						  ["slark_pounce_ebf"] = true,
						  ["ebf_blinkz"] = true,
						  ["phantom_lancer_splinter_strike"] = true,
						  ["dragon_knight_intervene"] = true,
						  ["juggernaut_ronin_slice"] = true,
						  ["slardar_guardian_crush"] = true,
						  ["phantom_assassin_assassins_dance"] = true,
						  ["drow_ranger_leapshot"] = true,
						  [""] = true,}
	if movementlist[usedability:GetName()] then
		local cdreduction = 1 - ability:GetSpecialValueFor("mobility_reduction") / 100
		Timers:CreateTimer(0.01,function()
			if not usedability:IsCooldownReady() then
				local cd = usedability:GetCooldownTimeRemaining()
				usedability:EndCooldown()
				usedability:StartCooldown(cd * cdreduction)
			else
				return 0.01
			end
		end)
	end
end

function PlaceRageStacks(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local threat = caster.threat
	if threat <= 0 then
		caster:RemoveModifierByName(modifier)
	else
		if not caster:HasModifier(modifier) then
			ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
		end
		local multiplier = ability:GetSpecialValueFor("threat_amp") / 100
		caster:SetModifierStackCount(modifier, ability, threat*multiplier)
	end
end

function RefreshPerk(keys)
	local caster = keys.caster
	local ability = keys.ability
	local spellrefresh = ability:GetSpecialValueFor("single_spell_refresh")
	local allrefresh = ability:GetSpecialValueFor("all_spell_refresh")
	if not ability.prng then ability.prng = 0 end
	local rnd = math.random(100)
	if rnd < spellrefresh - 10 + ability.prng then
		local usedability = keys.event_ability
		if usedability:IsItem() then return end
		ability.prng = 0
		Timers:CreateTimer(0.01,function()
			if not usedability:IsCooldownReady() then
				usedability:EndCooldown()
				if rnd < allrefresh then
					for i = 0, caster:GetAbilityCount() - 1 do
						local ability = caster:GetAbilityByIndex( i )
						if ability and ability ~= keys.ability then
							ability:EndCooldown()
						end
					end
				end
			else
				return 0.01
			end
		end)
	else
		ability.prng = ability.prng + 1
	end
end