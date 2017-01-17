EHP_PER_ARMOR = 0.01

function SendClientSync(key, value)
	CustomNetTables:SetTableValue( "syncing_purposes",key, {value = value} )
end

function GetClientSync(key)
 	local value = CustomNetTables:GetTableValue( "syncing_purposes", key).value
	return value
end

function CalculateDistance(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local distance = (pos1 - pos2):Length2D()
	return distance
end

function CalculateDirection(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local direction = (pos1 - pos2):Normalized()
	return direction
end

function CDOTA_BaseNPC:CreateDummy(position)
	local dummy = CreateUnitByName("npc_dummy_unit", position, false, nil, nil, self:GetTeam())
	dummy:AddAbility("hide_hero"):SetLevel(1)
	return dummy
end


function get_aether_multiplier(caster)
    local aether_multiplier = 1
    for itemSlot = 0, 5, 1 do
        local Item = caster:GetItemInSlot( itemSlot )
		if Item ~= nil then
			local itemAmp = Item:GetSpecialValueFor("spell_amp")/100
			if Item:GetName() == "item_aether_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_redium_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_sunium_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_omni_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_asura_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
		end
    end
    return aether_multiplier
end

function AllPlayersAbandoned()
	local playerCounter = 0
	local dcCounter = 0
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			playerCounter = playerCounter + 1
			local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
			if hero then
				if hero:HasOwnerAbandoned() then
					dcCounter = dcCounter + 1
				end
				if PlayerResource:GetConnectionState(hero:GetPlayerID()) == 3 then
					if not hero.lastActiveTime then hero.lastActiveTime = GameRules:GetGameTime() end
					if hero.lastActiveTime + 60*3 < GameRules:GetGameTime() then
						dcCounter = dcCounter + 1
					end
				else
					hero.lastActiveTime = GameRules:GetGameTime()
				end
			else
				dcCounter = dcCounter + 1
			end
		end
	end
	if dcCounter >= playerCounter then
		return true
	else
		return false
	end
end

function MergeTables( t1, t2 )
    for name,info in pairs(t2) do
        t1[name] = info
    end
end

function PrintAll(t)
	for k,v in pairs(t) do
		print(k,v)
	end
end

function table.removekey(t1, key)
    for k,v in pairs(t1) do
		if t1[k] == key then
			table.remove(t1,k)
		end
	end
end

function GetAllPlayers()
	local counter = 0
	local abandon = 0
	local currtime = GameRules:GetGameTime()
	
	local base = 5
	
	if GetMapName() ~= "epic_boss_fight_normal" then
		base = 7
	end
	
	local challengemult = base

	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
				counter = counter + 1
				if hero then
					if not hero.disconnect then hero.disconnect = 0 end
					challengemult = challengemult - 1
					if PlayerResource:GetConnectionState(nPlayerID) == 3 then
						abandon = abandon + 0.3
						if hero.disconnect + 300 < GameRules:GetGameTime() then
							abandon = abandon + 0.7
						elseif hero:HasOwnerAbandoned() then
							abandon = abandon + 0.7
							challengemult = challengemult - 1
						end
					elseif hero:HasOwnerAbandoned() then
							abandon = abandon + 1
							challengemult = challengemult - 1
					end
				end
			else
				abandon = abandon + 1
				challengemult = challengemult - 1
			end
		end
	end
	challengemult = (challengemult/base)/3
	if counter - 1 <= abandon then abandon = counter - 1 end
	abandon = abandon / 3
	counter = (counter*(counter/(counter-abandon)))*(1 + challengemult)
	return counter
end

function CDOTA_BaseNPC:GetAttackDamageType()
	-- 1: DAMAGE_TYPE_ArmorPhysical
	-- 2: DAMAGE_TYPE_ArmorMagical
	-- 4: DAMAGE_TYPE_ArmorPure
	local resourceType = GameRules.UnitKV[self:GetUnitName()]["StatusResource"]
	if damagetype then
		return damagetype
	else
		return "Mana"
	end
end

function CDOTA_BaseNPC:IsSpawner()
	-- 1: DAMAGE_TYPE_ArmorPhysical
	-- 2: DAMAGE_TYPE_ArmorMagical
	-- 4: DAMAGE_TYPE_ArmorPure
	local resourceType = GameRules.UnitKV[self:GetUnitName()]["IsSpawner"]
	if resourceType then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:HasTalent(talentName)
	if self:HasAbility(talentName) then
		if self:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end
	return false
end

function CDOTA_BaseNPC:HasTalentType(talentType)
	for i = 0, 23 do
		local talent = self:GetAbilityByIndex(i)
		if talent and string.match(talent:GetName(), "special_bonus_"..talentType.."_(%d+)") then
			if talent:GetLevel() > 0 then
				return true
			end
		end
	end
	return false
end

function FindAllEntitiesByClassname(name)
	local entList = {}
	local sortList = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, 99999, 3, 63, DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, -1, false)
	for _, unit in pairs(sortList) do
		if unit:GetClassname() == name then
			table.insert(entList, unit)
		end
	end
	return entList
end

function GetRandomUnselectedHero()
	local heroList = GameRules.HeroList
	local sortList = {}
	for hero, activated in pairs(heroList) do
		if activated == 1 then
			sortList[hero] = true
		end
	end
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		local player = PlayerResource:GetPlayer(nPlayerID)
		if player and PlayerResource:HasSelectedHero(nPlayerID) then
			local pickedHero = PlayerResource:GetSelectedHeroName(nPlayerID)
			if sortList[pickedHero] then
				sortList[pickedHero] = nil
			end
		end
	end
	local randomList = {}
	for hero, activated in pairs(sortList) do
		if activated then
			table.insert(randomList, hero)
		end
	end
	local rndReturn = randomList[math.random(#randomList)]
	print(rndReturn)
	return rndReturn
end

function GetTableLength(rndTable)
	local counter = 0
	for k,v in pairs(rndTable) do
		counter = counter + 1
	end
	return counter
end

function CDOTA_BaseNPC:HighestTalentTypeValue(talentType)
	local value = 0
	for i = 0, 23 do
		local talent = self:GetAbilityByIndex(i)
		if talent and string.match(talent:GetName(), "special_bonus_"..talentType.."_(%d+)") and self:FindTalentValue(talent:GetName()) > value then
			value = self:FindTalentValue(talent:GetName())
		end
	end
	print("value")
	return value
end

function CDOTA_BaseNPC:FindTalentValue(talentName)
	if self:HasAbility(talentName) then
		return self:FindAbilityByName(talentName):GetSpecialValueFor("value")
	end
	return 0
end

function CDOTA_BaseNPC:NotDead()
	if self:IsAlive() or 
	self:IsReincarnating() or 
	(self:WillReincarnate() and not self:HasModifier("modifier_skeleton_king_reincarnation_cooldown")) or 
	(self:FindItemByName("item_ressurection_stone", true) and self:FindItemByName("item_ressurection_stone", true):IsCooldownReady()) then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:GetAverageBaseDamage()
	return (self:GetBaseDamageMax() + self:GetBaseDamageMin())/2
end

function CDOTA_BaseNPC:SetAverageBaseDamage(average, variance) -- variance is in percent (50 not 0.5)
	local var = variance or 0
	self:SetBaseDamageMax(average*(1+(var/100)))
	self:SetBaseDamageMin(average*(1+(var/100)))
end

function CDOTABaseAbility:Refresh()
	if not self:IsActivated() then
		self:SetActivated(true)
	end
    self:EndCooldown()
end

function CDOTABaseAbility:GetTrueCastRange()
	local castrange = self:GetCastRange()
	castrange = castrange + get_aether_range(self:GetCaster())
	return castrange
end

function CDOTA_BaseNPC:KillTarget()
	if not ( self:IsInvulnerable() or self:IsOutOfGame() or self:IsUnselectable() or self:NoHealthBar() ) then
		self:ForceKill(true)
	end
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

function CDOTA_BaseNPC:GetDisableResistance()
	if self:IsCreature() then
		return GameRules.UnitKV[self:GetUnitName()]["Creature"]["DisableResistance"] or 0
	else
		return 0
	end
end

function CDOTA_BaseNPC:GetBaseProjectileModel()
	if self:IsRangedAttacker() then
		return GameRules.UnitKV[self:GetUnitName()]["ProjectileModel"] or nil
	else
		return nil
	end
end

function CDOTA_BaseNPC:GetProjectileModel()
	if self:IsRangedAttacker() then
		return self.currentProjectileModel or GameRules.UnitKV[self:GetUnitName()]["ProjectileModel"] or nil
	else
		return nil
	end
end

function CDOTA_BaseNPC:SetProjectileModel(projectile)
	self:SetRangedProjectileName(projectile)
	self.currentProjectileModel = projectile
end


function  CDOTA_BaseNPC:ConjureImage( position, duration, outgoing, incoming, specIllusionModifier )
	local player = self:GetPlayerID()

	local unit_name = self:GetUnitName()
	local origin = position or self:GetAbsOrigin() + RandomVector(100)
	local outgoingDamage = outgoing
	local incomingDamage = incoming

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, self, nil, self:GetTeamNumber())
	illusion:SetPlayerID(self:GetPlayerID())
	illusion:SetControllableByPlayer(player, true)
		
	-- Level Up the unit to the casters level
	local casterLevel = self:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end

	-- Set the skill points to 0 and learn the skills of the caster
	illusion:SetAbilityPoints(0)
	for abilitySlot=0,15 do
		local abilityillu = self:GetAbilityByIndex(abilitySlot)
		if abilityillu ~= nil then 
			local abilityLevel = abilityillu:GetLevel()
			local abilityName = abilityillu:GetAbilityName()
			if illusion:FindAbilityByName(abilityName) ~= nil and abilityName ~= "phantom_lancer_juxtapose" then
				local illusionAbility = illusion:FindAbilityByName(abilityName)
				illusionAbility:SetLevel(abilityLevel)
			end
		end
	end

			-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = self:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	if specIllusionModifier then
		illusion:AddNewModifier(self, ability, specIllusionModifier, { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	end
	illusion:AddNewModifier(self, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
			
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()
end



function CDOTABaseAbility:PiercesDisableResistance()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["PiercesDisableReduction"] or 0
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function CDOTABaseAbility:HasBehavior(behavior)
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["PiercesDisableReduction"] or 0
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function CDOTABaseAbility:IsInnateAbility()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["InnateAbility"] or 0
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function CDOTABaseAbility:IsAetherAmplified()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["IsAetherAmplified"] or 1
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return true
	end
end

function CDOTABaseAbility:IgnoresDamageFilterOverride()
	if GameRules.AbilityKV[self:GetName()] and not (self:GetClassname() == "ability_datadriven" or self:GetClassname() == "ability_lua" or self:GetClassname() == "item_datadriven")  then
		local truefalse = GameRules.AbilityKV[self:GetName()]["IgnoresDamageFilterOverride"] or 0
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function CDOTABaseAbility:HasPureCooldown()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["HasPureCooldown"] or 0
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function CDOTABaseAbility:AbilityScepterDamageType()
	if GameRules.AbilityKV[self:GetName()] then
		local damagetype = GameRules.AbilityKV[self:GetName()]["AbilityScepterUnitDamageType"] or self:GetAbilityDamageType()
		if damagetype == "DAMAGE_TYPE_PHYSICAL" then
			damagetype = 1
		elseif damagetype == "DAMAGE_TYPE_MAGICAL" then
			damagetype = 2
		elseif damagetype == "DAMAGE_TYPE_PURE" then
			damagetype = 4
		end
		return damagetype
	else
		return self:GetAbilityDamageType()
	end
end

function CDOTABaseAbility:HasNoThreatFlag()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["NoThreatFlag"] or 0
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function CDOTABaseAbility:AbilityPierces()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["AbilityPierces"] or 0
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end


function CDOTABaseAbility:GetThreat()
	if GameRules.AbilityKV[self:GetName()] then
		local threat = GameRules.AbilityKV[self:GetName()]["AbilityThreat"] or 0
		return threat
	else
		return 0
	end
end

function CDOTA_BaseNPC:GetThreat()
	self.threat = self.threat or 0
	return self.threat
end

function CDOTA_BaseNPC:SetThreat(val)
	self.threat = val
end

function CDOTA_BaseNPC:ModifyThreat(val)
	self.threat = self.threat + val
end

function get_aether_range(caster)
    local aether_range = 0
    for itemSlot = 0, 5, 1 do
        local Item = caster:GetItemInSlot( itemSlot )
		if Item ~= nil then
			local itemRange = Item:GetSpecialValueFor("cast_range_bonus")
			if Item:GetName() == "item_asura_lens" then
				if aether_range < itemRange then
					aether_range = itemRange
				end
			end
			if Item:GetName() == "item_omni_lens" then
				if aether_range < itemRange then
					aether_range = itemRange
				end
			end
			if Item:GetName() == "item_sunium_lens" then
				if aether_range < itemRange then
					aether_range = itemRange
				end
			end
			if Item:GetName() ==  "item_redium_lens" then
				if aether_range < itemRange then
					aether_range = itemRange
				end
			end
			if Item:GetName() == "item_aether_lens" then
				if aether_range < itemRange then
					aether_range = itemRange
				end
			end
		end
	end
	local talentMult = caster:HighestTalentTypeValue("cast_range")
	aether_range = aether_range+talentMult
    return aether_range
end

function CDOTA_BaseNPC:IsSlowed()
	if self:GetIdealSpeed() < self:GetBaseMoveSpeed() then return true
	else return false end
end

function CDOTA_BaseNPC:IsDisabled()
	local customModifier = false
	if self:HasModifier("creature_slithereen_crush_stun") then
		local customModifier = true
	end
	if self:IsSlowed() or self:IsStunned() or self:IsRooted() or self:IsSilenced() or self:IsHexed() or self:IsDisarmed() or customModifier then 
		return true
	else return false end
end

function CDOTA_BaseNPC:GetPhysicalArmorReduction()
	local armornpc = self:GetPhysicalArmorValue()
	local armor_reduction = 1 - (0.06 * armornpc) / (1 + (0.06 * math.abs(armornpc)))
	armor_reduction = 100 - (armor_reduction * 100)
	return armor_reduction
end

function CDOTA_BaseNPC:GetRealPhysicalArmorReduction()
	local armornpc = self:GetPhysicalArmorValue()
	local armor_reduction = 1 - (EHP_PER_ARMOR * armornpc) / (1 + (EHP_PER_ARMOR * math.abs(armornpc)))
	armor_reduction = 100 - (armor_reduction * 100)
	return armor_reduction
end

function CDOTA_BaseNPC:FindItemByName(sItemname, bBackpack)
	local inventoryIndex = 5
	if bBackpack then inventoryIndex = 8 end
	for i = 0, inventoryIndex do
		local item = self:GetItemInSlot(i)
		if item and item:GetName() == sItemname then 
			return item
		end
	end
end

function CDOTA_BaseNPC:ShowPopup( data )
    if not data then return end

    local target = self
    if not target then error( "ShowNumber without target" ) end
    local number = tonumber( data.Number or nil )
    local pfx = data.Type or "miss"
    local player = data.Player or false
    local color = data.Color or Vector( 255, 255, 255 )
    local duration = tonumber( data.Duration or 1 )
    local presymbol = tonumber( data.PreSymbol or nil )
    local postsymbol = tonumber( data.PostSymbol or nil )

    local path = "particles/msg_fx/msg_" .. pfx .. ".vpcf"
    local particle = ParticleManager:CreateParticle(path, PATTACH_OVERHEAD_FOLLOW, target)
    if player then
		local playerent = PlayerResource:GetPlayer( self:GetPlayerID() )
        local particle = ParticleManager:CreateParticleForPlayer( path, PATTACH_OVERHEAD_FOLLOW, target, playerent)
    end
	
	if number then
		number = math.floor(number+0.5)
	end

    local digits = 0
    if number ~= nil then digits = string.len(number) end
    if presymbol ~= nil then digits = digits + 1 end
    if postsymbol ~= nil then digits = digits + 1 end

    ParticleManager:SetParticleControl( particle, 1, Vector( presymbol, number, postsymbol ) )
    ParticleManager:SetParticleControl( particle, 2, Vector( duration, digits, 0 ) )
    ParticleManager:SetParticleControl( particle, 3, color )
end

function CDOTA_BaseNPC:IsTargeted()
	if self == GameRules.focusedUnit then
		return true
	else
		return false
	end
end

function CDOTABaseAbility:GetAbilityLifeTime()
    local kv = self:GetAbilityKeyValues()
    local duration = self:GetDuration()
	if not duration or duration == 0 then
		local check = 0
		for k,v in pairs(kv) do -- trawl through keyvalues
			if k == "AbilitySpecial" then
				for l,m in pairs(v) do
					for o,p in pairs(m) do
						if string.match(o, "duration") then -- look for the highest duration keyvalue
							local checkDuration = self:GetSpecialValueFor(o)
							if checkDuration > check then check = checkDuration end
						end
					end
				end
			end
		end
		duration = check
	end
	
	if not duration then duration = 0 end
    return duration
end

function CDOTABaseAbility:ProvidesModifier(modifiername)
    local kv = self:GetAbilityKeyValues()
	local found = false
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "Modifiers" then
			for l,m in pairs(v) do
				if l == modifiername then
					found = true
					break
				end
			end
		end
	end
	return found
end

function CDOTA_BaseNPC:GetModifierPropertyValue(propertyname)
    local modifiers = self:FindAllModifiers()
	local value = 0
	local checkedMod = {}
	
	for k,v in pairs(modifiers) do
		if not checkedMod[v:GetName()] then
			local stacks = v:GetStackCount()
			if stacks == 0 then stacks = 1 end
			local propVal = v:GetModifierPropertyValue(propertyname) * stacks
			if propVal > 0 then
				value = propVal
				break
			end
			checkedMod[v:GetName()] = true
		end
	end
	return value
end

function CDOTA_BaseNPC:FindModifierByAbility(abilityname)
	local modifiers = self:FindAllModifiers()
	local returnTable = {}
	for _,modifier in pairs(modifiers) do
		if modifier:GetAbility():GetName() == abilityname then
			table.insert(returnTable, modifier)
		end
	end
	return returnTable
end

function CDOTA_BaseNPC:IsFakeHero()
	if self:IsIllusion() or (self:HasModifier("modifier_monkey_king_fur_army_soldier") or self:HasModifier("modifier_monkey_king_fur_army_soldier_hidden")) then
		return true
	else return false end
end



function CDOTA_Buff:GetModifierPropertyValue(propertyname)
	if not self:GetAbility() then return 0 end
	local kv = self:GetAbility():GetAbilityKeyValues()
	local value = 0
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "Modifiers" then
			for l,m in pairs(v) do
				if l == self:GetName() then
					for j,k in pairs(m) do
						if j == "Properties" then
							for g,h in pairs(k) do
								if g == propertyname then
									value = h			
									break
								end
							end
						end
					end
				end
			end
		end
	end
	return value
end

function CDOTABaseAbility:GetTalentSpecialValueFor(value)
	local base = self:GetSpecialValueFor(value)
	local talentName
	local kv = self:GetAbilityKeyValues()
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end
	if talentName then 
		local talent = self:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
	end
	return base
end

function CDOTA_Buff:HasBeenRefreshed()
	if self:GetCreationTime() + self:GetDuration() < self:GetDieTime() then -- if original destroy time is smaller than new destroy time
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IncreaseStrength(amount)
	local attribute = self:GetBaseStrength()
	local strength = attribute + amount
	self:SetBaseStrength(strength)
end

function CDOTA_BaseNPC:IncreaseAgility(amount)
	local attribute = self:GetBaseAgility()
	local agility = attribute + amount
	self:SetBaseStrength(agility)
end

function CDOTA_BaseNPC:IncreaseIntellect(amount)
	local attribute = self:GetBaseIntellect()
	local intellect = attribute + amount
	self:SetBaseStrength(intellect)
end

function CDOTA_BaseNPC:StatsItemslot(index)
	local item = self:GetItemInSlot(index)
	if item then return item:GetName() else return 0 end
end

function CDOTA_BaseNPC:GetSpellDamageAmp()
	local aether_multiplier = 1
    for itemSlot = 0, 5, 1 do
        local Item = self:GetItemInSlot( itemSlot )
		if Item ~= nil and aether_multiplier < 4 then
			local itemAmp = Item:GetSpecialValueFor("spell_amp")/100
			if Item:GetName() == "item_aether_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_redium_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_sunium_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_omni_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_asura_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
		end
    end
	if aether_multiplier > 5.5 then aether_multiplier = 5.5 end
	if self:FindAbilityByName("new_game_damage_increase") then
		aether_multiplier = aether_multiplier + self:FindAbilityByName("new_game_damage_increase"):GetSpecialValueFor("spell_amp")/100
	end
	local ampint = 0
	if self:IsHero() then
		ampint = (self:GetIntellect() * 0.0075)/100
	end
	local totalamp = aether_multiplier + ampint
	return totalamp
end

function CDOTA_BaseNPC:GetOriginalSpellDamageAmp()
	local aether_multiplier = 1
    for itemSlot = 0, 5, 1 do
        local Item = self:GetItemInSlot( itemSlot )
		if Item ~= nil then
			local itemAmp = Item:GetSpecialValueFor("spell_amp")/100
			if Item:GetName() == "item_aether_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_redium_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_sunium_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_omni_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_asura_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
		end
    end
	if self:FindAbilityByName("new_game_damage_increase") then
		aether_multiplier = aether_multiplier + self:FindAbilityByName("new_game_damage_increase"):GetSpecialValueFor("spell_amp")/100
	end
	local ampint = 0
	if self:IsHero() then
		ampint = self:GetIntellect() / 1600
	end
	local totalamp = aether_multiplier + ampint
	return totalamp
end

function CDOTABaseAbility:GetTrueCooldown()
	local cooldown = self:GetCooldown(-1)
	local octarineMult = get_octarine_multiplier(self:GetCaster())
	cooldown = cooldown * octarineMult
	return cooldown
end

function CScriptHeroList:GetRealHeroCount()
	local heroes = self:GetAllHeroes()
	local realHeroes = {}
	for _,hero in pairs(heroes) do
		if hero:IsRealHero() and not (hero:HasModifier("modifier_monkey_king_fur_army_soldier") or hero:HasModifier("modifier_monkey_king_fur_army_soldier_hidden")) then
			table.insert(realHeroes, hero)
		end
	end
	return #realHeroes
end

function RotateVector2D(vector, theta)
    local xp = vector.x*math.cos(theta)-vector.y*math.sin(theta)
    local yp = vector.x*math.sin(theta)+vector.y*math.cos(theta)
    return Vector(xp,yp,vector.z):Normalized()
end

function CDOTA_BaseNPC:SwapAbilityIndexes(index, swapname)
	local ability = self:GetAbilityByIndex(index)
	local swapability = self:FindAbilityByName(swapname)
	self:SwapAbilities(ability:GetName(), swapname, false, true)
	swapability:SetAbilityIndex(index)
end

function CDOTABaseAbility:ApplyAOE(particles, sound, location, radius, damage, damage_type, modifier, duration)
    if duration == nil then
        duration = self:GetAbilityDuration()
    end
    if radius == nil then
        radius = self:GetCaster():GetHullRadius()*2
    end
    if damage_type == nil then
        damage_type = self:GetAbilityDamageType()
    end
    if sound ~= nil then
        StartSoundEventFromPosition(sound,location)
    end
	if location == nil then
		location = self:GetCaster():GetAbsOrigin()
	end
	if particles then
		local AOE_effect = ParticleManager:CreateParticle(particles, PATTACH_ABSORIGIN  , self:GetCaster())
		ParticleManager:SetParticleControl(AOE_effect, 0, location)
		ParticleManager:SetParticleControl(AOE_effect, 1, location)
		Timers:CreateTimer(duration,function()
			ParticleManager:DestroyParticle(AOE_effect, false)
		end)
	end

    local nearbyUnits = FindUnitsInRadius(self:GetCaster():GetTeam(),
                                  location,
                                  nil,
                                  radius,
                                  self:GetAbilityTargetTeam(),
                                  self:GetAbilityTargetType(),
                                  self:GetAbilityTargetFlags(),
                                  FIND_ANY_ORDER,
                                  false)

    for _,unit in pairs(nearbyUnits) do
        if unit ~= self:GetCaster() then
                if unit:GetUnitName()~="npc_dota_courier" and unit:GetUnitName()~="npc_dota_flying_courier" then
					if damage and damage_type then
						local damageTableAoe = {victim = unit,
									attacker = self:GetCaster(),
									damage = damage,
									damage_type = damage_type,
									ability = self,
									}
						ApplyDamage(damageTableAoe)
					end
					if modifier and unit:IsAlive() and not unit:HasModifier(modifier) then
						if self:GetClassname() == "ability_lua" then
							unit:AddNewModifier( self:GetCaster(), self, modifier, { duration = duration } )
						elseif self:GetClassname() == "ability_datadriven" then
							self:ApplyDataDrivenModifier(self:GetCaster(), unit, modifier , { duration = duration })
						end
					end
                end
        end
    end
end

function get_octarine_multiplier(caster)
    local octarine_multiplier = 1
    for itemSlot = 0, 5, 1 do
        local Item = caster:GetItemInSlot( itemSlot )
        if Item ~= nil and Item:GetName() == "item_octarine_core" then
            if octarine_multiplier > 0.75 then
                octarine_multiplier = 0.75
            end
        end
        if Item ~= nil and Item:GetName() == "item_octarine_core2" then
            if octarine_multiplier > 0.67 then
                octarine_multiplier = 0.67
            end
        end
        if Item ~= nil and Item:GetName() == "item_octarine_core3" then
            if octarine_multiplier > 0.5 then
                octarine_multiplier = 0.5
            end
        end
        if Item ~= nil and Item:GetName() == "item_octarine_core4" then
            if octarine_multiplier > 0.33 then
                octarine_multiplier =0.33
            end
        end
		if Item ~= nil and Item:GetName() == "item_octarine_core5" then
            if octarine_multiplier > 0.25 then
                octarine_multiplier = 0.25
            end
        end
		if Item ~= nil and Item:GetName() == "item_asura_core" then
            if octarine_multiplier > 0.25 then
                octarine_multiplier = 0.25
            end
        end
    end
	local talentMult = 1 - caster:HighestTalentTypeValue("cooldown_reduction")/100
	octarine_multiplier = octarine_multiplier*talentMult
    return octarine_multiplier
end


function get_core_cdr(caster)
    local octarine_multiplier = 1
    for itemSlot = 0, 5, 1 do
        local Item = caster:GetItemInSlot( itemSlot )
        if Item ~= nil and Item:GetName() == "item_octarine_core" then
			local cdr = 1 - Item:GetSpecialValueFor("bonus_cooldown") / 100
            if octarine_multiplier > cdr then
                octarine_multiplier = cdr
            end
        end
        if Item ~= nil and Item:GetName() == "item_octarine_core2" then
            local cdr = 1 - Item:GetSpecialValueFor("bonus_cooldown") / 100
            if octarine_multiplier > cdr then
                octarine_multiplier = cdr
            end
        end
        if Item ~= nil and Item:GetName() == "item_octarine_core3" then
            local cdr = 1 - Item:GetSpecialValueFor("bonus_cooldown") / 100
            if octarine_multiplier > cdr then
                octarine_multiplier = cdr
            end
        end
        if Item ~= nil and Item:GetName() == "item_octarine_core4" then
            local cdr = 1 - Item:GetSpecialValueFor("bonus_cooldown") / 100
            if octarine_multiplier > cdr then
                octarine_multiplier = cdr
            end
        end
		if Item ~= nil and Item:GetName() == "item_octarine_core5" then
            local cdr = 1 - Item:GetSpecialValueFor("bonus_cooldown") / 100
            if octarine_multiplier > cdr then
                octarine_multiplier = cdr
            end
        end
		if Item ~= nil and Item:GetName() == "item_asura_core" then
            local cdr = 1 - Item:GetSpecialValueFor("bonus_cooldown") / 100
            if octarine_multiplier > cdr then
                octarine_multiplier = cdr
            end
        end
    end
    return octarine_multiplier
end


function ApplyKnockback( keys )
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, keys.modifier, {duration = keys.duration})
	if keys.target:IsInvulnerable() or keys.target:IsMagicImmune() then return end
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    -- Position variables
    local target_origin = target:GetAbsOrigin()
    local target_initial_x = target_origin.x
    local target_initial_y = target_origin.y
    local target_initial_z = target_origin.z
    local position = Vector(target_initial_x, target_initial_y, target_initial_z)  --This is updated whenever the target has their position changed.
    
    local duration = keys.duration
    local begin_time = GameRules:GetGameTime()
   	if keys.distance > 0 then
   		local len = ( target:GetAbsOrigin() - caster:GetAbsOrigin() ):Length2D()
   		local vector = ( target:GetAbsOrigin() - caster:GetAbsOrigin() )/len
   		local travel_distance = vector * keys.distance
   		local number_of_frame = duration*(1/.03)
   		local travel_distance_per_frame = travel_distance/number_of_frame
   		Timers:CreateTimer(duration,function()
   			FindClearSpaceForUnit(target, position, true)
   		end)
   		print (travel_distance_per_frame)
   		Timers:CreateTimer(0.03 ,function()
   			if GameRules:GetGameTime() <= begin_time+duration then
	   			position = position+travel_distance_per_frame
	   			target:SetAbsOrigin(position)
	   			return 0.03
	   		else
	   			return
	   		end
   		end)

    elseif keys.height > 0 then
    	keys.target:EmitSound("Hero_Invoker.Tornado.Target")
   		local turnado_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_tornado_child.vpcf", PATTACH_ABSORIGIN , target)
		ParticleManager:SetParticleControl(turnado_effect, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(turnado_effect, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(turnado_effect, 2, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(turnado_effect, 3, target:GetAbsOrigin())

		Timers:CreateTimer(keys.duration,function()
   			keys.target:StopSound("Hero_Invoker.Tornado.Target")
   			ParticleManager:DestroyParticle(turnado_effect, false)
   			target:RemoveModifierByName( "item_sheepstick_2_effect" )
   		end)
   		

	    local ground_position = GetGroundPosition(position, target)
	    local cyclone_initial_height = keys.height + ground_position.z
	    local cyclone_min_height = keys.height + ground_position.z + 10
	    local cyclone_max_height = keys.height + ground_position.z + 110
	    local tornado_start = GameRules:GetGameTime()

	    -- Height per time calculation
	    local time_to_reach_initial_height = duration / 10  --1/10th of the total cyclone duration will be spent ascending and descending to and from the initial height.
	    local initial_ascent_height_per_frame = ((cyclone_initial_height - position.z) / time_to_reach_initial_height) * .03  --This is the height to add every frame when the unit is first cycloned, and applies until the caster reaches their max height.
	    
	    local up_down_cycle_height_per_frame = initial_ascent_height_per_frame / 3  --This is the height to add or remove every frame while the caster is in up/down cycle mode.
	    if up_down_cycle_height_per_frame > 7.5 then  --Cap this value so the unit doesn't jerk up and down for short-duration cyclones.
	        up_down_cycle_height_per_frame = 7.5
	    end
	    
	    local final_descent_height_per_frame = nil  --This is calculated when the unit begins descending.

	    -- Time to go down
	    local time_to_stop_fly = duration - time_to_reach_initial_height

	    -- Loop up and down
	    local going_up = true

	    -- Loop every frame for the duration
	    Timers:CreateTimer(function()
	        local time_in_air = GameRules:GetGameTime() - tornado_start
	        
	        -- First send the target to the cyclone's initial height.
	        if position.z < cyclone_initial_height and time_in_air <= time_to_reach_initial_height then
	            --print("+",initial_ascent_height_per_frame,position.z)
	            position.z = position.z + initial_ascent_height_per_frame
	            target:SetAbsOrigin(position)
	            return 0.03

	        -- Go down until the target reaches the ground.
	        elseif time_in_air > time_to_stop_fly and time_in_air <= duration then
	            --Since the unit may be anywhere between the cyclone's min and max height values when they start descending to the ground,
	            --the descending height per frame must be calculated when that begins, so the unit will end up right on the ground when the duration is supposed to end.
	            if final_descent_height_per_frame == nil then
	                local descent_initial_height_above_ground = position.z - ground_position.z
	                --print("ground position: " .. GetGroundPosition(position, target).z)
	                --print("position.z : " .. position.z)
	                final_descent_height_per_frame = (descent_initial_height_above_ground / time_to_reach_initial_height) * .03
	            end
	            
	            --print("-",final_descent_height_per_frame,position.z)
	            position.z = position.z - final_descent_height_per_frame
	            target:SetAbsOrigin(position)
	            return 0.03

	        -- Do Up and down cycles
	        elseif time_in_air <= duration then
	            -- Up
	            if position.z < cyclone_max_height and going_up then 
	                --print("going up")
	                position.z = position.z + up_down_cycle_height_per_frame
	                target:SetAbsOrigin(position)
	                return 0.03

	            -- Down
	            elseif position.z >= cyclone_min_height then
	                going_up = false
	                --print("going down")
	                position.z = position.z - up_down_cycle_height_per_frame
	                target:SetAbsOrigin(position)
	                return 0.03

	            -- Go up again
	            else
	                --print("going up again")
	                going_up = true
	                return 0.03
	            end

	        -- End
	        else
	            --print(GetGroundPosition(target:GetAbsOrigin(), target))
	            --print("End TornadoHeight")
	        end
	    end)
	end
end