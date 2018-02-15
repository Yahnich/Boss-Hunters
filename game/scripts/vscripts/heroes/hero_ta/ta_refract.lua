ta_refract = class({})
LinkLuaModifier( "modifier_ta_refract", "heroes/hero_ta/ta_refract.lua", LUA_MODIFIER_MOTION_NONE )

function ta_refract:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_ta_refract", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_ta_refract = ({})
function modifier_ta_refract:OnCreated(table)
	if IsServer() then
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.nfx, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), false)
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_ta_refract:OnIntervalThink()
	if self:GetCaster():HasTalent("special_bonus_unique_ta_refract_1") then
		self:GetCaster():Dispel(self:GetCaster(), true)
		self:StartIntervalThink(0.5)
	end
end

function modifier_ta_refract:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.nfx, false)
	end
end

function modifier_ta_refract:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

function modifier_ta_refract:GetModifierPreAttack_BonusDamage()
	return self:GetSpecialValueFor("bonus_damage")
end

function modifier_ta_refract:GetModifierIncomingDamage_Percentage()
	return self:GetSpecialValueFor("damage_reduction")
end