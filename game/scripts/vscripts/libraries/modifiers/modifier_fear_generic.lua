modifier_fear_generic = class({})
LinkLuaModifier("modifier_fear_generic", "libraries/modifiers/modifier_fear_generic", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_fear_generic:OnCreated()
		self:OnIntervalThink()
		self:StartIntervalThink(0.5)
	end
	
	function modifier_fear_generic:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local newPos
		local checkPos
		if caster == parent then
			for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), -1, {order = FIND_CLOSEST} ) ) do
				caster = enemy
				break
			end
		end
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), parent:GetIdealSpeed() * 2, {order = FIND_CLOSEST} ) ) do
			checkPos = (( checkPos or enemy:GetAbsOrigin() ) + enemy:GetAbsOrigin() )/2
			break
		end
		if caster == parent then
			return
		end
		if not checkPos then
			return
		end
		if RoundManager.spawnPositions then
			for _, possiblePos in ipairs( RoundManager.spawnPositions ) do
				if not newPos or CalculateDistance( checkPos, possiblePos ) > CalculateDistance( checkPos, newPos )  then
					local secondCheck = parent:GetAbsOrigin() + CalculateDirection( parent, checkPos ) * parent:GetIdealSpeed() * 0.5 -- we want the parent to move away when possible, cull movement towards the enemies
					if GridNav:FindPathLength( secondCheck, possiblePos ) < GridNav:FindPathLength( parent:GetAbsOrigin(), possiblePos ) then
						newPos = possiblePos
					end
				end
			end
		end
		if not newPos then
			local direction = CalculateDirection(parent, caster)
			local oldPos = parent:GetAbsOrigin()
			local newPos = oldPos + direction * self:GetParent():GetIdealSpeed() * 0.5
			if not GridNav:CanFindPath(oldPos, newPos) then
				local iteration = 50
				local angleCheck = 360 / iteration
				while not GridNav:CanFindPath(oldPos, newPos) and iteration > 0 do
					local newDirection1 = RotateVector2D(direction, ToRadians( angleCheck * (51-iteration) ) )
					local newDirection2 = -RotateVector2D(direction, ToRadians( angleCheck * (51-iteration) ) )
					local newPos1 = oldPos + newDirection1 * parent:GetIdealSpeed() * 0.5
					local newPos2 = oldPos + newDirection2 * parent:GetIdealSpeed() * 0.5
					newPos = newPos1
					if GridNav:CanFindPath(oldPos, newPos2) and GridNav:FindPathLength( oldPos, newPos2 ) < GridNav:FindPathLength( oldPos, newPos1 ) and CalculateDistance(caster, newPos2 ) > CalculateDistance(caster, newPos1 ) then
						newPos = newPos2
					end
					iteration = iteration - 1
				end
			end
		end
		if CalculateDistance( caster, self.oldPos or caster ) < CalculateDistance( caster, newPos or caster ) then
			self:GetParent():MoveToPosition(newPos)
			self.oldPos = newPos
		end
	end
end

function modifier_fear_generic:GetEffectName()
	return "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf"
end

function modifier_fear_generic:GetStatusEffectName()
	return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

function modifier_fear_generic:StatusEffectPriority()
	return 10
end

function modifier_fear_generic:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_PROVIDES_VISION] = true,
			}
end