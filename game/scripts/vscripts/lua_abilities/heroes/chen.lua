require("libraries/utility")

function DevilBless(keys)
    local modifierName = "Modifier_bless_subtle"
    local caster = keys.caster
    local ability = keys.ability
	-- PREVENT STACKING
	caster:RemoveModifierByName(modifierName)
	caster:SetModifierStackCount( modifierName, ability, 0)
	
    local damagebonus = caster:GetAverageBaseDamage() 
    local percent = ability:GetTalentSpecialValueFor("damage_percent")
    local damage = damagebonus*percent*0.01
	
    ability:ApplyDataDrivenModifier( caster, caster, modifierName, {duration = keys.duration} )
    caster:SetModifierStackCount( modifierName, ability, damage)
end

function RNDamage(keys)
	local mindmg = keys.damagemin
	local maxdmg = keys.damagemax * math.random()
	print("trigger")
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = mindmg + maxdmg, damage_type = keys.ability:GetAbilityDamageType(), ability = keys.ability})
end

function PureBless(keys)
    local modifierName = "Modifier_bless_subtle"
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
	-- PREVENT STACKING
	caster:RemoveModifierByName(modifierName)
	caster:SetModifierStackCount( modifierName, ability, 0)
	
    local damagebonus = caster:GetAverageBaseDamage()
    local percent = ability:GetTalentSpecialValueFor("damage_percent")
    local damage = damagebonus*percent*0.01

    ability:ApplyDataDrivenModifier( caster, target, modifierName, {duration = keys.duration} )
    target:SetModifierStackCount( modifierName, ability, damage)
end

function TestOfFaithHeal(keys)
	local caster = keys.caster
	local target = keys.target
	local maxheal = keys.ability:GetTalentSpecialValueFor("max_heal")
	local minheal = keys.ability:GetTalentSpecialValueFor("min_heal")
	local heal = target:GetMaxHealth()*(math.random(minheal,maxheal))/100
	target:Heal(heal,keys.ability)
end

function PenitenceDamageAmp(keys)
	local caster = keys.caster
	local target = keys.unit
	local amp = keys.ability:GetTalentSpecialValueFor("bonus_damage_taken")/100
	local multiplier = get_aether_multiplier(caster)
	local filter = ((caster:GetIntellect()/1600 + multiplier))
	if keys.attacker == caster then
		ApplyDamage({victim = target, attacker = target, damage = keys.damage*amp/filter, damage_type = DAMAGE_TYPE_PURE, ability = keys.ability})
	end
end

function ChenBuff(keys)
	local caster = keys.caster
	if not keys.ability:IsHidden() and not caster:HasModifier(keys.modifier) then
		keys.ability:ApplyDataDrivenModifier(caster,caster,keys.modifier, nil)
	elseif keys.ability:IsHidden() then
		caster:RemoveModifierByName(keys.modifier)
	end
end

function Chen_Swap(keys)
	local caster = keys.caster
	local mainAbilityName1 = caster:GetAbilityByIndex(0):GetName()
	local mainAbilityName2 = caster:GetAbilityByIndex(1):GetName()
	local mainAbilityName3 = caster:GetAbilityByIndex(2):GetName()
	local mainAbilityName4 = caster:GetAbilityByIndex(3):GetName()
	local mainAbilityName5 = caster:GetAbilityByIndex(4):GetName()
	caster:SwapAbilities( mainAbilityName1, keys.ability_name1, false, true )
	caster:SwapAbilities( mainAbilityName2, keys.ability_name2, false, true )
	caster:SwapAbilities( mainAbilityName3, keys.ability_name3, false, true )
	caster:SwapAbilities( mainAbilityName4, keys.ability_name4, false, true )
	caster:SwapAbilities( mainAbilityName5, keys.ability_name5, false, true )
	local caster5 = caster:FindAbilityByName(mainAbilityName5)
	caster:FindAbilityByName(keys.ability_name5):StartCooldown(caster5:GetCooldownTimeRemaining())
end

function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end