lina_fireball = class({})
LinkLuaModifier( "modifier_lina_fireball", "heroes/hero_lina/lina_fireball.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lina_fireball_fire", "heroes/hero_lina/lina_fireball.lua" ,LUA_MODIFIER_MOTION_NONE )

function lina_fireball:IsStealable()
    return true
end

function lina_fireball:IsHiddenWhenStolen()
    return false
end

function lina_fireball:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    EmitSoundOn("Hero_Jakiro.LiquidFire", caster)

    self.castPoint = caster:GetAbsOrigin()
    self:FireTrackingProjectile("particles/units/heroes/hero_lina/lina_fireball.vpcf", target, 1000, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 100)
end

function lina_fireball:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    
    if hTarget ~= nil and not hTarget:TriggerSpellAbsorb( self ) then
        EmitSoundOn("Hero_Jakiro.LiquidFire", hTarget)

        ParticleManager:FireParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_POINT, caster, {[0]=hTarget:GetAbsOrigin(), [1]=Vector(self:GetTalentSpecialValueFor("radius"),self:GetTalentSpecialValueFor("radius"),self:GetTalentSpecialValueFor("radius"))})

        local enemies = caster:FindEnemyUnitsInRadius(vLocation, self:GetTalentSpecialValueFor("radius"))
        for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb( self ) then
				if caster:HasTalent("special_bonus_unique_lina_fireball_2") then
					self:Stun(enemy, caster:FindTalentValue("special_bonus_unique_lina_fireball_2"), false)
				end

				self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
				enemy:AddNewModifier(caster, self, "modifier_lina_fireball", {Duration = self:GetTalentSpecialValueFor("duration")})
			end
        end

        if caster:HasTalent("special_bonus_unique_lina_fireball_1") then
            CreateModifierThinker(caster, self, "modifier_lina_fireball_fire", {Duration = self:GetTalentSpecialValueFor("duration")}, vLocation, caster:GetTeam(), false)
        end
    end
end

modifier_lina_fireball = class({})
function modifier_lina_fireball:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(1.0)
    end
end

function modifier_lina_fireball:OnIntervalThink()
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("damage_time"), {}, 0)
end

function modifier_lina_fireball:GetEffectName()
    return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_lina_fireball:GetStatusEffectName()
    return "particles/status_fx/status_effect_burn.vpcf"
end

function modifier_lina_fireball:StatusEffectPriority()
    return 10
end

modifier_lina_fireball_fire = class({})
function modifier_lina_fireball_fire:OnCreated(table)
    if IsServer() then
        self.fireFX = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_lsa_fire.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
        --self.fireFX = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_lsa_aoe.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(self.fireFX, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.fireFX, 1, Vector(self:GetTalentSpecialValueFor("radius"),1,1))
        self:StartIntervalThink(0.5)
    end
end

function modifier_lina_fireball_fire:OnIntervalThink()
    local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
    for _,enemy in pairs(enemies) do
        self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetTalentSpecialValueFor("damage_time"), {}, 0)
    end
end

function modifier_lina_fireball_fire:OnRemoved()
    if IsServer() then
        ParticleManager:DestroyParticle(self.fireFX, false)
    end
end