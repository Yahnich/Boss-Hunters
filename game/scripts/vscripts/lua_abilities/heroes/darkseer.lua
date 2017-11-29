function AdamantiumShell(keys)
	local target = keys.target
	local ability = keys.ability
	local charges = ability:GetTalentSpecialValueFor("charges")
	local charges = ability:GetTalentSpecialValueFor("duration")
	if caster:HasTalent("special_bonus_unique_dark_seer_3") then
		local units = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_dark_seer_3"))
		for _,unit in pairs( units ) do
			ApplyDataDrivenModifier(caster, unit, "modifier_shell_protection", {duration = duration})
			unit.charges = charges
			unit:SetModifierStackCount( "modifier_shell_protection", ability, unit.charges )
			if unit.shield then ParticleManager:DestroyParticle(unit.shield,true) end
			unit.shield = ParticleManager:CreateParticle("particles/adamantium_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW , unit)
			ParticleManager:SetParticleControl(unit.shield, 0, unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(unit.shield, 1, Vector(150,150,150))
			ParticleManager:SetParticleControl(unit.shield, 2, unit:GetAbsOrigin())
		end
	else
		ApplyDataDrivenModifier(caster, target, "modifier_shell_protection", {duration = duration})
		target.charges = charges
		target:SetModifierStackCount( "modifier_shell_protection", ability, target.charges )
		if target.shield then ParticleManager:DestroyParticle(target.shield,true) end
		target.shield = ParticleManager:CreateParticle("particles/adamantium_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW , target)
		ParticleManager:SetParticleControl(target.shield, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(target.shield, 1, Vector(150,150,150))
		ParticleManager:SetParticleControl(target.shield, 2, target:GetAbsOrigin())
	end
end

function AdamantiumShellHit(keys)
	local target = keys.unit
	local ability = keys.ability
	target.charges = target.charges - 1
	if target.charges == 0 then
		target:RemoveModifierByName("modifier_shell_protection")
	else
		target:SetModifierStackCount( "modifier_shell_protection", ability, target.charges )
	end
end

function AdamantiumShellPop(keys)
	local target = keys.target
	local ability = keys.ability
	local radius =	ability:GetTalentSpecialValueFor("radius")
	local damage =	ability:GetTalentSpecialValueFor("magic_burst")
	local units = FindUnitsInRadius(keys.caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER , false)
    for _,unit in pairs( units ) do
        ApplyDamage({victim = unit, attacker = keys.caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
    end
	local explosion = ParticleManager:CreateParticle("particles/adamantium_burst.vpcf",PATTACH_POINT_FOLLOW,target)
	ParticleManager:DestroyParticle(target.shield,true)
	target.shield = nil 
	if not ability:IsActivated() then
		ability:SetActivated(true)
		ability:StartCooldown(ability:GetTrueCooldown())
	end
end

function AdamantiumShellScepter(keys)
	if keys.caster:HasScepter() then
		local caster = keys.caster
		local ability = keys.ability
		local distance_check = ability:GetTalentSpecialValueFor("distance_scepter")
		local position = caster:GetAbsOrigin()
		if caster.distance == nil then caster.distance = 0 end
		if caster.origin == nil then caster.origin = position end
		if caster.distance > distance_check then
			local vacuum = caster:FindAbilityByName("dark_seer_vacuum")
			if ability:IsStolen() then
				local darkseer = caster.target
				vacuum = darkseer:FindAbilityByName("dark_seer_vacuum")
			end
			caster:SetCursorPosition(position)
			vacuum:OnSpellStart()	
			caster.distance = 0
		else
			local distance = math.sqrt((caster.origin.x - position.x)^2 + (caster.origin.y - position.y)^2)
			caster.distance = caster.distance + distance
			caster.origin = position
		end
	end
end