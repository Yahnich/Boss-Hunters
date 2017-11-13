function MidasPunch(keys)
	local caster = keys.caster
    local ability = keys.ability
	local target = keys.target
	
	local damage = ability:GetTalentSpecialValueFor("base_dmg")
	local bonusdamage = ability:GetTalentSpecialValueFor("net_worth_bonus_dmg") / 100
	local goldDamage = PlayerResource:GetTotalGoldSpent(caster:GetPlayerID()) * bonusdamage
	local totDmg = damage + goldDamage
	print(damage, goldDamage)
	ApplyDamage({ victim = target, attacker = caster, damage = totDmg, damage_type = ability:GetAbilityDamageType(), ability = ability })
	goldFountain = ParticleManager:CreateParticle("particles/econ/items/necrolyte/necrophos_sullen_gold/necro_sullen_pulse_enemy_explosion_gold.vpcf", PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(goldFountain, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(goldFountain, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end

function AlchGreed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local bonus_gold = keys.gold_on_hit
	local excess = bonus_gold - math.floor(bonus_gold)
	if caster:IsIllusion() then
		local player = caster:GetPlayerOwnerID()
		caster = PlayerResource:GetSelectedHeroEntity(player)
	end
	if excess > 0 then
		caster.greedRemainder = caster.greedRemainder or 0
		caster.greedRemainder = caster.greedRemainder + excess
	end
	bonus_gold = math.floor(bonus_gold)
	if caster.greedRemainder >= 1 then
		bonus_gold = bonus_gold + caster.greedRemainder
		caster.greedRemainder = 0
	end
	local level = ability:GetLevel()-1
	local cooldown = ability:GetCooldown(level)*get_octarine_multiplier(caster)
    if ability:IsCooldownReady() then
        local totalgold = caster:GetGold() + bonus_gold
        caster:SetGold(0 , false)
        caster:SetGold(totalgold, true)
		if caster:HasScepter() and caster:IsRealHero() then
			for _,hero in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
				if hero:IsRealHero() then
					local gold = hero:GetGold() + bonus_gold
					hero:SetGold(0 , false)
					hero:SetGold(gold , true)
				end
			end
		end
		if keys.caster:IsIllusion() then
			print("triggered")
			ability = keys.caster:FindAbilityByName("alchemist_greed_ebf")
			ability:StartCooldown(cooldown)
		else 
			ability:StartCooldown(cooldown)	
		end
    end
end


function AlchUltimate( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local new_bat = ability:GetTalentSpecialValueFor("base_attack_time")
	
	caster:RemoveModifierByName("modifier_chemical_rage_bat")
	local bat = caster:GetBaseAttackTime()
	if bat >= new_bat then
		ability:ApplyDataDrivenModifier(caster, caster, ("modifier_chemical_rage_bat"), {})
	end
end