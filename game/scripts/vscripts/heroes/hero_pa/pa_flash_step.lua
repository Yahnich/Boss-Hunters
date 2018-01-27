pa_flash_step = class({})
LinkLuaModifier( "modifier_flash_step", "heroes/hero_pa/pa_flash_step.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flash_step_as", "heroes/hero_pa/pa_flash_step.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flash_step_enemy", "heroes/hero_pa/pa_flash_step.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kunai_toss_slow", "heroes/hero_pa/pa_kunai_toss.lua" ,LUA_MODIFIER_MOTION_NONE )

function pa_flash_step:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local direction = CalculateDirection(point, caster:GetAbsOrigin())
    local currentDistance = CalculateDistance(point, caster:GetAbsOrigin())
	local hasTalent = caster:HasTalent("special_bonus_unique_pa_flash_step_2")
    caster:FindAbilityByName("pa_kunai_toss").TotesBounces = caster:FindAbilityByName("pa_kunai_toss"):GetSpecialValueFor("bounces")*caster:FindAbilityByName("pa_kunai_toss"):GetSpecialValueFor("max_targets")
    caster:FindAbilityByName("pa_kunai_toss").CurrentBounces = 0
	
	local count = 0
    caster:AddNewModifier(caster, self, "modifier_flash_step", {})
    Timers:CreateTimer(0, function()
        if currentDistance > 0 then
            caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * 100)
            currentDistance = currentDistance - 100
			
			if hasTalent then
				local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:FindAbilityByName("pa_kunai_toss"):GetSpecialValueFor("range"), {})
				count = count + 1
				for _,enemy in pairs(enemies) do
					if count >= 4 then
						count = 0
						caster:FindAbilityByName("pa_kunai_toss"):tossKunai(enemy)
						break
					end
				end
			end

            return FrameTime()
        else
            caster:RemoveModifierByName("modifier_flash_step")
            FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
            return nil
        end
    end)
end

modifier_flash_step = class({})
function modifier_flash_step:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_flash_step:OnRemoved()
    if IsServer() then
        local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
        for _,enemy in pairs(enemies) do
            if enemy:HasModifier("modifier_flash_step_enemy") then
                enemy:RemoveModifierByName("modifier_flash_step_enemy")
            end
        end
    end
end

function modifier_flash_step:OnIntervalThink()
    local caster = self:GetCaster()

    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange(), {})
    for _,enemy in pairs(enemies) do
        if not enemy:HasModifier("modifier_flash_step_enemy") then
            caster:PerformAttack(enemy, true, true, true, true, false, false, false)
            self:GetAbility():DealDamage(caster, enemy, caster:GetAttackDamage()*(self:GetTalentSpecialValueFor("damage")-100)/100, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
            enemy:AddNewModifier(caster, self:GetAbility(), "modifier_flash_step_enemy", {Duration = self:GetTalentSpecialValueFor("duration")})
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_flash_step_as", {Duration = self:GetTalentSpecialValueFor("duration")}):IncrementStackCount()
            break
        end
    end
end

function modifier_flash_step:CheckState()
    local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
                }
    return state
end

function modifier_flash_step:GetEffectName()
    return "particles/units/heroes/hero_pa/pa_flash_step/pa_flash_step.vpcf"
end

function modifier_flash_step:IsHidden()
    return true
end

modifier_flash_step_as = class({})
function modifier_flash_step_as:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }   
    return funcs
end

function modifier_flash_step_as:GetModifierAttackSpeedBonus_Constant()
    return self:GetTalentSpecialValueFor("bonus_as") + self:GetStackCount()
end

function modifier_flash_step_as:IsDebuff()
    return false
end

modifier_flash_step_enemy = class({})
function modifier_flash_step_enemy:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }   
    return funcs
end

function modifier_flash_step_enemy:GetModifierAttackSpeedBonus_Constant()
    return -self:GetTalentSpecialValueFor("bonus_as")
end

function modifier_flash_step_enemy:IsDebuff()
    return true
end