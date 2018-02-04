sand_caustics = class({})
LinkLuaModifier( "modifier_caustics", "heroes/hero_sand/sand_caustics.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_caustics_enemy", "heroes/hero_sand/sand_caustics.lua" ,LUA_MODIFIER_MOTION_NONE )

function sand_caustics:GetAbilityType()
    if self:GetCaster():HasScepter() then
        return DAMAGE_TYPE_PURE
    end

    return DAMAGE_TYPE_MAGICAL
end

function sand_caustics:GetIntrinsicModifierName()
    return "modifier_caustics"
end

modifier_caustics = class({})
function modifier_caustics:DeclareFunctions()
    funcs = {MODIFIER_EVENT_ON_ATTACK}
    return funcs
end

function modifier_caustics:OnAttack(params)
    if IsServer() then
        if params.attacker == self:GetCaster() and params.target:IsAlive() and not params.target:IsMagicImmune() then
            params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_caustics_enemy", {Duration = self:GetTalentSpecialValueFor("duration")})
        end
    end
end

function modifier_caustics:IsHidden()
    return true
end

modifier_caustics_enemy = class({})
function modifier_caustics_enemy:OnCreated(table)
    if IsServer() then
		EmitSoundOn("Ability.SandKing_CausticFinale", self:GetParent())
        self:StartIntervalThink(1.0)
    end
end

function modifier_caustics_enemy:OnIntervalThink()
    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf", PATTACH_POINT, self:GetParent())
    ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(nfx)

    local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
    for _,enemy in pairs(enemies) do
        if self:GetCaster():HasScepter() then
            local damage = self:GetCaster():GetMaxHealth() * self:GetTalentSpecialValueFor("scepter_damage")/100
            self:GetAbility():DealDamage(self:GetCaster(), enemy, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
        else
            local damage = self:GetCaster():GetMaxHealth() * self:GetTalentSpecialValueFor("damage")/100
            self:GetAbility():DealDamage(self:GetCaster(), enemy, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
        end
    end
    
end

function modifier_caustics_enemy:GetEffectName()
    return "particles/units/heroes/hero_sandking/sandking_caustic_finale_debuff.vpcf"
end