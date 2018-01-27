riki_dagger = class({})
LinkLuaModifier( "modifier_dagger", "heroes/hero_riki/riki_dagger.lua" ,LUA_MODIFIER_MOTION_NONE )

function riki_dagger:GetIntrinsicModifierName()
    return "modifier_dagger"
end

modifier_dagger = class({})
function modifier_dagger:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }   
    return funcs
end

function modifier_dagger:OnAttackLanded(params)
    if IsServer() then
        local caster = self:GetCaster()
        if params.attacker == caster then
            local agility_damage_multiplier = self:GetTalentSpecialValueFor("damage_multiplier")

            -- The y value of the angles vector contains the angle we actually want: where units are directionally facing in the world.
            local victim_angle = params.target:GetAnglesAsVector().y
            local origin_difference = params.target:GetAbsOrigin() - params.attacker:GetAbsOrigin()

            -- Get the radian of the origin difference between the attacker and Riki. We use this to figure out at what angle the victim is at relative to Riki.
            local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
            
            -- Convert the radian to degrees.
            origin_difference_radian = origin_difference_radian * 180
            local attacker_angle = origin_difference_radian / math.pi
            -- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
            attacker_angle = attacker_angle + 180.0
            
            -- Finally, get the angle at which the victim is facing Riki.
            local result_angle = attacker_angle - victim_angle
            result_angle = math.abs(result_angle)
            -- Check for the backstab angle.
            local damage = params.attacker:GetAgility() * agility_damage_multiplier
            if result_angle >= (180 - (self:GetTalentSpecialValueFor("backstab_angle") / 2)) and result_angle <= (180 + (self:GetTalentSpecialValueFor("backstab_angle") / 2)) then 
                -- Play the sound on the victim.
                EmitSoundOn("Hero_Riki.Backstab", params.target)
                -- Create the back particle effect.
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target) 
                -- Set Control Point 1 for the backstab particle; this controls where it's positioned in the world. In this case, it should be positioned on the victim.
                ParticleManager:SetParticleControlEnt(particle, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(particle)
                -- Apply extra backstab damage based on Riki's agility
                self:GetAbility():DealDamage(params.attacker, params.target, damage, {}, OVERHEAD_ALERT_DAMAGE)
                
                if params.attacker:HasTalent("special_bonus_unique_riki_dagger_1") then
                    params.attacker:ModifyGold(params.attacker:FindTalentValue("special_bonus_unique_riki_dagger_1"), true, 0)
                    SendOverheadEventMessage(params.attacker:GetPlayerOwner(),OVERHEAD_ALERT_GOLD,params.attacker,params.attacker:FindTalentValue("special_bonus_unique_riki_dagger_1"),params.attacker:GetPlayerOwner())
                end
            end
        end
    end
end

function modifier_dagger:IsHidden()
    return true
end