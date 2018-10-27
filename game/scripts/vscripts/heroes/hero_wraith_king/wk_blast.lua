wk_blast = class({})
LinkLuaModifier( "modifier_wk_blast", "heroes/hero_wraith_king/wk_blast.lua" ,LUA_MODIFIER_MOTION_NONE )

function wk_blast:IsStealable()
    return true
end

function wk_blast:IsHiddenWhenStolen()
    return false
end

function wk_blast:GetBehavior()
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_unique_wk_blast_1") then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL
    else
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
end

function wk_blast:OnAbilityPhaseStart()
    local caster = self:GetCaster()

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_warmup.vpcf", PATTACH_POINT_FOLLOW, caster)
                ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(nfx)

    return true
end

function wk_blast:OnSpellStart()
	local caster = self:GetCaster()

    if caster:HasTalent("special_bonus_unique_wk_blast_1") then
        self:floatyOrb(self:GetCursorPosition())
    else
        self:FireBlast(self:GetCursorTarget())
    end 
end

function wk_blast:FireBlast(target)
    local speed = self:GetTalentSpecialValueFor("speed")
    self:FireTrackingProjectile("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf", target, speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, true, true, 100)
end

function wk_blast:floatyOrb(pos)
    local caster = self:GetCaster()
    local mousePos = pos
    
    local vDir = CalculateDirection(mousePos, caster) * Vector(1,1,0)
    local orbDuration = 10
    local orbSpeed = self:GetTalentSpecialValueFor("speed") + FrameTime()
    local orbRadius = 75
    
    local position = caster:GetAbsOrigin()
    local vVelocity = vDir * orbSpeed

    position = GetGroundPosition(position, nil) + Vector(0,0,128)
    
    local ProjectileThink = function(self, ... )
        local position = self:GetPosition()
        local velocity = self:GetVelocity()
        if velocity.z > 0 then velocity.z = 0 end
        self:SetPosition( position + (velocity*FrameTime()) ) 
    end

    local ProjectileHit = function(self, target, position)
        local caster = self:GetCaster()
        local ability = self:GetAbility()

        local damage = ability:GetTalentSpecialValueFor("damage")
        local stun_duration = ability:GetTalentSpecialValueFor("stun_duration")
        local dot_duration = ability:GetTalentSpecialValueFor("dot_duration")  

        if not self.hitUnits[target:entindex()] then
            ability:DealDamage(caster, target, damage, {}, 0)
            ability:Stun(target, stun_duration, false)
            target:AddNewModifier(caster, ability, "modifier_wk_blast", {Duration = dot_duration})
            self.hitUnits[target:entindex()] = true
        end
            
        return true
    end
    ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf",
                                                                          position = position,
                                                                          caster = caster,
                                                                          ability = self,
                                                                          speed = orbSpeed,
                                                                          radius = orbRadius,
                                                                          distance = 1000,
                                                                          hitUnits = {},
                                                                          velocity = vVelocity,
                                                                          duration = orbDuration})
end

function wk_blast:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()

    local damage = self:GetTalentSpecialValueFor("damage")
    local stun_duration = self:GetTalentSpecialValueFor("stun_duration")
    local dot_duration = self:GetTalentSpecialValueFor("dot_duration")

    if hTarget then
        self:DealDamage(caster, hTarget, damage, {}, 0)
        self:Stun(hTarget, stun_duration, false)
        hTarget:AddNewModifier(caster, self, "modifier_wk_blast", {Duration = dot_duration})
    end
end


modifier_wk_blast = class({})
function modifier_wk_blast:IsDebuff()
    return true
end

function modifier_wk_blast:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(1)
    end
end

function modifier_wk_blast:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local damage = self:GetTalentSpecialValueFor("dot_damage")

    self:GetAbility():DealDamage(caster, parent, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
end

function modifier_wk_blast:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_wk_blast:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("slow")
end

function modifier_wk_blast:GetEffectName()
    return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf"
end