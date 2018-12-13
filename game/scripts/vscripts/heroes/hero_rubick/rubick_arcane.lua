rubick_arcane = class({})
LinkLuaModifier("modifier_rubick_arcane_handle", "heroes/hero_rubick/rubick_arcane", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_arcane_buff", "heroes/hero_rubick/rubick_arcane", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_arcane_debuff", "heroes/hero_rubick/rubick_arcane", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_arcane_mr", "heroes/hero_rubick/rubick_arcane", LUA_MODIFIER_MOTION_NONE)

function rubick_arcane:IsStealable()
    return false
end

function rubick_arcane:IsHiddenWhenStolen()
    return false
end

function rubick_arcane:GetIntrinsicModifierName()
    return "modifier_rubick_arcane_handle"
end

function rubick_arcane:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetTalentSpecialValueFor("duration")
	
	EmitSoundOn("Hero_Rubick.NullField.Offense", caster)
	EmitSoundOn("Hero_Rubick.NullField.Defense", caster)

	ParticleManager:FireParticle("particles/units/heroes/hero_rubick/rubick_nullfield_defensive.vpcf", PATTACH_POINT, caster, {[0]=caster:GetAbsOrigin()})
	ParticleManager:FireParticle("particles/units/heroes/hero_rubick/rubick_nullfield_offensive.vpcf", PATTACH_POINT, target, {[0]=target:GetAbsOrigin()})

	caster:AddNewModifier(caster, self, "modifier_rubick_arcane_buff", {Duration = duration})
	target:AddNewModifier(caster, self, "modifier_rubick_arcane_debuff", {Duration = duration})

	if caster:HasTalent("special_bonus_unique_rubick_arcane_2") then
		local allies = caster:FindFriendlyUnitsInRadius(target:GetAbsOrigin(), 300)
		for _,ally in pairs(allies) do
			ally:AddNewModifier(caster, self, "modifier_rubick_arcane_mr", {Duration = duration})
		end
	end

	self:StartDelayedCooldown(duration)
end

modifier_rubick_arcane_handle = class({})
function modifier_rubick_arcane_handle:OnCreated(table)
	self:StartIntervalThink(1)
end

function modifier_rubick_arcane_handle:OnIntervalThink()
	if self:GetCaster():HasTalent("special_bonus_unique_rubick_arcane_1") then
		self.spell_amp = self:GetTalentSpecialValueFor("spell_amp")/2
	end
end

function modifier_rubick_arcane_handle:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
	return funcs
end

function modifier_rubick_arcane_handle:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_rubick_arcane_handle:IsDebuff()
	return false
end

function modifier_rubick_arcane_handle:IsPurgable()
	return false
end

function modifier_rubick_arcane_handle:IsPurgeException()
	return false
end

function modifier_rubick_arcane_handle:IsHidden()
	return true
end

modifier_rubick_arcane_buff = class({})
function modifier_rubick_arcane_buff:OnCreated(table)
	self.spell_amp = self:GetTalentSpecialValueFor("spell_amp")
end

function modifier_rubick_arcane_buff:OnRefresh(table)
	self.spell_amp = self:GetTalentSpecialValueFor("spell_amp")
end

function modifier_rubick_arcane_buff:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
	return funcs
end

function modifier_rubick_arcane_buff:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_rubick_arcane_buff:IsDebuff()
	return false
end

function modifier_rubick_arcane_buff:IsPurgable()
	return true
end

function modifier_rubick_arcane_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_rubick_arcane_debuff = class({})
function modifier_rubick_arcane_debuff:OnCreated(table)
	self.status_resist = self:GetTalentSpecialValueFor("status_resist")
	self.magic_resist_reduc = self:GetTalentSpecialValueFor("magic_resist_reduc")
end

function modifier_rubick_arcane_debuff:OnRefresh(table)
	self.status_resist = self:GetTalentSpecialValueFor("status_resist")
	self.magic_resist_reduc = self:GetTalentSpecialValueFor("magic_resist_reduc")
end

function modifier_rubick_arcane_debuff:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
					MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
	return funcs
end

function modifier_rubick_arcane_debuff:GetModifierStatusResistanceStacking()
	return self.status_resist
end

function modifier_rubick_arcane_debuff:GetModifierMagicalResistanceBonus()
	return self.magic_resist_reduc
end

function modifier_rubick_arcane_debuff:IsDebuff()
	return true
end

function modifier_rubick_arcane_debuff:IsPurgable()
	return true
end

function modifier_rubick_arcane_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_rubick_arcane_mr = class({})
function modifier_rubick_arcane_mr:OnCreated(table)
	self.magic_resist_reduc = self:GetTalentSpecialValueFor("magic_resist_reduc")/2
end

function modifier_rubick_arcane_mr:OnRefresh(table)
	self.magic_resist_reduc = self:GetTalentSpecialValueFor("magic_resist_reduc")/2
end

function modifier_rubick_arcane_mr:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
	return funcs
end

function modifier_rubick_arcane_mr:GetModifierMagicalResistanceBonus()
	return -self.magic_resist_reduc
end

function modifier_rubick_arcane_mr:IsDebuff()
	return false
end

function modifier_rubick_arcane_mr:IsPurgable()
	return true
end