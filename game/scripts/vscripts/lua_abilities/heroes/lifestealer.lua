function IncreaseStackCount( keys )
    -- Variables
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local modifier_name = keys.modifier_counter_name
    local dur = ability:GetDuration()

    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)

    -- if the unit does not already have the counter modifier we apply it with a stackcount of 1
    -- else we increase the stack and refresh the counters duration
    if not modifier then
        ability:ApplyDataDrivenModifier(caster, target, modifier_name, {duration=dur})
        target:SetModifierStackCount(modifier_name, caster, 1)
    else
        modifier:IncrementStackCount()
        modifier:SetDuration(dur, true)
    end
end

--[[
    Author: Bude
    Date: 30.09.2015
    Decreases stack count on the visual modifier 
    This is called whenever the debuff modifier runs out
]]
function DecreaseStackCount(keys)
    --Variables
    local caster = keys.caster
    local target = keys.target
    local modifier_name = keys.modifier_counter_name
    local count = target:GetModifierStackCount(modifier_name, caster)
	local modifier = target:FindModifierByName(modifier_name)
	if modifier then
		modifier:DecrementStackCount()
		if modifier:GetStackCount() == 0 then
			target:RemoveModifierByName(modifier_name)
		end
	end
end

function HealDamage(keys)
	local caster = keys.caster
    local target = keys.target
	local ability = keys.ability
    local modifier_name = keys.modifier_counter_name
	
	local heal = ability:GetAbilityDamage() * ability:GetSpecialValueFor("heal")/100

	caster:Heal(heal, caster)
	ApplyDamage({ victim = target, attacker = caster, damage = ability:GetAbilityDamage()/get_aether_multiplier(caster), damage_type = ability:GetAbilityDamageType(), ability = ability })
	
end