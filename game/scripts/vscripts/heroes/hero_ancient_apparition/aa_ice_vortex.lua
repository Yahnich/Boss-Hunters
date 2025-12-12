aa_ice_vortex = class({})
LinkLuaModifier("modifier_aa_ice_vortex", "heroes/hero_ancient_apparition/aa_ice_vortex", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aa_ice_vortex_effect", "heroes/hero_ancient_apparition/aa_ice_vortex", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aa_ice_vortex_aa", "heroes/hero_ancient_apparition/aa_ice_vortex", LUA_MODIFIER_MOTION_NONE)

function aa_ice_vortex:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function aa_ice_vortex:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_aa_ice_vortex_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_aa_ice_vortex_2") end
    return cooldown
end

function aa_ice_vortex:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	EmitSoundOn("Hero_Ancient_Apparition.IceVortexCast", caster)

	CreateModifierThinker(caster, self, "modifier_aa_ice_vortex", {Duration = self:GetSpecialValueFor("duration")}, point, caster:GetTeam(), false)
end

modifier_aa_ice_vortex = class({})
function modifier_aa_ice_vortex:OnCreated(table)
	self.radius = self:GetSpecialValueFor("radius")
    if IsServer() then
    	EmitSoundOn("Hero_Ancient_Apparition.IceVortex", self:GetParent())
    	self:GetAbility():CreateVisibilityNode(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("vision_aoe"), self:GetDuration())
    	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ancient_apparition/ancient_ice_vortex.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    	ParticleManager:SetParticleControl(self.nfx, 0, GetGroundPosition(self:GetParent():GetAbsOrigin(), self:GetParent()) + Vector(0,0,100))
    	ParticleManager:SetParticleControl(self.nfx, 5, Vector(self.radius, self.radius, self.radius))

    	self:StartIntervalThink(FrameTime())
    end
end

function modifier_aa_ice_vortex:OnIntervalThink()
    local friends = self:GetCaster():FindFriendlyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius)
    for _,friend in pairs(friends) do
    	if friend == self:GetCaster() then
    		friend:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_aa_ice_vortex_aa", {Duration = 0.5})
    	end
    end
end

function modifier_aa_ice_vortex:OnRemoved()
    if IsServer() then
    	StopSoundOn("Hero_Ancient_Apparition.IceVortex", self:GetParent())
    	ParticleManager:ClearParticle(self.nfx)
    end
end

function modifier_aa_ice_vortex:IsAura()
    return true
end

function modifier_aa_ice_vortex:GetAuraDuration()
    return 0.5
end

function modifier_aa_ice_vortex:GetAuraRadius()
    return self.radius
end

function modifier_aa_ice_vortex:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_aa_ice_vortex:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_aa_ice_vortex:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_aa_ice_vortex:GetModifierAura()
    return "modifier_aa_ice_vortex_effect"
end

function modifier_aa_ice_vortex:IsAuraActiveOnDeath()
    return false
end

function modifier_aa_ice_vortex:IsHidden()
    return false
end

modifier_aa_ice_vortex_effect = class({})
function modifier_aa_ice_vortex_effect:OnCreated(table)
	self.slow = -self:GetSpecialValueFor("slow_move")
	self.resist = -self:GetSpecialValueFor("magic_resist")
	self.chill = self:GetSpecialValueFor("chill_dmg") / 100
	self.freeze = self:GetSpecialValueFor("freeze_dmg")
    if IsServer() then self:StartIntervalThink(self:GetSpecialValueFor("tick_rate")) end
end

function modifier_aa_ice_vortex_effect:OnIntervalThink()
    if self:GetParent() and not self:GetParent():IsNull() then self:GetParent():AddChill(self:GetAbility(), self:GetCaster(), 1) end
	local damage = self:GetParent():GetChillCount() * self.chill
	if self:GetParent():IsFrozenGeneric() then
		damage = self.freeze
	end
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), damage )
end

function modifier_aa_ice_vortex_effect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
    return funcs
end

function modifier_aa_ice_vortex_effect:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

function modifier_aa_ice_vortex_effect:GetModifierMagicalResistanceBonus()
    return self.resist
end

function modifier_aa_ice_vortex_effect:GetEffectName()
    return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

modifier_aa_ice_vortex_aa = class({})
function modifier_aa_ice_vortex_aa:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_aa_ice_vortex_aa:GetModifierMoveSpeedBonus_Percentage()
    return self:GetSpecialValueFor("slow_move")*2
end

function modifier_aa_ice_vortex_aa:GetEffectName()
    return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end