function MoonLightShadow(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	ability:ApplyDataDrivenModifier(caster, target, "modifier_moonlight_duration_datadriven", { duration = ability:GetTalentSpecialValueFor("duration") })
	ability:ApplyDataDrivenModifier(caster, target, "modifier_moonlight_fade_datadriven", { duration = ability:GetTalentSpecialValueFor("fade_delay") })
end

					

function MoonEye(keys)
	local caster = keys.caster
	local ability = keys.ability
	local agility = caster:GetAgility()
	local buff_duration = ability:GetTalentSpecialValueFor("duration")
	local agi_mult = ability:GetTalentSpecialValueFor("agi_mult")
	local modifier = "mooneye_buff"
	ability:ApplyDataDrivenModifier(caster, caster, "mooneye_counter", { duration = buff_duration })
	if not caster:HasModifier(modifier) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier, { duration = buff_duration })
		caster:SetModifierStackCount( modifier, ability, agility * agi_mult )
	else
		local stacks = caster:GetModifierStackCount( modifier, caster )
		agility = (agility - stacks)*agi_mult
		print(agility, stacks)
		ability:ApplyDataDrivenModifier(caster, caster, modifier, { duration = buff_duration })
		caster:SetModifierStackCount( modifier, caster, agility )
	end
end

function AddMoonEyePassive(keys)
	local caster = keys.caster
	local ability = keys.ability
	local agility = math.floor(caster:GetAgility() - caster:GetModifierStackCount("mooneye_buff", caster) - caster:GetModifierStackCount("mooneye_passive_buff", caster))
	local additionPct = ability:GetTalentSpecialValueFor("passive_agi_mult") / 100
	local addedAgi = math.floor(agility * additionPct + 0.5)
	print(addedAgi, agility, caster:GetModifierStackCount("mooneye_passive_buff", caster))
	ability.stackTable = ability.stackTable or {}
	table.insert(ability.stackTable, GameRules:GetGameTime())
	caster:SetModifierStackCount("mooneye_passive_buff", caster, addedAgi * #ability.stackTable)
	ability:ApplyDataDrivenModifier(caster, caster, "mooneye_passive_counter", {ability:GetTalentSpecialValueFor("passive_duration")})
	caster:SetModifierStackCount("mooneye_passive_counter", caster, #ability.stackTable)
end

function HandleMoonEyePassive(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability.stackTable = ability.stackTable or {}
	if #ability.stackTable > 0 then
		local expireTime = ability:GetTalentSpecialValueFor("passive_duration")
		local modifier = caster:FindModifierByName("mooneye_passive_counter")
		for i = #ability.stackTable, 1, -1 do
			if ability.stackTable[i] + expireTime < GameRules:GetGameTime() then
				local agility = caster:GetAgility() - caster:GetModifierStackCount("mooneye_buff", caster) - caster:GetModifierStackCount("mooneye_passive_buff", caster)
				local additionPct = ability:GetTalentSpecialValueFor("passive_agi_mult") / 100
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

