function GetClientSync(key)
	local value = CustomNetTables:GetTableValue( "syncing_purposes", key).value
	return value
end

function MergeTables( t1, t2 )
    for name,info in pairs(t2) do
		if type(info) == "table"  and type(t1[name]) == "table" then
			MergeTables(t1[name], info)
		else
			t1[name] = info
		end
	end
end

function HasBit(checker, value)
	return bit.band(checker, value) == value
end

function AddTableToTable( t1, t2)
	for k,v in pairs(t2) do
		table.insert(t1, v)
	end
end

function C_DOTA_BaseNPC:GetAttackRange()
	return self:Script_GetAttackRange()
end

function TernaryOperator(value, bCheck, default)
	if bCheck then 
		return value 
	else 
		return default
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

AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
MergeTables(AbilityKV, LoadKeyValues("scripts/npc/npc_abilities_override.txt"))
MergeTables(AbilityKV, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
MergeTables(AbilityKV, LoadKeyValues("scripts/npc/items.txt"))
UnitKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
MergeTables(UnitKV, LoadKeyValues("scripts/npc/npc_heroes_custom.txt"))

function C_DOTA_BaseNPC:IsSameTeam(unit)
	return (self:GetTeamNumber() == unit:GetTeamNumber())
end

function C_DOTA_BaseNPC:GetThreat()
	local data = CustomNetTables:GetTableValue("hero_properties", unit:GetUnitName()..unit:entindex() ) or {}
	local threat = data.threat or 0
	return self.threat
end

function C_DOTA_BaseNPC:HasTalent(talentName)
	local unit = self
	if unit:GetParentUnit() then
		unit = unit:GetParentUnit()
	end
	local data = CustomNetTables:GetTableValue("talents", tostring(unit:entindex())) or {}
	if data and data[talentName] then
		return true 
	end
	return false
end

function C_DOTA_BaseNPC:FindTalentValue(talentName, valname)
	local value = valname or "value"
	local unit = self
	if unit:GetParentUnit() then
		unit = unit:GetParentUnit()
	end
	if unit:HasTalent(talentName) and AbilityKV[talentName] then  
		local specialVal = AbilityKV[talentName]["AbilitySpecial"]
		for l,m in pairs(specialVal) do
			if m[value] then
				return m[value]
			end
		end
	end    
	return 0
end

function C_DOTABaseAbility:GetAbilityTextureName()
	if AbilityKV[self:GetName()] and AbilityKV[self:GetName()]["AbilityTextureName"] then
		return AbilityKV[self:GetName()]["AbilityTextureName"]
	end
	return nil
end

function C_DOTABaseAbility:GetTalentSpecialValueFor(value)
	local base = self:GetSpecialValueFor(value)
	local talentName
	local kv = AbilityKV[self:GetName()]["AbilitySpecial"]
	local valname = "value"
	local multiply = false
	local subtract = false
	local zadd = false
	if kv then
		for k,v in pairs(kv) do -- trawl through keyvalues
			if v[value] then
				talentName = v["LinkedSpecialBonus"]
				if v["LinkedSpecialBonusField"] then valname = v["LinkedSpecialBonusField"] end
				if v["LinkedSpecialBonusOperation"] and v["LinkedSpecialBonusOperation"] == "SPECIAL_BONUS_MULTIPLY" then multiply = true end
				if v["LinkedSpecialBonusOperation"] and v["LinkedSpecialBonusOperation"] == "SPECIAL_BONUS_SUBTRACT" then subtract = true end
				if v["LinkedSpecialBonusOperation"] and v["LinkedSpecialBonusOperation"] == "SPECIAL_BONUS_PERCENTAGE_ADD" then zadd = true end
				break
			end
		end
	end
	local unit = self:GetCaster()
	if unit:GetParentUnit() then
		unit = unit:GetParentUnit()
	end
	if talentName and unit:HasTalent(talentName) then 
		if multiply then
			base = base * unit:FindTalentValue(talentName, valname) 
		elseif subtract then
			base = base - unit:FindTalentValue(talentName, valname) 
		elseif zadd then
			base = base + math.floor(base * unit:FindTalentValue(talentName, valname) /100)
		else
			base = base + unit:FindTalentValue(talentName, valname)
		end
	end
	return base
end

function C_DOTA_BaseNPC:HealDisabled()
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

function C_DOTA_Modifier_Lua:GetSpecialValueFor(specVal)
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor(specVal)
	end
	return 0
end

function C_DOTA_Modifier_Lua:GetTalentSpecialValueFor(specVal)
	return self:GetAbility():GetTalentSpecialValueFor(specVal)
end

function C_DOTA_Modifier_Lua:AddIndependentStack()
	if self:GetStackCount() == 0 then self:GetStackCount(1)
	else self:IncrementStackCount() end
end


function C_DOTA_BaseNPC:GetStrength()
	local unit = self
	if self:GetParentUnit() then
		unit = self:GetParentUnit()
	end
	local netTable = CustomNetTables:GetTableValue("hero_properties", unit:GetUnitName()..unit:entindex())
	if netTable and netTable.strength then return  math.floor(tonumber(netTable.strength)) end
	return 0
end

function C_DOTA_BaseNPC:GetIntellect()
	local unit = self
	if self:GetParentUnit() then
		unit = self:GetParentUnit()
	end
	local netTable = CustomNetTables:GetTableValue("hero_properties", unit:GetUnitName()..unit:entindex())
	if netTable and netTable.intellect then return  math.floor(tonumber(netTable.intellect)) end
	return 0
end

function C_DOTA_BaseNPC:GetAgility()
	local unit = self
	if self:GetParentUnit() then
		unit = self:GetParentUnit()
	end
	local netTable = CustomNetTables:GetTableValue("hero_properties", unit:GetUnitName()..unit:entindex())
	if netTable and netTable.agility then return math.floor(tonumber(netTable.agility)) end
	return 0
end

function C_DOTA_BaseNPC:GetPrimaryAttribute()
	local unit = self
	if self:GetParentUnit() then
		unit = self:GetParentUnit()
	end
	if UnitKV[unit:GetUnitName()] then
		attribute = UnitKV[unit:GetUnitName()]["AttributePrimary"]
		if attribute then
			if attribute == "DOTA_ATTRIBUTE_STRENGTH" then
				return DOTA_ATTRIBUTE_STRENGTH
			elseif attribute == "DOTA_ATTRIBUTE_INTELLECT" then
				return DOTA_ATTRIBUTE_INTELLECT
			elseif attribute == "DOTA_ATTRIBUTE_AGILITY" then
				return DOTA_ATTRIBUTE_AGILITY
			end
		end
	end
	return -1
end

function C_DOTA_BaseNPC:GetPrimaryStatValue()
	local unit = self
	if self:GetParentUnit() then
		unit = self:GetParentUnit()
	end
	local nPrim = unit:GetPrimaryAttribute()
	if nPrim == DOTA_ATTRIBUTE_STRENGTH then
		return unit:GetStrength()
	elseif nPrim == DOTA_ATTRIBUTE_AGILITY then
		return unit:GetAgility()
	elseif nPrim == DOTA_ATTRIBUTE_INTELLECT then
		return unit:GetIntellect()
	end
	return 0
end

function C_DOTA_BaseNPC:InWater()
	return self:HasModifier("modifier_in_water")
end

function C_DOTA_BaseNPC:IsRoundNecessary()
	return self:HasModifier("modifier_boss_evasion")
end

function C_BaseEntity:RollPRNG( percentage )
	local internalInt = (100/percentage)
	local startingRoll = internalInt^2
	self.internalPRNGCounter = self.internalPRNGCounter or (1/internalInt)^2
	if RollPercentage(self.internalPRNGCounter * 100) then
		self.internalPRNGCounter = (1/internalInt)^2
		return true
	else
		local internalCount = 1/self.internalPRNGCounter
		self.internalPRNGCounter = 1/( math.max(internalCount - internalInt, 1) )
		return false
	end
end

function C_DOTA_Ability_Lua:RollPRNG( percentage )
	local internalInt = (100/percentage)
	local startingRoll = internalInt^2
	self.internalPRNGCounter = self.internalPRNGCounter or (1/internalInt)^2
	if RollPercentage(self.internalPRNGCounter * 100) then
		self.internalPRNGCounter = (1/internalInt)^2
		return true
	else
		local internalCount = 1/self.internalPRNGCounter
		self.internalPRNGCounter = 1/( math.max(internalCount - internalInt, 1) )
		return false
	end
end

function RollPercentage( percentage )
	return RandomInt(1, 100) <= percentage
end

function C_DOTA_Modifier_Lua:RollPRNG( percentage )
	local internalInt = (100/percentage)
	local startingRoll = internalInt^2
	self.internalPRNGCounter = self.internalPRNGCounter or (1/internalInt)^2
	if RollPercentage(self.internalPRNGCounter * 100) then
		self.internalPRNGCounter = (1/internalInt)^2
		return true
	else
		local internalCount = 1/self.internalPRNGCounter
		self.internalPRNGCounter = 1/( math.max(internalCount - internalInt, 1) )
		return false
	end
end


function C_DOTA_BaseNPC:GetParentUnit()
	return self.unitOwnerEntity
end

BH_MINION_TYPE_WILD = 1
BH_MINION_TYPE_UNDEAD = bit.lshift(BH_MINION_TYPE_WILD, 1)
BH_MINION_TYPE_DEMONIC = bit.lshift(BH_MINION_TYPE_UNDEAD, 1)
BH_MINION_TYPE_CELESTIAL = bit.lshift(BH_MINION_TYPE_DEMONIC, 1)

BH_MINION_TYPE_MINION = bit.lshift(BH_MINION_TYPE_CELESTIAL, 1)
BH_MINION_TYPE_BOSS = bit.lshift(BH_MINION_TYPE_MINION, 1)

function C_DOTA_BaseNPC:IsBoss()
	local stacks = self:GetModifierStackCount( "modifier_typing_tag", self )
	return HasBit(stacks, BH_MINION_TYPE_BOSS)
end

function C_DOTA_BaseNPC:IsMinion()
	local stacks = self:GetModifierStackCount( "modifier_typing_tag", self )
	return HasBit(stacks, BH_MINION_TYPE_MINION)
end


function C_DOTA_BaseNPC:IsUndead()
	local stacks = self:GetModifierStackCount( "modifier_typing_tag", self )
	return HasBit(stacks, BH_MINION_TYPE_UNDEAD)
end

function C_DOTA_BaseNPC:IsWild()
	local stacks = self:GetModifierStackCount( "modifier_typing_tag", self )
	return HasBit(stacks, BH_MINION_TYPE_WILD)
end

function C_DOTA_BaseNPC:IsDemon()
	local stacks = self:GetModifierStackCount( "modifier_typing_tag", self )
	return HasBit(stacks, BH_MINION_TYPE_DEMONIC)
end

function C_DOTA_BaseNPC:IsCelestial()
	local stacks = self:GetModifierStackCount( "modifier_typing_tag", self )
	return HasBit(stacks, BH_MINION_TYPE_CELESTIAL)
end