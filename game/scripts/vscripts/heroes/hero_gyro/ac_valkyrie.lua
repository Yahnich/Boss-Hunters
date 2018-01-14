LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )

function valkyrie( keys )
	local caster = keys.caster
	local ability = keys.ability

	local speed = ability:GetLevelSpecialValueFor("speed", ability:GetLevel() -1)/100
	local casterSpeed = caster:GetBaseMoveSpeed() + caster:GetBaseMoveSpeed()*speed
	--print("Speed: " .. casterSpeed)
	local distance = (caster:GetAbsOrigin() - ability:GetCursorPosition()):Length2D()
	--local distanceNormal = (caster:GetAbsOrigin() - ability:GetCursorPosition()):Normalized()
	--print("Distance: " .. distance)
	local duration = distance/casterSpeed
	--print("Duration: " .. duration)

	caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_valkyrie", { duration = duration })
	caster:MoveToPosition(ability:GetCursorPosition())
end