function ThreatGeneration(keys)
	local caster = keys.caster
	local threat = keys.threat
	local agility = caster:GetAgility()
	local strength = caster:GetStrength()
	if agility > strength then return end
	
	caster.threat = caster.threat + threat
	local player = PlayerResource:GetPlayer(caster:GetPlayerID())
	caster.lastHit = GameRules:GetGameTime()
	PlayerResource:SortThreat()
	local event_data =
	{
		threat = caster.threat,
		lastHit = caster.lastHit,
		aggro = caster.aggro
	}
	CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
end

function SpreadStats(keys)
	local caster = keys.caster
	local ability = keys.ability
		
	local agility = caster:GetAgility() - caster:GetModifierStackCount( keys.modagi , ability)
	local strength = caster:GetStrength() - caster:GetModifierStackCount( keys.modstr , ability)
	local statpct = (ability:GetTalentSpecialValueFor("stat_increase") - 100)/100
	local stats = math.floor((agility + strength)*statpct)
	
	if agility > strength then
		caster:RemoveModifierByName(keys.modstr)
		if caster:HasModifier(keys.modagi) then
			caster:SetModifierStackCount( keys.modagi , ability, stats )
		else
			ability:ApplyDataDrivenModifier(caster, caster, keys.modagi, {})
			caster:SetModifierStackCount( keys.modagi , ability, stats )
		end
	else 
		caster:RemoveModifierByName(keys.modagi)
		if caster:HasModifier(keys.modstr) then
			caster:SetModifierStackCount( keys.modstr , ability, stats )
		else
			ability:ApplyDataDrivenModifier(caster, caster, keys.modstr, {})
			caster:SetModifierStackCount( keys.modstr , ability, stats )
		end
	end
	caster:CalculateStatBonus()
end
	