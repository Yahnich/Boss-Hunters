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
	local mana_drain = ability:GetLevelSpecialValueFor("fiend_grip_mana_drain", (ability:GetLevel() -1)) / 100
	if caster:HasScepter() then
		mana_drain = ability:GetLevelSpecialValueFor("fiend_grip_mana_drain_scepter", (ability:GetLevel() -1)) / 100
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
	local duration = ability:GetLevelSpecialValueFor("fiend_grip_duration", (ability:GetLevel() -1))
	if caster:HasScepter() then
		damage = ability:GetLevelSpecialValueFor("fiend_grip_damage_scepter", (ability:GetLevel() -1))
	end
	ApplyDamage({victim = target, attacker = caster, damage = damage/duration, damage_type = ability:GetAbilityDamageType(), ability = ability})
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
	local duration2 = ability2:GetLevelSpecialValueFor("duration", (ability2:GetLevel() -1))
	if keys.ability:IsChanneling() and keys.target == keys.caster and not keys.ability:IsStolen() then
		caster:SetCursorCastTarget(attacker)
		ability1:OnSpellStart()
		caster:SetCursorCastTarget(attacker)
		ability2:OnSpellStart()
	if keys.ability:IsStolen() then
		attacker:AddNewModifier(attacker, ability1, "modifier_bane_enfeeble", {duration = duration1})
		attacker:AddNewModifier(attacker, ability2, "modifier_bane_nightmare", {duration = duration2})
	end
	end
end