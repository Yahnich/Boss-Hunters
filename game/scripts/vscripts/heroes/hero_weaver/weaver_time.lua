weaver_time = class({})
LinkLuaModifier( "modifier_weaver_time", "heroes/hero_weaver/weaver_time.lua" ,LUA_MODIFIER_MOTION_NONE )

function weaver_time:IsStealable()
	return true
end

function weaver_time:IsHiddenWhenStolen()
	return false
end

function weaver_time:GetIntrinsicModifierName()
    return "modifier_weaver_time"
end

function weaver_time:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_weaver_time_2") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
	end
end

function weaver_time:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_weaver_time_2")
end

function weaver_time:OnSpellStart()
	local caster = self:GetCaster()
    local target = self:GetCursorTarget() or caster

    local health = self.tempList[target:entindex()][1]["health"]
    local mana = self.tempList[target:entindex()][1]["mana"]
    local position = self.tempList[target:entindex()][1]["position"]
    target:Interrupt()
    
    EmitSoundOn("Hero_Weaver.TimeLapse", target)

    -- Adds damage to caster's current health
    local particle_ground = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_timelapse.vpcf", PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(particle_ground, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_ground, 1, position) --radius
    ParticleManager:SetParticleControl(particle_ground, 2, position) --ammount of particle
    ParticleManager:ReleaseParticleIndex(particle_ground)
	
	if target:IsSameTeam( caster ) then
		target:SetHealth(health)
		target:SetMana(mana)
		ProjectileManager:ProjectileDodge(target)
	elseif target:TriggerSpellAbsorb( self ) then
		return
	end
    
	if target == caster then
		self:PayManaCost( )
	end
	
	if caster:HasTalent("special_bonus_unique_weaver_time_1") then
		local fabricTear = caster:FindAbilityByName("weaver_fabric_tear")
		local duration = fabricTear:GetTalentSpecialValueFor("duration") * caster:FindTalentValue("special_bonus_unique_weaver_time_1") / 100
		if fabricTear then
			fabricTear:CreateFabricTear( target:GetAbsOrigin(), duration )
			fabricTear:CreateFabricTear( position, duration )
		end
	end

    target:Dispel (caster, true)
    FindClearSpaceForUnit(target, position, true)
end

modifier_weaver_time = class({})
function modifier_weaver_time:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function modifier_weaver_time:OnIntervalThink()
    local caster = self:GetParent()

    local ability = self:GetAbility()
    local backtrack_time = self:GetTalentSpecialValueFor("time")
    
    -- Temporary damage array and index
    if not ability.tempList then ability.tempList = {} end
    
    if caster:HasTalent("special_bonus_unique_weaver_time_2") then
        local units = caster:FindAllUnitsInRadius( caster:GetAbsOrigin(), -1 )
        for _,unit in pairs(units) do
            if not ability.tempList[unit:entindex()] then ability.tempList[unit:entindex()] = {} end
            local unitTable = {}
            unitTable["health"] = unit:GetHealth()
            unitTable["mana"] = unit:GetMana()
            unitTable["position"] = unit:GetAbsOrigin()
            table.insert(ability.tempList[unit:entindex()],unitTable)
			local maxindex = backtrack_time/0.2
			if #ability.tempList[unit:entindex()] > maxindex then
				table.remove(ability.tempList[unit:entindex()],1)
			end
        end
	else
		if not ability.tempList[caster:entindex()] then ability.tempList[caster:entindex()] = {} end
		local casterTable = {}
		casterTable["health"] = caster:GetHealth()
		casterTable["mana"] = caster:GetMana()
		casterTable["position"] = caster:GetAbsOrigin()
		table.insert(ability.tempList[caster:entindex()],casterTable)
		local maxindex = backtrack_time/0.2
		if #ability.tempList[caster:entindex()] > maxindex then
			table.remove(ability.tempList[caster:entindex()],1)
		end
    end
	for entindex, dataTables in ipairs( ability.tempList ) do
		local unit = EntIndexToHScript( entindex )
		if not unit or unit:IsNull() then
			ability.tempList[entindex] = nil
		end
	end
end

function modifier_weaver_time:IsHidden()
    return true
end
