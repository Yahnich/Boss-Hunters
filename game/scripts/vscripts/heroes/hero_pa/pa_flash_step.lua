pa_flash_step = class({})
LinkLuaModifier( "modifier_flash_step", "heroes/hero_pa/pa_flash_step.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flash_step_as", "heroes/hero_pa/pa_flash_step.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flash_step_enemy", "heroes/hero_pa/pa_flash_step.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kunai_toss_slow", "heroes/hero_pa/pa_kunai_toss.lua" ,LUA_MODIFIER_MOTION_NONE )

function pa_flash_step:IsStealable()
    return true
end

function pa_flash_step:IsHiddenWhenStolen()
    return false
end

function pa_flash_step:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    EmitSoundOn("Hero_PhantomAssassin.Strike.Start", caster)

    caster:AddNewModifier(caster, self, "modifier_flash_step", {Duration = 5})
end

modifier_flash_step = class({})
function modifier_flash_step:OnCreated(table)
    if IsServer() then
        local caster = self:GetParent()
        self.direction = CalculateDirection(self:GetAbility():GetCursorPosition(), caster:GetAbsOrigin())
        self.currentDistance = CalculateDistance(self:GetAbility():GetCursorPosition(), caster:GetAbsOrigin())

        self.hasTalent = caster:HasTalent("special_bonus_unique_pa_flash_step_2")
        if caster:FindAbilityByName("pa_kunai_toss") then
            caster:FindAbilityByName("pa_kunai_toss").TotesBounces = caster:FindAbilityByName("pa_kunai_toss"):GetSpecialValueFor("bounces")*caster:FindAbilityByName("pa_kunai_toss"):GetSpecialValueFor("max_targets")
            caster:FindAbilityByName("pa_kunai_toss").CurrentBounces = 0
        end
		self.hitUnits = {}
        self:StartIntervalThink(FrameTime())

        self:StartMotionController()
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

function modifier_flash_step:DoControlledMotion()
    local caster = self:GetParent()
    if self.currentDistance > 0 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + self.direction * self:GetSpecialValueFor("speed")*FrameTime())
        self.currentDistance = self.currentDistance - self:GetSpecialValueFor("speed")*FrameTime()
        
        local count = 4
        if self.hasTalent then
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
    else
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        self:StopMotionController(true)
        self:Destroy()
    end
end

function modifier_flash_step:OnIntervalThink()
    local caster = self:GetCaster()

    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange(), {})
    for _,enemy in pairs(enemies) do
        if not self.hitUnits[enemy] then
			if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
				caster:PerformAbilityAttack( enemy, true, self:GetAbility() )
				self:GetAbility():DealDamage(caster, enemy, caster:GetAttackDamage()*(self:GetTalentSpecialValueFor("damage")-100)/100, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_flash_step_as", {Duration = self:GetTalentSpecialValueFor("duration")}):IncrementStackCount()
				enemy:AddNewModifier(caster, self:GetAbility(), "modifier_flash_step_enemy", {Duration = self:GetTalentSpecialValueFor("duration")})
			end
			self.hitUnits[enemy] = true
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
        
    }   
    return funcs
end

function modifier_flash_step_as:GetModifierAttackSpeedBonus()
    return self:GetTalentSpecialValueFor("bonus_as") * self:GetStackCount()
end

function modifier_flash_step_as:IsDebuff()
    return false
end

modifier_flash_step_enemy = class({})
function modifier_flash_step_enemy:DeclareFunctions()
    local funcs = {
        
    }   
    return funcs
end

function modifier_flash_step_enemy:GetModifierAttackSpeedBonus()
    return -self:GetTalentSpecialValueFor("bonus_as")
end

function modifier_flash_step_enemy:IsDebuff()
    return true
end