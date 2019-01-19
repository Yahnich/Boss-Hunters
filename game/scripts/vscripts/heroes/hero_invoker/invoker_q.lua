invoker_q = class({})
LinkLuaModifier("modifier_invoker_q", "heroes/hero_invoker/invoker_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invoker_w", "heroes/hero_invoker/invoker_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invoker_e", "heroes/hero_invoker/invoker_e", LUA_MODIFIER_MOTION_NONE)

function invoker_q:IsStealable()
    return false
end

function invoker_q:IsHiddenWhenStolen()
    return false
end

function invoker_q:OnUpgrade()
    self:ReplaceOrbModifier()
end

function invoker_q:OnOwnerSpawned()
    self:ReplaceOrbModifier()
end

function invoker_q:OnSpellStart()
    local caster = self:GetCaster()

    if RollPercentage(50) then
        caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
    else
        caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
    end

    self:ReplaceOrb()
end

function invoker_q:ReplaceOrb()
    local caster = self:GetCaster()
    --Initialization for storing the orb properties, if not already done.
    if caster.invoked_orbs == nil then
        caster.invoked_orbs = {}
    end
    if caster.invoked_orbs_particle == nil then
        caster.invoked_orbs_particle = {}
    end
    if caster.invoked_orbs_particle_attach == nil then
        caster.invoked_orbs_particle_attach = {}
        caster.invoked_orbs_particle_attach[1] = "attach_orb1"
        caster.invoked_orbs_particle_attach[2] = "attach_orb2"
        caster.invoked_orbs_particle_attach[3] = "attach_orb3"
    end
    
    --Invoker can only have three orbs active at any time.  Each time an orb is activated, its hscript is
    --placed into keys.caster.invoked_orbs[3], the old [3] is moved into [2], and the old [2] is moved into [1].
    --Therefore, the oldest orb is located in [1], and the newest is located in [3].
    --Now, shift the ordered list of currently summoned orbs down, and add the newest orb to the queue.
    caster.invoked_orbs[1] = caster.invoked_orbs[2]
    caster.invoked_orbs[2] = caster.invoked_orbs[3]
    caster.invoked_orbs[3] = self
    
    --Remove the removed orb's particle effect.
    if caster.invoked_orbs_particle[1] ~= nil then
        ParticleManager:DestroyParticle(caster.invoked_orbs_particle[1], false)
        caster.invoked_orbs_particle[1] = nil
    end
    
    --Shift the ordered list of currently summoned orb particle effects down, and create the new particle.
    caster.invoked_orbs_particle[1] = caster.invoked_orbs_particle[2]
    caster.invoked_orbs_particle[2] = caster.invoked_orbs_particle[3]
    caster.invoked_orbs_particle[3] = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(caster.invoked_orbs_particle[3], 1, caster, PATTACH_POINT_FOLLOW, caster.invoked_orbs_particle_attach[1], caster:GetAbsOrigin(), false)
    
    --Shift the ordered list of currently summoned orb particle effect attach locations down.
    local temp_attachment_point = caster.invoked_orbs_particle_attach[1]
    caster.invoked_orbs_particle_attach[1] = caster.invoked_orbs_particle_attach[2]
    caster.invoked_orbs_particle_attach[2] = caster.invoked_orbs_particle_attach[3]
    caster.invoked_orbs_particle_attach[3] = temp_attachment_point
    
    self:ReplaceOrbModifier() --Remove and reapply the orb instance modifiers.
end

function invoker_q:ReplaceOrbModifier()
    local caster = self:GetCaster()

    --caster:StartGesture(ACT_DOTA_CONSTANT_LAYER)

    --Initialization for storing the orb list, if not already done.
    if caster.invoked_orbs == nil then
        caster.invoked_orbs = {}
    end

    --Reapply all the orbs Invoker has out in order to benefit from the upgraded ability's level.  By reapplying all
    --three orb modifiers, they will maintain their order on the modifier bar (so long as all are removed before any
    --are reapplied, since ordering problems arise if there are two of the same type of orb otherwise).
    while caster:HasModifier("modifier_invoker_q") do
        caster:RemoveModifierByName("modifier_invoker_q")
    end
    while caster:HasModifier("modifier_invoker_w") do
        caster:RemoveModifierByName("modifier_invoker_w")
    end
    while caster:HasModifier("modifier_invoker_e") do
        caster:RemoveModifierByName("modifier_invoker_e")
    end

    --Reapply the orb modifiers in the correct order.
    for i=1, 3, 1 do
        if caster.invoked_orbs[i] ~= nil then
            local orb_name = caster.invoked_orbs[i]:GetName()
            if orb_name == "invoker_q" then
                local quas_ability = caster:FindAbilityByName("invoker_q")
                if quas_ability ~= nil then
                    caster:AddNewModifier(caster, self, "modifier_invoker_q", {})
                end
            elseif orb_name == "invoker_w" then
                local wex_ability = caster:FindAbilityByName("invoker_w")
                if wex_ability ~= nil then
                    caster:AddNewModifier(caster, self, "modifier_invoker_w", {})
                end
            elseif orb_name == "invoker_e" then
                local exort_ability = caster:FindAbilityByName("invoker_e")
                if exort_ability ~= nil then
                    caster:AddNewModifier(caster, self, "modifier_invoker_e", {})
                end
            end
        end
    end
end

modifier_invoker_q = class({})
function modifier_invoker_q:OnCreated(table)
    self.regen = self:GetSpecialValueFor("bonus_hregen")
end

function modifier_invoker_q:OnRefresh(table)
    self.regen = self:GetSpecialValueFor("bonus_hregen")
end

function modifier_invoker_q:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
    return funcs
end

function modifier_invoker_q:GetModifierConstantHealthRegen()
    return self.regen
end

function modifier_invoker_q:IsDebuff()
    return false
end

function modifier_invoker_q:GetTexture()
    return "invoker_quas"
end


function modifier_invoker_q:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_invoker_q:IsPurgeException()
    return false
end

function modifier_invoker_q:IsPurgable()
    return false
end
