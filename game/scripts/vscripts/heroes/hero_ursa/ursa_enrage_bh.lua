ursa_enrage_bh = class({})
LinkLuaModifier("modifier_ursa_enrage_bh", "heroes/hero_ursa/ursa_enrage_bh", LUA_MODIFIER_MOTION_NONE)

function ursa_enrage_bh:IsStealable()
	return true
end

function ursa_enrage_bh:IsHiddenWhenStolen()
	return false
end

function ursa_enrage_bh:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_UNRESTRICTED
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
end

function ursa_enrage_bh:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasScepter() then cooldown = self:GetLevelSpecialValueFor("cooldown_scepter", iLvl) end
    return cooldown
end

function ursa_enrage_bh:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Ursa.Enrage", caster)

	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
	caster:Purge(false, true, false, true, true)

	caster:AddNewModifier(caster, self, "modifier_ursa_enrage_bh", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_ursa_enrage_bh = class({})

function modifier_ursa_enrage_bh:AllowIllusionDuplicate()
	return false
end

function modifier_ursa_enrage_bh:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_ursa_enrage_bh:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ursa_enrage_bh:GetStatusEffectName()
	return "particles/units/heroes/hero_ursa/status_effect_ursa_enrage_bh_3.vpcf"
end

function modifier_ursa_enrage_bh:StatusEffectPriority()
	return 11
end

function modifier_ursa_enrage_bh:IsDebuff()
	return false
end

function modifier_ursa_enrage_bh:IsHidden()
	return false
end

function modifier_ursa_enrage_bh:IsPurgable()
	return false
end

function modifier_ursa_enrage_bh:OnCreated()
	local caster = self:GetCaster()
	self.damage_resist = self:GetTalentSpecialValueFor("reduction") * (-1)
	self.status_resist = self:GetTalentSpecialValueFor("status_resist")
	if IsServer() then
		caster:SetRenderColor(255,0,0)
	end
end

function modifier_ursa_enrage_bh:OnDestroy()
	local caster = self:GetCaster()
	if IsServer() then
		caster:SetRenderColor(255,255,255)
	end
end

function modifier_ursa_enrage_bh:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
	}
	return decFuncs
end

function modifier_ursa_enrage_bh:GetModifierModelScale()
	return 40
end

function modifier_ursa_enrage_bh:GetModifierIncomingDamage_Percentage()
	return self.damage_resist
end

function modifier_ursa_enrage_bh:GetModifierStatusResistanceStacking()
	return self.status_resist
end