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

function weaver_time:OnSpellStart()
	local caster = self:GetCaster()
    local target = caster

    local health = self.tempList[caster:GetUnitName()][1]["health"]
    local mana = self.tempList[caster:GetUnitName()][1]["mana"]
    local position = self.tempList[caster:GetUnitName()][1]["position"]

    target:Interrupt()
    
    EmitSoundOn("Hero_Weaver.TimeLapse", caster)

    -- Adds damage to caster's current health
    local particle_ground = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_timelapse.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particle_ground, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_ground, 1, position) --radius
    ParticleManager:SetParticleControl(particle_ground, 2, position) --ammount of particle
    ParticleManager:ReleaseParticleIndex(particle_ground)
    
    if caster:HasTalent("special_bonus_unique_weaver_time_1") then
        target:ConjureImage( target:GetAbsOrigin(), 5, 200, 100, "", self, false, caster)
    end

    if caster:HasTalent("special_bonus_unique_weaver_time_2") then
        health = target:GetMaxHealth()
        mana = target:GetMaxMana()

        for i=0,6 do
            local ability = target:GetAbilityByIndex(i)
            if ability ~= self then
                ability:EndCooldown()
            end
        end
    end

    target:SetHealth(health)
    target:SetMana(mana)
    target:Purge(false,true,false,true,false)
    ProjectileManager:ProjectileDodge(target)
    FindClearSpaceForUnit(target, position, true)
end

modifier_weaver_time = class({})
function modifier_weaver_time:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

function modifier_weaver_time:OnIntervalThink()
    local caster = self:GetParent()

    local ability = self:GetAbility()
    local backtrack_time = self:GetTalentSpecialValueFor("time")
    
    -- Temporary damage array and index
    if not ability.tempList then ability.tempList = {} end
    if not ability.tempList[caster:GetUnitName()] then ability.tempList[caster:GetUnitName()] = {} end
    local casterTable = {}
    casterTable["health"] = caster:GetHealth()
    casterTable["mana"] = caster:GetMana()
    casterTable["position"] = caster:GetAbsOrigin()
    table.insert(ability.tempList[caster:GetUnitName()],casterTable)
    --[[if caster:HasScepter() then
        enemies = FindUnitsInRadius(caster:GetTeam(),
                                        caster:GetAbsOrigin(),
                                        nil,
                                        9999,
                                        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                        DOTA_UNIT_TARGET_HERO,
                                        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
                                        FIND_ANY_ORDER,
                                        false)
        for _,enemy in pairs(enemies) do
            if not ability.tempList[enemy:GetName()] then ability.tempList[enemy:GetName()] = {} end
            local enemyTable = {}
            enemyTable["health"] = enemy:GetHealth()
            enemyTable["mana"] = enemy:GetMana()
            enemyTable["position"] = enemy:GetAbsOrigin()
            table.insert(ability.tempList[enemy:GetName()],enemyTable)
        end
    end]]
    
    local maxindex = backtrack_time/0.2
    if #ability.tempList[caster:GetUnitName()] > maxindex then
        table.remove(ability.tempList[caster:GetUnitName()],1)
        --[[for _,enemy in pairs(enemies) do
            table.remove(ability.tempList[enemy:GetName()],1)
        end]]
    end
end

function modifier_weaver_time:IsHidden()
    return true
end
