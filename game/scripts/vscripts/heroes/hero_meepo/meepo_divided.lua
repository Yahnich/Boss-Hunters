meepo_divided = class({})
LinkLuaModifier("modifier_meepo_divided","heroes/hero_meepo/meepo_divided.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meepo_divided_death","heroes/hero_meepo/meepo_divided.lua",LUA_MODIFIER_MOTION_NONE)

function meepo_divided:IsRefreshable()
	return false
end

function meepo_divided:OnHeroLevelUp()
    local caster = self:GetCaster()
    local PID = caster:GetPlayerOwnerID()
    local mainMeepo = PlayerResource:GetSelectedHeroEntity(PID)
	if caster == mainMeepo then
		if caster:GetLevel() == 10 then
			self:SpawnMeepo()
		end

		if caster:GetLevel() == 20 then
			self:SpawnMeepo()
		end

		if caster:GetLevel() == 30 then
			self:SpawnMeepo()
		end
		
		if caster.meepoList then
			for _, meepo in ipairs( caster.meepoList ) do
				if caster:GetLevel() < mainMeepo:GetLevel() and caster ~= meepo then
					local xp = GameRules.XP_PER_LEVEL[mainMeepo:GetLevel()] - GameRules.XP_PER_LEVEL[caster:GetLevel()]
					meepo:AddExperience(xp,1,false,false)
					meepo:SetAbilityPoints( mainMeepo:GetAbilityPoints() )
				end
			end
		end
	end
end

function meepo_divided:OnInventoryContentsChanged()
    local caster = self:GetCaster()
    local PID = caster:GetPlayerOwnerID()
    local mainMeepo = PlayerResource:GetSelectedHeroEntity(PID)
	if caster == mainMeepo and caster.meepoList then
		local currentItem = mainMeepo:GetItemInSlot(0)
		local firstItem
    	if currentItem then
	        firstItem = currentItem:GetAbilityName()
			if ( currentItem.IsConsumable and currentItem:IsConsumable() ) or firstItem == "item_ward_observer" then
				firstItem = nil
			end
		end
		for _, meepo in ipairs( caster.meepoList ) do
			if caster ~= meepo then
				for i = 0, 9 do
					local clonedItem = meepo:GetItemInSlot(i)
					if clonedItem then UTIL_Remove(clonedItem) end
				end
				if firstItem then
					local itemToClone = meepo:AddItemByName(firstItem)
					if itemToClone then
						meepo.ignoreInventoryEvent = true
						if currentItem.itemData then
							Timers:CreateTimer(function()
								itemToClone.itemData = table.copy( currentItem.itemData )
								local passive = meepo:FindModifierByNameAndAbility( itemToClone:GetIntrinsicModifierName(), itemToClone )
								local funcs = {}
								for slot, rune in pairs( currentItem.itemData ) do
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
							end)
						end
						itemToClone:SetStacksWithOtherOwners(true)
						itemToClone:SetPurchaser(nil)
						itemToClone:SetSellable(false)
						itemToClone:SetDroppable(false)
						itemToClone.isClonedItem = true
						meepo.ignoreInventoryEvent = false
					end
				end
			end
		end
	elseif caster ~= mainMeepo and caster.ignoreInventoryEvent then
		for i = 0, 9 do
			local clonedItem = caster:GetItemInSlot(i)
			if clonedItem and not clonedItem.isClonedItem then 
				caster:DropItemAtPositionImmediate( clonedItem, caster:GetAbsOrigin() + RandomVector(128) )
			end
		end
	end
end

function meepo_divided:SpawnMeepo()
	local caster = self:GetCaster()

    local PID = caster:GetPlayerOwnerID()

    local mainMeepo = PlayerResource:GetSelectedHeroEntity(PID)

    local list = mainMeepo.meepoList or {}

    if caster ~= mainMeepo then
        return nil
    end

    if not mainMeepo.meepoList then
        table.insert(list, mainMeepo)
        mainMeepo.meepoList = list
        mainMeepo:AddNewModifier(mainMeepo, self, "modifier_meepo_divided", {})
    end

    local newMeepo = CreateUnitByName(caster:GetUnitName(), mainMeepo:GetAbsOrigin(), true, mainMeepo, mainMeepo:GetPlayerOwner(), mainMeepo:GetTeamNumber())
    newMeepo:SetModelScale(0.93)
    newMeepo:SetControllableByPlayer(PID, false)
    newMeepo:SetOwner(caster:GetOwner())
	
	newMeepo:AddNewModifier( mainMeepo, nil, "modifier_stats_system_handler", {})
    newMeepo:AddNewModifier(mainMeepo, self, "modifier_phased", {Duration = 0.1})
    newMeepo:AddNewModifier(mainMeepo, self, "modifier_meepo_divided", {})
	
	newMeepo:AddExperience(GameRules.XP_PER_LEVEL[mainMeepo:GetLevel()],1,false,false)
	newMeepo:SetAbilityPoints( mainMeepo:GetAbilityPoints() )
	
	for a=0,caster:GetAbilityCount()-1,1 do
		local ability = caster:GetAbilityByIndex(a)
		if ability then
			local cloneAbility = newMeepo:FindAbilityByName(ability:GetAbilityName())
			if cloneAbility then
				cloneAbility:SetLevel(ability:GetLevel())
			end
		end
	end
	
    list = mainMeepo.meepoList
    table.insert(list, newMeepo)
    mainMeepo.meepoList = list
	
	
	self:OnInventoryContentsChanged()
end

modifier_meepo_divided = class({})
function modifier_meepo_divided:IsHidden()
    return true
end

function modifier_meepo_divided:IsPermanent()
    return true
end

function modifier_meepo_divided:RemoveOnDeath()
    return false
end

function modifier_meepo_divided:IsPurgable()
    return false
end

function modifier_meepo_divided:IsPurgeException()
    return false
end

function modifier_meepo_divided:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ORDER,
    		MODIFIER_EVENT_ON_DEATH}
end

function modifier_meepo_divided:OnCreated(table)
    if IsServer() then
        self.currentTime = 0
        self.respawnTime = self:GetSpecialValueFor("respawn")
		
		self.statsHandler =  self:GetParent():FindModifierByName("modifier_stats_system_handler")
		self.mainHandler = self:GetCaster():FindModifierByName("modifier_stats_system_handler")
		
        self:StartIntervalThink(0.25)
    end
end

function modifier_meepo_divided:OnIntervalThink()
    local meepo = self:GetParent()
    local mainMeepo = self:GetCaster()
    local ability = self:GetAbility()
	
	if meepo ~= mainMeepo then
		if not meepo:IsAlive() then
			if self.currentTime < self.respawnTime then
				self.currentTime = self.currentTime + 0.25
			elseif mainMeepo:IsAlive() then
				meepo:RespawnHero(false, false)
				self.currentTime = 0
			end
		end
		
		local strength = mainMeepo:GetBaseStrength()
		local agility = mainMeepo:GetBaseAgility()
		local intellect = mainMeepo:GetBaseIntellect()
		
		local calculate = strength ~= meepo:GetBaseStrength() and agility ~= meepo:GetBaseAgility() and intellect ~= meepo:GetBaseIntellect()
		if calculate then
			meepo:SetBaseStrength(strength)
			meepo:SetBaseAgility(agility)
			meepo:SetBaseIntellect(intellect)
			meepo:CalculateStatBonus()
		end
		
		if self.statsHandler:GetStackCount() ~= self.mainHandler:GetStackCount() then
			self.statsHandler:SetStackCount( self.mainHandler:GetStackCount() )
		end
	end
end

function modifier_meepo_divided:OnOrder(params)
	if params.order_type == DOTA_UNIT_ORDER_TRAIN_ABILITY and params.unit == self:GetParent() then
		local mainMeepo = self:GetCaster()
		local parent = self:GetParent()
		local abilityName = params.ability:GetName()
		for _, meepo in ipairs( GetAllMeepos(mainMeepo) ) do
			if meepo ~= parent then
				local ability = meepo:FindAbilityByName(abilityName)
				if ability then
					ability:SetLevel( params.ability:GetLevel() + 1 )
					meepo:SetAbilityPoints( meepo:GetAbilityPoints() - 1 )
				end
			end
		end
	end
end

function modifier_meepo_divided:OnDeath(params)
    local mainMeepo = self:GetCaster()
    local parent = self:GetParent()

    if params.unit == mainMeepo and params.unit ~= parent then
        for _, meepo in pairs(GetAllMeepos(mainMeepo)) do
            if meepo ~= mainMeepo and meepo:IsAlive() then
                meepo:ForceKill(false)
            end
        end

    elseif params.unit == parent and params.unit ~= mainMeepo then
        if mainMeepo:IsAlive() then
            local healthLoss = mainMeepo:GetMaxHealth() * self:GetSpecialValueFor("health_remove")/100
            mainMeepo:ModifyHealth(mainMeepo:GetHealth() - healthLoss, self:GetAbility(), true, 0)
			self:GetAbility():SetCooldown(self.respawnTime)
        end
    end
end

function GetAllMeepos(caster)
    if caster.meepoList then
        return caster.meepoList
    else
        return {caster}
    end
end
