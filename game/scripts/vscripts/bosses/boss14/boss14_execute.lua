boss14_execute = class({})

function boss14_execute:OnAbilityPhaseStart()
	ParticleManager:FireParticle("particles/units/heroes/hero_axe/axe_culling_blade_boost.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), {[1] = self:GetCaster():GetAbsOrigin()})
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	return true
end

function boss14_execute:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	if target:TriggerSpellAbsorb(self) then return end
	
	self:DealDamage(caster, target, target:GetMaxHealth() * self:GetSpecialValueFor("execution_damage") / 100, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
	if target:GetHealth() == 0 then
		EmitSoundOn("Hero_Axe.Culling_Blade_Success", target)
		Timers:CreateTimer(0.1, function() self:EndCooldown() end)
	else
		EmitSoundOn("Hero_Axe.Culling_Blade_Fail", target)
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_POINT_FOLLOW, target, {[4] = target:GetAbsOrigin()})
end


function boss14_execute:NearestExecuteableTarget(range)
    local caster = self:GetCaster()
    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), range)

    local execuTable = {}
    local bloodLustStacks = 0
    local modifier = caster:FindModifierByName("modifier_boss14_bloodlust_passive")
    local executeDamage = self:GetSpecialValueFor("execution_damage") / 100
    if modifier then 
        local bloodLust = modifier:GetAbility()
        executeDamage = executeDamage * ( 1 + ( modifier:GetStackCount() * bloodLust:GetSpecialValueFor("damage_amp") )/100 )
    end
    for _,enemy in ipairs(enemies) do
        if enemy:GetHealth() < enemy:GetMaxHealth() * executeDamage then table.insert(execuTable, enemy) end
    end
    local minRange = range or self:GetTrueCastRange()
    for _, executable in ipairs(execuTable) do
        local distanceToEnemy = CalculateDistance(caster, executable)
        if executable:IsAlive() and distanceToEnemy < minRange then
            minRange = distanceToEnemy
            target = executable
        end
    end
    return target
end