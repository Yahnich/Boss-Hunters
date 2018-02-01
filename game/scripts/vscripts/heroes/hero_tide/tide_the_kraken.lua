tide_the_kraken = class({})
LinkLuaModifier( "modifier_the_kraken", "heroes/hero_tide/tide_the_kraken.lua" ,LUA_MODIFIER_MOTION_NONE )

function tide_the_kraken:OnSpellStart()
    local caster = self:GetCaster()
    local point = caster:GetAbsOrigin()
    
    local i = 0
    local t = 25
	
	local maxRadius = self:GetTalentSpecialValueFor("radius")

    EmitSoundOn("Ability.Ravage", caster)

    local nfx2 = ParticleManager:CreateParticle("particles/econ/events/ti7/shivas_guard_active_ti7.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(nfx2, 0, point)
    ParticleManager:SetParticleControl(nfx2, 1, Vector(900,4,self:GetTalentSpecialValueFor("radius")/2))
    ParticleManager:ReleaseParticleIndex(nfx2)

    local nfx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(nfx3, 0, point)
    ParticleManager:SetParticleControl(nfx3, 1, Vector(maxRadius/5, 1, 833))
    ParticleManager:SetParticleControl(nfx3, 2, Vector(maxRadius * 2/5, 1, 833))
    ParticleManager:SetParticleControl(nfx3, 3, Vector(maxRadius * 3/5, 1, 833))    
    ParticleManager:SetParticleControl(nfx3, 4, Vector(maxRadius * 4/5, 1, 833))
    ParticleManager:SetParticleControl(nfx3, 5, Vector(maxRadius, 1, 833))
    ParticleManager:ReleaseParticleIndex(nfx3)

    Timers:CreateTimer(0, function()
        if 250+i < maxRadius then
            local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_beast/beast_hawk_spirit_aura/beast_hawk_spirit_aura.vpcf", PATTACH_POINT, caster)
            ParticleManager:SetParticleControl(nfx, 0, point)
            ParticleManager:SetParticleControl(nfx, 1, Vector(250+i,0,0))

            Timers:CreateTimer(0.1, function()
                ParticleManager:DestroyParticle(nfx, false)
            end)

            local enemies = caster:FindEnemyUnitsInRing(point, 250+i, 1+i, {})
            for _,enemy in pairs(enemies) do
                if not enemy:HasModifier("modifier_the_kraken") and not enemy:IsNull() then
                    enemy:AddNewModifier(caster, self, "modifier_the_kraken", {Duration = 0.5})
                end
            end
            i = i + t
            return FrameTime()
        else
            return nil
        end
    end)
end

modifier_the_kraken = class({})
function modifier_the_kraken:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local target = self:GetParent()
        local ability = self:GetAbility()

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_ravage_tentacle_model.vpcf", PATTACH_POINT, caster)
        ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(nfx)

        self:StartIntervalThink(0.5)
        self:GetParent():ApplyKnockBack(self:GetParent():GetAbsOrigin(), 0.5, 0.5, 0, 350, self:GetCaster(), self:GetAbility())
    end
end

function modifier_the_kraken:OnIntervalThink()
    self:GetAbility():Stun(self:GetParent(), self:GetTalentSpecialValueFor("duration"), false)
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("damage"), {}, 0)
    self:Destroy()
end

function modifier_the_kraken:IsHidden()
    return true
end