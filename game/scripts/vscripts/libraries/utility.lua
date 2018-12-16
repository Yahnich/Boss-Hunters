DOTA_LIFESTEAL_SOURCE_NONE = 0
DOTA_LIFESTEAL_SOURCE_ATTACK = 1
DOTA_LIFESTEAL_SOURCE_ABILITY = 2

function SendClientSync(key, value)
	CustomNetTables:SetTableValue( "syncing_purposes",key, {value = value} )
end

function Context_Wrap(o, funcname)
	return function(...) o[funcname](o, ...) end
end

function GetTableLength(rndTable)
	local counter = 0
	for k,v in pairs(rndTable) do
		counter = counter + 1
	end
	return counter
end

function MergeTables( t1, t2 )
	local copyTable = {}
	for name, info in pairs(t1) do
		copyTable[name] = info
	end
    for name,info in pairs(t2) do
		if type(info) == "table"  and type(copyTable[name]) == "table" then
			MergeTables(copyTable[name], info)
		else
			copyTable[name] = info
		end
	end
	return copyTable
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

function table.copy(t1)
	copy = {}
	for k,v in pairs(t1) do
		copy[k] = v
	end
	return copy
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

function GetClientSync(key)
 	local value = CustomNetTables:GetTableValue( "syncing_purposes", key).value
	CustomNetTables:SetTableValue( "syncing_purposes",key, nil )
	return value
end

function HasValInTable(checkTable, val)
	for key, value in pairs(checkTable) do
		if value == val then return true end
	end
	return false
end

function TableToWeightedArray(t1)
	local copy = {}
	for value, weight in pairs( t1 ) do
		if tonumber(weight) > 0 then
			for i = 1, tonumber(weight) * 10 do
				table.insert(copy, value)
			end
		end
	end
	return copy
end

function TableToArray(t1)
	local copy = {}
	for key, value in pairs( t1 ) do
		table.insert(copy, value)
	end
	return copy
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

function FindLineIntersection( tLinePoints1, tLinePoints2 )
	-- derive line equations through x1 and x2 and y1 and y2; form C = Ax + By
	local a1 = tLinePoints1[2].y - tLinePoints1[1].y
	local b1 =  tLinePoints1[2].x - tLinePoints1[1].x
	local c1 = a1 * tLinePoints1[1].x + b1 * tLinePoints1[1].y
	
	local a2 = tLinePoints2[2].y - tLinePoints2[1].y
	local b2 =  tLinePoints2[2].x - tLinePoints2[1].x
	local c2 = a2 * tLinePoints2[1].x + b1 * tLinePoints2[1].y
	
	local determinant = a1 * b2 - a2 * b1
	if determinant == 0 then
		return error("lines are parallel")
	end
	local intersectX = ( b2 * c1 - b1 * c2 ) / determinant
	local intersectY = ( a1 * c2 - a2 * c1 ) / determinant
	return Vector( intersectX, intersectY )
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
	direction.z = 0
	return direction
end

function CDOTA_BaseNPC:CreateDummy(position, duration)
	local dummy = CreateUnitByName("npc_dummy_unit", position, false, nil, nil, self:GetTeam())
	if duration and duration > 0 then
		dummy:AddNewModifier(self, nil, "modifier_kill", {duration = duration})
	end
	dummy:AddNewModifier(self, nil, "modifier_hidden_generic", {})
	return dummy
end

function CDOTABaseAbility:CreateDummy(position, duration)
	local dummy = CreateUnitByName("npc_dummy_unit", position, false, nil, nil, self:GetCaster():GetTeam())
	if duration and duration > 0 then
		dummy:AddNewModifier(self, nil, "modifier_kill", {duration = duration})
	end
	dummy:AddNewModifier(self:GetCaster(), nil, "modifier_hidden_generic", {})
	return dummy
end

function CDOTA_BaseNPC:CalculateStatBonus()
	return false
end

function CDOTA_BaseNPC:GetPlayerID()
	return self:GetPlayerOwnerID()
end

function CDOTA_BaseNPC:GetAttackRange()
	return self:Script_GetAttackRange()
end

function CDOTA_BaseNPC_Hero:CreateSummon(unitName, position, duration, bControllable)
	local summon = CreateUnitByName(unitName, position, true, self, nil, self:GetTeam())
  if bControllable or bControllable == nil then summon:SetControllableByPlayer( self:GetPlayerID(),  true ) end
	self.summonTable = self.summonTable or {}
	table.insert(self.summonTable, summon)
	summon:SetOwner(self)
	local summonMod = summon:AddNewModifier(self, nil, "modifier_summon_handler", {duration = duration})
	if duration and duration > 0 then
		summon:AddNewModifier(self, nil, "modifier_kill", {duration = duration})
	end
	StartAnimation(summon, {activity = ACT_DOTA_SPAWN, rate = 1.5, duration = 2})
	local endDur = summonMod:GetRemainingTime()
	return summon, endDur
end

function CDOTA_BaseNPC_Hero:RemoveSummon(entity)
	for id,ent in pairs(self.summonTable) do
		if ent == entity then
			table.remove(self.summonTable, id)
		end
	end
end

function CDOTA_BaseNPC_Hero:GetSummons()
	return self.summonTable or {}
end

function CDOTA_BaseNPC:IsBeingAttacked()
	local enemies = FindUnitsInRadius(self:GetTeam(), self:GetAbsOrigin(), nil, 999999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
	for _, enemy in pairs(enemies) do
		if enemy:IsAttackingEntity(self) then return true end
	end
	return false
end

function CDOTA_BaseNPC:IsInAbilityAttackMode()
	return self.autoAttackFromAbilityState ~= nil
end

function CDOTA_BaseNPC:GetCurrentAttackSource()
	if self.autoAttackFromAbilityState then
		return self.autoAttackFromAbilityState.ability
	end
	return nil
end

function CDOTA_BaseNPC:PerformAbilityAttack(target, bProcs, ability, flBonusDamage, bDamagePct, bNeverMiss)
	self.autoAttackFromAbilityState = {} -- basically the same as setting it to true
	self.autoAttackFromAbilityState.ability = ability

	if flBonusDamage then
		if bDamagePct then
			local bonusDamage = flBonusDamage
			if type(flBonusDamage) == "number" then
				bonusDamage = bDamagePct
			end
			self:AddNewModifier(caster, nil, "modifier_generic_attack_bonus_pct", {damage = flBonusDamage})
		end
		if flBonusDamage and bDamagePct == false or bDamagePct == nil then
			self:AddNewModifier(caster, nil, "modifier_generic_attack_bonus", {damage = flBonusDamage})
		end
	end
	self:PerformAttack(target,bProcs,bProcs,true,false,false,false,bNeverMiss or true)
	self.autoAttackFromAbilityState = nil

	self:RemoveModifierByName("modifier_generic_attack_bonus")
	self:RemoveModifierByName("modifier_generic_attack_bonus_pct")
end

function CDOTA_BaseNPC:PerformGenericAttack(target, immediate, flBonusDamage, bDamagePct, bNeverMiss)
	local neverMiss = false
	if bNeverMiss == true then neverMiss = true end
	if flBonusDamage then
		if bDamagePct then
			if type(bDamagePct) ~= 'number' then
				bDamagePct = flBonusDamage
			end
			self:AddNewModifier(caster, nil, "modifier_generic_attack_bonus_pct", {damage = bDamagePct})
		end
		if flBonusDamage and (not bDamagePct or type(bDamagePct) == 'number') then
			self:AddNewModifier(caster, nil, "modifier_generic_attack_bonus", {damage = flBonusDamage})
		end
	end
	self:PerformAttack(target, true, true, true, false, not immediate, false, neverMiss)
	self:RemoveModifierByName("modifier_generic_attack_bonus")
	self:RemoveModifierByName("modifier_generic_attack_bonus_pct")
end

function CDOTA_Modifier_Lua:AttachEffect(pID)
	self:AddParticle(pID, false, false, 0, false, false)
end

function CDOTA_Modifier_Lua:GetSpecialValueFor(specVal)
	if self and not self:IsNull() and self:GetAbility() and not self:GetAbility():IsNull() then
		return self:GetAbility():GetSpecialValueFor(specVal)
	end
end

function CDOTABaseAbility:DealDamage(attacker, victim, damage, data, spellText)
	--OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, OVERHEAD_ALERT_DAMAGE, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, OVERHEAD_ALERT_MANA_LOSS
	if self:IsNull() or victim:IsNull() or attacker:IsNull() then return end
	local internalData = data or {}
	local damageType =  internalData.damage_type or self:GetAbilityDamageType() or DAMAGE_TYPE_MAGICAL
	local damageFlags = internalData.damage_flags or DOTA_DAMAGE_FLAG_NONE
	local localdamage = damage or self:GetAbilityDamage() or 0
	local spellText = spellText or 0
	local ability = self or internalData.ability
	local returnDamage = ApplyDamage({victim = victim, attacker = attacker, ability = ability, damage_type = damageType, damage = localdamage, damage_flags = damageFlags})
	if spellText > 0 then
		SendOverheadEventMessage(attacker:GetPlayerOwner(),spellText,victim,returnDamage,attacker:GetPlayerOwner()) --Substract the starting health by the new health to get exact damage taken values.
	end
	return returnDamage
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

function CDOTA_BaseNPC:Blink(position)
	if self:IsNull() then return end
	EmitSoundOn("DOTA_Item.BlinkDagger.Activate", self)
	ParticleManager:FireParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, self, {[0] = self:GetAbsOrigin()})
	FindClearSpaceForUnit(self, position, true)
	ProjectileManager:ProjectileDodge( self )
	ParticleManager:FireParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, self, {[0] = self:GetAbsOrigin()})
	EmitSoundOn("DOTA_Item.BlinkDagger.NailedIt", self)
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

function CDOTA_BaseNPC:SetCoreHealth(newHP)
	self:SetBaseMaxHealth(newHP)
	self:SetMaxHealth(newHP)
	self:SetHealth(newHP)
end

function CDOTA_PlayerResource:IsDeveloper(id)
	self.VIP = self.VIP or LoadKeyValues( "scripts/kv/vip.kv" )
	local steamID = self:GetSteamID(id)
	local tag = self.VIP[tostring(steamID)]

	return (tag and tag == "dev") or false
end

function CDOTA_PlayerResource:IsManager(id)
	self.VIP = self.VIP or LoadKeyValues( "scripts/kv/vip.kv" )
	local steamID = self:GetSteamID(id)
	local tag = self.VIP[tostring(steamID)]

	return (tag and tag == "com") or false
end

function CDOTA_PlayerResource:IsVIP(id)
	self.VIP = self.VIP or LoadKeyValues( "scripts/kv/vip.kv" )
	local steamID = self:GetSteamID(id)
	local tag = self.VIP[tostring(steamID)]

	return (tag and tag == "vip") or false
end

function CDOTA_BaseNPC:IsUndead()
	local resourceType = GameRules.UnitKV[self:GetUnitName()]["IsUndead"]
	if resourceType == 1 or self.Holdout_IsCore then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IsWild()
	local resourceType = GameRules.UnitKV[self:GetUnitName()]["IsWild"]
	if resourceType == 1 or self.Holdout_IsCore then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IsDemon()
	local resourceType = GameRules.UnitKV[self:GetUnitName()]["IsDemon"]
	if resourceType == 1 or self.Holdout_IsCore then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IsCelestial()
	local resourceType = GameRules.UnitKV[self:GetUnitName()]["IsCelestial"]
	if resourceType == 1 or self.Holdout_IsCore then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IsElite()
	self.NPCIsElite = self.NPCIsElite or false
	return self.NPCIsElite
end

function CDOTA_BaseNPC:HasTalent(talentName)
	local unit = self
	if self:GetParentUnit() then
		unit = self:GetParentUnit()
	end
	if unit:HasAbility(talentName) then
		if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
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

function CDOTA_BaseNPC:FindTalentValue(talentName, value)	
	local unit = self
	if self:GetParentUnit() then
		unit = self:GetParentUnit()
	end
	if unit:HasAbility(talentName) then
		return unit:FindAbilityByName(talentName):GetSpecialValueFor(value or "value")
	end
	return 0
end

function CDOTA_BaseNPC:FindSpecificTalentValue(talentName, value)
	local unit = self
	if self:GetParentUnit() then
		unit = self:GetParentUnit()
	end
	if unit:HasAbility(talentName) then
		return unit:FindAbilityByName(talentName):GetSpecialValueFor(value)
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
	local var = variance or ((self:GetBaseDamageMax() / self:GetBaseDamageMin()) * 100 )
	self:SetBaseDamageMax(math.ceil(average*(1+(var/100))))
	self:SetBaseDamageMin(math.floor(average*(1-(var/100))))
end

function CDOTABaseAbility:Refresh()
	if self.IsRefreshable and not self:IsRefreshable() then return end
	if not self:IsActivated() then
		self:SetActivated(true)
	end
	if self.delayedCooldownTimer then self:EndDelayedCooldown() end
    self:EndCooldown()
end

function CDOTABaseAbility:GetTrueCastRange()
	local caster = self:GetCaster()
	local castrange = self:GetCastRange()
	castrange = castrange + caster:GetBonusCastRange()
	return castrange
end

function CDOTA_Ability_Lua:GetTrueCastRange()
	local caster = self:GetCaster()
	local castrange = self:GetCastRange(caster:GetAbsOrigin(), caster)
	castrange = castrange + caster:GetBonusCastRange()
	return castrange
end

function CDOTA_BaseNPC:GetBonusCastRange()
	local staticRange = 0
	local stackingRange = 0
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		if modifier.GetModifierCastRangeBonus and modifier:GetModifierCastRangeBonus() and modifier:GetModifierCastRangeBonus() > staticRange then
			staticRange = modifier:GetModifierCastRangeBonus()
		end
		if modifier.GetModifierCastRangeBonusStacking and modifier:GetModifierCastRangeBonusStacking() then
			stackingRange = stackingRange + modifier:GetModifierCastRangeBonusStacking()
		end
	end
	local aether_range = staticRange + stackingRange
    return aether_range
end

function CDOTA_BaseNPC:GetOriginalAttackCapability()
	if GameRules.UnitKV[self:GetUnitName()] then
		self.originalAttackCapability = self.originalAttackCapability or GameRules.UnitKV[self:GetUnitName()]["AttackCapabilities"]
		if self.originalAttackCapability == "DOTA_UNIT_CAP_MELEE_ATTACK" or self.originalAttackCapability == DOTA_UNIT_CAP_MELEE_ATTACK then
			return DOTA_UNIT_CAP_MELEE_ATTACK
		elseif self.originalAttackCapability == "DOTA_UNIT_CAP_RANGED_ATTACK" or self.originalAttackCapability == DOTA_UNIT_CAP_RANGED_ATTACK then
			return DOTA_UNIT_CAP_RANGED_ATTACK
		else
			return DOTA_UNIT_CAP_NO_ATTACK
		end
	end
end 

function CDOTA_BaseNPC:GetOriginalModel()
	if GameRules.UnitKV[self:GetUnitName()] then
		return GameRules.UnitKV[self:GetUnitName()]["Model"] or nil
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

function CDOTA_BaseNPC:RefreshAllCooldowns(bItems, bNoUltimate)
    for i = 0, self:GetAbilityCount() - 1 do
        local ability = self:GetAbilityByIndex( i )
        if ability then
			if (bNoUltimate and ability:GetAbilityType() ~= 1) or not bNoUltimate then
				ability:Refresh()
			end
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

function CDOTA_BaseNPC:IsIllusion()
	local isIllusion = false
	if self:GetPlayerOwnerID() ~= -1 then
		isIllusion = PlayerResource:GetSelectedHeroName( self:GetPlayerOwnerID() ) == self:GetUnitName() and PlayerResource:GetSelectedHeroEntity( self:GetPlayerOwnerID() ) ~= self and PlayerResource:GetSelectedHeroEntity( self:GetPlayerOwnerID() ) ~= nil
	end
	return isIllusion
end

function  CDOTA_BaseNPC:ConjureImage( position, duration, outgoing, incoming, specIllusionModifier, ability, controllable, caster, callback )
	local owner = caster or self
	local player = owner:GetPlayerID()

	local unit_name = self:GetUnitName()
	local origin = position or self:GetAbsOrigin() + RandomVector(100)
	local outgoingDamage = outgoing or 0
	local incomingDamage = incoming or 0
	
	bControl = controllable
	if bControl == nil then bControl = true end
	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusionIndex = CreateUnitByNameAsync("npc_illusion_template", origin, true, owner, owner, owner:GetTeamNumber(), function( illusion )
		if bControl then illusion:SetControllableByPlayer(player, true) end
		for abilitySlot=0,15 do
			local abilityillu = self:GetAbilityByIndex(abilitySlot)
			if abilityillu ~= nil then
				local abilityLevel = abilityillu:GetLevel()
				local abilityName = abilityillu:GetAbilityName()
				if illusion:FindAbilityByName(abilityName) ~= nil then
					local illusionAbility = illusion:FindAbilityByName(abilityName)
					illusionAbility:SetLevel(abilityLevel)
				else
					local illusionAbility = illusion:AddAbility(abilityName)
					if illusionAbility then illusionAbility:SetLevel(abilityLevel) end
				end
			end
		end
		
		-- Make illusion look like owner
		illusion:SetBaseMaxHealth( self:GetMaxHealth() )
		illusion:SetMaxHealth( self:GetMaxHealth() )
		illusion:SetHealth( self:GetHealth() )
		
		illusion:SetAverageBaseDamage( self:GetAverageBaseDamage(), 15 )
		illusion:SetPhysicalArmorBaseValue( self:GetPhysicalArmorValue() )
		illusion:SetBaseAttackTime( self:GetBaseAttackTime() )
		illusion:SetBaseMoveSpeed( self:GetIdealSpeed() )
		
		illusion:SetOriginalModel( self:GetOriginalModel() )
		illusion:SetModel( self:GetOriginalModel() )
		illusion:SetModelScale( self:GetModelScale() )
		
		local moveCap = DOTA_UNIT_CAP_MOVE_NONE
		if self:HasMovementCapability() then
			moveCap = DOTA_UNIT_CAP_MOVE_GROUND
			if self:HasFlyMovementCapability() then
				moveCap = DOTA_UNIT_CAP_MOVE_FLY
			end
		end
		illusion:SetMoveCapability( moveCap )
		illusion:SetAttackCapability( self:GetOriginalAttackCapability() )
		illusion:SetUnitName( self:GetUnitName() )
		if self:IsRangedAttacker() then
			illusion:SetRangedProjectileName( self:GetRangedProjectileName() )
		end
		
		for _, modifier in ipairs( self:FindAllModifiers() ) do
			if modifier.AllowIllusionDuplicate and modifier:AllowIllusionDuplicate() then
				local caster = modifier:GetCaster()
				if caster == self then
					caster = illusion
				end
				illusion:AddNewModifier( caster, modifier:GetAbility(), modifier:GetName(), { duration = modifier:GetRemainingTime() })
			end
		end
		
		illusion:AddNewModifier( self, nil, "modifier_illusion_bonuses", { duration = duration })
		illusion:AddNewModifier( illusion, nil, "modifier_cooldown_reduction_handler", {})
		illusion:AddNewModifier( illusion, nil, "modifier_base_attack_time_handler", {})
		illusion:AddNewModifier( illusion, nil, "modifier_accuracy_handler", {})
		illusion:AddNewModifier( illusion, nil, "modifier_attack_speed_handler", {})
		illusion:AddNewModifier( illusion, nil, "modifier_move_speed_handler", {})
		illusion:AddNewModifier( illusion, nil, "modifier_health_handler", {})
		-- Recreate the items of the caster
		for itemSlot=0,5 do
			local item = self:GetItemInSlot(itemSlot)
			if item ~= nil then
				local itemName = item:GetName()
				local newItem = illusion:AddItemByName(itemName)
				if newItem then
					newItem:SetStacksWithOtherOwners(true)
					newItem:SetPurchaser(nil)
				end
			end
		end

		-- Set the unit as an illusion
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
		illusion:AddNewModifier(owner, ability, "modifier_kill", { duration = duration })
		illusion:AddNewModifier(owner, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
		if specIllusionModifier then
			illusion:AddNewModifier(owner, ability, specIllusionModifier, { duration = duration })
		end
		
		for _, wearable in ipairs( self:GetChildren() ) do
			if wearable:GetClassname() == "dota_item_wearable" and wearable:GetModelName() ~= "" then
				local newWearable = CreateUnitByName("wearable_dummy", illusion:GetAbsOrigin(), false, nil, nil, self:GetTeam())
				newWearable:SetOriginalModel(wearable:GetModelName())
				newWearable:SetModel(wearable:GetModelName())
				newWearable:AddNewModifier(nil, nil, "modifier_wearable", {})
				newWearable:AddNewModifier(owner, ability, "modifier_kill", { duration = duration })
				newWearable:AddNewModifier(owner, ability, "modifier_illusion", { duration = duration })
				if specIllusionModifier then
					newWearable:AddNewModifier(owner, ability, specIllusionModifier, { duration = duration })
				end
				newWearable:MakeIllusion()
				newWearable:SetParent(illusion, nil)
				newWearable:FollowEntity(illusion, true)
				-- newWearable:SetRenderColor(100,100,255)
				Timers:CreateTimer(1, function()
					if illusion and not illusion:IsNull() and illusion:IsAlive() then
						return 0.25
					else
						UTIL_Remove( newWearable )
					end
				end)
			end
		end
		if callback then
			callback( illusion, self, caster, ability )
		end
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		illusion:MakeIllusion()
		illusion.isCustomIllusion = true
	end )
end

function CDOTA_BaseNPC:GetAgility()
	if self:GetPlayerID() >= 0 and PlayerResource:GetSelectedHeroEntity( self:GetPlayerID() ) then
		return PlayerResource:GetSelectedHeroEntity( self:GetPlayerID() ):GetAgility()
	else
		return 0
	end
end

function CDOTA_BaseNPC:GetStrength()
	if self:GetPlayerID() >= 0 and PlayerResource:GetSelectedHeroEntity( self:GetPlayerID() ) then
		return PlayerResource:GetSelectedHeroEntity( self:GetPlayerID() ):GetStrength()
	else
		return 0
	end
end

function CDOTA_BaseNPC:GetIntellect()
	if self:GetPlayerID() >= 0 and PlayerResource:GetSelectedHeroEntity( self:GetPlayerID() ) then
		return PlayerResource:GetSelectedHeroEntity( self:GetPlayerID() ):GetIntellect()
	else
		return 0
	end
end

function CDOTABaseAbility:IsOrbAbility()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["IsOrb"] or 0
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
	self.lastHit = GameRules:GetGameTime()
	local newVal = val
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		if modifier.Bonus_ThreatGain and modifier:Bonus_ThreatGain() then
			newVal = newVal + ( math.abs(val) * ( modifier:Bonus_ThreatGain()/100 ) )
		end
	end
	self.threat = math.min(math.max(0, (self.threat or 0) + newVal ), 10000)
	if self:IsHero() and not self:IsFakeHero() then 
		local player = PlayerResource:GetPlayer(self:GetOwner():GetPlayerID())
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
end

function CDOTA_BaseNPC:ModifyThreat(val)
	self.lastHit = GameRules:GetGameTime()
	local newVal = val
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		if modifier.Bonus_ThreatGain and modifier:Bonus_ThreatGain() then
			newVal = newVal + ( math.abs(val) * ( modifier:Bonus_ThreatGain()/100 ) )
		end
	end
	self.threat = math.min(math.max(0, (self.threat or 0) + newVal ), 10000)
	if not self:IsFakeHero() then 
		local player = PlayerResource:GetPlayer( self:GetOwner():GetPlayerID() )

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
end


function CDOTA_BaseNPC:IsRoundBoss()
	return self.unitIsRoundBoss == true
end

function CDOTA_BaseNPC:IsMinion()
	return self.unitIsRoundBoss ~= true or self.unitIsMinion
end

function CDOTA_BaseNPC:IsSlowed()
	if self:GetIdealSpeed() < self:GetIdealSpeedNoSlows() then return true
	else return false end
end

function CDOTA_BaseNPC:IsDisabled(bHard)
	if (self:IsSlowed() and not bHard) or self:IsStunned() or self:IsRooted() or self:IsSilenced() or self:IsHexed() or self:IsDisarmed() then 
		return true
	else return false end
end

function CDOTA_BaseNPC:GetPhysicalArmorReduction()
	local armornpc = self:GetPhysicalArmorValue()
	local armor_reduction = 1 - (0.05 * armornpc) / (1 + (0.05 * math.abs(armornpc)))
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

function CDOTA_BaseNPC:FindAllModifiersByAbility(abilityname)
	local modifiers = self:FindAllModifiers()
	local returnTable = {}
	for _,modifier in ipairs(modifiers) do
		if modifier:GetAbility():GetName() == abilityname then
			table.insert(returnTable, modifier)
		end
	end
	return returnTable
end

function CDOTA_BaseNPC:FindModifierByNameAndAbility(name, ability)
	local modifiers = self:FindAllModifiers()
	local returnTable = {}
	for _,modifier in ipairs(modifiers) do
		if ability == modifier:GetAbility() and modifier:GetName() == name then
			return modifier
		end
	end
end

function CDOTA_BaseNPC:IsFakeHero()
	if self:IsIllusion() or (self:HasModifier("modifier_monkey_king_fur_army_soldier") or self:HasModifier("modifier_monkey_king_fur_army_soldier_hidden")) or self:IsTempestDouble() or self:IsClone() then
		return true
	else return false end
end

function CDOTA_BaseNPC:IsRealHero()
	if not self:IsNull() then
		return self:IsHero() and not ( self:IsIllusion() or self:IsClone() ) and not self:IsFakeHero()
	end
end

function CDOTABaseAbility:GetTalentSpecialValueFor(value)
	local base = self:GetSpecialValueFor(value)
	local talentName
	local valname = "value"
	local multiply = false
	local subtract = false
	local kv = self:GetAbilityKeyValues()
	if kv["AbilitySpecial"] then
		for k,v in pairs( kv["AbilitySpecial"] ) do -- trawl through keyvalues
			if v[value] then
				talentName = v["LinkedSpecialBonus"]
				if v["LinkedSpecialBonusField"] then valname = v["LinkedSpecialBonusField"] end
				if v["LinkedSpecialBonusOperation"] and v["LinkedSpecialBonusOperation"] == "SPECIAL_BONUS_MULTIPLY" then multiply = true end
				if v["LinkedSpecialBonusOperation"] and v["LinkedSpecialBonusOperation"] == "SPECIAL_BONUS_SUBTRACT" then subtract = true end
				break
			end
		end
	end
	if talentName then 
		local unit = self:GetCaster()
		if unit:GetParentUnit() then
			unit = unit:GetParentUnit()
		end
		local talent = self:GetCaster():FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then 
			if multiply then
				base = base * talent:GetSpecialValueFor(valname) 
			elseif subtract then
				base = base - talent:GetSpecialValueFor(valname) 
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

function CDOTABaseAbility:GetTrueCooldown()
	return self:GetCooldown(-1) * self:GetCaster():GetCooldownReduction()
end

function CDOTABaseAbility:SetCooldown(fCD)
	self:EndCooldown()
	if self:GetCaster():HasModifier("relic_cursed_unchanging_globe") then
		self:StartCooldown(9)
	elseif fCD then
		self:StartCooldown(fCD)
	else
		self:UseResources(false, false, true)
	end
end

function CDOTABaseAbility:SpendMana()
	if self.ShouldUseResources then
		self:UseResources(true, false, false)
	else
		self:PayManaCost( )
	end
end

function CDOTA_BaseNPC:SpendMana( flMana, bForced )
	local cost = flMana * self:GetManaCostReduction()
	print(cost)
	self:ReduceMana( cost ) 
end

function CDOTA_BaseNPC:GetManaCostReduction( )
	local mcReduction = 0
	local mcReductionStack = 0
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		if modifier.GetModifierPercentageManacostStacking then
			mcReductionStack = mcReductionStack + (modifier:GetModifierPercentageManacostStacking(params) or 0)
		end
		if modifier.GetModifierPercentageManacost and modifier:GetModifierPercentageManacost(params) and modifier:GetModifierPercentageManacost(params) > mcReduction then
			mcReduction = modifier:GetModifierPercentageManacost( params )
		end
	end
	return (1 - mcReduction/100) * (1 - mcReductionStack/100)
end

function CDOTA_BaseNPC:GetStatusAmplification( tParams )
	local params = tParams or {}
	local amp = 0
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		if modifier.GetModifierStatusAmplify_Percentage then
			amp = amp + (modifier:GetModifierStatusAmplify_Percentage( params ) or 0)
		end
	end
	return math.max( 0.25, 1 + (amp / 100) )
end

function CDOTA_BaseNPC:GetStatusResistance( tParams)
	local params = tParams or {}
	local resistance = 0
	local stackResist = 0
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		if modifier.GetModifierStatusResistanceStacking then
			stackResist = stackResist + (modifier:GetModifierStatusResistanceStacking(params) or 0)
		end
		if modifier.GetModifierStatusResistance and modifier:GetModifierStatusResistance(params) and modifier:GetModifierStatusResistance(params) > resistance then
			resistance = modifier:GetModifierStatusResistance( params )
		end
	end
	return math.max(0.10, (1 - resistance/100)) * math.max(0.10, (1 - stackResist/100))
end

function CDOTABaseAbility:IsDelayedCooldown()
	return self.delayedCooldownTimer ~= nil
end

function CDOTABaseAbility:StartDelayedCooldown(flDelay, newCD)
	-- self:EndDelayedCooldown()
	-- self:EndCooldown()
	-- self:UseResources(false, false, true)
	-- local cd = newCD or self:GetCooldownTimeRemaining()
	-- local ability = self
	-- self:SetActivated(false)
	-- self.delayedCooldownTimer = Timers:CreateTimer(FrameTime(), function()
		-- if not ability or ability:IsNull() then return end
		-- ability:EndCooldown()
		-- ability:StartCooldown(cd)
		-- return FrameTime()
	-- end)
	-- if flDelay then
		-- if self.automaticDelayedCD then
			-- Timers:RemoveTimer(self.automaticDelayedCD)
		-- end
		-- self.automaticDelayedCD = Timers:CreateTimer(flDelay, function() ability:EndDelayedCooldown() end)
	-- end
end

function CDOTABaseAbility:EndDelayedCooldown()
	-- if self.delayedCooldownTimer then
		-- Timers:RemoveTimer(self.delayedCooldownTimer)
		-- self.delayedCooldownTimer = nil
	-- end
	-- self:SetActivated(true)
end

function CDOTABaseAbility:ModifyCooldown(amt)
	local currCD = self:GetCooldownTimeRemaining()
	self:EndCooldown()
	if currCD + amt > 0 then self:StartCooldown( math.max(0, currCD + amt) ) end
end

function CDOTA_BaseNPC_Hero:CreateTombstone()
	self.tombstoneEntity = nil
	if not self.tombstoneDisabled then
		local newItem = CreateItem( "item_tombstone", self, self )
		newItem:SetPurchaseTime( 0 )
		newItem:SetPurchaser( self )
		local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
		tombstone:SetContainedItem( newItem )
		tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
		FindClearSpaceForUnit( tombstone, self:GetAbsOrigin(), true )
		self.tombstoneEntity = newItem
	end
	self.tombstoneDisabled = false
end

function CScriptHeroList:GetRealHeroes()
	local heroes = self:GetAllHeroes()
	local realHeroes = {}
	for _,hero in pairs(heroes) do
		if hero:IsRealHero() then
			table.insert(realHeroes, hero)
		end
	end
	return realHeroes
end

function CScriptHeroList:GetRealHeroCount()
	return #self:GetRealHeroes()
end

function CScriptHeroList:GetActiveHeroes()
	local heroes = self:GetRealHeroes()
	local activeHeroes = {}
	for _, hero in pairs(heroes) do
		if hero:GetPlayerOwner() then
			table.insert(activeHeroes, hero)
		end
	end
	return activeHeroes
end

function CScriptHeroList:GetActiveHeroCount()
	return #self:GetActiveHeroes()
end

function CDOTA_BaseNPC:IsSameTeam(unit)
	return (self:GetTeamNumber() == unit:GetTeamNumber())
end

function CDOTA_BaseNPC:Lifesteal(source, lifestealPct, damage, target, damage_type, iSource, bParticles)
	local damageDealt = damage or 0
	local sourceType = iSource or DOTA_LIFESTEAL_SOURCE_NONE
	local particles = true
	if bParticles == false then
		particles = false
	end
	if sourceType == DOTA_LIFESTEAL_SOURCE_ABILITY and source then
		damageDealt = source:DealDamage( self, target, damage, {damage_type = damage_type} )
	elseif sourceType == DOTA_LIFESTEAL_SOURCE_ATTACK then
		local oldHP = target:GetHealth()
		self:PerformAttack(target, true, true, true, true, false, false, false)
		damageDealt = math.abs(oldHP - target:GetHealth())
	end
	
	if particles then
		if sourceType == DOTA_LIFESTEAL_SOURCE_ABILITY then
			ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
		else
			local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
				ParticleManager:SetParticleControlEnt(lifesteal, 0, self, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(lifesteal, 1, self, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(lifesteal)
		end
	end

	local flHeal = damageDealt * lifestealPct / 100
	self:HealEvent(flHeal, source, self)
end

function CDOTA_BaseNPC:HealEvent(amount, sourceAb, healer, bRegen) -- for future shit
	local healBonus = 1
	local flAmount = amount
	if healer and not healer:IsNull() then
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
	flAmount = math.min( flAmount, self:GetHealthDeficit() )
	if flAmount > 0 then
		if not bRegen then
			SendOverheadEventMessage(self, OVERHEAD_ALERT_HEAL, self, flAmount, healer)
		end
		self:Heal(flAmount, sourceAb)
	end
	return flAmount
end

function CDOTA_BaseNPC:SwapAbilityIndexes(index, swapname)
	local ability = self:GetAbilityByIndex(index)
	local swapability = self:FindAbilityByName(swapname)
	self:SwapAbilities(ability:GetName(), swapname, false, true)
	swapability:SetAbilityIndex(index)
end

function FindAllUnits(hData)
	local team = DOTA_TEAM_GOODGUYS
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_BOTH
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
	local iOrder = data.order or FIND_ANY_ORDER
	return FindUnitsInRadius(team, Vector(0,0), nil, -1, iTeam, iType, iFlag, iOrder, false)
end

function CDOTA_BaseNPC:FindEnemyUnitsInLine(startPos, endPos, width, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end

function CDOTA_BaseNPC:FindFriendlyUnitsInLine(startPos, endPos, width, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end

function CDOTA_BaseNPC:FindAllUnitsInLine(startPos, endPos, width, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_BOTH
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	return FindUnitsInLine(team, startPos, endPos, nil, width, iTeam, iType, iFlag)
end

function CDOTA_BaseNPC:FindEnemyUnitsInRing(position, maxRadius, minRadius, hData)
	if not self:IsNull() then
		local team = self:GetTeamNumber()
		local data = hData or {}
		local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = data.type or DOTA_UNIT_TARGET_ALL
		local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
		local iOrder = data.order or FIND_ANY_ORDER
	
		local innerRing = FindUnitsInRadius(team, position, nil, minRadius, iTeam, iType, iFlag, iOrder, false)
		local outerRing = FindUnitsInRadius(team, position, nil, maxRadius, iTeam, iType, iFlag, iOrder, false)
		local resultTable = {}
		for _, unit in ipairs(outerRing) do
			if not unit:IsNull() then
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
		end
		return resultTable
		
	else return {} end
end

function CDOTA_BaseNPC:FindEnemyUnitsInRadius(position, radius, hData)
	if not self:IsNull() then
		local team = self:GetTeamNumber()
		local data = hData or {}
		local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = data.type or DOTA_UNIT_TARGET_ALL
		local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
		local iOrder = data.order or FIND_ANY_ORDER
		return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
	else return {} end
end

function CDOTA_BaseNPC:FindFriendlyUnitsInRadius(position, radius, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = data.order or FIND_ANY_ORDER
	return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
end

function CDOTA_BaseNPC:FindAllUnitsInRadius(position, radius, hData)
	local team = self:GetTeamNumber()
	local data = hData or {}
	local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_BOTH
	local iType = data.type or DOTA_UNIT_TARGET_ALL
	local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = data.order or FIND_ANY_ORDER
	return FindUnitsInRadius(team, position, nil, radius, iTeam, iType, iFlag, iOrder, false)
end

function ParticleManager:FireWarningParticle(position, radius)
	local thinker = ParticleManager:CreateParticle("particles/generic_radius_warning.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(thinker, 0, GetGroundPosition( position, nil) )
			ParticleManager:SetParticleControl(thinker, 1, Vector(radius,0,0))
	ParticleManager:ReleaseParticleIndex(thinker)
end

function ParticleManager:FireLinearWarningParticle(vStartPos, vEndPos, vWidth)
	local fWidth = vWidth or 50
	local width = Vector(fWidth, fWidth, fWidth)
	local fx = ParticleManager:FireParticle("particles/range_ability_line.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = GetGroundPosition(vStartPos, nil),
																											[1] = GetGroundPosition(vEndPos, nil),
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
			elseif type(value) == "table" then
				ParticleManager:SetParticleControlEnt(FX, cp, value.owner or owner, value.attach or attach, value.point or "attach_hitloc", owner:GetAbsOrigin(), true)
			else
				ParticleManager:SetParticleControlEnt(FX, cp, owner, attach, value, owner:GetAbsOrigin(), true)
			end
		end
	end
	ParticleManager:ReleaseParticleIndex(FX)
end

function ParticleManager:FireRopeParticle(effect, attach, owner, target, tCP, sAttachPoint)
	if not owner or not target or not attach or not effect then return end
	local FX = ParticleManager:CreateParticle(effect, attach, owner)

	local attachPoint = sAttachPoint or "attach_hitloc"
	ParticleManager:SetParticleControlEnt(FX, 0, owner, attach, attachPoint, owner:GetAbsOrigin(), true)
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
		self:GetParent():StopMotionControllers()
		self:GetParent():InterruptMotionControllers(true)
		self.controlledMotionTimer = Timers:CreateTimer(function()
			if pcall( function() self:DoControlledMotion() end ) then
				return 0.03
			elseif not self:IsNull() then
				self:Destroy()
			end
		end)
	else
	end
end

function CDOTA_Modifier_Lua:AddIndependentStack(duration, limit, bDontDestroy, tTimerTable)
	local timerTable = tTimerTable or {}
	self.stackTimers = self.stackTimers or {}
	if limit then
		if  self:GetStackCount() < limit then
			if timerTable.stacks then
				self:SetStackCount( math.min( limit, self:GetStackCount() + timerTable.stacks ) )
			else
				self:IncrementStackCount()
			end
		elseif self.stackTimers[1] and #self.stackTimers >= limit then
			self:SetStackCount( limit )
			Timers:RemoveTimer(self.stackTimers[1])
			table.remove(self.stackTimers, 1)
		end
	else
		if timerTable.stacks then
			self:SetStackCount( self:GetStackCount() + timerTable.stacks )
		else
			self:IncrementStackCount()
		end
	end
	local destroy = bDontDestroy
	if bDontDestroy == nil then destroy = true end
	timerTable.ID = Timers:CreateTimer(duration or self:GetRemainingTime(), function(timer)
		if not self:IsNull() then
			if timerTable.stacks then	
				self:SetStackCount( math.max( 0, self:GetStackCount() - timerTable.stacks ) )
			else
				self:DecrementStackCount()
			end
			for pos, timerInfo in ipairs( self.stackTimers ) do
				if timer.name == timerInfo.ID then
					table.remove(self.stackTimers, pos)
					break
				end
			end
			if self:GetStackCount() == 0 and self:GetDuration() == -1 and not destroy then self:Destroy() end
		end
	end)
	
	table.insert(self.stackTimers, timerTable or {})
end


function CDOTA_Modifier_Lua:StopMotionController(bForceDestroy)
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	if self.controlledMotionTimer then Timers:RemoveTimer(self.controlledMotionTimer) end
	if bForceDestroy then self:Destroy() end
end

function CDOTA_BaseNPC:StopMotionControllers(bForceDestroy)
	self:InterruptMotionControllers(true)
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		if modifier.controlledMotionTimer then 
			modifier:StopMotionController(bForceDestroy)
		end
	end
end

function CDOTA_BaseNPC:GetAbsOriginCenter()
	return GetGroundPosition( self:GetAbsOrigin(), self ) + Vector(0,0,self:GetBoundingMaxs( ).z/2)
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
	local enemies = self:FindEnemyUnitsInRadius(position, radius, data)
	return enemies[RandomInt(1, #enemies)]
end

function CDOTA_BaseNPC:Dispel(hCaster, bHard)
	local sameTeam = (hCaster:GetTeam() == self:GetTeam())
	local hardDispel = bHard or false
	self:Purge(not sameTeam, sameTeam, false, hardDispel, hardDispel)
end

function CDOTA_BaseNPC:SmoothFindClearSpace(position)
	self:SetAbsOrigin(position)
	ResolveNPCPositions(position, self:GetHullRadius() + self:GetCollisionPadding())
end

function CDOTABaseAbility:Stun(target, duration, bDelay)
	if not target or target:IsNull() then return end
	local delay = false
	if bDelay then delay = Bdelay end
	return target:AddNewModifier(self:GetCaster(), self, "modifier_stunned_generic", {duration = duration, delay = delay})
end

function CDOTABaseAbility:FireLinearProjectile(FX, velocity, distance, width, data, bDelete, bVision, vision)
	local internalData = data or {}
	local delete = false
	if bDelete then delete = bDelete end
	local provideVision = true
	if bVision then provideVision = bVision end
	local info = {
		EffectName = FX,
		Ability = self,
		vSpawnOrigin = internalData.origin or self:GetCaster():GetAbsOrigin(), 
		fStartRadius = width,
		fEndRadius = internalData.width_end or width,
		vVelocity = velocity,
		fDistance = distance or 1000,
		Source = internalData.source or self:GetCaster(),
		iUnitTargetTeam = internalData.team or DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = internalData.type or DOTA_UNIT_TARGET_ALL,
		iUnitTargetFlags = internalData.type or DOTA_UNIT_TARGET_FLAG_NONE,
		bDeleteOnHit = delete,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bProvidesVision = provideVision,
		iVisionRadius = vision or 100,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		ExtraData = internalData.extraData
	}
	local projectile = ProjectileManager:CreateLinearProjectile( info )
	return projectile
end

function CDOTABaseAbility:FireTrackingProjectile(FX, target, speed, data, iAttach, bDodge, bVision, vision)
	local internalData = data or {}
	local dodgable = true
	if bVision ~= nil then dodgable = bDodge end
	local provideVision = false
	if bVision ~= nil then provideVision = bVision end
	local projectile = {
		Target = target,
		Source = internalData.source or self:GetCaster(),
		Ability = self,	
		EffectName = FX,
	    iMoveSpeed = speed,
		vSourceLoc= internalData.origin or self:GetCaster():GetAbsOrigin(),
		bDrawsOnMinimap = false,
        bDodgeable = dodgable,
        bIsAttack = false,
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        flExpireTime = internalData.duration,
		bProvidesVision = provideVision,
		iVisionRadius = vision or 100,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		iSourceAttachment = iAttach or 0,
		ExtraData = internalData.extraData
	}
	return ProjectileManager:CreateTrackingProjectile(projectile)
end

-- FX is optional
function CDOTA_BaseNPC:FireAbilityAutoAttack( target, ability, FX )
	ability:FireTrackingProjectile( FX or self:GetProjectileModel(), target, self:GetProjectileSpeed() )
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
		ParticleManager:FireWarningParticle( eventTable.location, eventTable.radius )
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
								local modifier = unit:AddNewModifier( self:GetCaster(), self, eventTable.modifier, { duration = eventTable.duration } )
								if eventTable.stacks then modifier:SetStackCount(eventTable.stacks) end
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

function CDOTA_BaseNPC:GetCooldownReduction(bReduced)
	local cdr = self:FindModifierByName("modifier_cooldown_reduction_handler")
	if bReduced then
		if cdr then
			local mult = cdr:GetStackCount() / 100
			return mult
		end
		
		return 0
	else
		if cdr then
			local mult = cdr:GetStackCount() / 100
			return 1 - mult/100
		end
		
		return 1
	end
end

function CDOTA_BaseNPC:AddChill(hAbility, hCaster, chillDuration, chillAmount)
	local modifier = self:AddNewModifier(hCaster, hAbility, "modifier_chill_generic", {Duration = chillDuration})
	local chillBonus = chillAmount or 1
	if modifier then
		modifier:SetStackCount( modifier:GetStackCount() + chillBonus)
	end
end

function CDOTA_BaseNPC:GetChillCount()
	if self:HasModifier("modifier_chill_generic") then
		return self:FindModifierByName("modifier_chill_generic"):GetStackCount()
	else
		return 0
	end
end

function CDOTA_BaseNPC:SetChillCount( count, chillDuration )
	if self:HasModifier("modifier_chill_generic") then
		self:FindModifierByName("modifier_chill_generic"):SetStackCount(count)
	elseif chillDuration then
		local modifier = self:AddNewModifier(hCaster, hAbility, "modifier_chill_generic", {Duration = chillDuration})
		if modifier then modifier:SetStackCount(count) end
	else
		error("Target can't be given chill!")
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

function CDOTA_BaseNPC:IsDazed()
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

function CDOTA_BaseNPC:AttemptKill(sourceAb, attacker)
	if not ( self:NoHealthBar() or self:IsOutOfGame() or self:IsNull() or attacker:IsNull() or sourceAb:IsNull() ) then
		self:SetHealth(1)
		local damage = ApplyDamage({victim = self, attacker = attacker, ability = sourceAb, damage_type = DAMAGE_TYPE_PURE, damage = self:GetMaxHealth(), damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR})
		if self:IsNull() then return end
		return not self:IsAlive()
	end
end

function CDOTA_BaseNPC:ApplyKnockBack(position, stunDuration, knockbackDuration, distance, height, caster, ability, bStun)
	local caster = caster or nil
	local ability = ability or nil
	self:StopMotionControllers(false)
	local modifierKnockback = {
		center_x = position.x,
		center_y = position.y,
		center_z = position.z,
		should_stun = 0,
		duration = knockbackDuration,
		knockback_duration = knockbackDuration,
		knockback_distance = distance,
		knockback_height = height or 0,
	}
	if bStun == nil or bStun == true then
		ability:Stun(self, stunDuration)
	end
	self:AddNewModifier(caster, ability, "modifier_knockback", modifierKnockback )
end

function CDOTA_BaseNPC:IsKnockedBack()
	if self:HasModifier("modifier_knockback") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:RemoveKnockBack()
	if self:HasModifier("modifier_knockback") then
		self:RemoveModifierByName("modifier_knockback")
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
	caster:SetCursorTargetingNothing(target == nil)
	self:CastAbility()
end

function CDOTA_BaseNPC:DisableHealing(Duration)
	if Duration == -1 or Duration == nil then
		self:AddNewModifier(nil, nil, "modifier_healing_disable", {})
	else
		self:AddNewModifier(nil, nil, "modifier_healing_disable", {Duration = Duration})
	end
end

function CDOTA_BaseNPC:IsHealingDisabled()
	if self:HasModifier("modifier_healing_disable") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:EnableHealing()
	if self:HasModifier("modifier_healing_disable") then
		self:RemoveModifierByName("modifier_healing_disable")
	end
end

function CDOTA_BaseNPC:InWater()
	return self:HasModifier("modifier_in_water")
end

function CDOTA_BaseNPC:Paralyze(hAbility, hCaster, duration)
	self:AddNewModifier(hCaster, hAbility, "modifier_paralyze", {Duration = duration or 1})
end

function CDOTA_BaseNPC:IsParalyzed()
	if self:HasModifier("modifier_paralyze") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:RemoveParalyze()
	if self:HasModifier("modifier_paralyze") then
		self:RemoveModifierByName("modifier_paralyze")
	end
end

function CDOTA_BaseNPC:Disarm(hAbility, hCaster, duration, bDelay)
	local modifier = self:AddNewModifier(hCaster, hAbility, "modifier_disarm_generic", {Duration = duration, delay = bDelay})
	return modifier
end

function CDOTA_BaseNPC:Break(hAbility, hCaster, duration, bDelay)
	self:AddNewModifier(hCaster, hAbility, "modifier_break_generic", {Duration = duration, delay = bDelay})
end


function CDOTA_BaseNPC:Silence(hAbility, hCaster, duration, bDelay)
	self:AddNewModifier(hCaster, hAbility, "modifier_silence_generic", {Duration = duration, delay = bDelay})
end

function CDOTA_BaseNPC:IsSilenced()
	if self:HasModifier("modifier_silence_generic") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:RemoveSilence()
	if self:HasModifier("modifier_silence_generic") then
		self:RemoveModifierByName("modifier_silence_generic")
	end
end

function CDOTA_BaseNPC:Fear(hAbility, hCaster, duration)
	self:AddNewModifier(hCaster, hAbility, "modifier_fear_generic", {Duration = duration})
end

function CDOTA_BaseNPC:Root(hAbility, hCaster, duration)
	self:AddNewModifier(hCaster, hAbility, "modifier_root_generic", {Duration = duration})
end

function CDOTA_BaseNPC:Blind(missChance, hAbility, hCaster, duration)
	self:AddNewModifier(hCaster, hAbility, "modifier_blind_generic", {Duration = duration, miss = missChance})
end

function CDOTA_BaseNPC:IsBlinded()
	if self:HasModifier("modifier_blind_generic") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:RemoveBlind()
	if self:HasModifier("modifier_blind_generic") then
		self:RemoveModifierByName("modifier_blind_generic")
	end
end

function CDOTA_BaseNPC:AddGold(val)
	if self:GetPlayerID() >= 0 then
		local hero = PlayerResource:GetSelectedHeroEntity( self:GetPlayerID() )
		if hero then
			local gold = val or 0
			if gold >= 0 then
				for _, modifier in pairs(hero:FindAllModifiers()) do
					if modifier.GetBonusGold and modifier:GetBonusGold() then
						gold = gold * math.max( 0, (1 + (modifier:GetBonusGold() / 100)) )
					end
				end
			end
			local gold = hero:GetGold() + gold
			hero:SetGold(0, false)
			hero:SetGold(gold, true)
			SendOverheadEventMessage(self:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, self, val, self:GetPlayerOwner())
		end
	end
end

function CDOTA_BaseNPC:AddXP( val )
	if self:GetPlayerID() >= 0 then
		local hero = PlayerResource:GetSelectedHeroEntity( self:GetPlayerID() )
		if hero then
			local xp = val or 0
			if xp >= 0 then
				for _, modifier in pairs(hero:FindAllModifiers()) do
					if modifier.GetBonusExp and modifier:GetBonusExp() then
						xp = xp * math.max( 0, (1 + (modifier.GetBonusExp() / 100)) )
					end
				end
			end
			hero:AddExperience(xp, DOTA_ModifyXP_Unspecified , false, true)
		end
	end
end

function CutTreesInRadius(vloc, radius)
	local trees = GridNav:GetAllTreesAroundPoint(vloc, radius, false)
	local treesCut = 0
	if #trees > 0 then
		GridNav:DestroyTreesAroundPoint(vloc, radius, false)
	end
	return #trees
end

function CBaseEntity:RollPRNG( percentage )
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

function CDOTA_Ability_Lua:RollPRNG( percentage )
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

function CDOTA_Modifier_Lua:RollPRNG( percentage )
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

function CDOTA_BaseNPC:FindEnemyUnitsInCone(vDirection, vPosition, flSideRadius, flLength, hData)
	if not self:IsNull() then
		local vDirectionCone = Vector( vDirection.y, -vDirection.x, 0.0 )
		local team = self:GetTeamNumber()
		local data = hData or {}
		local iTeam = data.team or DOTA_UNIT_TARGET_TEAM_ENEMY
		local iType = data.type or DOTA_UNIT_TARGET_ALL
		local iFlag = data.flag or DOTA_UNIT_TARGET_FLAG_NONE
		local iOrder = data.order or FIND_ANY_ORDER
		local enemies = self:FindEnemyUnitsInRadius(vPosition, flSideRadius + flLength, hData)
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
	else return {} end
end

function GameRules:RefreshPlayers(bDontHealFull)
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero ~=nil then
					if not hero:IsAlive() then
						hero:RespawnHero(false, false)
						hero:SetHealth( 1 )
						hero:SetMana( 1 )
					end
					if not bDontHealFull then
						hero:SetHealth( hero:GetMaxHealth() )
						hero:SetMana( hero:GetMaxMana() )
					else
						hero:HealEvent( hero:GetMaxHealth() * 0.25, nil, hero )
						hero:GiveMana( hero:GetMaxMana() * 0.25 )
					end
					hero.threat = 0
					ResolveNPCPositions( hero:GetAbsOrigin(), hero:GetHullRadius() + hero:GetCollisionPadding() )
				end
			end
		end
	end
end

function GameRules:GetGameDifficulty()
	return GameRules.gameDifficulty
end

function GameRules:SetLives(val, bMax)
	GameRules._lives = val
	CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._lives, maxLives = GameRules._maxLives } )
end

function GameRules:ModifyLives(val, bMax)
	GameRules._lives = GameRules._lives + val
	if bMax then
		GameRules._maxLives = GameRules._maxLives + val
	end
	CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._lives, maxLives = GameRules._maxLives } )
end

function GameRules:GetLives()
	return GameRules._lives
end

function CDOTA_BaseNPC:GetIllusionOwnerEntindex()
	if self:HasModifier("modifier_illusion_tag") then
		return self:GetModifierStackCount("modifier_illusion_tag", self)
	else
		error("Not an illusion!")
	end
end

function CDOTA_Modifier_Lua:IsCurse()
	return self.modifierIsCurse
end

function CDOTA_Modifier_Lua:IsBlessing()
	return self.modifierIsBlessing
end

function CDOTA_BaseNPC:PurgeCurses( )
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		if modifier.IsCurse and modifier:IsCurse() then
			modifier:Destroy()
		end
	end
end

function CDOTA_BaseNPC:AddCurse(curseName)	
	local curse = self:AddNewModifier(self, nil, curseName, {})
	if curse then 
		curse.modifierIsCurse = true
		if self:HasRelic("relic_unique_ofuda") and self:FindModifierByName("relic_unique_ofuda"):GetStackCount() > 0 then
			local ofuda = self:FindModifierByName("relic_unique_ofuda")
			ofuda:DecrementStackCount()
			curse:Destroy()
		end
	end
	
	return curse
end

function CDOTA_BaseNPC:AddBlessing( blessingName )
	local blessing = self:AddNewModifier(self, nil, blessingName, {})
	if blessing then blessing.modifierIsBlessing = true end
	return blessing
end

function CDOTA_BaseNPC:HasActiveAbility()
	return self:GetCurrentActiveAbility() ~= nil or self:IsChanneling()
end

function CDOTA_BaseNPC_Hero:GetAttributePoints()
	return self.bonusTalentPoints or 0
end

function CDOTA_BaseNPC_Hero:ModifyAttributePoints(value)
	self.totalGainedTalentPoints = self.totalGainedTalentPoints or 0
	if value > 0 then
		self.totalGainedTalentPoints = self.totalGainedTalentPoints + value
	end
	self.bonusTalentPoints = self.bonusTalentPoints + value
	local netTable = CustomNetTables:GetTableValue("hero_properties", self:GetUnitName()..self:entindex()) or {}
	netTable.attribute_points = self.bonusTalentPoints
	CustomNetTables:SetTableValue("hero_properties", self:GetUnitName()..self:entindex(), netTable)
	CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", { playerID = self:GetPlayerID() } )
end

function CDOTA_BaseNPC_Hero:SetAttributePoints(value)
	self.bonusTalentPoints = value or 0
	local netTable = CustomNetTables:GetTableValue("hero_properties", self:GetUnitName()..self:entindex()) or {}
	netTable.attribute_points = self.bonusTalentPoints
	CustomNetTables:SetTableValue("hero_properties", self:GetUnitName()..self:entindex(), netTable)
	CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", { playerID = self:GetPlayerID() } )
end

function CDOTA_Ability_Lua:Cleave(target, damage, startRadius, endRadius, distance, effect )
	DoCleaveAttack(self:GetCaster(), target, self, damage, startRadius, endRadius, distance, effect )
end

function CDOTA_BaseNPC:GetParentUnit()
	return self.unitOwnerEntity
end

function CDOTA_BaseNPC:Charm(hAbility, hCaster, charmDuration)
	self:AddNewModifier(hCaster, hAbility, "modifier_charm_generic", {Duration = charmDuration})
end

function CDOTA_BaseNPC:IsCharmed()
	if self:HasModifier("modifier_charm_generic") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:RemoveCharm()
	if self:HasModifier("modifier_charm_generic") then
		self:RemoveModifierByName("modifier_charm_generic")
	end
end