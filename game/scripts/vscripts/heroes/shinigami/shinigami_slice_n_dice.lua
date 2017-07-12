shinigami_slice_n_dice = class({})

function shinigami_slice_n_dice:OnSpellStart()
	local caster = self:GetCaster()
	local endPos = self:GetCursorPosition()
	local startPos = caster:GetAbsOrigin()
	local units = FindUnitsInLine(caster:GetTeamNumber(), startPos, endPos, nil, self:GetSpecialValueFor("search_width"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
	local orderedUnits = self:FindPathToObjective(startPos, units, endPos)
	local speed = self:GetSpecialValueFor("speed")
	
	local pathNr = 1
	caster:AddNewModifier(caster, self, "modifier_slice_n_dice_invuln", {})
	
	local strike = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_end.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(strike, 0, startPos)
	ParticleManager:ReleaseParticleIndex(strike)
	
	local distanceTravelled = 0
	
	local min_attacks = #orderedUnits
	if caster:HasTalent("shinigami_slice_n_dice_talent_1") then
		if min_attacks < caster:FindTalentValue("shinigami_slice_n_dice_talent_1") then
			min_attacks = caster:FindTalentValue("shinigami_slice_n_dice_talent_1")
		end
	end
	
	local attacks_per_unit = math.ceil(min_attacks / #orderedUnits)
	
	EmitSoundOn("Hero_PhantomAssassin.Strike.Start", caster)
	Timers:CreateTimer(FrameTime(), function()
		EmitSoundOn("Hero_PhantomAssassin.Strike.End", target)
		ProjectileManager:ProjectileDodge(caster)
		if orderedUnits[pathNr] then
			if CalculateDistance(caster, orderedUnits[pathNr]) > speed * FrameTime() then
				caster:SetAbsOrigin( caster:GetAbsOrigin() + CalculateDirection(orderedUnits[pathNr], caster) * speed * FrameTime() )
			else
				caster:SetAbsOrigin( caster:GetAbsOrigin() + CalculateDirection(orderedUnits[pathNr], caster) * speed * FrameTime() )
				for i = 1, attacks_per_unit do
					caster:PerformAbilityAttack(orderedUnits[pathNr], true)
				
					local attack = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_attack_blink_blur.vpcf", PATTACH_ABSORIGIN, orderedUnits[pathNr])
					ParticleManager:SetParticleControl(attack, 0, orderedUnits[pathNr]:GetAbsOrigin())
					ParticleManager:SetParticleControl(attack, 1, orderedUnits[pathNr]:GetAbsOrigin())
					ParticleManager:ReleaseParticleIndex(attack)
					
					EmitSoundOn("Hero_PhantomAssassin.Attack", orderedUnits[pathNr])
					EmitSoundOn("Hero_PhantomAssassin.Attack.Rip", orderedUnits[pathNr])
				end
				pathNr = pathNr + 1
			end
		else
			distanceTravelled = (distanceTravelled or 0) + (speed * FrameTime())+1
			if CalculateDistance(caster, endPos) > (speed * FrameTime())+1 and (distanceTravelled < self:GetSpecialValueFor("max_distance")) then
				caster:SetAbsOrigin( caster:GetAbsOrigin() + CalculateDirection(endPos, caster) * speed * FrameTime() )
			else
				caster:SetAbsOrigin( caster:GetAbsOrigin() + CalculateDirection(endPos, caster) * speed * FrameTime() )
				EmitSoundOn("Hero_PhantomAssassin.Strike.Start", caster)
				FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)
				caster:RemoveModifierByName("modifier_slice_n_dice_invuln")
				return nil
			end
		end
		return FrameTime()
	end)
end

function shinigami_slice_n_dice:FindPathToObjective(startPos, units, endPos)
	local orderedPath = {}
	local sortTable = {}
	for _, unit in pairs(units) do
		table.insert(sortTable, unit)
	end
	local referencePoint = self:GetCaster():GetAbsOrigin()
	while #sortTable > 0 do
		local nearest = self:NearestUnitInTable(sortTable, referencePoint)
		table.insert(orderedPath, nearest)
		referencePoint = nearest:GetAbsOrigin()
		table.removeval(sortTable, nearest)
	end
	return orderedPath
end

function shinigami_slice_n_dice:NearestUnitInTable(unitTable, referencePoint)
	local nearestEnemy
	local distance
	for _, unit in pairs(unitTable) do
		local newDist = CalculateDistance(unit, referencePoint)
		if not distance or newDist < distance then 
			nearestEnemy = unit
			distance = newDist
		end
	end
	return nearestEnemy
end

modifier_slice_n_dice_invuln = class({})
LinkLuaModifier("modifier_slice_n_dice_invuln", "heroes/shinigami/shinigami_slice_n_dice.lua", 0)


function modifier_slice_n_dice_invuln:CheckState()
	local state = { [MODIFIER_STATE_ATTACK_IMMUNE] = true,
					[MODIFIER_STATE_DISARMED] = true,
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true}
	return state
end

function modifier_slice_n_dice_invuln:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun_blur.vpcf"
end