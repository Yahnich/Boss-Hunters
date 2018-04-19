skywrath_arcane = class({})

function skywrath_arcane:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_SkywrathMage.ArcaneBolt.Cast", caster)

	self:FireTrackingProjectile("particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf", target, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, self:GetTalentSpecialValueFor("vision"))

    if caster:HasTalent("special_bonus_unique_skywrath_arcane_1") then
        Timers:CreateTimer(caster:FindTalentValue("special_bonus_unique_skywrath_arcane_1"), function()
            local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange()*2)
            for _,enemy in pairs(enemies) do
                self:FireTrackingProjectile("particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf", enemy, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, self:GetTalentSpecialValueFor("vision"))
                break
            end
        end)
    end

    if caster:HasScepter() then
        local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange())
        for _,enemy in pairs(enemies) do
            if enemy ~= target then
                self:FireTrackingProjectile("particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf", enemy, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, self:GetTalentSpecialValueFor("vision"))
                break
            end
        end
    end

end

function skywrath_arcane:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()

    if hTarget then
        EmitSoundOn("Hero_SkywrathMage.ArcaneBolt.Impact", hTarget)
        local damage = self:GetTalentSpecialValueFor("damage") + self:GetTalentSpecialValueFor("int_multiplier")/100 * caster:GetIntellect()
        self:DealDamage(caster, hTarget, damage, {}, 0)
    end
end