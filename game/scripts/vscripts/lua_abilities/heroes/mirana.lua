function MoonEye(keys)
	local caster = keys.caster
	local ability = keys.ability
	local agility = caster:GetAgility()
	local buff_duration = keys.duration
	local modifier = "mooneye_buff"
	if not caster:HasModifier(modifier) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier, { duration = buff_duration })
		caster:SetModifierStackCount( modifier, ability, agility )
	else
		caster:RemoveModifierByName(modifier)
		ability:ApplyDataDrivenModifier(caster, caster, modifier, { duration = buff_duration })
		caster:SetModifierStackCount( modifier, caster, agility )
	end
end

function AddMoonEyePassive(keys)
	local caster = keys.caster
	local ability = keys.ability
	local agility = math.floor(caster:GetAgility() - caster:GetModifierStackCount("mooneye_buff", caster) - caster:GetModifierStackCount("mooneye_passive_buff", caster))
	local additionPct = ability:GetSpecialValueFor("passive_agi_mult") / 100
	local addedAgi = math.floor(agility * additionPct + 0.5)
	print(addedAgi, agility, caster:GetModifierStackCount("mooneye_passive_buff", caster))
	ability.stackTable = ability.stackTable or {}
	table.insert(ability.stackTable, GameRules:GetGameTime())
	caster:SetModifierStackCount("mooneye_passive_buff", caster, addedAgi * #ability.stackTable)
	ability:ApplyDataDrivenModifier(caster, caster, "mooneye_passive_counter", {ability:GetSpecialValueFor("passive_duration")})
	caster:SetModifierStackCount("mooneye_passive_counter", caster, #ability.stackTable)
end

function HandleMoonEyePassive(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability.stackTable = ability.stackTable or {}
	if #ability.stackTable > 0 then
		local expireTime = ability:GetSpecialValueFor("passive_duration")
		local modifier = caster:FindModifierByName("mooneye_passive_counter")
		for i = #ability.stackTable, 1, -1 do
			if ability.stackTable[i] + expireTime < GameRules:GetGameTime() then
				local agility = caster:GetAgility() - caster:GetModifierStackCount("mooneye_buff", caster) - caster:GetModifierStackCount("mooneye_passive_buff", caster)
				local additionPct = ability:GetSpecialValueFor("passive_agi_mult") / 100
				local addedAgi = agility * additionPct
				table.remove(ability.stackTable, i)
				modifier:DecrementStackCount()
				caster:SetModifierStackCount("mooneye_passive_buff", caster, addedAgi * modifier:GetStackCount())
				if modifier:GetStackCount() == 0 then	
					caster:SetModifierStackCount( "mooneye_passive_buff", caster, -1 ) 
				end
			end
		end
	end
end

function ResetMoonEyePassive(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability.stackTable = {}
	caster:SetModifierStackCount( "mooneye_passive_buff", caster, -1 )
end

