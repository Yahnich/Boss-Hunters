function on_spawned(keys)
	local caster = keys.caster
	local ability = keys.ability

	Timers:CreateTimer(0.25,function()
		if caster:GetHealth() < caster:GetMaxHealth()*0.2 then
			--shadows_dance BITCH
			caster:SetBaseHealthRegen(caster:GetMaxHealth()*0.1) 
			
			Timers:CreateTimer(5,function()
		else
			return 0.25
		end

	end)

end