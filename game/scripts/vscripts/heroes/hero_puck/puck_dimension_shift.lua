puck_dimension_shift = class({})

function puck_dimension_shift:GetChannelTime()
    return self:GetSpecialValueFor("duration")
end

function puck_dimension_shift:OnSpellStart()
    local duration = self:GetSpecialValueFor("duration")
    local frozen = self:GetSpecialValueFor("not_frozen")

    if self:GetSpecialValueFor("immunity") == 0 then
        self:Shift(duration)
    else
        self:Crystalhide(duration)
    end

    self:SetFrozenCooldown(true)
end

function puck_dimension_shift:Shift(duration)
    local caster = self:GetCaster()
    ProjectileManager:ProjectileDodge(caster)
    caster:AddNewModifier(caster, self, "modifier_puck_phase_shift", {duration = duration})

    if self:GetSpecialValueFor("cdr") ~= 0 then
        caster:AddNewModifier(caster, self, "modifier_puck_whimsicatastrophe_shift", {duration = duration})
    end

    if self:GetSpecialValueFor("attacks") ~= 0 then
        for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange()) ) do
			caster:PerformGenericAttack(enemy, false, {neverMiss = false})
		end
    end

    if self:GetSpecialValueFor("hp_regen") ~= 0 then
        caster:AddNewModifier(caster, self, "modifier_puck_chrysalis", {duration = duration})
    end

    if self:GetSpecialValueFor("blooms") ~= 0 then
        caster:AddNewModifier(caster, self, "modifier_puck_bloom_shift", {duration = duration})
    end

    EmitSoundOn("Hero_Puck.Phase_Shift", caster)
end

function puck_dimension_shift:Crystalhide(duration)
    local caster = self:GetCaster()
    ProjectileManager:ProjectileDodge(caster)
    caster:AddNewModifier(caster, self, "modifier_puck_crystalhide_shift", {duration = duration})
    EmitSoundOn("Hero_Puck.Phase_Shift", caster)
end

function puck_dimension_shift:OnChannelFinish(bInterrupt)
	local caster = self:GetCaster()
    caster:RemoveModifierByName("modifier_puck_phase_shift")
    caster:RemoveModifierByName("modifier_puck_chrysalis")
    caster:RemoveModifierByName("modifier_puck_whimsicatastrophe_shift")
    caster:RemoveModifierByName("modifier_puck_crystalhide_shift")
    caster:RemoveModifierByName("modifier_puck_bloom_shift")
    caster:StopSound("Hero_Puck.Phase_Shift")
    self:SetFrozenCooldown(false)
end

modifier_puck_chrysalis = class({})
LinkLuaModifier("modifier_puck_chrysalis", "heroes/hero_puck/puck_dimension_shift", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_chrysalis:IsHidden()
    return true
end

function modifier_puck_chrysalis:OnCreated()
    self:OnRefresh()
end

function modifier_puck_chrysalis:OnRefresh()
    self.regen = self:GetSpecialValueFor("hp_regen")/100
    self:StartIntervalThink(1)
end

function modifier_puck_chrysalis:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        local maxHP = parent:GetMaxHealth()
        local healAmt = maxHP * self.regen
        parent:HealEvent(healAmt, self:GetAbility(), self:GetCaster())
    end
end

modifier_puck_bloom_shift = class({})
LinkLuaModifier("modifier_puck_bloom_shift", "heroes/hero_puck/puck_dimension_shift", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_bloom_shift:IsHidden()
    return true
end

function modifier_puck_bloom_shift:OnCreated()
    self:OnRefresh()
end

function modifier_puck_bloom_shift:OnRefresh()
    self.radius = self:GetSpecialValueFor("blooms")
    self.int_multiplier = self:GetSpecialValueFor("int_multiplier") / 100
    self:StartIntervalThink(0)
end

function modifier_puck_bloom_shift:OnIntervalThink()
    local caster = self:GetParent()
    local int = caster:GetIntellect(true)
    local damage = int * self.int_multiplier
    for _, enemy in ipairs(caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.radius)) do
        self:GetAbility():DealDamage(caster, enemy, damage)
    end
end

modifier_puck_whimsicatastrophe_shift = class({})
LinkLuaModifier("modifier_puck_whimsicatastrophe_shift", "heroes/hero_puck/puck_dimension_shift", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_whimsicatastrophe_shift:IsHidden()
    return true
end

function modifier_puck_whimsicatastrophe_shift:OnCreated()
    self:OnRefresh()
    self.tick = 0.33
    if IsServer() then self:StartIntervalThink(self.tick) end
end

function modifier_puck_whimsicatastrophe_shift:OnRefresh()
    self.cdr = self:GetSpecialValueFor("cdr") / 100
end

function modifier_puck_whimsicatastrophe_shift:OnIntervalThink()
    local parent = self:GetParent()
    for i = 0, parent:GetAbilityCount() - 1 do
        local ability = parent:GetAbilityByIndex(i)
        if ability and ability:GetCooldownTimeRemaining() > 0 and ability ~= nil and not ability:IsInnateAbility() then
            ability:ModifyCooldown(-self.cdr * self.tick)
        end
    end
end


modifier_puck_crystalhide_shift = class({})
LinkLuaModifier("modifier_puck_crystalhide_shift", "heroes/hero_puck/puck_dimension_shift", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_crystalhide_shift:IsHidden()
    return true
end

function modifier_puck_crystalhide_shift:OnCreated()
    if IsServer() then
        self.nfx = ParticleManager:CreateParticle("particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
                   ParticleManager:SetParticleControlEnt(self.nfx, 0 , self:GetParent(), PATTACH_POINT_FOLLOW, "attach_base", self:GetParent():GetAbsOrigin(), true)
                   self:AttachEffect(self.nfx)
    end
end

function modifier_puck_crystalhide_shift:CheckState()
    return {[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
            [MODIFIER_STATE_DEBUFF_IMMUNE] = true,}
end

function modifier_puck_crystalhide_shift:OnDestroy()
    if not IsServer() then return end
    self:GetParent():Dispel(self:GetCaster(), true)
end

function modifier_puck_crystalhide_shift:GetStatusEffectName()
    return "particles/status_fx/status_effect_phase_shift.vpcf"
end