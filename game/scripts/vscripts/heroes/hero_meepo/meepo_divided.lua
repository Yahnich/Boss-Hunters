meepo_divided = class({})
LinkLuaModifier("modifier_meepo_divided","heroes/hero_meepo/meepo_divided.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meepo_divided_death","heroes/hero_meepo/meepo_divided.lua",LUA_MODIFIER_MOTION_NONE)

function meepo_divided:OnHeroLevelUp()
    local caster = self:GetCaster()

    if caster:GetLevel() == 10 then
    	self:SpawnMeepo()
    end

    if caster:GetLevel() == 20 then
    	self:SpawnMeepo()
    end

    if caster:GetLevel() == 30 then
    	self:SpawnMeepo()
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
    newMeepo:SetModelScale(0.75)
    newMeepo:SetControllableByPlayer(PID, false)
    newMeepo:SetOwner(caster:GetOwner())
    newMeepo:AddNewModifier(mainMeepo, self, "modifier_phased", {Duration = 0.1})

    newMeepo:AddNewModifier(mainMeepo, self, "modifier_meepo_divided", {})
    list = mainMeepo.meepoList
    table.insert(list, newMeepo)
    mainMeepo.meepoList = list
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
    		MODIFIER_EVENT_ON_DEATH,
    		MODIFIER_EVENT_ON_RESPAWN,
    		MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_meepo_divided:OnCreated(table)
    if IsServer() then
        self.currentTime = 0
        self.respawnTime = self:GetSpecialValueFor("respawn")

        self:StartIntervalThink(FrameTime())
    end
end

function modifier_meepo_divided:OnIntervalThink()
    local meepo = self:GetParent()
    local mainMeepo = self:GetCaster()
    local ability = self:GetAbility()

    if not meepo:IsAlive() then
        if self.currentTime < self.respawnTime then
            self.currentTime = self.currentTime + FrameTime()
        else
            meepo:RespawnHero(false, false)
            self.currentTime = 0
        end
    end

    if mainMeepo ~= meepo then
    	if mainMeepo:GetItemInSlot(0) then
	        local boots = { mainMeepo:GetItemInSlot(0):GetAbilityName() }

	        local item = ""

	        for _, name in pairs(boots) do
	            if item == "" then
	                for j=0,5 do
	                    local it = mainMeepo:GetItemInSlot(j)
	                    if it and (name == it:GetAbilityName()) and name ~= "item_ultimate_scepter" then
	                        item = it:GetAbilityName()
	                    end
	                end
	            else
	               break
	            end
	        end

	        if item ~= "" then
	            if meepo["item"] then
	                if meepo["item"] ~= item then
	                    UTIL_Remove( meepo["itemHandle"] )
	                    local itemHandle = meepo:AddItemByName(item)
	                    itemHandle:SetDroppable(false)
	                    itemHandle:SetSellable(false)
	                    itemHandle:SetCanBeUsedOutOfInventory(true)
	                    itemHandle:SetPurchaser(mainMeepo)
	                    meepo["itemHandle"] = itemHandle
	                    meepo["item"] = item
	                end
	            else
	                meepo["itemHandle"] = meepo:AddItemByName(item)
	                meepo["item"] = item
	                meepo["itemHandle"]:SetDroppable(false)
	                meepo["itemHandle"]:SetSellable(false)
	                meepo["itemHandle"]:SetCanBeUsedOutOfInventory(false)
	                meepo["itemHandle"]:SetPurchaser(mainMeepo)
	            end
	        end

	        for j=0,5 do
	            local itemToCheck = meepo:GetItemInSlot(j)
	            if itemToCheck then
	                local name = itemToCheck:GetAbilityName()
	                if name ~= item then
	                    UTIL_Remove(itemToCheck)
	                end
	            end
	        end

	        meepo:SetBaseStrength(mainMeepo:GetStrength())
	        meepo:SetBaseAgility(mainMeepo:GetAgility())
	        meepo:SetBaseIntellect(mainMeepo:GetIntellect())
	        meepo:CalculateStatBonus()

	        while meepo:GetLevel() < mainMeepo:GetLevel() do
	            meepo:AddExperience(10,1,false,false)
	        end
	    end
    else
        LevelAbilitiesForAllMeepos(meepo)
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
            mainMeepo:ModifyHealth(mainMeepo:GetMaxHealth() - healthLoss, self:GetAbility(), true, 0)
        end
    end
end

function LevelAbilitiesForAllMeepos(caster)
    local PID = caster:GetPlayerOwnerID()
    local mainMeepo = PlayerResource:GetSelectedHeroEntity(PID)
    if caster == mainMeepo then
        for a=0,caster:GetAbilityCount()-1,1 do
            local ability = caster:GetAbilityByIndex(a)
            if ability then
                for _, meepo in pairs(GetAllMeepos(mainMeepo)) do

                    local cloneAbility = meepo:FindAbilityByName(ability:GetAbilityName())
                    if ability:GetLevel() > cloneAbility:GetLevel() then
                        cloneAbility:SetLevel(ability:GetLevel())
                        meepo:SetAbilityPoints(meepo:GetAbilityPoints()-1)
                    end

                    if ability:GetLevel() < cloneAbility:GetLevel() then
                        ability:SetLevel(cloneAbility:GetLevel())
                        mainMeepo:SetAbilityPoints(mainMeepo:GetAbilityPoints()-1)
                    end
                end
            end
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
