if not VectorTarget then 
	VectorTarget = class({})
end

CANCEL_EVENT = {[DOTA_UNIT_ORDER_MOVE_TO_POSITION] = true,
				[DOTA_UNIT_ORDER_MOVE_TO_TARGET] = true,
				[DOTA_UNIT_ORDER_ATTACK_MOVE] = true,
				[DOTA_UNIT_ORDER_ATTACK_TARGET] = true,
				[DOTA_UNIT_ORDER_CAST_TARGET] = true,
				[DOTA_UNIT_ORDER_CAST_TARGET_TREE] = true,
				[DOTA_UNIT_ORDER_CAST_NO_TARGET] = true,
				[DOTA_UNIT_ORDER_HOLD_POSITION] = true,
				[DOTA_UNIT_ORDER_DROP_ITEM] = true,
				[DOTA_UNIT_ORDER_GIVE_ITEM] = true,
				[DOTA_UNIT_ORDER_PICKUP_ITEM] = true,
				[DOTA_UNIT_ORDER_PICKUP_RUNE] = true,
				[DOTA_UNIT_ORDER_STOP] = true,
				[DOTA_UNIT_ORDER_MOVE_TO_DIRECTION] = true,
				[DOTA_UNIT_ORDER_PATROL] = true,
				}

function VectorTarget:OrderFilter(event)
	if not event.units["0"] then return true end
	local unit = EntIndexToHScript(event.units["0"])
	local ability = EntIndexToHScript( event.entindex_ability )
	if ability and ability.GetBehavior and ability:GetBehavior() and HasBit( ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING ) then
		if event.order_type == DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION then
			ability.vectorTargetPosition2 = Vector( event.position_x, event.position_y, 0 )
		end
		if event.order_type == DOTA_UNIT_ORDER_CAST_POSITION then
			ability.vectorTargetPosition = Vector( event.position_x, event.position_y, 0 )
			local position = ability:GetVectorPosition()
			local direction = CalculateDirection( ability.vectorTargetPosition2, position )
			direction = Vector(direction.x, direction.y, 0):Normalized()
			ability.vectorTargetDirection = direction
			local function OverrideSpellStart(self, position, direction)
				self:OnVectorCastStart(position, direction)
			end
			ability.OnSpellStart = function(self) return OverrideSpellStart(self, position, direction) end
		end
	end
	return true
end

function CDOTABaseAbility:IsVectorTargeting()
	return false
end

function CDOTABaseAbility:GetVectorTargetRange()
	return 800
end 

function CDOTABaseAbility:GetVectorTargetStartRadius()
	return 125
end 

function CDOTABaseAbility:GetVectorTargetEndRadius()
	return self:GetVectorTargetStartRadius()
end 

function CDOTABaseAbility:GetVectorPosition()
	return self.vectorTargetPosition
end 

function CDOTABaseAbility:GetVector2Position() -- world click
	return self.vectorTargetPosition2
end 

function CDOTABaseAbility:GetVectorDirection()
	return self.vectorTargetDirection
end 

function CDOTABaseAbility:OnVectorCastStart(vStartLocation, vDirection)
	print("Vector Cast")
end