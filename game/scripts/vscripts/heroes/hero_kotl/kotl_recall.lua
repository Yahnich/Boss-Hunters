kotl_recall = class({})
LinkLuaModifier( "modifier_kotl_recall", "heroes/hero_kotl/kotl_recall.lua" ,LUA_MODIFIER_MOTION_NONE )

function kotl_recall:IsStealable()
    return true
end

function kotl_recall:IsHiddenWhenStolen()
    return false
end

function kotl_recall:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    EmitSoundOn("Hero_KeeperOfTheLight.Recall.Cast", caster)


    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_recall_cast.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_ABSORIGIN, "attach_staffend", caster:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(nfx)

    if target == caster then
        local allies = caster:FindFriendlyUnitsInRadius(self:GetCursorPosition(), FIND_UNITS_EVERYWHERE, {type=DOTA_UNIT_TARGET_HERO} )
        for _,ally in pairs(allies) do
            if ally ~= caster then
                EmitSoundOn("Hero_KeeperOfTheLight.Recall.Target", ally)
                ally:AddNewModifier(caster, self, "modifier_kotl_recall", {Duration = self:GetSpecialValueFor("teleport_delay")})
            end
        end
    end
    
    if not target then
        local allies = caster:FindFriendlyUnitsInRadius(self:GetCursorPosition(), FIND_UNITS_EVERYWHERE, {type=DOTA_UNIT_TARGET_HERO} )
        for _,ally in pairs(allies) do
            if ally ~= caster then
                EmitSoundOn("Hero_KeeperOfTheLight.Recall.Target", ally)
                ally:AddNewModifier(caster, self, "modifier_kotl_recall", {Duration = self:GetSpecialValueFor("teleport_delay")})
                break
            end
        end
    else
        EmitSoundOn("Hero_KeeperOfTheLight.Recall.Target", target)
        target:AddNewModifier(caster, self, "modifier_kotl_recall", {Duration = self:GetSpecialValueFor("teleport_delay")})
    end
end

modifier_kotl_recall = class({})
function modifier_kotl_recall:OnCreated(table)
    if IsServer() then
        self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_recall.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.nfx, 0, self:GetParent():GetAbsOrigin())
    end
end

function modifier_kotl_recall:OnRemoved()
    if IsServer() then
        StopSoundOn("Hero_KeeperOfTheLight.Recall.Target", self:GetParent())
        EmitSoundOn("Hero_KeeperOfTheLight.Recall.End", ally)
        ParticleManager:FireParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_recall_poof.vpcf", PATTACH_POINT, self:GetCaster(), {[0]=self:GetParent():GetAbsOrigin()})
        ParticleManager:DestroyParticle(self.nfx, false)
        FindClearSpaceForUnit(self:GetParent(), self:GetCaster():GetAbsOrigin(), true)
    end
end