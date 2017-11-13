AbilityManager = class({})



function AbilityManager:constructor(data)
	CustomGameEventManager:RegisterListener('randomAbilities', Dynamic_Wrap( AbilityManager, 'RandomAbilitiesFromList'))
	CustomGameEventManager:RegisterListener('initializeAbilities', Dynamic_Wrap( AbilityManager, 'InitializeQueriedAbilities'))
end

function AbilityManager:RandomAbilitiesFromList(event)
	local hero = EntIndexToHScript(event.heroID)
	local orderedList = {}
	if not hero then return end
	if not hero.selectedSkills and GameRules.UnitKV[hero:GetUnitName()]["Abilities"] then
		hero.selectedSkills = {}
		for skill,_ in pairs( GameRules.UnitKV[hero:GetUnitName()]["Abilities"] ) do
			skillTable[i] = skill
			hero.selectedSkills[skill] = false
			i = i + 1
		end
	end
	if not hero.selectedSkills then return end
	for ability, state in pairs(hero.selectedSkills) do
		table.insert(orderedList, ability)
	end
	while #orderedList ~= 4 do
		table.remove(orderedList, RandomInt(1, #orderedList))
	end
	event = {pID = hero:GetPlayerID(), abList = orderedList}
	GameRules.abilityManager:InitializeQueriedAbilities(event)
end

function AbilityManager:InitializeQueriedAbilities(event)
	local pID = event.pID
	local abilityList = event.abList

	local player = PlayerResource:GetPlayer(pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID) 
	if not hero then return nil end
	local trueCount = 0
	local orderedList = {}
	for index, ability in pairs(abilityList) do
		orderedList[tonumber(index)] = ability
		trueCount = trueCount + 1
	end
	if trueCount == 4 then
		hero.abilityIndexingList = orderedList
		GameRules.abilityManager:LoadHeroSkills(hero)
		hero.HasBeenInitialized = true
		hero.hasSkillsSelected = true
		CustomGameEventManager:Send_ServerToPlayer(player, "finishedAbilityQuery", {})
	end
end

function AbilityManager:LoadHeroSkills(hero)
	for i = 0, #hero.abilityIndexingList do
		local index = self:FindNextAbilityIndex(hero)
		local ability = hero.abilityIndexingList[i]
		local talentIndex = self:FindNextTalentIndex(hero)
		
		if ability and index and talentIndex then
			hero:RemoveAbility(hero:GetAbilityByIndex(index):GetName())
			hero:AddAbilityPrecache(ability):SetAbilityIndex(index)
			
			hero:RemoveAbility(hero:GetAbilityByIndex(talentIndex):GetName())
			local talentName = ability.."_talent_1"
			local talent = hero:AddAbility(talentName)
			talent:SetAbilityIndex(talentIndex)
		end
	end
end

function AbilityManager:FindNextAbilityIndex(hero)
	for i = 0, 23 do
		if hero:GetAbilityByIndex(i) then
			if string.match(hero:GetAbilityByIndex(i):GetName(), "empty") then
				return i 
			end
		end
	end
end

function AbilityManager:FindNextTalentIndex(hero)
	for i = 0, 23 do
		if hero:GetAbilityByIndex(i) then
			if string.match(hero:GetAbilityByIndex(i):GetName(), "generic_empty_talent") then
				return i 
			end
		end
	end
end