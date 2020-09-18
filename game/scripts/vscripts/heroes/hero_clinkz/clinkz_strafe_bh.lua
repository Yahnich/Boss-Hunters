clinkz_strafe_bh = class({})
LinkLuaModifier( "modifier_clinkz_strafe_bh", "heroes/hero_clinkz/clinkz_strafe_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function clinkz_strafe_bh:IsStealable()
    return true
end

function clinkz_strafe_bh:IsHiddenWhenStolen()
    return false
end

function clinkz_strafe_bh:OnSpellStart()
	local caster = self:GetCaster()

    EmitSoundOn("Hero_Clinkz.Strafe", caster)

    caster:AddNewModifier(caster, self, "modifier_clinkz_strafe_bh", {Duration = self:GetTalentSpecialValueFor("duration")})

    -- if caster:HasTalent("special_bonus_unique_clinkz_strafe_bh_2") then
        -- caster:ConjureImage( caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("duration"), 100, 300, nil, self, false, caster )
    -- end
end

modifier_clinkz_strafe_bh = class({})
function modifier_clinkz_strafe_bh:IsDebuff()
    return false
end

function modifier_clinkz_strafe_bh:IsPurgable()
    return true
end

function modifier_clinkz_strafe_bh:OnCreated(table)
    self.as = self:GetTalentSpecialValueFor("as_bonus")
    self.evasion = self:GetTalentSpecialValueFor("evasion_bonus")
	self.cost = self:GetCaster():FindTalentValue("special_bonus_unique_clinkz_strafe_bh_2")

    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_clinkz_strafe_bh:OnRefresh(table)
    self.as = self:GetTalentSpecialValueFor("as_bonus")
    self.evasion = self:GetTalentSpecialValueFor("evasion_bonus")
	self.cost = self:GetCaster():FindTalentValue("special_bonus_unique_clinkz_strafe_bh_2")
	
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_clinkz_strafe_bh:OnIntervalThink()
    ProjectileManager:ProjectileDodge(self:GetParent())
end

function modifier_clinkz_strafe_bh:DeclareFunctions()
    local funcs = {
        
        MODIFIER_EVENT_ON_PROJECTILE_DODGE,
        MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_clinkz_strafe_bh:OnProjectileDodge(params)
    if IsServer() then
        if params.target == self:GetParent() then
            self:GetParent():StartGesture(DODGE)

            ParticleManager:FireParticle("particles/units/heroes/hero_clinkz/clinkz_strafe_dodge.vpcf", PATTACH_POINT, self:GetParent(), {})
        end
    end
end

function modifier_clinkz_strafe_bh:OnAttackFail(params)
    if IsServer() then
        if params.target == self:GetParent() then
            self:GetParent():StartGesture(DODGE)

            ParticleManager:FireParticle("particles/units/heroes/hero_clinkz/clinkz_strafe_dodge.vpcf", PATTACH_POINT, self:GetParent(), {})
        end
    end
end

function modifier_clinkz_strafe_bh:GetModifierAttackSpeedBonus_Constant()
    return self.as
end

function modifier_clinkz_strafe_bh:GetModifierEvasion_Constant()
    return self.evasion
end

function modifier_clinkz_strafe_bh:GetModifierPercentageManacostStacking()
    return self.cost * (-1)
end

function modifier_clinkz_strafe_bh:GetEffectName()
    return "particles/units/heroes/hero_clinkz/clinkz_strafe.vpcf"
end