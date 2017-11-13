function haste_armor(keys)
    local caster = keys.caster
    local ability = keys.ability
    ability:ApplyDataDrivenModifier(caster, caster, "haste_armor_bonus", {})
	local haste_armor = ParticleManager:CreateParticle("particles/spirit_breaker_haste_armor.vpcf", PATTACH_POINT_FOLLOW , caster)
		ParticleManager:SetParticleControl(haste_armor, 0, caster:GetAbsOrigin())
    Timers:CreateTimer(0.03,function()
        if caster:IsAlive() then
            if caster:GetIdealSpeed() ~= caster:GetModifierStackCount( "haste_armor_bonus", ability ) then
                caster:SetModifierStackCount( "haste_armor_bonus", ability, caster:GetIdealSpeed() )
				ParticleManager:SetParticleControl(haste_armor, 1, Vector(caster:GetIdealSpeed(), 0, 0))
            end
            return 0.3
        end
    end)
end

function refresh_haste_armor(keys)
    local caster = keys.caster
    local ability = keys.ability
    ability:ApplyDataDrivenModifier(caster, caster, "haste_armor_bonus", {})
    caster:SetModifierStackCount( "haste_armor_bonus", ability, caster:GetIdealSpeed() )
end

function ground_smash(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    local radius = ability:GetTalentSpecialValueFor("radius")
    local vRadius = Vector(radius,0,0)
    local damage = ability:GetTalentSpecialValueFor("damage")

    local damage_type = DAMAGE_TYPE_MAGICAL

    particle_ground = ParticleManager:CreateParticle("particles/ground_smash_aoe.vpcf", PATTACH_ABSORIGIN  , keys.caster)
    ParticleManager:SetParticleControl(particle_ground, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_ground, 1, vRadius) --radius
    ParticleManager:SetParticleControl(particle_ground, 2, Vector(radius/2000,0,0)) --ammount of particle
    ParticleManager:SetParticleControl(particle_ground, 3, Vector(radius/10,0,0)) --size of particle 
    Timers:CreateTimer(2.5,function()
        ParticleManager:DestroyParticle(particle_ground,true)
    end)

    local nearbyUnits = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
	if nearbyUnits ~= nil then
		ability:ApplyDataDrivenModifier(caster,caster,"bonus_ground_smash",{})
	end
    for _,unit in pairs(nearbyUnits) do
        if unit ~= keys.caster then
                if unit:GetUnitName() ~="npc_dota_courier" and unit:GetUnitName()~="npc_dota_flying_courier" then
                    local damageTableAoe = {victim = unit,
                                attacker = caster,
                                damage = damage,
                                damage_type = damage_type,
                                ability = keys.ability,
                                }
                    ApplyDamage(damageTableAoe)
                    ability:ApplyDataDrivenModifier(caster,unit,"slow_ground_smash",{})
                end
        end
    end
end