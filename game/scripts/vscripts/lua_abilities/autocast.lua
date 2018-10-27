function AdamantiumShellAutoCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local unit = keys.target
	if ability:IsFullyCastable() and ability:GetAutoCastState() then
		caster:Interrupt()
		order = 
		{
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = unit:entindex(),
			AbilityIndex = ability:entindex(),
			Queue = true
		}
		ExecuteOrderFromTable(order)
	end
end