function spin_web( keys )
	local caster = keys.caster
	local ability = keys.ability
	local player = caster:GetPlayerID()

		-- Modifiers and dummy abilities/modifiers
	local stack_modifier = keys.stack_modifier
	local dummy_modifier = keys.dummy_modifier
		-- Dummy
	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeam())
	ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {})
		

	-- Save the web dummy in a table and increase the count
	table.insert(caster.web_table, dummy)
	caster.web_current_webs = caster.web_current_webs + 1
	-- If the maximum web limit is reached then remove the first web dummy
	if caster.web_current_webs > caster.web_maximum_webs then
		caster.web_table[1]:RemoveSelf()
		table.remove(caster.web_table, 1)
		caster.web_current_webs = caster.web_current_webs - 1
	end	
end

--[[Author: Pizzalol
	Date: 18.01.2015.
	Finds the dummy in the table and then removes it]]
function spin_web_destroy( keys )
	local caster = keys.caster
	local caster_owner = caster:GetOwner()

	for i = 1, #caster_owner.web_table do
		if caster_owner.web_table[i] == caster then
			caster_owner.web_table[i]:RemoveSelf()
			table.remove(caster_owner.web_table, i)
			caster_owner.web_current_webs = caster_owner.web_current_webs - 1
			return
		end
	end
end

--[[Author: Pizzalol
	Date: 18.01.2015.
	Acts as an aura, applying the aura modifiers to the valid targets]]
function spin_web_aura( keys )
	local ability = keys.ability
	local caster = keys.caster	
	local target = keys.target

	-- Owner variables
	local caster_owner = caster:GetPlayerOwner()
	local target_owner = target:GetPlayerOwner()

	-- Units
	local unit_spiderling = keys.unit_spiderling
	local unit_spiderite = keys.unit_spiderite
	local all_units = ability:GetLevelSpecialValueFor("all_units", (ability:GetLevel() - 1))

	-- Modifiers
	local aura_modifier = keys.aura_modifier
	local pathing_modifier = keys.pathing_modifier
	local pathing_fade_modifier = keys.pathing_fade_modifier
	local invis_modifier = keys.invis_modifier
	local invis_fade_modifier = keys.invis_fade_modifier

	-- Checking if it should apply the aura to all player controlled units
	if all_units == 1 then all_units = true else all_units = false end

	if all_units then
		if target_owner == caster_owner then
			-- Aura modifier
			ability:ApplyDataDrivenModifier(caster, target, aura_modifier, {})
			-- If it doesnt have the fade pathing modifier or the pathing modifier then apply it
			if not target:HasModifier(pathing_fade_modifier) and not target:HasModifier(pathing_modifier) then
				ability:ApplyDataDrivenModifier(caster, target, pathing_modifier, {}) 
			end

			-- If it doesnt have the fade invis modifier or the invis modifier then apply it
			if not target:HasModifier(invis_modifier) and not target:HasModifier(invis_fade_modifier) then
				ability:ApplyDataDrivenModifier(caster, target, invis_modifier, {})
			end
		end
	else
		if target_owner == caster_owner and target == caster or target:GetName() == unit_spiderite or target:GetName() == unit_spiderling then
			-- Aura modifier
			ability:ApplyDataDrivenModifier(caster, target, aura_modifier, {})
			-- If it doesnt have the fade pathing modifier or the pathing modifier then apply it
			if not target:HasModifier(pathing_fade_modifier) and not target:HasModifier(pathing_modifier) then
				ability:ApplyDataDrivenModifier(caster, target, pathing_modifier, {}) 
			end

			-- If it doesnt have the fade invis modifier or the invis modifier then apply it
			if not target:HasModifier(invis_modifier) and not target:HasModifier(invis_fade_modifier) then
				ability:ApplyDataDrivenModifier(caster, target, invis_modifier, {})
			end
		end
	end
end