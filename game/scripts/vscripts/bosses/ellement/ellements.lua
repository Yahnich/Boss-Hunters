--[[ ============================================================================================================
    Author: Rook
    Date: April 02, 2015
    Called whenever Wex is cast.  Removes the third-to-most-recent orb on Invoker (if applicable) to make room for
    the newest orb, then adds the new orb.
    This function is general enough that it can be used for Quas, Wex, or Exort.

    Modified for ellementalist by frenchdeath , made the number of max orb increase with level of caster
================================================================================================================= ]]
function invoker_replace_orb(keys, particle_filepath)
    --Initialization for storing the orb properties, if not already done.
    if keys.caster.invoked_orbs == nil then
        keys.caster.invoked_orbs = {}
    end
    if keys.caster.invoked_orbs_particle == nil then
        keys.caster.invoked_orbs_particle = {}
    end

    local number = 1
    if keys.caster:GetLevel() >= 50 then
        number = 6
    elseif keys.caster:GetLevel() >= 40 then
        number = 5
    elseif keys.caster:GetLevel() >= 30 then
        number = 4
    elseif keys.caster:GetLevel() >= 20 then
        number = 3
    elseif keys.caster:GetLevel() >= 10 then
        number = 2
    end
    if keys.caster.invoked_orbs_particle_attach == nil then
        keys.caster.invoked_orbs_particle_attach = {}
    end
    if table.getn(keys.caster.invoked_orbs_particle_attach) ~= number then
        keys.caster.invoked_orbs_particle_attach = {}
        keys.caster.invoked_orbs_particle_attach[1] = "attach_orb1"
        if keys.caster:GetLevel() >= 10 then
            keys.caster.invoked_orbs_particle_attach[2] = "attach_orb2"
        end
        if keys.caster:GetLevel() >= 20 then
            keys.caster.invoked_orbs_particle_attach[3] = "attach_orb3"
        end
        if keys.caster:GetLevel() >= 30 then
            keys.caster.invoked_orbs_particle_attach[4] = "attach_hitloc"
        end
        if keys.caster:GetLevel() >= 40 then 
            keys.caster.invoked_orbs_particle_attach[5] = "attach_attack1"
        end
        if keys.caster:GetLevel() >=50 then 
            keys.caster.invoked_orbs_particle_attach[6] = "attach_attack2"
        end
    end

        


    
    --Invoker can only have three orbs active at any time.  Each time an orb is activated, its hscript is
    --placed into keys.caster.invoked_orbs[3], the old [3] is moved into [2], and the old [2] is moved into [1].
    --Therefore, the oldest orb is located in [1], and the newest is located in [3].
    --Now, shift the ordered list of currently summoned orbs down, and add the newest orb to the queue.
    if keys.caster:GetLevel() >= 50 then
        keys.caster.invoked_orbs[6] = keys.caster.invoked_orbs[5]
    end
    if keys.caster:GetLevel() >= 40 then
        keys.caster.invoked_orbs[5] = keys.caster.invoked_orbs[4]
    end
    if keys.caster:GetLevel() >= 30 then
        keys.caster.invoked_orbs[4] = keys.caster.invoked_orbs[3]
    end
    if keys.caster:GetLevel() >= 20 then
        keys.caster.invoked_orbs[3] = keys.caster.invoked_orbs[2]
    end
    if keys.caster:GetLevel() >= 10 then
        keys.caster.invoked_orbs[2] = keys.caster.invoked_orbs[1]
    end
    keys.caster.invoked_orbs[1] = keys.ability

    --Remove the removed orb's particle effect.
    if keys.caster.invoked_orbs_particle[1] ~= nil then
        ParticleManager:DestroyParticle(keys.caster.invoked_orbs_particle[1], false)
        keys.caster.invoked_orbs_particle[1] = nil
    end
    --Shift the ordered list of currently summoned orb particle effects down, and create the new particle.
    if keys.caster:GetLevel() >= 50 then
        keys.caster.invoked_orbs_particle[5] = keys.caster.invoked_orbs_particle[6]
    end
    if keys.caster:GetLevel() >= 40 then
        keys.caster.invoked_orbs_particle[4] = keys.caster.invoked_orbs_particle[5]
    end
    if keys.caster:GetLevel() >= 30 then
        keys.caster.invoked_orbs_particle[3] = keys.caster.invoked_orbs_particle[4]
    end
    if keys.caster:GetLevel() >= 20 then
        keys.caster.invoked_orbs_particle[2] = keys.caster.invoked_orbs_particle[3]
    end
    if keys.caster:GetLevel() >= 10 then
        keys.caster.invoked_orbs_particle[1] = keys.caster.invoked_orbs_particle[2]
    end
    keys.caster.invoked_orbs_particle[number] = ParticleManager:CreateParticle(particle_filepath, PATTACH_OVERHEAD_FOLLOW, keys.caster)
    ParticleManager:SetParticleControlEnt(keys.caster.invoked_orbs_particle[number], 1, keys.caster, PATTACH_POINT_FOLLOW, keys.caster.invoked_orbs_particle_attach[1], keys.caster:GetAbsOrigin(), false)
    
    
    --Shift the ordered list of currently summoned orb particle effect attach locations down.
    local temp_attachment_point = keys.caster.invoked_orbs_particle_attach[1]
    if keys.caster:GetLevel() >= 10 then
        keys.caster.invoked_orbs_particle_attach[1] = keys.caster.invoked_orbs_particle_attach[2]
    end
    if keys.caster:GetLevel() >= 20 then
        keys.caster.invoked_orbs_particle_attach[2] = keys.caster.invoked_orbs_particle_attach[3]
    end
    if keys.caster:GetLevel() >= 30 then
        keys.caster.invoked_orbs_particle_attach[3] = keys.caster.invoked_orbs_particle_attach[4]
    end
    if keys.caster:GetLevel() >= 40 then
        keys.caster.invoked_orbs_particle_attach[4] = keys.caster.invoked_orbs_particle_attach[5]
    end
    if keys.caster:GetLevel() >= 50 then
        keys.caster.invoked_orbs_particle_attach[5] = keys.caster.invoked_orbs_particle_attach[6]
    end
    keys.caster.invoked_orbs_particle_attach[number] = temp_attachment_point


    
    


    replace_ellement_modifiers(keys)  --Remove and reapply the orb instance modifiers.
end


--[[ ============================================================================================================
    Author: Rook
    Date: April 02, 2015
    Called when Wex is cast or upgraded.  Replaces the modifiers on the caster's modifier bar to
    ensure the correct order, which also has the effect of leveling the effects of any currently existing orbs.
    This function is general enough that it can be used for Quas, Wex, or Exort.\
    Known bugs: The correct order of the orb modifiers on the modifier bar is not always maintained.  This is a
        visual bug only and likely has to do with removing and reapplying modifiers on the same frame.
================================================================================================================= ]]
function replace_ellement_modifiers(keys)
    --Initialization for storing the orb list, if not already done.
    if keys.caster.invoked_orbs == nil then
        keys.caster.invoked_orbs = {}
    end

    --Reapply all the orbs Invoker has out in order to benefit from the upgraded ability's level.  By reapplying all
    --three orb modifiers, they will maintain their order on the modifier bar (so long as all are removed before any
    --are reapplied, since ordering problems arise if there are two of the same type of orb otherwise).
    while keys.caster:HasModifier("ellement_wind_modifiers") do
        keys.caster:RemoveModifierByName("ellement_wind_modifiers")
    end
    while keys.caster:HasModifier("ellement_fire_modifiers") do
        keys.caster:RemoveModifierByName("ellement_fire_modifiers")
    end
    while keys.caster:HasModifier("ellement_ice_modifiers") do
        keys.caster:RemoveModifierByName("ellement_ice_modifiers")
    end

    local number = 1
    if keys.caster:GetLevel() >= 50 then
        number = 6
    elseif keys.caster:GetLevel() >= 40 then
        number = 5
    elseif keys.caster:GetLevel() >= 30 then
        number = 4
    elseif keys.caster:GetLevel() >= 20 then
        number = 3
    elseif keys.caster:GetLevel() >= 10 then
        number = 2
    end

    --Reapply the orb modifiers in the correct order.
    for i=1, number, 1 do
        if keys.caster.invoked_orbs[i] ~= nil then
            local orb_name = keys.caster.invoked_orbs[i]:GetName()
            if orb_name == "invoker_wind_ellement" then
                local quas_ability = keys.caster:FindAbilityByName("invoker_wind_ellement")
                if quas_ability ~= nil then
					if not keys.caster:HasModifier("ellement_wind_modifiers") then
						quas_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "ellement_wind_modifiers", nil)
						keys.caster:SetModifierStackCount( "ellement_wind_modifiers", quas_ability, 1)
					else
						keys.caster:SetModifierStackCount( "ellement_wind_modifiers", quas_ability, keys.caster:GetModifierStackCount( "ellement_wind_modifiers", quas_ability ) + 1)
					end
                end
            elseif orb_name == "invoker_fire_ellement" then
                local wex_ability = keys.caster:FindAbilityByName("invoker_fire_ellement")
                if wex_ability ~= nil then
                    if not keys.caster:HasModifier("ellement_fire_modifiers") then
						wex_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "ellement_fire_modifiers", nil)
						keys.caster:SetModifierStackCount( "ellement_fire_modifiers", wex_ability, 1)
					else
						keys.caster:SetModifierStackCount( "ellement_fire_modifiers", wex_ability, keys.caster:GetModifierStackCount( "ellement_fire_modifiers", wex_ability ) + 1)
					end
                end
            elseif orb_name == "invoker_ice_ellement" then
                local exort_ability = keys.caster:FindAbilityByName("invoker_ice_ellement")
                if exort_ability ~= nil then
                    if not keys.caster:HasModifier("ellement_ice_modifiers") then
						exort_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "ellement_ice_modifiers", nil)
						keys.caster:SetModifierStackCount( "ellement_ice_modifiers", exort_ability, 1)
					else
						keys.caster:SetModifierStackCount( "ellement_ice_modifiers", exort_ability, keys.caster:GetModifierStackCount( "ellement_ice_modifiers", exort_ability ) + 1)
					end
                end
            end
        end
    end
end


function wind_on_spell_start(keys)
    invoker_replace_orb(keys, "particles/units/heroes/hero_invoker/invoker_wex_orb.vpcf")
    print(keys.ability:GetLevelSpecialValueFor("ellement_power", keys.ability:GetLevel()))
end

function fire_on_spell_start(keys)
    invoker_replace_orb(keys, "particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf")
end

function ice_on_spell_start(keys)
    invoker_replace_orb(keys, "particles/invoker_quas_orb_test.vpcf")
end

function reset(keys)
    --Initialization for storing the orb list, if not already done.
    if keys.caster.invoked_orbs_particle == nil then
        keys.caster.invoked_orbs_particle = {}
    end

    local number = 1
    if keys.caster:GetLevel() >= 50 then
        number = 6
    elseif keys.caster:GetLevel() >= 40 then
        number = 5
    elseif keys.caster:GetLevel() >= 30 then
        number = 4
    elseif keys.caster:GetLevel() >= 20 then
        number = 3
    elseif keys.caster:GetLevel() >= 10 then
        number = 2
    end
    while keys.caster:HasModifier("ellement_wind_modifiers") do
        keys.caster:RemoveModifierByName("ellement_wind_modifiers")
    end
    while keys.caster:HasModifier("ellement_fire_modifiers") do
        keys.caster:RemoveModifierByName("ellement_fire_modifiers")
    end
    while keys.caster:HasModifier("ellement_ice_modifiers") do
        keys.caster:RemoveModifierByName("ellement_ice_modifiers")
    end
    for i=1, number, 1 do
        if keys.caster.invoked_orbs_particle[i] ~= nil then
            ParticleManager:DestroyParticle(keys.caster.invoked_orbs_particle[i], false)
            keys.caster.invoked_orbs_particle[i] = nil
        end
    end
    keys.caster.invoked_orbs = nil
end