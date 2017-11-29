function FiendsGripStopSound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
end

--[[Fiends grip mana drain
	Author: chrislotix, Pizzalol
	Date: 11.1.2015.
	Changed: 11.03.2015.
	Reason: Improved the code]]
function ManaDrain( keys )	
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsChanneling() then
		target:RemoveModifierByName("modifier_fiends_grip_datadriven")
	end
	local mana_drain = ability:GetTalentSpecialValueFor("fiend_grip_mana_drain") / 100
	if caster:HasScepter() then
		mana_drain = ability:GetTalentSpecialValueFor("fiend_grip_mana_drain_scepter") / 100
	end
	
	if target:GetMaxMana() then
		local max_mana_drain = target:GetMaxMana() * mana_drain
		local current_mana = target:GetMana()

		-- Calculates the amount of mana to be given to the caster
		if current_mana >= max_mana_drain then
			caster:GiveMana(max_mana_drain)
		else
			caster:GiveMana(current_mana)
		end

		target:ReduceMana(max_mana_drain)
	end
end

--[[Author: Pizzalol
	Date: 11.03.2015.
	Reveals the target if its invisible]]
function FiendsGripInvisCheck( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier
	if target:IsInvisible() then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {})
	end
end

function ApplyGripDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = keys.damage
	local duration = ability:GetTalentSpecialValueFor("fiend_grip_duration")
	if caster:HasScepter() then
		damage = ability:GetTalentSpecialValueFor("fiend_grip_damage_scepter")
	end
	ApplyDamage({victim = target, attacker = caster, damage = damage/duration, damage_type = ability:GetAbilityDamageType(), ability = ability})
	if not target:IsAlive() then
		ability:EndChannel(true)
		caster:Interrupt()
	end
end

function ScepterCheck(keys)
	local caster = keys.caster
	if caster:HasScepter() then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_scepter_channeling", {})
	elseif not caster:HasScepter() and caster:HasModifier("modifier_scepter_channeling") then
		caster:RemoveModifierByName("modifier_scepter_channeling")
	end
end

function ScepterNightmare(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local ability1 = caster:GetAbilityByIndex(0)
	local ability2 = caster:GetAbilityByIndex(2)
	if keys.ability:IsStolen() then
		local bane = caster.target
		ability1 = bane:GetAbilityByIndex(0)
		ability2 = bane:GetAbilityByIndex(2)
	end
	
	local duration1 = ability1:GetDuration()
	local duration2 = ability2:GetTalentSpecialValueFor("duration")
	if keys.ability:IsChanneling() and keys.target == keys.caster and not keys.ability:IsStolen() then
		caster:SetCursorCastTarget(attacker)
		ability1:OnSpellStart()
		caster:SetCursorCastTarget(attacker)
		ability2:OnSpellStart()
	elseif keys.ability:IsStolen() then
		attacker:AddNewModifier(attacker, ability1, "modifier_bane_enfeeble", {duration = duration1})
		attacker:AddNewModifier(attacker, ability2, "modifier_bane_nightmare", {duration = duration2})
	end
end

function EnfeebleFilter(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	local damageReduction = math.abs(ability:GetTalentSpecialValueFor("enfeeble_attack_reduction"))
	local damageReductionAlt = math.abs( ability:GetTalentSpecialValueFor("enfeeble_attack_reduction_alt") * target:GetAverageBaseDamage() / 100 )
	print(damageReduction, damageReductionAlt)
	if damageReduction > damageReductionAlt then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_mass_enfeeble", {duration = ability:GetDuration()})
	else
		ability:ApplyDataDrivenModifier(caster, target, "modifier_mass_enfeeble_alt", {duration = ability:GetDuration()})
	end
end

function BrainSapInit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	ability.dmgCount = 0
end

function BrainSapDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	ability.dmgCount = ability.dmgCount + 1
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetTalentSpecialValueFor("tooltip_brain_sap_heal_amt"), damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function BrainSapHeal(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	local pctHeal = ability:GetTalentSpecialValueFor("pct_heal")
	local dmgHeal = ability:GetTalentSpecialValueFor("tooltip_brain_sap_heal_amt")
	 
	target:HealEvent(target:GetMaxHealth() * pctHeal + ability.dmgCount * dmgHeal, ability, caster)
end

function StartNightmare(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local duration = ability:GetTalentSpecialValueFor("duration")
	ability:ApplyDataDrivenModifier(caster, target, "modifier_nightmare_datadriven", {duration = duration})
	ability:StartDelayedCooldown(duration)
end

function NightmareStop(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	StopSoundEvent("Hero_Bane.Nightmare.Loop", target)
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
	ability:EndDelayedCooldown()
end