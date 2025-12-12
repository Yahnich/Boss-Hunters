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

    caster:AddNewModifier(caster, self, "modifier_clinkz_strafe_bh", {Duration = self:GetSpecialValueFor("duration")})
	for _, skeleton in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		if skeleton:GetUnitName() == "npc_dota_clinkz_skeleton_archer" then
			skeleton:AddNewModifier(caster, self, "modifier_clinkz_strafe_bh", {Duration = self:GetSpecialValueFor("duration")})
		end
	end
    -- if caster:HasTalent("special_bonus_unique_clinkz_strafe_bh_2") then
        -- caster:ConjureImage( caster:GetAbsOrigin(), self:GetSpecialValueFor("duration"), 100, 300, nil, self, false, caster )
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
    self:OnRefresh()
end

function modifier_clinkz_strafe_bh:OnRefresh(table)
    self.as = self:GetSpecialValueFor("as_bonus")
    self.rate = self:GetSpecialValueFor("dodge_rate")
	self.cost = self:GetCaster():FindTalentValue("special_bonus_unique_clinkz_strafe_bh_2")
    if IsServer() then
        self:StartIntervalThink(self.rate)
		self:OnIntervalThink()
    end
end

function modifier_clinkz_strafe_bh:OnIntervalThink()
	ProjectileManager:ProjectileDodge(self:GetParent())
	self:GetParent():StartGesture(ACT_DUCK_DODGE)
	ParticleManager:FireParticle("particles/units/heroes/hero_clinkz/clinkz_strafe_dodge.vpcf", PATTACH_POINT, self:GetParent(), {})
end

function modifier_clinkz_strafe_bh:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_clinkz_strafe_bh:GetModifierAttackSpeedBonus_Constant()
    return self.as
end

function modifier_clinkz_strafe_bh:GetModifierPercentageManacostStacking()
    return self.cost * (-1)
end

function modifier_clinkz_strafe_bh:GetEffectName()
    return "particles/units/heroes/hero_clinkz/clinkz_strafe.vpcf"
end