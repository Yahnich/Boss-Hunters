pa_flash_step = class({})
LinkLuaModifier( "modifier_flash_step", "heroes/hero_pa/pa_flash_step.lua" ,LUA_MODIFIER_MOTION_NONE )
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

        self.talent1 = caster:HasTalent("special_bonus_unique_pa_flash_step_1")
        self.talent2 = caster:HasTalent("special_bonus_unique_pa_flash_step_2")
        if self.talent2 and caster:FindAbilityByName("pa_kunai_toss") then
			self.kunai = caster:FindAbilityByName("pa_kunai_toss")
			self.daggers = caster:FindTalentValue("special_bonus_unique_pa_flash_step_2")
        end
		self.hitUnits = {}
		
		self:StartIntervalThink(0.2)
        self:StartMotionController()
    end
end

function modifier_flash_step:OnIntervalThink()
	ProjectileManager:ProjectileDodge( self:GetParent() )
end

function modifier_flash_step:OnRemoved()
    if IsServer() then
		local caster = self:GetCaster()
        caster:AddNewModifier(caster, self:GetAbility(), "modifier_flash_step_as", {Duration = self:GetTalentSpecialValueFor("duration")})
		caster:MoveToPositionAggressive( caster:GetAbsOrigin() )
		if self.talent2 then
			local angle = 20
			local maxAngle = 180 - math.abs(2 * angle)
			local angleDiff = (maxAngle - angle) / self.daggers
			for i = 1, self.daggers do
				local position = caster:GetAbsOrigin() + 100 * RotateVector2D( -caster:GetRightVector(), ToRadians( angle ) )
				angle = angle + angleDiff
				self.kunai:TossKunai( position )
			end
		end
    end
end

function modifier_flash_step:DoControlledMotion()
    local caster = self:GetParent()
    if self.currentDistance > 0 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + self.direction * self:GetSpecialValueFor("speed")*FrameTime())
        self.currentDistance = self.currentDistance - self:GetSpecialValueFor("speed")*FrameTime()
    else
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        self:StopMotionController(true)
        self:Destroy()
    end
end

function modifier_flash_step:CheckState()
    local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
                }
    return state
end

function modifier_flash_step:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT
    }   
    return funcs
end

function modifier_flash_step:GetModifierEvasion_Constant()
    return 100
end

function modifier_flash_step:GetEffectName()
    return "particles/units/heroes/hero_pa/pa_flash_step/pa_flash_step.vpcf"
end

function modifier_flash_step:IsHidden()
    return true
end

modifier_flash_step_as = class({})
LinkLuaModifier( "modifier_flash_step_as", "heroes/hero_pa/pa_flash_step.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_flash_step_as:OnCreated()
	self:OnRefresh()
end

function modifier_flash_step_as:OnRefresh()
	self.attack_speed = self:GetTalentSpecialValueFor("bonus_as")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_pa_flash_step_1")
end

function modifier_flash_step_as:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_FAIL 
    }   
    return funcs
end

function modifier_flash_step_as:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed
end

function modifier_flash_step_as:OnAttackFail(params)
    if self.talent1 and params.target == self:GetParent() then
		params.target:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, 3 )
		params.target:PerformGenericAttack( params.attacker, true )
	end
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

function modifier_flash_step_enemy:GetModifierAttackSpeedBonus_Constant()
    return -self:GetTalentSpecialValueFor("bonus_as")
end

function modifier_flash_step_enemy:IsDebuff()
    return true
end