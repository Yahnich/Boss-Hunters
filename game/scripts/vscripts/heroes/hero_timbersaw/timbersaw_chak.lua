timbersaw_chak = class({})
LinkLuaModifier( "modifier_timbersaw_chak", "heroes/hero_timbersaw/timbersaw_chak.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_timbersaw_hylophobia", "heroes/hero_timbersaw/timbersaw_hylophobia.lua" ,LUA_MODIFIER_MOTION_NONE )

function timbersaw_chak:IsStealable()
    return true
end

function timbersaw_chak:IsHiddenWhenStolen()
    return false
end

function timbersaw_chak:OnUpgrade()
    self:GetCaster():FindAbilityByName("timbersaw_chak2"):SetLevel(self:GetLevel())
end

function timbersaw_chak:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local direction = CalculateDirection(point, caster:GetAbsOrigin())
    local distance = self:GetTrueCastRange() --CalculateDistance(point, caster:GetAbsOrigin())
    local vel = direction * self:GetTalentSpecialValueFor("speed")

    --[[self.hook_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook_chain.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleAlwaysSimulate(self.hook_pfx)
    ParticleManager:SetParticleControlEnt(self.hook_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.hook_pfx, 2, Vector(self:GetTalentSpecialValueFor("speed"), self:GetTrueCastRange(), self:GetTalentSpecialValueFor("radius")) )
    ParticleManager:SetParticleControl(self.hook_pfx, 3, Vector(60, 60, 60) )]]

    EmitSoundOn("Hero_Shredder.Chakram.Cast", caster)
    self:FireLinearProjectile("particles/units/heroes/hero_shredder/shredder_chakram.vpcf", vel, distance, self:GetTalentSpecialValueFor("radius"), {}, false, true, self:GetTalentSpecialValueFor("radius"))
    self:StartDelayedCooldown(self:GetTrueCooldown())
end

function timbersaw_chak:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    
    if hTarget == nil then
        --ParticleManager:SetParticleControl(self.hook_pfx, 1, vLocation )
        local dummy = self:CreateDummy(vLocation)
        EmitSoundOnLocationWithCaster(vLocation, "Hero_Shredder.Chakram.Return", caster)
        self:FireTrackingProjectile("particles/units/heroes/hero_shredder/shredder_chakram_return.vpcf", caster, self:GetTalentSpecialValueFor("speed"), {source=dummy,origin=vLocation}, 0, false, true, self:GetTalentSpecialValueFor("radius"))
        dummy:ForceKill(false)
    elseif hTarget == caster then
        self:EndDelayedCooldown()
        --ParticleManager:ClearParticle(self.hook_pfx)
    end
end

function timbersaw_chak:OnProjectileThink(vLocation)
    local caster = self:GetCaster()

   --[[ParticleManager:SetParticleControl(self.hook_pfx, 1, vLocation )
    ParticleManager:SetParticleControl(self.hook_pfx, 2, Vector(self:GetTalentSpecialValueFor("speed"), self:GetTrueCastRange(), self:GetTalentSpecialValueFor("radius")) )
    ParticleManager:SetParticleControl(self.hook_pfx, 3, Vector(60, 60, 60) )]]

    local treesCut = CutTreesInRadius(vLocation, self:GetTalentSpecialValueFor("radius"))
    if treesCut > 0 then
        local duration = caster:FindAbilityByName("timbersaw_hylophobia"):GetTalentSpecialValueFor("duration")
        for i=1,treesCut do
            caster:AddNewModifier(caster, caster:FindAbilityByName("timbersaw_hylophobia"), "modifier_timbersaw_hylophobia", {Duration = duration}):AddIndependentStack(duration)
        end
    end

    local enemies = caster:FindEnemyUnitsInRadius(vLocation, self:GetTalentSpecialValueFor("radius"))
    for _,enemy in pairs(enemies) do
        if not enemy:HasModifier("modifier_timbersaw_chak") then
            EmitSoundOn("Hero_Shredder.Chakram.Target", enemy)
            enemy:Paralyze(self, caster)
            enemy:AddNewModifier(caster, self, "modifier_timbersaw_chak", {Duration = 0.1})
        end
    end
end

modifier_timbersaw_chak = class({})
function modifier_timbersaw_chak:OnCreated(table)
    if IsServer() then
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local damage = self:GetTalentSpecialValueFor("damage")/6

        if caster:HasTalent("special_bonus_unique_timbersaw_chak_2") then
            caster:Lifesteal(ability, caster:FindTalentValue("special_bonus_unique_timbersaw_chak_2"), damage, parent, ability:GetAbilityDamageType(), DOTA_LIFESTEAL_SOURCE_ABILITY)
        else
            ability:DealDamage(caster, self:GetParent(), damage, {}, 0)
        end
    end
end

function modifier_timbersaw_chak:IsHidden()
    return true
end

function modifier_timbersaw_chak:GetEffectName()
    return "particles/units/heroes/hero_shredder/shredder_chakram_hit.vpcf"
end