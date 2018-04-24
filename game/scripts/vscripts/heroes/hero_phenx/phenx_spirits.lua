phenx_spirits = class({})
LinkLuaModifier( "modifier_phenx_spirits_caster", "heroes/hero_phenx/phenx_spirits.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_phenx_spirits_burn", "heroes/hero_phenx/phenx_spirits.lua", LUA_MODIFIER_MOTION_NONE )

function phenx_spirits:IsStealable()
    return true
end

function phenx_spirits:IsHiddenWhenStolen()
    return false
end

function phenx_spirits:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_phenx_spirits_caster") then
        return "phoenix_launch_fire_spirit"
    end

    return "phoenix_fire_spirits"
end

function phenx_spirits:GetBehavior()
    if self:GetCaster():HasModifier("modifier_phenx_spirits_caster") then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNRESTRICTED
    end

    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_UNRESTRICTED
end

function phenx_spirits:GetCastAnimation()
    if self:GetCaster():HasModifier("modifier_phenx_spirits_caster") then
        return ACT_DOTA_OVERRIDE_ABILITY_2
    end

    return ACT_DOTA_CAST_ABILITY_2
end

function phenx_spirits:GetManaCost(iLvl)
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_phenx_spirits_caster") then
		return self.BaseClass.GetManaCost(self, iLvl)
	else
		return 0
	end
end

function phenx_spirits:GetCooldown(iLvl)
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_phenx_spirits_caster") then
		return self.BaseClass.GetCooldown(self, iLvl)
	else
		return 0
	end
end

function phenx_spirits:OnSpellStart()
    local caster = self:GetCaster()
    
    if caster:HasModifier("modifier_phenx_spirits_caster") then
        EmitSoundOn("Hero_Phoenix.FireSpirits.Launch", caster)
        -- Update spirits count
        local modifier = caster:FindModifierByName("modifier_phenx_spirits_caster")
        local currentStack  = modifier:GetStackCount()
        currentStack = currentStack - 1
        modifier:DecrementStackCount()

        local point = self:GetCursorPosition()
        local dir = CalculateDirection(point, caster:GetAbsOrigin())
        local dist = CalculateDistance(point, caster:GetAbsOrigin())
        local vel = dir * self:GetTalentSpecialValueFor("spirit_speed")

        self:FireLinearProjectile("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_launch.vpcf", vel, dist, self:GetTalentSpecialValueFor("radius")/1.5, {}, false, true, self:GetTalentSpecialValueFor("radius"))

        -- Update the particle FX
        ParticleManager:SetParticleControl( modifier.pfx, 1, Vector( currentStack, 0, 0 ) )
        for i=1, caster.fire_spirits_numSpirits do
            local radius = 0
            if i <= currentStack then
                radius = 1
            end

            ParticleManager:SetParticleControl( modifier.pfx, 8+i, Vector( radius, 0, 0 ) )
        end

        -- Remove the stack modifier if all the spirits has been launched.
        if currentStack == 0 then
            modifier:Destroy()
        end
        if caster:FindModifierByName("modifier_phenx_spirits_caster") and caster:FindModifierByName("modifier_phenx_spirits_caster"):GetStackCount() > 0 then
            self:EndCooldown()
        else
            self:SetCooldown()
        end
        
    else
        EmitSoundOn("Hero_Phoenix.FireSpirits.Cast", caster)
    
        local hpCost        = self:GetTalentSpecialValueFor("hp_cost_perc")
        local numSpirits    = self:GetTalentSpecialValueFor("spirit_count")

		local modifier = caster:AddNewModifier(caster, self, "modifier_phenx_spirits_caster", {})
        modifier:SetStackCount( numSpirits )
        -- Create particle FX
        modifier.pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_fire_spirits.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
        ParticleManager:SetParticleControl( modifier.pfx, 1, Vector( numSpirits, 0, 0 ) )
        for i=1, numSpirits do
            ParticleManager:SetParticleControl( modifier.pfx, 8+i, Vector( 1, 0, 0 ) )
        end

        caster.fire_spirits_numSpirits  = numSpirits

        caster:SetHealth( caster:GetHealth() * ( 100 - hpCost ) / 100 )

        
        self:EndCooldown()
    end
end

function phenx_spirits:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()

    if hTarget ~= nil then
        hTarget:AddNewModifier(caster, self, "modifier_phenx_spirits_burn", {Duration = self:GetTalentSpecialValueFor("duration")})
    else
        GridNav:DestroyTreesAroundPoint(vLocation, self:GetTalentSpecialValueFor("radius"), false)
        ParticleManager:FireParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_POINT, caster, {[0]=vLocation, [1]=Vector(self:GetTalentSpecialValueFor("radius"), 1, 1)})
        local enemies = caster:FindEnemyUnitsInRadius(vLocation, self:GetTalentSpecialValueFor("radius"))
        for _,enemy in pairs(enemies) do
            enemy:AddNewModifier(caster, self, "modifier_phenx_spirits_burn", {Duration = self:GetTalentSpecialValueFor("duration")})
        end
    end
end

modifier_phenx_spirits_caster = class({})
function modifier_phenx_spirits_caster:OnRemoved()
	if IsServer() then
		if self:GetStackCount() < 1 then
			self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
		end
		ParticleManager:ClearParticle( self.pfx )
	end
end

modifier_phenx_spirits_burn = class({})
function modifier_phenx_spirits_burn:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_phenx_spirits_burn:OnIntervalThink()
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("damage_per_second"), {}, 0)
    self:StartIntervalThink(self:GetTalentSpecialValueFor("tick_interval"))
end

function modifier_phenx_spirits_burn:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf"
end

function modifier_phenx_spirits_burn:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_phenx_spirits_burn:GetModifierAttackSpeedBonus_Constant()
    return self:GetTalentSpecialValueFor("attackspeed_slow")
end