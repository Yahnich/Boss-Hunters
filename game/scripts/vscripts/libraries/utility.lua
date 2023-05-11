DOTA_LIFESTEAL_SOURCE_NONE = 0
DOTA_LIFESTEAL_SOURCE_ATTACK = 1
DOTA_LIFESTEAL_SOURCE_ABILITY = 2

HEAL_TYPE_HEAL = 0
HEAL_TYPE_REGEN = 1
HEAL_TYPE_LIFESTEAL = 2

HEAL_FLAG_NONE = 0
HEAL_FLAG_IGNORE_AMPLIFICATION = 1

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


function MergeTables( t1, t2, bDebugPrint )
	local copyTable = {}
	for name, info in pairs(t1) do
		copyTable[name] = info
	end
    for name,info in pairs(t2) do
		if type(info) == "table"  and type(copyTable[name]) == "table" then
			copyTable[name] = MergeTables(copyTable[name], info, printThisShit)
		else
			copyTable[name] = table.copy(info) 
		end
	end
	return copyTable
end

function PrintAll(t)
	if type(t) == "table" then
		for k,v in pairs(t) do
			print(k,v)
			if type(v) == "table" then
				for m,n in pairs(v) do
					print('--', m,n)
					if type(n) == "table" then
						for h,j in pairs(n) do
							print('----', h,j)
						end
					end
				end
			end
		end
	else
		print( t )
	end
end

function string.split( inputStr, delimiter )
	local d = delimiter or '%s' 
	local t={} 
	for field,s in string.gmatch(inputStr, "([^"..delimiter.."]*)("..delimiter.."?)") do 
		table.insert(t,field) 
		if s=="" then 
			return t 
		end 
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
	if t1 == nil then
		return t1
	end
	if type(t1) == 'table' then
		local copy = {}
		for k,v in pairs(t1) do
			local kCopy = table.copy(k)
			local vCopy = table.copy(v)
			copy[kCopy] = vCopy
		end
		return copy
	else
		local copy = t1
		return copy
	end
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

function TableToArray(t1, bValue)
	local copy = {}
	for key, value in pairs( t1 ) do
		if bValue then
			table.insert(copy, value)
		else
			table.insert(copy, key)
		end
	end
	return copy
end

function TernaryOperator(value, bCheck, default)
	if bCheck == true then 
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
		return nil
	end
	local intersectX = ( b2 * c1 - b1 * c2 ) / determinant
	local intersectY = ( a1 * c2 - a2 * c1 ) / determinant
	return Vector( intersectX, intersectY )
end

function FindProjectedPointOnLine( position, lineSegment)
	local lineVector = Vector( lineSegment[2].x - lineSegment[1].x, lineSegment[2].y - lineSegment[1].y )
	local positionVector = Vector( position.x - lineSegment[1].x, position.y - lineSegment[1].y )
	local dotProduct = lineVector:Dot(positionVector)
	local sqrLen = (lineVector.x * lineVector.x) + (lineVector.y * lineVector.y)
	local projPoint = Vector( lineSegment[1].x + (dotProduct * lineVector.x) / sqrLen, lineSegment[1].y + (dotProduct * lineVector.y) / sqrLen )
	return projPoint
end

function FindSideOfLine( point, lineSegment )
	local d = ( point.x - lineSegment[1].x ) * ( lineSegment[2].y - lineSegment[1].y ) - ( point.y - lineSegment[1].y ) * ( lineSegment[2].x - lineSegment[1].x )
	return d
end

function ActualRandomVector(maxLength, flMinLength)
	local minLength = flMinLength or 0
	return RandomVector(RandomInt(minLength, maxLength))
end

function GetRandomInTable( hArray )
	if hArray[1] then
		return hArray[RandomInt( 1, #hArray )]
	else
		local array = TableToArray( hArray )
		return array[RandomInt( 1, #array )]
	end
end

function HasBit(checker, value)
	local checkVal = checker
	if type(checkVal) == 'userdata' then
		checkVal = tonumber(checker:ToHexString(), 16)
	end
	return bit.band( checkVal, tonumber(value)) == tonumber(value)
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
	else -- tables and bools
		return thing
	end
end

function CalculateDistance(ent1, ent2, b3D)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local vector = (pos1 - pos2)
	if b3D then
		return vector:Length()
	else
		return vector:Length2D()
	end
end

function CalculateDirection(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local direction = (pos1 - pos2)
	direction.z = 0
	return direction:Normalized()
end



if not CDOTA_BaseNPC_Hero.oldCalculateStatBonus then
	CDOTA_BaseNPC_Hero.oldCalculateStatBonus = CDOTA_BaseNPC_Hero.CalculateStatBonus
end

function CDOTA_BaseNPC_Hero:CalculateStatBonus( forceRefresh )
	local bRef = forceRefresh or true
	self:oldCalculateStatBonus( bRef )
end

if not oldCreateModifierThinker then
	oldCreateModifierThinker = CreateModifierThinker
end

function CreateModifierThinker( modifierCaster, modifierAbility, modifierName, modifierTable, thinkerPosition, teamNumber, blockPathing )
	local kv = modifierTable or {}
	local duration = kv.Duration or kv.duration or -1
	kv.duration = nil
	kv.Duration = nil
	kv.original_duration = duration
	kv.duration = duration
	if duration ~= -1 and self and modifierCaster and not kv.ignoreStatusAmp then
		local params = {caster = modifierCaster, target = self, duration = duration, ability = modifierAbility, modifier_name = modifierName}
		duration = duration * modifierCaster:GetStatusAmplification( params )
		kv.duration = duration
	end
	return oldCreateModifierThinker( modifierCaster,  modifierAbility, modifierName, kv, thinkerPosition, teamNumber, blockPathing )
end

if not CDOTA_BaseNPC.oldAddNewModifier then
	CDOTA_BaseNPC.oldAddNewModifier = CDOTA_BaseNPC.AddNewModifier
end

function CDOTA_BaseNPC:AddNewModifier(modifierCaster, modifierAbility, modifierName, modifierTable)
	local kv = modifierTable or {}
	local duration = kv.Duration or kv.duration or -1
	kv.duration = nil
	kv.Duration = nil
	kv.original_duration = duration
	kv.duration = duration
	if duration ~= -1 and self and modifierCaster and not kv.ignoreStatusAmp then
		local params = {caster = modifierCaster, target = self, duration = duration, ability = modifierAbility, modifier_name = modifierName}
		duration = duration * modifierCaster:GetStatusAmplification( params )
		if self:GetTeam() ~= modifierCaster:GetTeam() then
			duration = duration * self:GetStatusResistance( params )
		end
		kv.duration = duration
	end
	return self:oldAddNewModifier( modifierCaster,  modifierAbility, modifierName, kv )
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
		dummy:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
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
		local kill = summon:AddNewModifier(self, nil, "modifier_kill", {duration = duration})
	end
	summon:AddNewModifier(self, nil, "modifier_stats_system_handler", {})
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
	
	if flBonusDamage or bDamagePct then
		if bDamagePct then
			local bonusDamage = flBonusDamage
			if type(bDamagePct) == "number" then
				bonusDamage = bDamagePct
			end
			self:AddNewModifier(caster, nil, "modifier_generic_attack_bonus_pct", {damage = bonusDamage})
		end
		if flBonusDamage and not bDamagePct then
			self:AddNewModifier(caster, nil, "modifier_generic_attack_bonus", {damage = flBonusDamage})
		end
	end
	miss = (bNeverMiss ~= false)
	self:PerformAttack(target,bProcs,bProcs,true,false,false,false,miss)
	self.autoAttackFromAbilityState = nil
	
	if flBonusDamage or bDamagePct then
		self:RemoveModifierByName("modifier_generic_attack_bonus")
		self:RemoveModifierByName("modifier_generic_attack_bonus_pct")
	end
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

function CDOTABaseAbility:DealDamage(attacker, target, damage, data, spellText)
	--OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, OVERHEAD_ALERT_DAMAGE, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, OVERHEAD_ALERT_MANA_LOSS
	if not self or not target or not attacker then return end
	if self:IsNull() or target:IsNull() or attacker:IsNull() then return end
	if not target:IsAlive() then return 0 end
	local internalData = data or {}
	local damageType =  internalData.damage_type or self:GetAbilityDamageType()
	if damageType == nil or damageType == 0 then
		damageType = DAMAGE_TYPE_MAGICAL
	end
	local damageFlags = internalData.damage_flags or DOTA_DAMAGE_FLAG_NONE
	local localdamage = damage or self:GetAbilityDamage() or 0
	local spellText = spellText or 0
	local ability = self or internalData.ability
	local oldHealth = target:GetHealth()
	ApplyDamage({victim = target, attacker = attacker, ability = ability, damage_type = damageType, damage = localdamage, damage_flags = damageFlags})
	if target:IsNull() then return oldHealth end
	local newHealth = target:GetHealth()
	local returnDamage = oldHealth - newHealth
	if spellText > 0 then
		SendOverheadEventMessage(attacker:GetPlayerOwner(),spellText,target,returnDamage,attacker:GetPlayerOwner()) --Substract the starting health by the new health to get exact damage taken values.
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

function GridNav:FindTreesInCone( vDirection, vPosition, flSideRadius, flLength )
	local trees = GridNav:GetAllTreesAroundPoint( vPosition, flSideRadius + flLength, true )
	local vDirectionCone = Vector( vDirection.y, -vDirection.x, 0.0 )
	local treesTable = {}
	if #trees > 0 then
		for _,tree in pairs(trees) do
			if tree ~= nil then
				local vToPotentialTarget = tree:GetOrigin() - vPosition
				local flSideAmount = math.abs( vToPotentialTarget.x * vDirectionCone.x + vToPotentialTarget.y * vDirectionCone.y + vToPotentialTarget.z * vDirectionCone.z )
				local flLengthAmount = ( vToPotentialTarget.x * vDirection.x + vToPotentialTarget.y * vDirection.y + vToPotentialTarget.z * vDirection.z )
				if ( flSideAmount < flSideRadius ) and ( flLengthAmount > 0.0 ) and ( flLengthAmount < flLength ) then
					table.insert(treesTable, tree)
				end
			end
		end
	end
	return treesTable
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

function CDOTA_PlayerResource:IsKarien(id)
	self.VIP = self.VIP or LoadKeyValues( "scripts/kv/vip.kv" )
	local steamID = self:GetSteamID(id)
	local tag = self.VIP[tostring(steamID)]

	return (tag and tag == "karien") or false
end

function CDOTA_PlayerResource:IsSunrise(id)
	self.VIP = self.VIP or LoadKeyValues( "scripts/kv/vip.kv" )
	local steamID = self:GetSteamID(id)
	local tag = self.VIP[tostring(steamID)]

	return (tag and tag == "sunrise") or false
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
	if unit:IsNull() then return end
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
	self.resurrectionStoned or 
	self:GetLives() > 0 then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:GetAverageBaseDamage()
	return (self:GetBaseDamageMax() + self:GetBaseDamageMin())/2
end

function CDOTA_BaseNPC:GetTrueAttackDamage( target )
	local variance = math.ceil( self:GetBaseDamageMax() - self:GetBaseDamageMin() ) / 2
	local average = self:GetAverageTrueAttackDamage( target )
	local range = RandomInt( -variance, variance )
	return average + range
end

function CDOTA_BaseNPC:SetAverageBaseDamage(average, variance) -- variance is in percent (50 not 0.5)
	local var = variance or ((self:GetBaseDamageMax() / self:GetBaseDamageMin()) * 100 )
	self:SetBaseDamageMax(math.ceil(average*(1+(var/100))))
	self:SetBaseDamageMin(math.max(1, math.ceil(average*(1-(var/100)))))
end

function CDOTABaseAbility:Refresh()
	if self.IsRefreshable and not self:IsRefreshable() then return end
	if not self:IsActivated() then
		self:SetActivated(true)
	end
	if self.delayedCooldownTimer then self:EndDelayedCooldown() end
    self:EndCooldown()
end

function CDOTABaseAbility:GetTrueCastRange( target )
	local caster = self:GetCaster()
	local castrange = self:GetCastRange(caster:GetAbsOrigin(), caster)
	if castrange == -1 then return -1 end
	castrange = castrange + caster:GetBonusCastRange( target )
	return castrange
end

function CDOTA_BaseNPC:GetBonusCastRange(target)
    return self:GetCastRangeBonus(  )
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
	if self.currentProjectileModel ~= self.previousProjectileModel then
		self:SetRangedProjectileName(self.previousProjectileModel)
		local newModel = self.previousProjectileModel
		self.previousProjectileModel = self.currentProjectileModel
		self.currentProjectileModel = newModel
	end
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

function CDOTA_BaseNPC:IsAtAngleWithEntity(hEntity, flDesiredAngle, bCheckForward)
	local angleDiff = self:GetAngleDifference(hEntity)
	if bCheckForward then 
		return angleDiff <= flDesiredAngle / 2 or angleDiff >= (360 - flDesiredAngle / 2)
	else
		return angleDiff >= (180 - flDesiredAngle / 2) and angleDiff <= (180 + flDesiredAngle / 2)
	end
end

function CDOTA_BaseNPC:RefreshAllCooldowns(bItems, bNoUltimate)
    for i = 0, self:GetAbilityCount() - 1 do
        local ability = self:GetAbilityByIndex( i )
		
        if ability and not ability:IsToggle() then
			if (bNoUltimate and ability:GetAbilityType() ~= 1) or not bNoUltimate then
				ability:Refresh()
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


function CDOTA_BaseNPC:GetPrimaryAttribute()
	if self:IsIllusion() then
		return self:GetParentUnit():GetPrimaryAttribute()
	else
		return DOTA_ATTRIBUTE_INVALID
	end
end

function CDOTA_BaseNPC:IsIllusion()
	local isIllusion = self:HasModifier("modifier_illusion")
	return isIllusion
end

function CDOTA_BaseNPC:AddItemCopiesFromOriginal( originalHero )
	for itemSlot=0,5 do
		local item = originalHero:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = self:GetItemInSlot(itemSlot)
			if not newItem then
				newItem = self:AddItemByName( itemName )
			end
			if newItem and item.itemData then
				newItem.itemData = table.copy( item.itemData )
				local passive = self:AddNewModifier( self, newItem, newItem:GetIntrinsicModifierName(), {} )
				local funcs = {}
				for slot, rune in pairs( item.itemData ) do
					if rune and rune.funcs then
						for func, result in pairs( rune.funcs ) do
							funcs[func] = ( funcs[func] or 0 ) + result
						end
					end
				end
				for func, result in pairs( funcs ) do
					passive[func] = function() return result end
				end
				passive:ForceRefresh()
			end
		end
	end
end

function CDOTA_BaseNPC:ConjureImage( illusionInfo, duration, caster, amount )
	local illuInfo = illusionInfo or {}
	illuInfo.outgoing_damage = illuInfo.outgoing_damage or 0
	illuInfo.incoming_damage = illuInfo.incoming_damage or 0
	
	if self:IsHero() then
		local params = {caster = caster, target = self, duration = duration, ability = illuInfo.ability, modifier_name = "modifier_illusion"}
		local fDur = duration
		if fDur ~= -1 then
			fDur = duration * caster:GetStatusAmplification( params )
		end
		local illusionTable = CreateIllusions( caster or self , self, {outgoing_damage = illuInfo.outgoing_damage, incoming_damage = illuInfo.incoming_damage, duration = fDur}, amount or 1, self:GetHullRadius() + self:GetCollisionPadding(), illuInfo.scramble or false, true )
		if not illusionTable then return end
		for _, illusion in ipairs( illusionTable ) do
			illusion:AddNewModifier( self, nil, "modifier_stats_system_handler", {})
			local trueParent = self
			if self.unitOwnerEntity then
				trueParent = self.unitOwnerEntity
			end
			illusion:SetPhysicalArmorBaseValue( self:GetPhysicalArmorBaseValue() )
			-- Check for runes
			illusion:AddItemCopiesFromOriginal( self )
			for _, modifier in ipairs( self:FindAllModifiers() ) do
				if modifier.AllowIllusionDuplicate and modifier:AllowIllusionDuplicate() then
					illusion:AddNewModifier( modifier:GetCaster(), modifier:GetAbility(), modifier:GetName(), {duration = modifier:GetRemainingTime()} ):SetStackCount( modifier:GetStackCount() )
				end
			end
			for i = 0, 23 do
				local ability = illusion:GetAbilityByIndex( i )
				if ability then
					ability:SetActivated( false )
					local ownerAbility = self:GetAbilityByIndex( i )
					if ownerAbility then
						ability:SetCooldown (  ownerAbility:GetCooldownTimeRemaining() )
						if ownerAbility:GetAutoCastState() then
							ability:ToggleAutoCast()
						end
					end
				end
			end
			illusion:SetHealth( math.min( illusion:GetMaxHealth(), math.max( self:GetHealth(), 1 ) ) )
			illusion:SetOwner(caster or self)
			illusion:SetMaximumGoldBounty( 0 )
			illusion:SetMinimumGoldBounty( 0 )
			if illuInfo.controllable == false then
				illusion:SetControllableByPlayer(-1, true)
			end
			if illuInfo.position then
				FindClearSpaceForUnit( illusion, illuInfo.position, true )
			end
			if illuInfo.illusion_modifier then
				illusion:AddNewModifier( caster or self, illuInfo.ability, illuInfo.illusion_modifier, {} )
			end
			illusion.hasBeenInitialized = true	
			-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
			illusion.isCustomIllusion = true
			Timers:CreateTimer(0.1, function() ResolveNPCPositions( illusion:GetAbsOrigin(), 128 ) end )
		end
		return illusionTable
	else
		local illusionTable = {}
		local owner = caster or self
		for i = 1, amount do
			local illusion = CreateUnitByName( self:GetUnitName(), illuInfo.position or self:GetAbsOrigin(), true, owner, owner, owner:GetTeamNumber() )
			if illuInfo.illusion_modifier then
				illusion:AddNewModifier( caster or self, illuInfo.ability, illuInfo.illusion_modifier, {duration = duration} )
			else
				illusion:AddNewModifier( caster or self, illuInfo.ability, "modifier_illusion", {duration = duration} )
			end
			illusion:SetOwner(caster or self)
			for i = 0, 23 do
				local ability = illusion:GetAbilityByIndex( i )
				if ability then
					ability:SetActivated( false )
					local ownerAbility = owner:GetAbilityByIndex( i )
					if ownerAbility then
						ability:SetCooldown (  ownerAbility:GetCooldownTimeRemaining() )
					end
				end
			end
			illusion:SetBaseDamageMax( self:GetBaseDamageMax() - 10 )
			illusion:SetBaseDamageMin( self:GetBaseDamageMin() - 10 )
			illusion:SetPhysicalArmorBaseValue( self:GetPhysicalArmorBaseValue() )
			illusion:SetBaseAttackTime( self:GetSecondsPerAttack() )
			illusion:SetBaseMoveSpeed( self:GetBaseMoveSpeed() )
			illusion:SetMaximumGoldBounty( 0 )
			illusion:SetMinimumGoldBounty( 0 )
			if illuInfo.controllable == false then
				illusion:SetControllableByPlayer(-1, true)
			else
				illusion:SetControllableByPlayer(caster:GetPlayerID(), true)
			end
			Timers:CreateTimer(0.1, function() ResolveNPCPositions( illusion:GetAbsOrigin(), 128 ) end )
			table.insert( illusionTable, illusion )
		end
		return illusionTable
	end
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
	local newVal = val
	local newThreat = math.min(math.max(0, (newVal or 0) ), 10000)
	
	self.threat = self.threat or 0
	if newThreat > self.threat then
		self.lastHit = GameRules:GetGameTime()
	end
	
	self.threat = newThreat
	
	if self:IsHero() and not self:IsFakeHero() then 
		local player = self:GetPlayerOwner()
		local data = CustomNetTables:GetTableValue("hero_properties", tostring(self:entindex()) ) or {}
		data.threat = self.threat
		CustomNetTables:SetTableValue("hero_properties", tostring(self:entindex()), data )
	end
end

function CDOTA_BaseNPC:ModifyThreat(val, bIgnoreCap)
	local newVal = val or 0
	
	self.threat = self.threat or 0
	local reduction = 0.35 ^ math.floor( self.threat / 100 )
	-- Every 100 threat, threat gain effectiveness is reduced
	local threatgainCap = math.min( 10, (self.threat + 1) * 4 )
	local newCap = threatgainCap
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		if modifier.Bonus_ThreatGain and modifier:Bonus_ThreatGain() then
			newVal = newVal + ( math.abs(newVal) * ( modifier:Bonus_ThreatGain()/100 ) )
			newCap = newCap + ( math.abs(threatgainCap) * ( modifier:Bonus_ThreatGain()/100 ) )
		end
	end
	threatgainCap = newCap
	if bIgnoreCap then
		threatgainCap = 999
	end
	
	local threatToGive = math.min( math.max(0, (self.threat or 0) + math.min(newVal * reduction, threatgainCap ) ), 999 )
	self:SetThreat( threatToGive )
end


function CDOTA_BaseNPC:IsRoundNecessary()
	return self.unitIsRoundNecessary == true
end

function CDOTA_BaseNPC:IsBoss()
	return self.unitIsBoss == true
end

function CDOTA_BaseNPC:IsMinion()
	return (not self:IsHero() and self.unitIsRoundNecessary ~= true) or self.unitIsMinion
end

function CDOTA_BaseNPC:IsUndead()
	if not GameRules.UnitKV[self:GetUnitName()] then return false end
	local monsterType = GameRules.UnitKV[self:GetUnitName()]["IsUndead"]
	if monsterType == 1 then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IsWild()
	if not GameRules.UnitKV[self:GetUnitName()] then return false end
	local monsterType = GameRules.UnitKV[self:GetUnitName()]["IsWild"]
	if monsterType == 1 then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IsDemon()
	if not GameRules.UnitKV[self:GetUnitName()] then return false end
	local monsterType = GameRules.UnitKV[self:GetUnitName()]["IsDemon"]
	if monsterType == 1 then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IsCelestial()
	if not GameRules.UnitKV[self:GetUnitName()] then return false end
	local monsterType = GameRules.UnitKV[self:GetUnitName()]["IsCelestial"]
	if monsterType == 1 then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IsElite()
	self.NPCIsElite = self.NPCIsElite or false
	return self.NPCIsElite
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
	local armornpc = self:GetPhysicalArmorValue(false)
	local armor_reduction = 1 - ((0.06 * armornpc) / (1 + 0.06 * math.abs(armornpc)))
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
	local modifiers = self:FindAllModifiersByName(name)
	local returnTable = {}
	for _,modifier in ipairs(modifiers) do
		if ability == modifier:GetAbility() and modifier:GetName() == name then
			return modifier
		end
	end
end

function CDOTA_BaseNPC:IsFakeHero()
	local fakeHero = self.GetPlayerID and self ~= PlayerResource:GetSelectedHeroEntity( self:GetPlayerID() )
	if not self.GetPlayerID then return true end
	if PlayerResource:GetSelectedHeroEntity( self:GetPlayerID() ) == nil then
		return false
	end
	return self.GetPlayerID and self ~= PlayerResource:GetSelectedHeroEntity( self:GetPlayerID() )
end

function CDOTA_BaseNPC:IsRealHero()
	if not self:IsNull() then
		return self:IsHero() and not ( self:IsIllusion() or self:IsClone() ) and not self:IsFakeHero()
	end
end

function CDOTABaseAbility:GetTalentSpecialValueFor(value)
	return self:GetTalentLevelSpecialValueFor(value, -1)
end

function CDOTABaseAbility:GetTalentLevelSpecialValueFor(value, level)
	local base = self:GetLevelSpecialValueFor(value, level)
	local talentName
	local valname = "value"
	local multiply = false
	local subtract = false
	local zadd = false
	local kv = self:GetAbilityKeyValues()
	if kv["AbilitySpecial"] then
		for k,v in pairs( kv["AbilitySpecial"] ) do -- trawl through keyvalues
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
	if kv["AbilityValues"] then
		local valueData = kv["AbilityValues"][value]
		if type(valueData) == "table" then
			talentName = valueData["LinkedSpecialBonus"]
			if valueData["LinkedSpecialBonusOperation"] and valueData["LinkedSpecialBonusOperation"] == "SPECIAL_BONUS_MULTIPLY" then multiply = true end
			if valueData["LinkedSpecialBonusOperation"] and valueData["LinkedSpecialBonusOperation"] == "SPECIAL_BONUS_SUBTRACT" then subtract = true end
			if valueData["LinkedSpecialBonusOperation"] and valueData["LinkedSpecialBonusOperation"] == "SPECIAL_BONUS_PERCENTAGE_ADD" then zadd = true end
		end
	end
	if talentName then 
		local unit = self:GetCaster()
		if unit:GetParentUnit() then
			unit = unit:GetParentUnit()
		end
		local talent = unit:FindAbilityByName(talentName)
		if talent and talent:GetLevel() > 0 then
			if multiply then
				base = base * talent:GetSpecialValueFor(valname) 
			elseif subtract then
				base = base - talent:GetSpecialValueFor(valname) 
			elseif zadd then
				base = base + math.floor(base * talent:GetSpecialValueFor(valname)/100)
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

function CDOTA_Modifier_Lua:GetTalentLevelSpecialValueFor(value, level)
	return self:GetAbility():GetTalentLevelSpecialValueFor(value, level)
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
	return self:GetCooldown(-1) * self:GetCaster():GetModifierPercentageCooldown()
end

function CDOTABaseAbility:SetCooldown(fCD)
	self:EndCooldown()
	if self:GetCaster():HasModifier("relic_cursed_unchanging_globe") then
		self:StartCooldown(9)
	elseif fCD then
		self:StartCooldown(fCD)
	else
		self:UseResources(false, false, false, true)
	end
end

function CDOTABaseAbility:SpendMana( flValue )
	local value = flValue or self:GetManaCost( -1 )
	local caster = self:GetCaster()
	local spentMana = true
	local mana = caster:GetMana()
	self:GetCaster():ReduceMana( value )
	local realValue = math.max( 1, mana - caster:GetMana() )
	caster:SetMana( mana )
	self:GetCaster():SpendMana( realValue, self )
	if caster:GetMana() <= 0 then
		caster:SetMana( mana )
		spentMana = false
	end
	return spentMana
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
	if not self or self:IsNull() then return end
	local params = tParams or {}
	local amp = 0
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		if modifier.GetModifierStatusAmplify_Percentage then
			amp = amp + (modifier:GetModifierStatusAmplify_Percentage( params ) or 0)
		end
	end
	return math.max( 0.25, 1 + (amp / 100) )
end

function CDOTA_BaseNPC:GetStatusResistance( tParams )
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
	if currCD > 0 then
		self:EndCooldown()
		if currCD + amt > 0 then self:StartCooldown( math.max(0, currCD + amt) ) end
	end
end

function CDOTA_BaseNPC_Hero:CreateTombstone()
	self.tombstoneEntity = nil
	if not self:IsTombstoneDisabled() then
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

function CDOTA_BaseNPC_Hero:IsTombstoneDisabled()
	return self.tombstoneDisabled
end

function CDOTA_BaseNPC_Hero:SetTombstoneDisabled(bool)
	self.tombstoneDisabled = toboolean(bool)
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

function CDOTA_PlayerResource:GetActivePlayerCount()
	local count = 0
	for id = 0, PlayerResource:GetPlayerCountForTeam( DOTA_TEAM_GOODGUYS ) do
		if PlayerResource:GetConnectionState( id ) == DOTA_CONNECTION_STATE_CONNECTED then
			count = count + 1
		end
	end
	return count
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
	local sourceCaster = self
	if source then
		sourceCaster = source:GetCaster()
	end
	local particles = true
	if bParticles == false then
		particles = false
	end
	if sourceType == DOTA_LIFESTEAL_SOURCE_ABILITY and source then
		damageDealt = source:DealDamage( sourceCaster, target, damage, {damage_type = damage_type} )
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
	self:HealEvent( flHeal, source, sourceCaster, {heal_type = HEAL_TYPE_LIFESTEAL} )
	return flHeal
end

function CDOTA_BaseNPC:HealEvent(amount, sourceAb, healer, data) -- for future shit
	local hData = data or {}
	local flAmount = amount or 0
	
	if not hData.heal_type then
		hData.heal_type = HEAL_TYPE_HEAL
	end
	if not hData.heal_flags then
		hData.heal_flags = HEAL_FLAG_NONE
	end

	local healFactorAllied = 1
	local healFactorSelf = 1
	local params = {original_amount = flAmount, amount = flAmount, source = sourceAb, unit = healer, target = self, heal_type = hData.heal_type}
	
	if not HasBit( hData.heal_flags, HEAL_FLAG_IGNORE_AMPLIFICATION ) then
		if hData.heal_type == HEAL_TYPE_HEAL then
			if healer and not healer:IsNull() then
				for _,modifier in ipairs( healer:FindAllModifiers() ) do
					if modifier.GetModifierHealAmplify_Const then
						flAmount = flAmount + ((modifier:GetModifierHeal_Const() or 0)/100)
					end
					if healer ~= self then
						if modifier.GetModifierHealAmplify_Percentage then
							healFactorAllied = healFactorAllied + ( modifier:GetModifierHealAmplify_Percentage( params ) or 0 )/100
						end
					end
				end
			end
			if self then
				for _, modifier in ipairs( self:FindAllModifiers() ) do
					if modifier.GetModifierHealAmplify_Percentage then
						healFactorSelf = healFactorSelf + (modifier:GetModifierHealAmplify_Percentage( params ) or 0 )/100
					end
				end
			end
		elseif hData.heal_type == HEAL_TYPE_REGEN then
			if self then
				for _, modifier in ipairs( self:FindAllModifiers() ) do
					if modifier.GetModifierHPRegenAmplify_Percentage then
						healFactorSelf = healFactorSelf + (modifier:GetModifierHPRegenAmplify_Percentage( params ) or 0 )/100
					end
				end
			end
		elseif hData.heal_type == HEAL_TYPE_LIFESTEAL then
			if self then
				for _, modifier in ipairs( self:FindAllModifiers() ) do
					if modifier.GetModifierLifestealRegenAmplify_Percentage then
						healFactorSelf = healFactorSelf + (modifier:GetModifierLifestealRegenAmplify_Percentage( params ) or 0 )/100
					end
				end
			end
		end
	end
	local flOriginalAmount = flAmount
	flAmount = math.max( flAmount * healFactorAllied * healFactorSelf, 0 )
	local params2 = {original_amount = flOriginalAmount, amount = flAmount, source = sourceAb, unit = healer, target = self, heal_type = hData.heal_type}
	local units = self:FindAllUnitsInRadius(self:GetAbsOrigin(), -1)
	for _, unit in ipairs(units) do
		if unit.FindAllModifiers then
			for _, modifier in ipairs( unit:FindAllModifiers() ) do
				if modifier.OnHealed then
					modifier:OnHealed(params2)
				end
				if modifier.OnHeal then
					modifier:OnHeal(params2)
				end
				if modifier.OnHealRedirect then
					modifier:OnHealRedirect(params2)
				end
			end
		end
	end
	flAmount = math.min( params2.amount, self:GetHealthDeficit() )
	if flAmount > 0 then
		local hp = self:GetHealth()
		self:Heal(flAmount, sourceAb)
		local totalHeal = self:GetHealth() - hp
		if hData.heal_type ~= HEAL_TYPE_REGEN then
			self.healingToTransfer = (self.healingToTransfer or 0)
			if self.healingToTransfer == 0 then
				Timers:CreateTimer(function()
					SendOverheadEventMessage(self, OVERHEAD_ALERT_HEAL, self, self.healingToTransfer, healer)
					self.healingToTransfer = 0
				end)
			end
			self.healingToTransfer = (self.healingToTransfer or 0) + totalHeal
		end
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
	if self:IsNull() then return end
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

function ParticleManager:FireLinearWarningParticle(vStartPos, vEndPos, vWidth, vStartWidth)
	local fWidth = vWidth or 50
	local width = Vector(fWidth, vStartWidth or fWidth, fWidth)
	local fx = ParticleManager:FireParticle("particles/ui_mouseactions/warning_particle_cone.vpcf", PATTACH_WORLDORIGIN, nil, { [1] = GetGroundPosition(vStartPos, nil),
																																[2] = GetGroundPosition(vEndPos, nil),
																															[3] = width,
																															[4] = Vector(255,0,0)} )
																															
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
			elseif type(value) == "number" then
				ParticleManager:SetParticleControl(FX, tonumber(cp), Vector(value, value, value) )
			elseif type(value) == "table" then
				ParticleManager:SetParticleControlEnt(FX, cp, value.owner or owner, value.attach or attach, value.point or "attach_hitloc", (value.owner or owner):GetAbsOrigin(), true)
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


function ParticleManager:CreateRopeParticle(effect, attach, owner, target, tCP, sAttachPoint)
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
	return FX
end

function ParticleManager:ClearParticle(cFX, bImmediate)
	if cFX then
		self:DestroyParticle(cFX, bImmediate or false)
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

function CDOTA_BaseNPC:HasDebuffs()
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		local caster = modifier:GetCaster()
		if modifier:IsDebuff() or (caster and not caster:IsSameTeam( self ) ) then
			return true
		end
	end
	return false
end

function CDOTA_BaseNPC:HasPurgableDebuffs()
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		local caster = modifier:GetCaster()
		if (modifier:IsDebuff() or (caster and not caster:IsSameTeam( self ) )) and ((modifier.IsPurgable and modifier:IsPurgable()) or not modifier.IsPurgable) and not modifier:HasAuraOrigin() then
			return true
		end
	end
	return false
end

function CDOTA_Modifier_Lua:HasAuraOrigin()
	for _, modifier in ipairs( self:GetCaster():FindAllModifiers() ) do
		if modifier.GetModifierAura and modifier:GetModifierAura() == self:GetName() then
			return true
		end
	end
	return false
end

function CDOTA_Buff:HasAuraOrigin()
	for _, modifier in ipairs( self:GetCaster():FindAllModifiers() ) do
		if modifier.GetModifierAura and modifier:GetModifierAura() == self:GetName() then
			return true
		end
	end
	return false
end

function CDOTA_BaseNPC:WillReincarnate()
	return self.unitWillReincarnate
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
			Timers:RemoveTimer(self.stackTimers[1].ID)
			table.remove(self.stackTimers, 1)
		end
	else
		if timerTable.stacks then
			self:SetStackCount( self:GetStackCount() + timerTable.stacks )
		else
			self:IncrementStackCount()
		end
	end
	local dontDestroy = bDontDestroy
	if bDontDestroy == nil then dontDestroy = true end
	timerTable.ID = Timers:CreateTimer(duration or self:GetRemainingTime(), function(timer)
		if not self:IsNull() then
			if timerTable.stacks then	
				self:SetStackCount( math.max( 0, self:GetStackCount() - timerTable.stacks ) )
			else
				self:DecrementStackCount()
			end
			for i = #self.stackTimers, 1, -1 do
				if timer.name == self.stackTimers[i].ID then
					table.remove(self.stackTimers, pos)
					break
				end
			end
			if self:GetStackCount() == 0 and self:GetDuration() == -1 and not dontDestroy then self:Destroy() end
		end
	end)
	
	table.insert(self.stackTimers, timerTable or {})
end


function CDOTA_Modifier_Lua:StopMotionController(bForceDestroy)
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	if self.controlledMotionTimer then Timers:RemoveTimer(self.controlledMotionTimer) end
	self:Destroy()
end

function CDOTA_BaseNPC:StopMotionControllers(bForceDestroy)
	if self.InterruptMotionControllers then self:InterruptMotionControllers(true) end
	for _, modifier in ipairs( self:FindAllModifiers() ) do
		if modifier.controlledMotionTimer then 
			modifier:StopMotionController(bForceDestroy)
		end
	end
end

function CDOTA_BaseNPC:GetAbsOriginCenter()
	return GetGroundPosition( self:GetAbsOrigin(), self ) + Vector(0,0,self:GetBoundingMaxs( ).z/2)
end

function CDOTA_Modifier_Lua:AddEffect(id, bRelease)
	self:AddParticle(id, false, false, 0, false, false)
	release = bRelease or false
	if release then
		ParticleManager:ReleaseParticleIndex( id )
	end
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
	local sameTeam = true
	if hCaster ~= nil then
		sameTeam = (hCaster:GetTeam() == self:GetTeam())
	end
	local hardDispel = bHard or false
	self:Purge(not sameTeam, sameTeam, false, hardDispel, hardDispel)
end

function CDOTA_BaseNPC:SmoothFindClearSpace(position)
	self:SetAbsOrigin(position)
	ResolveNPCPositions(position, self:GetHullRadius() + self:GetCollisionPadding())
	Timers:CreateTimer(function() FindClearSpaceForUnit(self, position, true) end)
end

function CDOTABaseAbility:Stun(target, duration, bDelay)
	if not target or target:IsNull() then return end
	local delay = false
	if bDelay then delay = Bdelay end
	local modifier
	modifier = target:FindModifierByNameAndAbility("modifier_stunned_generic", self)
	if modifier then
		if modifier:GetRemainingTime() < duration then
			modifier:SetDuration( duration, true )
		end
	else
		modifier = target:AddNewModifier(self:GetCaster(), self, "modifier_stunned_generic", {duration = duration, delay = delay})
	end
	return modifier
end

function CDOTABaseAbility:Sleep(target, duration, min_duration)
	if not target or target:IsNull() then return end
	return target:AddNewModifier(self:GetCaster(), self, "modifier_sleep_generic", {duration = duration, min_duration = min_duration or 0})
end

function CDOTABaseAbility:FireLinearProjectile(FX, velocity, distance, width, data, bDelete, bVision, vision)
	local internalData = data or {}
	local delete = false
	if bDelete then delete = bDelete end
	local provideVision = true
	if bVision then provideVision = bVision end
	if internalData.source and not internalData.origin then
		internalData.origin = internalData.source:GetAbsOrigin()
	end
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
		iUnitTargetFlags = internalData.flag or DOTA_UNIT_TARGET_FLAG_NONE,
		iSourceAttachment = internalData.attach or DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
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
	if bDodge ~= nil then dodgable = bDodge end
	local provideVision = false
	if bVision ~= nil then provideVision = bVision end
	local origin = self:GetCaster():GetAbsOrigin()
	if internalData.origin then
		origin = internalData.origin
	elseif internalData.source then
		origin = internalData.source:GetAbsOrigin()
	end
	local projectile = {
		Target = target,
		Source = internalData.source or self:GetCaster(),
		Ability = self,	
		EffectName = FX,
	    iMoveSpeed = speed,
		vSourceLoc= origin or self:GetCaster():GetAbsOrigin(),
		bDrawsOnMinimap = false,
        bDodgeable = dodgable,
        bIsAttack = false,
        bVisibleToEnemies = true,
        bReplaceExisting = false,
        flExpireTime = internalData.duration,
		bProvidesVision = provideVision,
		iVisionRadius = vision or 100,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		iSourceAttachment = iAttach or 3,
		ExtraData = internalData.extraData
	}
	return ProjectileManager:CreateTrackingProjectile(projectile)
end

-- FX is optional
function CDOTA_BaseNPC:FireAbilityAutoAttack( target, ability, source, FX )
	local data = {}
	if source then
		data.source = source
	end
	ability:FireTrackingProjectile( FX or self:GetProjectileModel(), target, self:GetProjectileSpeed(), data )
end

function CDOTABaseAbility:ApplyAOE(eventTable)
	if not self or self:IsNull() or not self:GetCaster() or self:GetCaster():IsNull() then return end
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
					if not unit:IsMagicImmune() or (unit:IsMagicImmune() and eventTable.magic_immune) and not unit:TriggerSpellAbsorb(self) then
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

function CDOTA_BaseNPC:GetModifierPercentageCooldown(bReduced)
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

function CDOTABaseAbility:GetChannelTimeRemaining()
	if self:IsChanneling() then
		local startTime = self:GetChannelStartTime()
		local currTime = GameRules:GetGameTime()
		local channelTime = self:GetChannelTime()
		return channelTime - ( currTime - startTime )
	else
		return 0
	end
end

function CDOTA_BaseNPC:AddChill(hAbility, hCaster, chillDuration, chillAmount)
	if not self or self:IsNull() then return end
	local chillBonus = chillAmount or 1
	local bonusDur = chillBonus * 0.1
	local currentChillDuration = 0
	local currentChill =  self:FindModifierByName("modifier_chill_generic")
	if currentChill then
		currentChillDuration = currentChill:GetRemainingTime()
	end
	local appliedDuration = chillDuration
	if currentChillDuration > appliedDuration then
		appliedDuration = currentChillDuration + bonusDur
	else
		appliedDuration = appliedDuration + currentChillDuration
	end
	local modifier = self:AddNewModifier(hCaster, hAbility, "modifier_chill_generic", {Duration = appliedDuration})
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
	ExecuteOrderFromTable({
		UnitIndex = self:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = hCaster:entindex()
	})
end

function CDOTA_BaseNPC:IsTaunted()
	if self:HasModifier("modifier_taunt_generic") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IsTauntedBy(entity)
	local taunt = self:FindModifierByNameAndCaster( "modifier_taunt_generic", entity )
	if taunt then
		return true
	end
	return false
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
		ignoreStatusAmp = true
	}
	if bStun == nil or bStun == true then
		local stun = self:AddNewModifier(caster, ability, "modifier_stunned_generic", {duration = stunDuration})
	end
	local knockback = self:AddNewModifier(caster, ability, "modifier_knockback", modifierKnockback )
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

function CDOTA_BaseNPC:DisableHealing(Duration, caster, ability)
	if Duration == -1 or Duration == nil then
		self:AddNewModifier(caster or self, ability, "modifier_bh_heal_disable", {})
	else
		self:AddNewModifier(caster or self, ability, "modifier_bh_heal_disable", {Duration = Duration})
	end
end

function CDOTA_BaseNPC:IsHealingDisabled()
	if self:HasModifier("modifier_bh_heal_disable") then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:EnableHealing()
	if self:HasModifier("modifier_bh_heal_disable") then
		self:RemoveModifierByName("modifier_bh_heal_disable")
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
	return self:AddNewModifier(hCaster, hAbility, "modifier_break_generic", {Duration = duration, delay = bDelay})
end


function CDOTA_BaseNPC:Silence(hAbility, hCaster, duration, bDelay)
	return self:AddNewModifier(hCaster, hAbility, "modifier_silence_generic", {Duration = duration, delay = bDelay})
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
	return self:AddNewModifier(hCaster, hAbility, "modifier_fear_generic", {Duration = duration})
end

function CDOTA_BaseNPC:Root(hAbility, hCaster, duration)
	return self:AddNewModifier(hCaster, hAbility, "modifier_root_generic", {Duration = duration})
end

function CDOTA_BaseNPC:Blind(missChance, hAbility, hCaster, duration)
	return self:AddNewModifier(hCaster, hAbility, "modifier_blind_generic", {Duration = duration, miss = missChance})
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

function CDOTA_BaseNPC:AddGold(val, bSound, bShowOnlyBonusGold)
	if self:GetPlayerID() >= 0 then
		local hero = PlayerResource:GetSelectedHeroEntity( self:GetPlayerID() )
		if hero then
			local baseGold = val or 0
			local bonusGold = 0
			local gold = baseGold
			
			-- bonus gold handling
			if gold >= 0 then
				for _, modifier in pairs(hero:FindAllModifiers()) do
					if modifier.GetBonusGold then
						bonusGold = bonusGold + baseGold * (modifier:GetBonusGold() or 0) / 100
					end
				end
			end
			gold = baseGold + bonusGold
			
			-- gold handling
			local newGold = hero:GetGold() + gold
			hero:SetGold(0, false)
			newGold = newGold + (hero.bonusGoldExcessValue or 0)
			hero.bonusGoldExcessValue = newGold % 1
			hero:SetGold(math.floor(newGold), true)
			
			-- notification handling
			if (( gold > 0 and bSound ~= false ) or bSound == true) and not bShowOnlyBonusGold then
				local showGold = baseGold
				if bonusGold < 0 then
					showGold = gold
				end
				SendOverheadEventMessage(self:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, self, showGold, self:GetPlayerOwner())
			end
			if bonusGold > 0 then
				Timers:CreateTimer( 0.15, function()
					SendOverheadEventMessage(self:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, self, bonusGold, self:GetPlayerOwner())
				end)
			end
			return gold
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

function CutTreesInRadius(vloc, radius, infoTable)
	local trees = GridNav:GetAllTreesAroundPoint(vloc, radius, false)
	local treesCut = 0
	if #trees > 0 then
		GridNav:DestroyTreesAroundPoint(vloc, radius, false)
		if infoTable then
			local ability = infoTable.ability
			local caster = infoTable.caster or ability:GetCaster()
			local params = {unit = caster, ability = ability, trees = #trees, position = vloc, radius = radius}
			for _, modifier in ipairs( caster:FindAllModifiers(  ) ) do
				if modifier.OnTreesCutDown then
					modifier:OnTreesCutDown( params )
				end
			end
		end
	end
	return #trees
end

function RollPRNGFormula( object, percentage )
	if percentage > 0 then
		if object.basePercentage ~= percentage then
			object.weight = FindProbabilityWeight(percentage)
			object.basePercentage = percentage
		end
		object.currentPercentage = (object.currentPercentage or 0)
		local roll = RollPercentage( object.currentPercentage )
		object.currentPercentage = (object.currentPercentage or 0) + object.weight
		if roll then
			object.currentPercentage = object.weight
		end
		return roll
	end
end

function FindRelativeProbability( weight )
	if not weight then weight = 1 end
	pProcOnN = 0.0
    pProcByN = 0.0
    sumNpProcOnN = 0.0
	maxFails = math.ceil(1.0 / weight)
	for N = 1, maxFails do
        pProcOnN = math.min( 1.0, N * weight ) * (1.0 - pProcByN)
        pProcByN = pProcByN + pProcOnN
        sumNpProcOnN = sumNpProcOnN + N * pProcOnN
	end
    return (1.0 / sumNpProcOnN)
end

function FindProbabilityWeight(roll)
	local percent = roll / 100
    local Cupper = percent;
    local Clower = 0.0;
    local Cmid = 0.0;
	local roll1;
    local roll2 = 1.0;
	
	check = true
	local maxDistr = 1000
    while check do
        Cmid = (Cupper + Clower) / 2
        roll1 = FindRelativeProbability(Cmid)
        if math.abs(roll1 - roll2) <= 0 then
			check = false
            break
		end
        if roll1 > percent then
            Cupper = Cmid
        else
            Clower = Cmid
		end
        roll2 = roll1
		maxDistr = maxDistr - 1
		if maxDistr < 0 then
			check = false
            break
		end
	end
    return Cmid * 100
end

function CBaseEntity:RollPRNG( percentage )
	return RollPRNGFormula( self, percentage )
end

function CDOTA_Ability_Lua:RollPRNG( percentage )
	return RollPRNGFormula( self, percentage )
end

function CDOTA_Modifier_Lua:RollPRNG( percentage )
	return RollPRNGFormula( self, percentage )
end

-- function CBaseEntity:RollPRNG( percentage, prngStream )
	-- return RollPseudoRandomPercentage( percentage, prngStream or DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, self )
-- end

-- function CDOTA_Ability_Lua:RollPRNG( percentage, prngStream )
	-- return self:GetCaster():RollPRNG( percentage, prngStream or DOTA_PSEUDO_RANDOM_CUSTOM_GAME_2 )
-- end

-- function CDOTA_Modifier_Lua:RollPRNG( percentage, prngStream )
	-- return self:GetParent():RollPRNG( percentage, prngStream or DOTA_PSEUDO_RANDOM_CUSTOM_GAME_3 )
-- end

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

function CDOTA_BaseNPC:RestoreMana( flMana )
	local manaToGive = math.min( flMana, self:GetManaDeficit() )
	if manaToGive > 0 then
		SendOverheadEventMessage( nil, OVERHEAD_ALERT_MANA_ADD, self, manaToGive, nil)
		self:GiveMana( flMana )
	end
end

function GameRules:GetMatchID()
	return GameRules:Script_GetMatchID()
end

function GameRules:RefreshPlayers(bDontHealFull, flPrepTime)
	local activePlayers = HeroList:GetActiveHeroCount()
	local playerMult = (GameRules.BasePlayers - activePlayers)
	local healMult = 0.25 + 0.0375 * playerMult
	local manaMult = 0.25 + 0.0375 * playerMult
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero ~= nil then
					if hero:GetHealth() < 1 and hero:IsAlive() then
						hero:SetHealth( 1 )
						hero:ForceKill( false )
					end
					if not hero:IsAlive() and not hero:WillReincarnate() then
						hero:RespawnHero(false, false)
						hero:SetHealth( 1 )
						hero:SetMana( 1 )
					end
					if not bDontHealFull then
						hero:SetHealth( hero:GetMaxHealth() )
						hero:SetMana( hero:GetMaxMana() )
					else
						if flPrepTime then
							hero:HealEvent( hero:GetHealthRegen() * flPrepTime, nil, hero, {heal_type = HEAL_TYPE_REGEN} )
							hero:RestoreMana( hero:GetManaRegen() * flPrepTime )
						else
							hero:HealEvent( hero:GetMaxHealth() * healMult, nil, hero, {heal_type = HEAL_TYPE_REGEN} )
							hero:RestoreMana( hero:GetMaxMana() * manaMult )
						end
					end
					hero.threat = 0
					ResolveNPCPositions( hero:GetAbsOrigin(), hero:GetHullRadius() + hero:GetCollisionPadding() )
				end
			end
		end
	end
end

function CDOTA_BaseNPC:GetManaDeficit()
	return self:GetMaxMana() - self:GetMana()
end

function GameRules:GetGameDifficulty()
	return GameRules.gameDifficulty
end

function CDOTA_BaseNPC_Hero:GetLives()
	local livesHandler = self:FindModifierByName("modifier_lives_handler")
	if not livesHandler then
		livesHandler = self:AddNewModifier( self, nil, "modifier_lives_handler", {} )
	end
	return livesHandler:GetStackCount()
end

function CDOTA_BaseNPC_Hero:SetLives(val)
	local livesHandler = self:FindModifierByName("modifier_lives_handler")
	if not livesHandler then
		livesHandler = self:AddNewModifier( self, nil, "modifier_lives_handler", {} )
	end
	livesHandler:SetStackCount( val or 0 )
	livesHandler:ForceRefresh()
end

function CDOTA_BaseNPC_Hero:ModifyLives(val)
	local livesHandler = self:FindModifierByName("modifier_lives_handler")
	if not livesHandler then
		livesHandler = self:AddNewModifier( self, nil, "modifier_lives_handler", {} )
	end
	if not livesHandler then return end
	livesHandler:SetStackCount( livesHandler:GetStackCount() + (val or 0))
	livesHandler:ForceRefresh()
end

function CDOTA_BaseNPC_Hero:GetMaxLives()
	local livesHandler = self:FindModifierByName("modifier_lives_handler")
	if not livesHandler then
		livesHandler = self:AddNewModifier( self, nil, "modifier_lives_handler", {} )
	end
	return livesHandler.limit
end

function CDOTA_BaseNPC_Hero:GetBonusMaxLives()
	return self.bonusLivesProvided
end

function CDOTA_BaseNPC_Hero:SetBonusMaxLives(val)
	self.bonusLivesProvided = val or 0
end

function CDOTA_BaseNPC_Hero:ModifyBonusMaxLives(val)
	self.bonusLivesProvided = (self.bonusLivesProvided or 0) + (val or 0)
	local livesHandler = self:FindModifierByName("modifier_lives_handler")
	if not livesHandler then
		livesHandler = self:AddNewModifier( self, nil, "modifier_lives_handler", {} )
	end
	livesHandler:ForceRefresh()
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
		if self:HasRelic("relic_ofuda") and self:FindModifierByName("relic_ofuda"):GetStackCount() > 0 then
			local ofuda = self:FindModifierByName("relic_ofuda")
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

function CDOTA_BaseNPC_Hero:GetTalentPoints()
	return self.uniqueTalentPoints or 0
end

function CDOTA_BaseNPC_Hero:ModifyTalentPoints(value)
	self.uniqueTalentPoints = self:GetTalentPoints() + value
end

function CDOTA_BaseNPC_Hero:ModifyAttributePoints(value)
	self.totalGainedTalentPoints = self.totalGainedTalentPoints or 0
	if value > 0 then
		self.totalGainedTalentPoints = self.totalGainedTalentPoints + value
	end
	self.bonusTalentPoints = (self.bonusTalentPoints or 0) + value
	local netTable = CustomNetTables:GetTableValue("hero_properties", tostring(self:entindex())) or {}
	netTable.attribute_points = self.bonusTalentPoints
	CustomNetTables:SetTableValue("hero_properties", tostring(self:entindex()), netTable)
	CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", { playerID = self:GetPlayerID() } )
end

function CDOTA_BaseNPC_Hero:ModifyAbilityPoints( value )
	self:SetAbilityPoints( self:GetAbilityPoints() + (value or 0) )
end

function CDOTA_BaseNPC_Hero:SetAttributePoints(value)
	self.bonusTalentPoints = value or 0
	local netTable = CustomNetTables:GetTableValue("hero_properties", tostring(self:entindex())) or {}
	netTable.attribute_points = self.bonusTalentPoints
	CustomNetTables:SetTableValue("hero_properties", tostring(self:entindex()), netTable)
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

function CDOTA_Item:GetRuneSlots()
	if GameRules.AbilityKV[self:GetName()] then
		local slotCount = GameRules.AbilityKV[self:GetName()]["AvailableRuneSlots"] or 0
		return slotCount
	else
		return 0
	end
end

function CDOTA_Item:GetAvailableRuneSlots()
	local count = self:GetRuneSlots()
	for i = 1, self:GetRuneSlots() do
		if self:GetRuneSlot(i).rune_type then
			count = count - 1
		end
	end
	return count
end

function CDOTA_Item:GetRuneSlot(index)
	self.itemData = self.itemData or {}
	return self.itemData[index]
end

function CDOTA_BaseNPC:HookInModifier( modifierType, modifier, priority )
	if not modifier then
		return
	end
	local statsHandler = self.statsSystemHandlerModifier
	if statsHandler and not statsHandler:IsNull() then
		statsHandler.modifierFunctions[modifierType] = statsHandler.modifierFunctions[modifierType] or {}
		statsHandler.modifierFunctions[modifierType][modifier] = priority or modifier:GetPriority() or 1
		statsHandler:ForceRefresh()
	end
end

function CDOTA_BaseNPC:HookOutModifier( modifierType, modifier )
	local statsHandler = self.statsSystemHandlerModifier
	if statsHandler and not statsHandler:IsNull() then
		statsHandler.modifierFunctions[modifierType] = statsHandler.modifierFunctions[modifierType] or {}
		statsHandler.modifierFunctions[modifierType][modifier] = nil
		statsHandler:ForceRefresh()
	end
end

function ProjectileManager:GetProjectileLocation( projectile )
	local position = ProjectileManager:GetTrackingProjectileLocation( projectile )
	if CalculateDistance( Vector(0, 0, 0), position ) < 0.5 then
		position = ProjectileManager:GetLinearProjectileLocation( projectile )
	end
	return position
end