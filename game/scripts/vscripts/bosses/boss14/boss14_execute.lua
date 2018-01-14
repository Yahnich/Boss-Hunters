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
	
	self:DealDamage(caster, target, target:GetMaxHealth() * self:GetSpecialValueFor("execution_damage") / 100)
	if target:GetHealth() == 0 then
		EmitSoundOn("Hero_Axe.Culling_Blade_Success", target)
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
	if modifier then  bloodLustStacks = modifier:GetStackCount() / 100 end
	for _,enemy in ipairs(enemies) do
		if enemy:GetHealthPercent() < enemy:GetMaxHealth() * self:GetSpecialValueFor("execution_damage") * (1 + bloodLustStacks) then table.insert(execuTable, enemy) end
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