lina_dragon = class({})
LinkLuaModifier( "modifier_lina_dragon", "heroes/hero_lina/lina_dragon.lua", LUA_MODIFIER_MOTION_NONE )

function lina_dragon:IsStealable()
    return true
end

function lina_dragon:IsHiddenWhenStolen()
    return false
end

function lina_dragon:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_lina_dragon_1") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_lina_dragon_1") end
    return cooldown
end

function lina_dragon:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    EmitSoundOn("Hero_Lina.DragonSlave", caster)

    self.castPoint = caster:GetAbsOrigin()
    self:FireLinearProjectile("particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf", CalculateDirection(point, caster)*self:GetTalentSpecialValueFor("speed"), self:GetTrueCastRange(), self:GetTalentSpecialValueFor("width"), {}, false, true, self:GetTalentSpecialValueFor("width"))
end

function lina_dragon:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    
    if hTarget ~= nil then
		if hTarget:TriggerSpellAbsorb( self ) then return end
        self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
    else
        local fireFX = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_dragons_breath.vpcf", PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControl(fireFX, 0, self.castPoint)
        ParticleManager:SetParticleControl(fireFX, 1, vLocation)
        ParticleManager:SetParticleControl(fireFX, 2, Vector(self:GetTalentSpecialValueFor("duration"), 0, 0))
        ParticleManager:ReleaseParticleIndex(fireFX)
        local count = 0
        local tickRate = self:GetTalentSpecialValueFor("tick_rate")
        Timers:CreateTimer(tickRate, function()
            if count < self:GetTalentSpecialValueFor("duration") then
                local enemies = caster:FindEnemyUnitsInLine(self.castPoint, vLocation, self:GetTalentSpecialValueFor("radius"), {})
                for _,enemy in pairs(enemies) do
                    if caster:HasTalent("special_bonus_unique_lina_dragon_2") then
                        enemy:AddNewModifier(caster, self, "modifier_lina_dragon", {Duration = tickRate})
                    end
                    self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage_flame"), {}, 0)
                end
                count = count + tickRate
                return tickRate
            else
                return nil
            end
        end)
    end
end

modifier_lina_dragon = class({})

function modifier_lina_dragon:GetModifierAttackSpeedBonus()
    return self:GetCaster():FindTalentValue("special_bonus_unique_lina_dragon_2")
end