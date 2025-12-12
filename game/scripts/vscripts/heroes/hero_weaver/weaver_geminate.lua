weaver_geminate = class({})
LinkLuaModifier( "modifier_weaver_geminate", "heroes/hero_weaver/weaver_geminate.lua" ,LUA_MODIFIER_MOTION_NONE )

function weaver_geminate:IsStealable()
	return false
end

function weaver_geminate:IsHiddenWhenStolen()
	return false
end

function weaver_geminate:GetIntrinsicModifierName()
    return "modifier_weaver_geminate"
end

function weaver_geminate:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()

    if hTarget then
        caster:PerformAbilityAttack(hTarget, true, self, 0, false, false)
    end
end

modifier_weaver_geminate = class({})
function modifier_weaver_geminate:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK}
end

function modifier_weaver_geminate:OnAttack(params)
    if IsServer() then
        local caster = self:GetCaster()
        local attacker = params.attacker

        if attacker == caster then
            local target = params.target
            local ability = self:GetAbility()

            local delay = self:GetSpecialValueFor("delay")
            local maxAttacks = self:GetSpecialValueFor("max_attacks")

            if ability:IsCooldownReady() and not caster:IsInAbilityAttackMode() then
                Timers:CreateTimer(delay, function()
                    if maxAttacks > 0 and not caster:IsInvisible() then
                        if RollPercentage(50) then
                            ability:FireTrackingProjectile(caster:GetProjectileModel(), target, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
                        else
                            ability:FireTrackingProjectile(caster:GetProjectileModel(), target, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, true, false, 0)
                        end
                        maxAttacks = maxAttacks - 1
                        return delay
                    else
                        return nil
                    end
                end)

                ability:SetCooldown()
            end
        end
    end
end

function modifier_weaver_geminate:IsHidden()
    return true
end