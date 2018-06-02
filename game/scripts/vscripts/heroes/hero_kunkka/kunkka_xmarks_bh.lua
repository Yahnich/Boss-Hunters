kunkka_xmarks_bh = class({})
LinkLuaModifier("modifier_kunkka_xmarks_bh", "heroes/hero_kunkka/kunkka_xmarks_bh", LUA_MODIFIER_MOTION_NONE)

function kunkka_xmarks_bh:IsStealable()
    return true
end

function kunkka_xmarks_bh:IsHiddenWhenStolen()
    return false
end

function kunkka_xmarks_bh:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    EmitSoundOn("Ability.XMarksTheSpot.Target", target)
    target:AddNewModifier(caster, self, "modifier_kunkka_xmarks_bh", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_kunkka_xmarks_bh = class({})
function modifier_kunkka_xmarks_bh:IsDebuff() return true end

function modifier_kunkka_xmarks_bh:OnCreated(table)
    if IsServer() then
        EmitSoundOn("Ability.XMark.Target_Movement", self:GetParent())
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_x_spot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
                    ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        self:AttachEffect(nfx)
        self.startPos = self:GetParent():GetAbsOrigin()
    end
end

function modifier_kunkka_xmarks_bh:OnRemoved()
    if IsServer() then
        StopSoundOn("Ability.XMark.Target_Movement", self:GetParent())
        EmitSoundOn("Ability.XMarksTheSpot.Return", self:GetParent())
        self:GetParent():Daze(self:GetAbility(), self:GetCaster(), self:GetTalentSpecialValueFor("daze_duration"))
        FindClearSpaceForUnit(self:GetParent(), self.startPos, true)
    end
end