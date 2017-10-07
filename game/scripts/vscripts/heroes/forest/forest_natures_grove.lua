forest_natures_grove = class({})

function forest_natures_grove:GetAOERadius()
	return self:GetSpecialValueFor("grove_radius")
end

function forest_natures_grove:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local ability = self
	
	local groveRadius = self:GetSpecialValueFor("grove_radius")
	local treeRadius = self:GetSpecialValueFor("tree_radius") 
	local treeDuration = self:GetSpecialValueFor("duration") 
	local healDamage = self:GetSpecialValueFor("damage_over_time")
	local sleepDelay = self:GetSpecialValueFor("sleep_delay")
	local sleepDuration = self:GetSpecialValueFor("sleep_duration")
	local TICK_RATE = 0.34
	
	local treeCount = (math.pi * groveRadius * groveRadius) / (math.pi * treeRadius * treeRadius)
	
	local sleepFX = ParticleManager:CreateParticle( "particles/heroes/forest/forest_natures_grove_sleep.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( sleepFX, 0, target)
	ParticleManager:SetParticleControl( sleepFX, 1, Vector(groveRadius + treeRadius, groveRadius + treeRadius, groveRadius + treeRadius) )
	
	
	local treeFX = ParticleManager:CreateParticle( "particles/heroes/forest/forest_natures_grove_ring.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( treeFX, 0, target)
	ParticleManager:SetParticleControl( treeFX, 1, Vector(groveRadius + treeRadius, groveRadius + treeRadius, groveRadius + treeRadius) )

	Timers:CreateTimer(treeDuration, function()
		ParticleManager:DestroyParticle(sleepFX, false)
		ParticleManager:ReleaseParticleIndex(sleepFX)
		ParticleManager:DestroyParticle(treeFX, false)
		ParticleManager:ReleaseParticleIndex(treeFX)
	end)

	
	for i = 1, treeCount do
		local randomPosition = target + ActualRandomVector(groveRadius)
		CreateTempTree(randomPosition, treeDuration)
	end
	
	local sleptTargets = {}
	local internalTimer = 0
	AddFOWViewer(caster:GetTeam(), target, groveRadius + treeRadius, treeDuration, false)
	Timers:CreateTimer(function()
		local targets = caster:FindAllUnitsInRadius(target, groveRadius + treeRadius)
		for _, treeTarget in ipairs(targets) do
			if treeTarget:IsSameTeam(caster) then
				treeTarget:HealEvent(healDamage * TICK_RATE, ability, caster)
			else
				ability:DealDamage(caster, treeTarget, healDamage * TICK_RATE)
				if sleptTargets[treeTarget:entindex()] == nil then sleptTargets[treeTarget:entindex()] = 0 end
				if type(sleptTargets[treeTarget:entindex()]) == 'number' then
					sleptTargets[treeTarget:entindex()] = sleptTargets[treeTarget:entindex()] + TICK_RATE
					if sleptTargets[treeTarget:entindex()] >= sleepDelay then
						sleptTargets[treeTarget:entindex()] = false
						print(caster:GetName(), ability:GetName(), sleepDuration)
						treeTarget:AddNewModifier(caster, ability, "modifier_forest_natures_grove_sleep_debuff", {duration = sleepDuration})
						EmitSoundOn("Hero_Treant.Eyes.Cast", caster)
					end
				end
			end
		end
		if caster:HasTalent("forest_natures_grove_talent_1") then
			local oldRadius = groveRadius
			groveRadius = groveRadius + (groveRadius / treeDuration) * 0.5 * TICK_RATE
			local newTrees = math.ceil(((math.pi * groveRadius * groveRadius) - (math.pi * oldRadius * oldRadius)) / (math.pi * treeRadius * treeRadius))
			for i = 1, newTrees do
				local randomPosition = target + ActualRandomVector(groveRadius, oldRadius)
				CreateTempTree(randomPosition, treeDuration - internalTimer)
			end
			
			ParticleManager:DestroyParticle(treeFX, true)
			ParticleManager:ReleaseParticleIndex(treeFX)
		
			treeFX = ParticleManager:CreateParticle( "particles/heroes/forest/forest_natures_grove_ring.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl( treeFX, 0, target)
			ParticleManager:SetParticleControl( treeFX, 1, Vector(groveRadius + treeRadius, groveRadius + treeRadius, groveRadius + treeRadius) )
			AddFOWViewer(caster:GetTeam(), target, groveRadius + treeRadius, 0.35, false)
			
			ParticleManager:SetParticleControl( sleepFX, 1, Vector(groveRadius + treeRadius, groveRadius + treeRadius, groveRadius + treeRadius) )
				
			ResolveNPCPositions(target, groveRadius)
		end
		internalTimer = internalTimer + TICK_RATE
		if internalTimer < treeDuration then
			return TICK_RATE
		end
	end)
	
	ResolveNPCPositions(target, groveRadius)
end

modifier_forest_natures_grove_sleep_debuff = class({})
LinkLuaModifier("modifier_forest_natures_grove_sleep_debuff", "heroes/forest/forest_natures_grove.lua", 0)

function modifier_forest_natures_grove_sleep_debuff:OnCreated() print(self:GetDuration()) end

function modifier_forest_natures_grove_sleep_debuff:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
end

function modifier_forest_natures_grove_sleep_debuff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_forest_natures_grove_sleep_debuff:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.inflictor ~= self:GetAbility() then
	print("destroyed")
	self:Destroy() end
end

function modifier_forest_natures_grove_sleep_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_sleep.vpcf"
end

function modifier_forest_natures_grove_sleep_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end