function SummonWolves( keys )
	print("lul")
    local caster = keys.caster
	local ability = keys.ability
    local targets = caster.wolves or {}
    for _,unit in pairs(targets) do 
        if unit and IsValidEntity(unit) then
            unit:ForceKill(true)
            end
        end
    caster.wolves = {}
    local origin = caster:GetAbsOrigin()
	for i=1, ability:GetTalentSpecialValueFor("wolf_count") do
		local angPoint = QAngle(0, ((-1)^i)*30, 0)
		local fv = caster:GetForwardVector()*((-1)^( math.ceil( i/2 ) -1 ) )
		local distance = ability:GetTalentSpecialValueFor("spawn_distance")
		local index = ability:GetTalentSpecialValueFor("wolf_index")
		local spawnOrigin = origin + fv * distance
		local spawnPoint = RotatePosition(origin, angPoint, spawnOrigin)
		-- position handling
		local wolf = CreateUnitByName( "npc_dota_lycan_wolf1" , spawnPoint, true, caster, caster, caster:GetTeam() )
		wolf:SetForwardVector(caster:GetForwardVector())
		wolf:SetOwner(caster)
		wolf:SetControllableByPlayer(caster:GetPlayerID(), true)
		wolf:AddNewModifier(caster, ability, "modifier_kill", {duration = ability:GetTalentSpecialValueFor("wolf_duration")})
		ability:ApplyDataDrivenModifier(caster, wolf, "modifier_summon_wolves_datadriven", {duration = ability:GetTalentSpecialValueFor("wolf_duration")})
		table.insert(caster.wolves, wolf)
		-- health handling
		local wolfHP = ability:GetTalentSpecialValueFor("wolf_hp")
		local wolfDamage = ability:GetTalentSpecialValueFor("wolf_damage")
		local wolfBAT = ability:GetTalentSpecialValueFor("wolf_bat")
		wolf:SetMaxHealth(wolfHP)
		wolf:SetBaseMaxHealth(wolfHP)
		wolf:SetHealth(wolf:GetMaxHealth())
		
		wolf:SetModelScale(0.8 + (ability:GetLevel()/2)/10)
		
		wolf:SetAverageBaseDamage(wolfDamage, 15)
		wolf:SetBaseAttackTime(wolfBAT)
	end
end