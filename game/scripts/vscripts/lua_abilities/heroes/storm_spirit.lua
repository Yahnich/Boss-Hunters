function overload_check_order( keys )
	local caster = keys.caster
	local ability = keys.ability
	local usedability = keys.event_ability
	if (usedability:GetCooldown(-1) <= 0 or usedability:GetName() == "item_shadow_amulet") and not (usedability:GetName() == "storm_spirit_static_remnant" or usedability:GetName() == "storm_spirit_ball_lightning") then return end
	local stacks = caster:GetModifierStackCount("modifier_overload_damage_datadriven",caster)
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_overload_damage_datadriven", {} )
	local adder = 1
	if caster:HasTalent("special_bonus_unique_storm_spirit") then adder = 2 end
	caster:SetModifierStackCount("modifier_overload_damage_datadriven", caster, stacks+adder)
end

function overload_reducestacks( keys )
	local caster = keys.caster
	local ability = keys.ability
	if keys.target:IsMagicImmune() then return end
	local stacks = caster:GetModifierStackCount("modifier_overload_damage_datadriven",caster)
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_overload_damage_datadriven", {} )
	caster:SetModifierStackCount("modifier_overload_damage_datadriven", caster, stacks-1)
	if stacks-1 < 1 then
		caster:RemoveModifierByName("modifier_overload_damage_datadriven")
	end
end

function overload_damage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function DynamoTick( keys )
	local caster = keys.caster
	local ability = keys.ability
	local overload = caster:FindAbilityByName("storm_spirit_overload_ebf")
	local stacks = caster:GetModifierStackCount("modifier_overload_damage_datadriven",caster)
	overload:ApplyDataDrivenModifier( caster, caster, "modifier_overload_damage_datadriven", {} )
	local adder = 1
	if caster:HasTalent("special_bonus_unique_storm_spirit") then adder = 2 end
	caster:SetModifierStackCount("modifier_overload_damage_datadriven", caster, stacks+adder)
	if caster:GetMana() < ability:GetManaCost(-1) then
		ability:OnToggle()
	end
end

function RefreshDynamo( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("storm_spirit_electric_dynamo_active") and ability:GetToggleState() == 1 then
		caster:RemoveModifierByName("storm_spirit_electric_dynamo_active")
		ability:ApplyDataDrivenModifier( caster, caster, "storm_spirit_electric_dynamo_active", {} )
	end
end

function HandleDynamo( keys )
	local caster = keys.caster
	local ability = keys.ability
	local tick = ability:GetTalentSpecialValueFor("tick_rate")
	if ability:GetToggleState() == true then
		ability:ApplyDataDrivenModifier(caster, caster, "storm_spirit_electric_dynamo_active", {} )
		local stacks = caster:GetModifierStackCount("modifier_overload_damage_datadriven",caster)
		local adder = 1
		if caster:HasTalent("special_bonus_unique_storm_spirit") then adder = 2 end
		caster:SetModifierStackCount("modifier_overload_damage_datadriven", caster, stacks+adder)
		ability:StartCooldown(tick)
	else
		caster:RemoveModifierByName("storm_spirit_electric_dynamo_active")
		ability:StartCooldown(tick)
	end
end