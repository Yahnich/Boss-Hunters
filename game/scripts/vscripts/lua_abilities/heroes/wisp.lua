function sacrifice(keys)
    local caster = keys.caster

    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if not unit:IsAlive() and caster:HasScepter() == true then
            local origin = unit:GetOrigin()
			unit:RespawnHero(false, false)
			unit:SetOrigin(origin)
        end
        if unit:IsAlive() then
            unit:SetHealth( unit:GetMaxHealth() )
            unit:SetMana( unit:GetMaxMana() )
        end
    end
    caster:ForceKill(true)
end