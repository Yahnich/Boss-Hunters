function ShadowRaze(keys)
	local ability = keys.ability
	local caster = keys.caster
	local radius = ability:GetTalentSpecialValueFor("shadowraze_radius")
	local offset = ability:GetTalentSpecialValueFor("shadowraze_range")
	local razePoint = caster:GetAbsOrigin() + caster:GetForwardVector():Normalized() * offset
	local AOE_effect = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN  , caster)
	ParticleManager:SetParticleControl(AOE_effect, 0, razePoint)
	ParticleManager:SetParticleControl(AOE_effect, 3, razePoint)
	EmitSoundOn("Hero_Nevermore.Shadowraze", caster)
	local nearbyUnits = FindUnitsInRadius(caster:GetTeamNumber(),
                                  razePoint,
                                  nil,
                                  radius,
                                  ability:GetAbilityTargetTeam(),
                                  ability:GetAbilityTargetType(),
                                  0,
                                  FIND_ANY_ORDER,
                                  false)
	print(#nearbyUnits)
	for _,unit in pairs(nearbyUnits) do
		local damage = ability:GetAbilityDamage()
		if #nearbyUnits == 1 then damage = damage * ability:GetTalentSpecialValueFor("solo_amp") / 100 end
		if unit:HasModifier(keys.sibling1) then damage = damage * ability:GetTalentSpecialValueFor("combo_amp") / 100 end
		if unit:HasModifier(keys.sibling2) then damage = damage * ability:GetTalentSpecialValueFor("combo_amp") / 100 end
		ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
		ability:ApplyDataDrivenModifier(caster, unit, keys.combo, {duration = ability:GetTalentSpecialValueFor("combo_time")})
	end
	if caster:FindAbilityByName("special_bonus_unique_nevermore_2"):GetLevel() > 0 then
		ability:EndCooldown()
		ability:StartCooldown( (ability:GetCooldown(-1) - caster:FindAbilityByName("special_bonus_unique_nevermore_2"):GetSpecialValueFor("value") ) * get_octarine_multiplier(caster))
	end
end

function LevelUpAbility( keys )
	local caster = keys.caster
	local this_ability = keys.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name1 = keys.ability_name1
	local ability_handle1 = caster:FindAbilityByName(ability_name1)	
	local ability_level1 = ability_handle1:GetLevel()
	
	local ability_name2 = keys.ability_name2
	local ability_handle2 = caster:FindAbilityByName(ability_name2)	
	local ability_level2 = ability_handle2:GetLevel()

	-- Check to not enter a level up loop
	if ability_level1 ~= this_abilityLevel then
		ability_handle1:SetLevel(this_abilityLevel)
	end
	if ability_level2 ~= this_abilityLevel then
		ability_handle2:SetLevel(this_abilityLevel)
	end
end

function CheckNecroStacks(keys)
	local caster = keys.caster
	local ability = keys.ability
	local necromasteryModifier = "modifier_nevermore_necromastery"
	if keys.attacker == caster then return end -- Don't include creeps SF kills
	if caster:HasModifier(necromasteryModifier) then
		local necromastery = caster:FindAbilityByName("nevermore_necromastery")
		local storage = necromastery:GetSpecialValueFor("passive_deaths_per_soul")
		local limit = necromastery:GetSpecialValueFor("necromastery_max_souls")
		if caster:HasScepter() then limit = necromastery:GetSpecialValueFor("necromastery_max_souls_scepter") end
		local stacks = caster:FindModifierByName(necromasteryModifier)
		stacks.passiveKills = stacks.passiveKills or 0
		stacks.passiveKills = stacks.passiveKills + 1
		if stacks.passiveKills >= storage and stacks:GetStackCount() < limit then
			stacks:IncrementStackCount()
			stacks.passiveKills = 0
		end
	end
end