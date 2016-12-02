function Devour_doom(keys)
    local modifierName = "iseating"
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local level = ability:GetLevel()-1
    local gold = ability:GetLevelSpecialValueFor("total_gold", level)
    local duration = ability:GetLevelSpecialValueFor("duration", level)
	
	local death = ability:GetLevelSpecialValueFor("death_perc", level)
    local kill_rand = math.random(100)
	local boss_curr = target:GetHealth()
	local boss_max = target:GetMaxHealth()
	local boss_perc = (boss_curr/boss_max)*100
	local mod_perc = death*(death/boss_perc) -- Scale chance up as HP goes down

    ability:ApplyDataDrivenModifier( caster, caster, modifierName, {duration = duration})
    target:SetModifierStackCount( modifierName, ability, 1)
    ability:StartCooldown(duration)
    local total_unit = 0
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if not unit:IsIllusion() then
            total_unit = total_unit + 1
        end
    end
    local gold_per_player = gold / total_unit
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if not unit:IsIllusion() then
            local totalgold = unit:GetGold() + gold_per_player
            unit:SetGold(0 , false)
            unit:SetGold(totalgold, true)
        end
    end
	if mod_perc >= kill_rand and boss_perc <= death  then
		local damage_table = {}
		damage_table.victim = target
		damage_table.attacker = caster
		damage_table.ability = ability
		damage_table.damage_type = DAMAGE_TYPE_PURE
		damage_table.damage = boss_curr +1
		ApplyDamage(damage_table)
	end
end

function DoomPurge( keys )
	local target = keys.target

	-- Purge
	local RemovePositiveBuffs = true
	local RemoveDebuffs = false
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = false
	local RemoveExceptions = false
	target:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
end


function DamageTick( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local duration = ability:GetSpecialValueFor("duration")
	if not ability.duration then 
		ability.duration = 0 -- ignore first damage tick
	else
		ability.duration = ability.duration + 1
	end
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability })
	if ability.duration >= duration then 
		target:RemoveModifierByName("modifier_doom_datadriven")
		ability.duration = nil -- this makes sure the first tick doens't count
	end
end

-- Stops the sound from playing
function StopSound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
end