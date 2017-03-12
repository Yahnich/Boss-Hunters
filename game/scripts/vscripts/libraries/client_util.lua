function GetClientSync(key)
 	local value = CustomNetTables:GetTableValue( "syncing_purposes", key).value
	return value
end

function MergeTables( t1, t2 )
    for name,info in pairs(t2) do
        t1[name] = info
    end
end


function GetTableLength(rndTable)
	local counter = 0
	for k,v in pairs(rndTable) do
		counter = counter + 1
	end
	return counter
end

function PrintAll(t)
	for k,v in pairs(t) do
		print(k,v)
	end
end

function CDOTA_BaseNPC:HasTalent(talentName)
	if self:HasAbility(talentName) then
		if self:HasModifier("modifier_"...talentName) then return true end
	end
	return false
end

function CDOTA_BaseNPC:FindTalentValue(talentName)
	if self:HasAbility(talentName) then
		local specialVal = GameRules.AbilityKV[talentName]["AbilitySpecial"]
		for l,m in pairs(v) do
			if m["value"] then
				return m["value"]
			end
		end
	end
	return 0
end

function CDOTA_BaseNPC:FindSpecificTalentValue(talentName, valname)
	if self:HasAbility(talentName) then
		local specialVal = GameRules.AbilityKV[talentName]["AbilitySpecial"]
		for l,m in pairs(v) do
			if m[valname] then
				return m[valname]
			end
		end
	end
	return 0
end

function CDOTABaseAbility:GetTalentSpecialValueFor(value)
	local base = self:GetSpecialValueFor(value)
	local talentName
	local kv = GameRules.AbilityKV[talentName]
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end
	if talentName and self:GetCaster():HasTalent(talentName) then 
		base = base + self:GetCaster():FindTalentValue(talentName) end
	end
	return base
end

function CDOTA_BaseNPC:HealDisabled()
	if self:HasModifier("Disabled_silence") or 
	   self:HasModifier("primal_avatar_miss_aura") or 
	   self:HasModifier("modifier_reflection_invulnerability") or 
	   self:HasModifier("modifier_elite_burning_health_regen_block") or 
	   self:HasModifier("modifier_elite_entangling_health_regen_block") or 
	   self:HasModifier("modifier_plague_damage") or 
	   self:HasModifier("modifier_rupture_datadriven") or 
	   self:HasModifier("fire_aura_debuff") or 
	   self:HasModifier("item_sange_and_yasha_4_debuff") or 
	   self:HasModifier("cursed_effect") then
	return true
	else return false end
end