EHP_PER_ARMOR = 0.01
DOTA_LIFESTEAL_SOURCE_NONE = 0
DOTA_LIFESTEAL_SOURCE_ATTACK = 1
DOTA_LIFESTEAL_SOURCE_ABILITY = 2

function SendClientSync(key, value)
	CustomNetTables:SetTableValue( "syncing_purposes",key, {value = value} )
end

function GetClientSync(key)
 	local value = CustomNetTables:GetTableValue( "syncing_purposes", key).value
	CustomNetTables:SetTableValue( "syncing_purposes",key, {} )
	return value
end

function HasValInTable(checkTable, val)
	for key, value in pairs(checkTable) do
		if value == val then return true end
	end
	return false
end

function TernaryOperator(value, bCheck, default)
	if bCheck then 
		return value 
	else 
		return default
	end
end

function GetPerpendicularVector(vector)
	return Vector(vector.y, -vector.x)
end

function ActualRandomVector(maxLength, flMinLength)
	local minLength = flMinLength or 0
	return RandomVector(RandomInt(minLength, maxLength))
end

function HasBit(checker, value)
	return bit.band(checker, value) == value
end

function toboolean(thing)
	if type(thing) == "number" then
		if thing == 1 then return true
		elseif thing == 0 then return false
		else error("number type not 1 or 0") end
	elseif type(thing) == "string" then
		if thing == "true" or thing == "1" then return true
		elseif thing == "false" or thing == "0" then return false
		else error("string type not true or false") end
	end
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

function CDOTA_BaseNPC_Hero:CreateSummon(unitName, position, duration)
	local summon = CreateUnitByName(unitName, position, true, self, nil, self:GetTeam())
	summon:SetControllableByPlayer(self:GetPlayerID(), true)
	self.summonTable = self.summonTable or {}
	table.insert(self.summonTable, summon)
	summon:SetOwner(self)
	summon:AddNewModifier(self, nil, "modifier_summon_handler", {duration = duration})
	if duration and duration > 0 then
		summon:AddNewModifier(self, nil, "modifier_kill", {duration = duration})
	end
	StartAnimation(summon, {activity = ACT_DOTA_SPAWN, rate = 1.5, duration = 2})
	return summon
end

function CDOTA_BaseNPC_Hero:RemoveSummon(entity)
	for id,ent in pairs(self.summonTable) do
		if ent == entity then
			table.remove(self.summonTable, id)
		end
	end
end

function CDOTA_BaseNPC_Hero:GetBarrier()
	return self._barrierHP or 0
end

function CDOTA_BaseNPC_Hero:SetBarrier(amt)
	self._barrierHP = amt
end

function CDOTA_BaseNPC_Hero:SetRelic(relicEntity)
	if self.equippedRelic then self.equippedRelic:Destroy() end
	self.equippedRelic = relicEntity
end

function CDOTA_BaseNPC_Hero:GetRelic()
	return self.equippedRelic
end

function CDOTA_BaseNPC:IsBeingAttacked()
	local enemies = FindUnitsInRadius(self:GetTeam(), self:GetAbsOrigin(), nil, 999999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
	for _, enemy in pairs(enemies) do
		if enemy:IsAttackingEntity(self) then return true end
	end
	return false
end

function CDOTA_BaseNPC:PerformAbilityAttack(target, bProcs, ability)
	self.autoAttackFromAbilityState = {} -- basically the same as setting it to true
	self.autoAttackFromAbilityState.ability = ability
	self:PerformAttack(target,bProcs,bProcs,true,false,false,false,true)
	Timers:CreateTimer(function() self.autoAttackFromAbilityState = nil end)
end

function CDOTA_BaseNPC:PerformGenericAttack(target, immediate)
	self:PerformAttack(target, true, true, true, false, not immediate, false, false)
end

function CDOTA_Modifier_Lua:AttachEffect(pID)
	self:AddParticle(pID, false, false, 0, false, false)
end

function CDOTA_Modifier_Lua:GetSpecialValueFor(specVal)
	return self:GetAbility():GetSpecialValueFor(specVal)
end

function CDOTABaseAbility:DealDamage(attacker, victim, damage, data, spellText)
	--OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, OVERHEAD_ALERT_DAMAGE, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, OVERHEAD_ALERT_MANA_LOSS
	local internalData = data or {}
	local damageType =  internalData.damage_type or self:GetAbilityDamageType() or DAMAGE_TYPE_MAGICAL
	local damageFlags = internalData.damage_flags or self:GetAbilityTargetFlags() or DOTA_DAMAGE_FLAG_NONE
	local localdamage = damage
	local spellText = spellText or 0
	local ability = self or internalData.ability
	local returnDamage = ApplyDamage({victim = victim, attacker = attacker, ability = ability, damage_type = damageType, damage = localdamage, damage_flags = damageFlags})
	if spellText > 0 then
		SendOverheadEventMessage(attacker:GetPlayerOwner(),spellText,victim,returnDamage,attacker:GetPlayerOwner()) --Substract the starting health by the new health to get exact damage taken values.
	end
	return returnDamage
end

function CDOTA_BaseNPC:DealAOEDamage(position, radius, damageTable)
	local team = self:GetTeamNumber()
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = FIND_ANY_ORDER
	local AOETargets = FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
	for _, target in pairs(AOETargets) do
		ApplyDamage({ victim = target, attacker = self, damage = damageTable.damage, damage_type = damageTable.damage_type, ability = damageTable.ability})
	end
end

function CDOTA_BaseNPC:DealMaxHPAOEDamage(position, radius, damage_pct, damage_type)
	local team = self:GetTeamNumber()
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = FIND_ANY_ORDER
	local AOETargets = FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
	for _, target in pairs(AOETargets) do
		ApplyDamage({ victim = target, attacker = self, damage = target:GetMaxHealth() * damage_pct / 100, damage_type = damage_type})
	end
end


function FindUnitsInCone(teamNumber, vDirection, vPosition, flSideRadius, flLength, hCacheUnit, targetTeam, targetUnit, targetFlags, findOrder, bCache)
	local vDirectionCone = Vector( vDirection.y, -vDirection.x, 0.0 )
	local enemies = FindUnitsInRadius(teamNumber, vPosition, hCacheUnit, flSideRadius + flLength, targetTeam, targetUnit, targetFlags, findOrder, bCache )
	local unitTable = {}
	if #enemies > 0 then
		for _,enemy in pairs(enemies) do
			if enemy ~= nil then
				local vToPotentialTarget = enemy:GetOrigin() - vPosition
				local flSideAmount = math.abs( vToPotentialTarget.x * vDirectionCone.x + vToPotentialTarget.y * vDirectionCone.y + vToPotentialTarget.z * vDirectionCone.z )
				local flLengthAmount = ( vToPotentialTarget.x * vDirection.x + vToPotentialTarget.y * vDirection.y + vToPotentialTarget.z * vDirection.z )
				if ( flSideAmount < flSideRadius ) and ( flLengthAmount > 0.0 ) and ( flLengthAmount < flLength ) then
					table.insert(unitTable, enemy)
				end
			end
		end
	end
	return unitTable
end

-- New taunt mechanics
function CDOTA_BaseNPC:GetTauntTarget()
	local target = nil
	for _, modifier in pairs(self:FindAllModifiers()) do
		if modifier.GetTauntTarget and not target then 
			target = modifier:GetTauntTarget()
		elseif modifier.GetTauntTarget and target and CalculateDistance(target, self) < CalculateDistance(modifier:GetTauntTarget(), self) then 
			target = modifier:GetTauntTarget()
		end
	end
	return target
end

function CDOTA_BaseNPC:AddAbilityPrecache(abName)
	PrecacheItemByNameAsync( abName, function() end)
	return self:AddAbility(abName)
end

function get_aether_multiplier(caster)
    local aether_multiplier = 1
    for itemSlot = 0, 5, 1 do
        local Item = caster:GetItemInSlot( itemSlot )
		if Item ~= nil then
			local itemAmp = Item:GetSpecialValueFor("spell_amp")/100
			aether_multiplier = aether_multiplier + itemAmp
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

function CDOTA_PlayerResource:FindActivePlayerCount()
	local playerCounter = 0
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
			if hero then
				if PlayerResource:GetConnectionState(hero:GetPlayerID()) == 2 then
					if not hero.lastActiveTime then hero.lastActiveTime = GameRules:GetGameTime() end
					if hero.lastActiveTime + 60*3 > GameRules:GetGameTime() then
						playerCounter = playerCounter + 1
					end
				end
			end
		end
	end
	return playerCounter
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

function PrintAll(t)
	for k,v in pairs(t) do
		print(k,v)
	end
end

function table.removekey(t1, key)
    for k,v in pairs(t1) do
		if k == key then
			table.remove(t1,k)
		end
	end
end

function table.removeval(t1, val)
    for k,v in pairs(t1) do
		if t1[k] == val then
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
	local resourceType = GameRules.UnitKV[self:GetUnitName()]["IsSpawner"]
	if resourceType then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IsCore()
	local resourceType = GameRules.UnitKV[self:GetUnitName()]["IsCore"]
	if resourceType == 1 or self.Holdout_IsCore then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IsElite()
	self.elite = self.elite or false
	return self.elite
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
	return value
end

function CDOTA_BaseNPC:FindTalentValue(talentName, value)
	if self:HasAbility(talentName) then
		return self:FindAbilityByName(talentName):GetSpecialValueFor(value or "value")
	end
	return 0
end

function CDOTA_BaseNPC:FindSpecificTalentValue(talentName, value)
	if self:HasAbility(talentName) then
		return self:FindAbilityByName(talentName):GetSpecialValueFor(value)
	end
	return 0
end

function CDOTA_BaseNPC:NotDead()
	if self:IsAlive() or 
	self:IsReincarnating() or 
	self.resurrectionStoned then
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
	if self.delayedCooldownTimer then self:EndDelayedCooldown() end
    self:EndCooldown()
end

function CDOTABaseAbility:GetTrueCastRange()
	local castrange = self:GetCastRange()
	castrange = castrange + get_aether_range(self:GetCaster())
	return castrange
end

function CDOTA_Ability_Lua:GetTrueCastRange()
	local castrange = self:GetCastRange(self:GetCaster():GetAbsOrigin(), self:GetCaster())
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
	   self:HasModifier("modifier_hawk_spirit_enemy") or 
	   self:HasModifier("item_sange_and_yasha_4_debuff") or 
	   self:HasModifier("cursed_effect") then
	return true
	else return false end
end

function CDOTA_BaseNPC:GetStunResistance()
	if self:IsCreature() then
		local stunResist = GameRules.UnitKV[self:GetUnitName()]["Creature"]["StunResistance"] or 0
		for _, modifier in pairs( self:FindAllModifiers() ) do
			if modifier.GetModifierBonusStunResistance_Constant then stunResist = stunResist + modifier:GetModifierBonusStunResistance_Constant() end
		end
		return  math.min(100, math.max(0, stunResist))
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
	self.previousProjectileModel = self.currentProjectileModel or self:GetBaseProjectileModel()
	self.currentProjectileModel = projectile
end

function CDOTA_BaseNPC:RevertProjectile()
	self:SetRangedProjectileName(self.previousProjectileModel)
	local newModel = self.previousProjectileModel
	self.previousProjectileModel = self.currentProjectileModel
	self.currentProjectileModel = newModel
end


function CDOTA_BaseNPC:GetAngleDifference(hEntity)
	-- The y value of the angles vector contains the angle we actually want: where units are directionally facing in the world.
	local victim_angle = hEntity:GetAnglesAsVector().y
	local origin_difference = hEntity:GetAbsOrigin() - self:GetAbsOrigin()

	-- Get the radian of the origin difference between the attacker and Riki. We use this to figure out at what angle the victim is at relative to Riki.
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	
	-- Convert the radian to degrees.
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
	attacker_angle = attacker_angle + 180.0
	
	-- Finally, get the angle at which the victim is facing Riki.
	local result_angle = (attacker_angle - victim_angle)
	result_angle = math.abs(result_angle)
	return result_angle
end

function CDOTA_BaseNPC:IsAtAngleWithEntity(hEntity, flDesiredAngle)
	local angleDiff = self:GetAngleDifference(hEntity)
	if angleDiff >= (180 - flDesiredAngle / 2) and angleDiff <= (180 + flDesiredAngle / 2) then 
		return true
	else
		return false
	end
end
	

function CDOTA_BaseNPC:RefreshAllCooldowns(bItems)
    for i = 0, self:GetAbilityCount() - 1 do
        local ability = self:GetAbilityByIndex( i )
        if ability then
			ability:Refresh()
			if ability:GetName() == "skeleton_king_reincarnation" then
				self:RemoveModifierByName("modifier_skeleton_king_reincarnation_cooldown")
			end
        end
    end
	if bItems then
		for i=0, 5, 1 do
			local current_item = self:GetItemInSlot(i)
			if current_item ~= nil and current_item ~= item then
				current_item:Refresh()
			end
		end
	end
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
	
	local player = PlayerResource:GetPlayer(self:GetPlayerID())
	PlayerResource:SortThreat()
	local event_data =
	{
		threat = self.threat,
		lastHit = self.lastHit,
		aggro = self.aggro
	}
	if player then
		CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
	end
	
	return self.threat
end

function CDOTA_BaseNPC:SetThreat(val)
	self.lastHit = GameRules:GetGameTime()
	self.threat = val
	
	local player = PlayerResource:GetPlayer(self:GetPlayerID())
	PlayerResource:SortThreat()
	local event_data =
	{
		threat = self.threat,
		lastHit = self.lastHit,
		aggro = self.aggro
	}
	if player then
		CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
	end
end

function CDOTA_BaseNPC:ModifyThreat(val)
	self.lastHit = GameRules:GetGameTime()
	self.threat = (self.threat or 0) + val
	
	local player = PlayerResource:GetPlayer(self:GetPlayerID())
	PlayerResource:SortThreat()
	local event_data =
	{
		threat = self.threat,
		lastHit = self.lastHit,
		aggro = self.aggro
	}
	if player then
		CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
	end
end

function CDOTA_BaseNPC:GetLastHitTime()
	return self.lastHit
end



function get_aether_range(caster)
    local aether_range = 0
    for itemSlot = 0, 5, 1 do
        local Item = caster:GetItemInSlot( itemSlot )
		if Item ~= nil then
			local itemRange = Item:GetSpecialValueFor("cast_range_bonus")
			if aether_range < itemRange then
				aether_range = itemRange
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
	local armor_reduction = 1 - (0.05 * armornpc) / (1 + (0.05 * math.abs(armornpc)))
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
	if self:IsIllusion() or (self:HasModifier("modifier_monkey_king_fur_army_soldier") or self:HasModifier("modifier_monkey_king_fur_army_soldier_hidden")) or self:IsTempestDouble() then
		return true
	else return false end
end

function CDOTA_Buff:IsStun()
	if GLOBAL_STUN_LIST[self:GetName()] then return true else return false end
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
	local valname = "value"
	local multiply = false
	local kv = self:GetAbilityKeyValues()
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
					if m["LinkedSpecialBonusField"] then valname = m["LinkedSpecialBonusField"] end
					if m["LinkedSpecialBonusOperation"] and m["LinkedSpecialBonusOperation"] == "SPECIAL_BONUS_MULTIPLY" then multiply = true end
				end
			end
		end
	end
	if talentName then 
		local talent = self:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then 
			if multiply then
				base = base * talent:GetSpecialValueFor(valname) 
			else
				base = base + talent:GetSpecialValueFor(valname) 
			end
		end
	end
	return base
end

function CDOTA_Modifier_Lua:GetTalentSpecialValueFor(value)
	return self:GetAbility():GetTalentSpecialValueFor(value)
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
		ampint = self:GetIntellect() / 1400
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

function CDOTABaseAbility:SetCooldown(fCD)
	if fCD then
		self:EndCooldown()
		self:StartCooldown(fCD)
	else
		self:UseResources(false, false, true)
	end
end

function CDOTABaseAbility:StartDelayedCooldown(flDelay)
	if self.delayedCooldownTimer then
		self:EndDelayedCooldown()
	end
	self:EndCooldown()
	self:UseResources(false, false, true)
	local cd = self:GetCooldownTimeRemaining()
	local ability = self
	self.delayedCooldownTimer = Timers:CreateTimer(0, function()
		ability:EndCooldown()
		ability:StartCooldown(cd)
		return 0
	end)
	if flDelay then
		Timers:CreateTimer(flDelay, function() ability:EndDelayedCooldown() end)
	end
end

function CDOTABaseAbility:EndDelayedCooldown()
	if self.delayedCooldownTimer then
		Timers:RemoveTimer(self.delayedCooldownTimer)
		self.delayedCooldownTimer = nil
	end
end

function CDOTABaseAbility:ModifyCooldown(amt)
	local currCD = self:GetCooldownTimeRemaining()
	self:EndCooldown()
	self:StartCooldown(currCD + amt)
end

function CScriptHeroList:GetRealHeroes()
	local heroes = self:GetAllHeroes()
	local realHeroes = {}
	for _,hero in pairs(heroes) do
		if hero:IsRealHero() and not (hero:HasModifier("modifier_monkey_king_fur_army_soldier") or hero:HasModifier("modifier_monkey_king_fur_army_soldier_hidden")) then
			table.insert(realHeroes, hero)
		end
	end
	return realHeroes
end

function CScriptHeroList:GetRealHeroCount()
	local heroes = self:GetAllHeroes()
	local realHeroes = {}
	for _,hero in pairs(heroes) do
		if hero:IsRealHero() and not (hero:HasModifier("modifier_monkey_king_fur_army_soldier") or hero:HasModifier("modifier_monkey_king_fur_army_soldier_hidden")) then
			table.insert(realHeroes, hero)
		end
	end
	return #self:GetRealHeroes()
end

function CScriptHeroList:GetActiveHeroes()
	local heroes = self:GetAllHeroes()
	local activeHeroes = {}
	for _, hero in pairs(heroes) do
		if hero:GetPlayerOwner() and hero:IsRealHero() then
			table.insert(activeHeroes, hero)
		end
	end
	return activeHeroes
end

function CScriptHeroList:GetActiveHeroCount()
	return #self:GetActiveHeroes()
end

function RotateVector2D(vector, theta)
    local xp = vector.x*math.cos(theta)-vector.y*math.sin(theta)
    local yp = vector.x*math.sin(theta)+vector.y*math.cos(theta)
    return Vector(xp,yp,vector.z):Normalized()
end

function ToRadians(degrees)
	return degrees * math.pi / 180
end

function ToDegrees(radians)
	return radians * 180 / math.pi 
end

function CDOTA_BaseNPC:IsSameTeam(unit)
	return (self:GetTeamNumber() == unit:GetTeamNumber())
end

function CDOTA_BaseNPC:AddBarrier(amount, caster, ability, duration)
	self:AddNewModifier(caster, ability, "modifier_generic_barrier", {duration = duration, barrier = amount})
end

function CDOTA_BaseNPC:Lifesteal(source, lifestealPct, damage, target, damage_type, iSource)
	local damageDealt = damage or 0
	local sourceType = iSource or DOTA_LIFESTEAL_SOURCE_NONE
	if sourceType == DOTA_LIFESTEAL_SOURCE_ABILITY then
		local oldHP = target:GetHealth()
		ApplyDamage({victim = target, attacker = self, damage = damage, damage_type = damage_type, ability = source})
		damageDealt = math.abs(oldHP - target:GetHealth())
	elseif sourceType == DOTA_LIFESTEAL_SOURCE_ATTACK then
		local oldHP = target:GetHealth()
		self:PerformAttack(target, true, true, true, true, false, false, false)
		damageDealt = math.abs(oldHP - target:GetHealth())
	end
	local flHeal = damageDealt * lifestealPct / 100
	self:HealEvent(flHeal, source, self)
	local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
		ParticleManager:SetParticleControlEnt(lifesteal, 0, self, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(lifesteal, 1, self, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(lifesteal)
end

function CDOTA_BaseNPC:HealEvent(amount, sourceAb, healer) -- for future shit
	local healBonus = 1
	local flAmount = amount
	if healer then
		for _,modifier in ipairs( healer:FindAllModifiers() ) do
			if modifier.GetOnHealBonus then
				healBonus = healBonus + ((modifier:GetOnHealBonus() or 0)/100)
			end
		end
	end
	
	flAmount = flAmount * healBonus
	local params = {amount = flAmount, source = sourceAb, unit = healer, target = self}
	local units = self:FindAllUnitsInRadius(self:GetAbsOrigin(), -1)
	
	for _, unit in ipairs(units) do
		if unit.FindAllModifiers then
			for _, modifier in ipairs( unit:FindAllModifiers() ) do
				if modifier.OnHealed then
					modifier:OnHealed(params)
				end
				if modifier.OnHeal then
					modifier:OnHeal(params)
				end
				if modifier.OnHealRedirect then
					local reduction = modifier:OnHealRedirect(params) or 0
					flAmount = flAmount + reduction
				end
			end
		end
	end
	SendOverheadEventMessage(self, OVERHEAD_ALERT_HEAL, self, flAmount, healer)
	self:Heal(flAmount, sourceAb)
end

function CDOTA_BaseNPC:SwapAbilityIndexes(index, swapname)
	local ability = self:GetAbilityByIndex(index)
	local swapability = self:FindAbilityByName(swapname)
	self:SwapAbilities(ability:GetName(), swapname, false, true)
	swapability:SetAbilityIndex(index)
end

function CDOTA_BaseNPC:ApplyLinearKnockback(distance, strength, source)
	local direction = (self:GetAbsOrigin() - source:GetAbsOrigin()):Normalized()
	self.isInKnockbackState = true
	local distance_traveled = 0
	local distAdded = (distance/0.2)*FrameTime() * strength
	StartAnimation(self, {activity = ACT_DOTA_FLAIL, rate = 1, duration = distAdded/distance})
	Timers:CreateTimer(function ()
		if not self:GetParent():HasMovementCapability() then return end
		if distance_traveled < distance and self:IsAlive() and not self:IsNull() then
			self:SetAbsOrigin(self:GetAbsOrigin() + direction * distAdded)
			distance_traveled = distance_traveled + distAdded
			return FrameTime()
		else
			FindClearSpaceForUnit(self, self:GetAbsOrigin(), true)
			self.isInKnockbackState = false
			return nil
		end 
	end)
end

function CDOTA_BaseNPC:IsKnockedBack()
	return self.isInKnockbackState
end


function FindAllUnits()
	local team = DOTA_TEAM_GOODGUYS
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_BOTH
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
	local iOrder = data.order or FIND_ANY_ORDER
	return FindUnitsInRadius(team, Vector(0,0), nil, -1, iTeam, iType, iFlag, iOrder, false)
end

function CDOTA_BaseNPC:FindEnemyUnitsInLine(startPos, endPos, width, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end

function CDOTA_BaseNPC:FindFriendlyUnitsInLine(startPos, endPos, width, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end

function CDOTA_BaseNPC:FindAllUnitsInLine(startPos, endPos, width, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end


function CDOTA_BaseNPC:FindEnemyUnitsInRing(position, maxRadius, minRadius, hData)
	if not self:IsNull() then
		local team = self:GetTeamNumber()
		local data = hData or {}
		local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	
		local innerRing = FindUnitsInRadius(team, position, nil, minRadius, iTeam, iType, iFlag, iOrder, false)
		local outerRing = FindUnitsInRadius(team, position, nil, maxRadius, iTeam, iType, iFlag, iOrder, false)
		
		local resultTable = {}
		for _, unit in ipairs(outerRing) do
			local addToTable = true
			for _, exclude in ipairs(innerRing) do
				if unit == exclude then
					addToTable = false
					break
				end
			end
			if addToTable then
				table.insert(resultTable, unit)
			end
		end
		return resultTable
		
	else return {} end
end

function CDOTA_BaseNPC:FindEnemyUnitsInRadius(position, radius, hData)
	if not self:IsNull() then
		local team = self:GetTeamNumber()
		local data = hData or {}
		local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
		local iOrder = data.order or FIND_ANY_ORDER
		return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
	else return {} end
end

function CDOTA_BaseNPC:FindFriendlyUnitsInRadius(position, radius, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = data.order or FIND_ANY_ORDER
	return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
end

function CDOTA_BaseNPC:FindAllUnitsInRadius(position, radius, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_BOTH
	local iType = data.type or DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = data.order or FIND_ANY_ORDER
	return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
end

function ParticleManager:FireWarningParticle(position, radius)
	local thinker = ParticleManager:CreateParticle("particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(thinker, 0, position)
			ParticleManager:SetParticleControl(thinker, 2, Vector(6,0,1))
			ParticleManager:SetParticleControl(thinker, 1, Vector(radius,0,0))
			ParticleManager:SetParticleControl(thinker, 3, Vector(255,0,0))
			ParticleManager:SetParticleControl(thinker, 4, Vector(0,0,0))
	ParticleManager:ReleaseParticleIndex(thinker)
end

function ParticleManager:FireLinearWarningParticle(vStartPos, vEndPos, vWidth)
	local width = Vector(vWidth, vWidth, vWidth)
	local fx = ParticleManager:FireParticle("particles/range_ability_line.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = vStartPos,
																											[1] = vEndPos,
																											[2] = width} )																						
end

function ParticleManager:FireTargetWarningParticle(target)
	local fx = ParticleManager:FireParticle("particles/generic/generic_marker.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
end

function ParticleManager:FireParticle(effect, attach, owner, cps)
	local FX = ParticleManager:CreateParticle(effect, attach, owner)
	if cps then
		for cp, value in pairs(cps) do
			if type(value) == "userdata" then
				ParticleManager:SetParticleControl(FX, tonumber(cp), value)
			else
				ParticleManager:SetParticleControlEnt(FX, cp, owner, attach, value, owner:GetAbsOrigin(), true)
			end
		end
	end
	ParticleManager:ReleaseParticleIndex(FX)
end

function ParticleManager:FireRopeParticle(effect, attach, owner, target, tCP)
	local FX = ParticleManager:CreateParticle(effect, attach, owner)

	ParticleManager:SetParticleControlEnt(FX, 0, owner, attach, "attach_hitloc", owner:GetAbsOrigin(), true)
	if target.GetAbsOrigin then -- npc (has getabsorigin function
		ParticleManager:SetParticleControlEnt(FX, 1, target, attach, "attach_hitloc", target:GetAbsOrigin(), true)
	else
		ParticleManager:SetParticleControl(FX, 1, target) -- vector
	end
	
	if tCP then
		for cp, value in pairs(tCP) do
			ParticleManager:SetParticleControl(FX, tonumber(cp), value)
		end
	end
	
	ParticleManager:ReleaseParticleIndex(FX)
end

function ParticleManager:ClearParticle(cFX)
	if cFX then
		self:DestroyParticle(cFX, false)
		self:ReleaseParticleIndex(cFX)
	end
end

function CDOTA_Modifier_Lua:StartMotionController()
	if not self:GetParent():IsNull() and not self:IsNull() and self.DoControlledMotion and self:GetParent():HasMovementCapability() then
		self.controlledMotionTimer = Timers:CreateTimer(FrameTime(), function()
			if self:IsNull() or self:GetParent():IsNull() then return end
			self:DoControlledMotion() 
			return FrameTime()
		end)
	else
	end
end

function CDOTA_Modifier_Lua:AddIndependentStack(duration, limit)
	if limit then
		if  self:GetStackCount() < limit then
			self:IncrementStackCount()
		else
			self:SetStackCount( limit )
			Timers:RemoveTimers(self.stackTimers[1])
			table.remove(self.stackTimers, 1)
		end
	else
		self:IncrementStackCount()
	end
	local timerID = Timers:CreateTimer(duration or self:GetDuration(), function()
		if not self:IsNull() then 
			self:DecrementStackCount()
			if self:GetStackCount() == 0 then self:Destroy() end
		end
	end)
	self.stackTimers = self.stackTimers or {}
	table.insert(self.stackTimers, timerID)
end


function CDOTA_Modifier_Lua:StopMotionController()
	Timers:RemoveTimer(self.controlledMotionTimer)
end

function CDOTA_Modifier_Lua:AddEffect(id)
	self:AddParticle(id, false, false, 0, false, false)
end

function CDOTA_Modifier_Lua:AddStatusEffect(id, priority)
	self:AddParticle(id, false, true, priority, false, false)
end

function CDOTA_Modifier_Lua:AddOverHeadEffect(id)
	self:AddParticle(id, false, false, 0, false, true)
end

function CDOTA_Modifier_Lua:AddHeroEffect(id)
	self:AddParticle(id, false, false, 0, true, false)
end

function CDOTA_BaseNPC:FindRandomEnemyInRadius(position, radius, data)
	for _, unit in ipairs(self:FindEnemyUnitsInRadius(position, radius, data)) do
		return unit
	end
end

function CDOTA_BaseNPC:Dispel(hCaster, bHard)
	local sameTeam = (hCaster:GetTeam() == self:GetTeam())
	self:Purge(not sameTeam, sameTeam, false, bHard, bHard)
end

function CDOTA_BaseNPC:SmoothFindClearSpace(position)
	self:SetAbsOrigin(position)
	ResolveNPCPositions(position, self:GetHullRadius() + self:GetCollisionPadding())
end

function CDOTABaseAbility:Stun(target, duration, bDelay)
	target:AddNewModifier(self:GetCaster(), self, "modifier_stunned_generic", {duration = duration, delay = bDelay})
end

function CDOTABaseAbility:FireLinearProjectile(FX, velocity, distance, width, data)
	local internalData = data or {}
	local info = {
		EffectName = FX,
		Ability = self,
		vSpawnOrigin = internalData.origin or self:GetCaster():GetAbsOrigin(), 
		fStartRadius = width,
		fEndRadius = internalData.width_end or width,
		vVelocity = velocity,
		fDistance = distance,
		Source = internalData.source or self:GetCaster(),
		iUnitTargetTeam = internalData.team or DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = internalData.type or DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		ExtraData = internalData.extraData
	}
	ProjectileManager:CreateLinearProjectile( info )
end

function CDOTABaseAbility:ApplyAOE(eventTable)
    if eventTable.duration == nil and eventTable.modifier then
        eventTable.duration = self:GetAbilityDuration()
	elseif not eventTable.duration then
		eventTable.duration = 0
    end
    if eventTable.radius == nil then
        eventTable.radius = self:GetCaster():GetHullRadius()*2
    end
    if eventTable.damage_type == nil then
        eventTable.damage_type = self:GetAbilityDamageType()
    end
	if eventTable.damage == nil then
        eventTable.damage_type = self:GetAbilityDamage()
    end
	if eventTable.location == nil then
		eventTable.location = self:GetCaster():GetAbsOrigin()
	end
	eventTable.location.z = eventTable.location.z + GetGroundHeight(eventTable.location, nil) / 2
	if eventTable.delay then
		local thinker = ParticleManager:CreateParticle("particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf", PATTACH_WORLDORIGIN , nil)
			ParticleManager:SetParticleControl(thinker, 0, eventTable.location)
			ParticleManager:SetParticleControl(thinker, 2, Vector(6,0,1))
			ParticleManager:SetParticleControl(thinker, 1, Vector(eventTable.radius,0,0))
			ParticleManager:SetParticleControl(thinker, 3, Vector(255,0,0))
			ParticleManager:SetParticleControl(thinker, 4, Vector(0,0,0))
		ParticleManager:ReleaseParticleIndex(thinker)
	else
		eventTable.delay = 0
	end
	Timers:CreateTimer(eventTable.delay,function()
		if eventTable.sound ~= nil then
			EmitSoundOnLocationWithCaster(eventTable.location, eventTable.sound, self:GetCaster())
		end
		if eventTable.particles then
			local AOE_effect = ParticleManager:CreateParticle(eventTable.particles, PATTACH_ABSORIGIN  , self:GetCaster())
			ParticleManager:SetParticleControl(AOE_effect, 0, eventTable.location)
			ParticleManager:SetParticleControl(AOE_effect, 1, eventTable.location)
			Timers:CreateTimer(eventTable.duration,function()
				ParticleManager:DestroyParticle(AOE_effect, false)
			end)
		end
		local nearbyUnits = FindUnitsInRadius(self:GetCaster():GetTeam(),
									  eventTable.location,
									  nil,
									  eventTable.radius,
									  self:GetAbilityTargetTeam(),
									  self:GetAbilityTargetType(),
									  self:GetAbilityTargetFlags(),
									  FIND_ANY_ORDER,
									  false)

		for _,unit in pairs(nearbyUnits) do
			if unit ~= self:GetCaster() then
				if unit:GetUnitName()~="npc_dota_courier" and unit:GetUnitName()~="npc_dota_flying_courier" then
					if eventTable.damage and eventTable.damage_type then
						ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = eventTable.damage, damage_type = eventTable.damage_type, ability = self})
					end
					if not unit:IsMagicImmune() or (unit:IsMagicImmune() and eventTable.magic_immune) then
						if eventTable.modifier and unit:IsAlive() and not unit:HasModifier(eventTable.modifier) then
							if self:GetClassname() == "ability_lua" then
								unit:AddNewModifier( self:GetCaster(), self, eventTable.modifier, { duration = eventTable.duration } )
							elseif self:GetClassname() == "ability_datadriven" then
								self:ApplyDataDrivenModifier(self:GetCaster(), unit, eventTable.modifier , { duration = eventTable.duration })
							end
						end
					end
				end
			end
		end
	end)
end

function get_octarine_multiplier(caster)
	local cooldown = caster:FindModifierByName("spell_lifesteal") or caster:FindModifierByName("modifier_item_octarine_core")
	local octarine_multiplier = 1
	if cooldown then
		octarine_multiplier = octarine_multiplier - cooldown:GetAbility():GetSpecialValueFor("bonus_cooldown")/100
	end
	local talentMult = 1 - caster:HighestTalentTypeValue("cooldown_reduction")/100
	octarine_multiplier = octarine_multiplier*talentMult
    return octarine_multiplier
end


function get_core_cdr(caster)
    local octarine_multiplier = 1
    for itemSlot = 0, 5, 1 do
        local Item = caster:GetItemInSlot( itemSlot )
        if Item ~= nil then
            local cdr = 1 - Item:GetSpecialValueFor("bonus_cooldown") / 100
            if octarine_multiplier > cdr then
                octarine_multiplier = cdr
            end
        end
    end
    return octarine_multiplier
end

function CDOTAGamerules:GetMaxRound()
	return GameRules.maxRounds
end

function CDOTAGamerules:GetCurrentRound()
	return GameRules._roundnumber
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
			for i = 0, 23 do
				local sourceAb = caster:GetAbilityByIndex(i)
				if sourceAb and sourceAb.onKnockBack then
					sourceAb:onKnockBack()
				end
				local victimAb = target:GetAbilityByIndex(i)
				if victimAb and victimAb.onKnockedBack then
					victimAb:onKnockedBack()
				end
			end
   		end)
   		Timers:CreateTimer(0.03 ,function()
			if target and not target:IsNull() and not target:HasMovementCapability() then return end
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
	            position.z = position.z + initial_ascent_height_per_frame
	            target:SetAbsOrigin(position)
	            return 0.03

	        -- Go down until the target reaches the ground.
	        elseif time_in_air > time_to_stop_fly and time_in_air <= duration then
	            --Since the unit may be anywhere between the cyclone's min and max height values when they start descending to the ground,
	            --the descending height per frame must be calculated when that begins, so the unit will end up right on the ground when the duration is supposed to end.
	            if final_descent_height_per_frame == nil then
	                local descent_initial_height_above_ground = position.z - ground_position.z
	                final_descent_height_per_frame = (descent_initial_height_above_ground / time_to_reach_initial_height) * .03
	            end
	            
	            position.z = position.z - final_descent_height_per_frame
	            target:SetAbsOrigin(position)
	            return 0.03

	        -- Do Up and down cycles
	        elseif time_in_air <= duration then
	            -- Up
	            if position.z < cyclone_max_height and going_up then 
	                position.z = position.z + up_down_cycle_height_per_frame
	                target:SetAbsOrigin(position)
	                return 0.03

	            -- Down
	            elseif position.z >= cyclone_min_height then
	                going_up = false
	                position.z = position.z - up_down_cycle_height_per_frame
	                target:SetAbsOrigin(position)
	                return 0.03

	            -- Go up again
	            else
	                going_up = true
	                return 0.03
	            end
	        end
	    end)
	end
end

function CDOTA_BaseNPC_Hero:GetEpicBossFightName()
	local nameTable = {
		["npc_dota_hero_treant_protector"] = "forest",
		["npc_dota_hero_sven"] = "guardian",
		["npc_dota_hero_windrunner"] = "windrunner",
		["npc_dota_hero_omniknight"] = "omniknight",
		["npc_dota_hero_phantom_assassin"] = "forest",
		["npc_dota_hero_necrolyte"] = "puppeteer",
		["npc_dota_hero_treant_lina"] = "ifrit",
		["npc_dota_hero_treant_legion_commander"] = "forest",
		["npc_dota_hero_treant_dazzle"] = "mystic",
	}
	return nameTable[self:GetUnitName()] or self:GetUnitName()
end

function CDOTA_BaseNPC:AddChill(hAbility, hCaster, chillDuration)
	self:AddNewModifier(hCaster, hAbility, "modifier_chill_generic", {Duration = chillDuration}):IncrementStackCount()
end

function CDOTA_BaseNPC:GetChillCount()
	if self:HasModifier("modifier_chill_generic") then
		return self:FindModifierByName("modifier_chill_generic"):GetStackCount()
	else
		return 0
	end
end

function CDOTA_BaseNPC:SetChillCount( count )
	if self:HasModifier("modifier_chill_generic") then
		self:FindModifierByName("modifier_chill_generic"):SetStackCount(count)
	end
end

function CDOTA_BaseNPC:IsChilled()
	if self:HasModifier("modifier_chill_generic") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:RemoveChill()
	if self:HasModifier("modifier_chill_generic") then
		self:RemoveModifierByName("modifier_chill_generic")
	end
end

function CDOTA_BaseNPC:Freeze(hAbility, hCaster, duration)
	self:RemoveModifierByName("modifier_chill_generic")
	self:AddNewModifier(hCaster, hAbility, "modifier_frozen_generic", {Duration = duration})
end

function CDOTA_BaseNPC:IsFrozenGeneric()
	if self:HasModifier("modifier_frozen_generic") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:RemoveFreeze()
	if self:HasModifier("modifier_frozen_generic") then
		self:RemoveModifierByName("modifier_frozen_generic")
	end
end

function CDOTA_BaseNPC:Hide()
	self:AddNewModifier(self, nil, "modifier_hidden_generic", {})
end

function CDOTA_BaseNPC:IsHidden()
	if self:HasModifier("modifier_hidden_generic") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:RemoveHidden()
	if self:HasModifier("modifier_hidden_generic") then
		self:RemoveModifierByName("modifier_hidden_generic")
	end
end

function CDOTA_BaseNPC:Taunt(hAbility, hCaster, tauntDuration)
	self:AddNewModifier(hCaster, hAbility, "modifier_taunt_generic", {Duration = tauntDuration})
end

function CDOTA_BaseNPC:IsTaunted()
	if self:HasModifier("modifier_taunt_generic") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:RemoveTaunt()
	if self:HasModifier("modifier_taunt_generic") then
		self:RemoveModifierByName("modifier_taunt_generic")
	end
end

function CDOTA_BaseNPC:Daze(hAbility, hCaster, dazeDuration)
	self:AddNewModifier(hCaster, hAbility, "modifier_daze_generic", {Duration = dazeDuration})
end

function CDOTA_BaseNPC:IsDazeed()
	if self:HasModifier("modifier_daze_generic") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:RemoveDaze()
	if self:HasModifier("modifier_daze_generic") then
		self:RemoveModifierByName("modifier_daze_generic")
	end
end

function CDOTA_BaseNPC:ApplyKnockBack(position, stunDuration, knockbackDuration, distance, height, caster, ability)
	local caster = caster or nil
	local ability = ability or nil

	local modifierKnockback = {
		center_x = position.x,
		center_y = position.y,
		center_z = position.z,
		duration = stunDuration,
		knockback_duration = knockbackDuration,
		knockback_distance = distance,
		knockback_height = height,
	}
	self:AddNewModifier(caster, ability, "modifier_knockback", modifierKnockback )
end

function CDOTABaseAbility:CD_pure()
    local CD = self:GetCooldown(-1)
    if self:GetCooldownTimeRemaining() <= CD then
		self:EndCooldown()
        self:StartCooldown(CD)
    end
end

function CDOTABaseAbility:CastSpell(target)
	local caster = self:GetCaster()
	if target then
		if target.GetAbsOrigin then -- npc
			caster:SetCursorCastTarget(target)
			caster:SetCursorPosition(target:GetAbsOrigin())
		else
			caster:SetCursorPosition(target)
		end
	end
	self:OnSpellStart()
	self:UseResources(true, true, true)
end