function OctarineLifesteal(keys)
	local hero = keys.caster
    local dmg = keys.damage
	local ability = keys.ability
    local nHeroHeal = ability:GetSpecialValueFor("hero_lifesteal")
	PrintTable(keys)
    if keys.inflictor then
        heal_amount = dmg * nCreepHeal 
		print(dmg, heal_amount)
        if heal_amount > 0 and hero:GetHealth() ~= hero:GetMaxHealth() then
            local healthCalculated = hero:GetHealth() + heal_amount
            hero:Heal(heal_amount, ability)
            ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, hero)
        end
    end
end