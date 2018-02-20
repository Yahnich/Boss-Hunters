lion_refined_fireblast = class({})

function lion_refined_fireblast:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetLevel(1)
        self:SetHidden(false)
        self:SetActivated(true)
    else
        self:SetLevel(0)
        self:SetHidden(true)
        self:SetActivated(false)
    end
end

function lion_refined_fireblast:GetManaCost()
    local manaCost = self:GetCaster():GetMana()*self:GetTalentSpecialValueFor("manabonus")/100
    return manaCost
end

function lion_refined_fireblast:OnAbilityPhaseStart()
    ParticleManager:FireParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), {[0]="attach_attack1"})
    return true
end

function lion_refined_fireblast:OnSpellStart()
    local caster = self:GetCaster()

    local target = self:GetCursorTarget()

    EmitSoundOn("Hero_OgreMagi.Fireblast.Cast", caster)
    EmitSoundOn("Hero_OgreMagi.Fireblast.Target", target)

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(nfx, 1, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(nfx)

    local damage = caster:GetMana()*self:GetTalentSpecialValueFor("manabonus")/100
    damage = damage + self:GetTalentSpecialValueFor("damage")
    self:DealDamage(caster, target, damage, {}, 0)

    self:Stun(target, self:GetSpecialValueFor("duration"), false)
end
