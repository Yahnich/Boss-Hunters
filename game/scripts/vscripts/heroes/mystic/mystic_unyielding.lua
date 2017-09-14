mystic_unyielding = class({})

function mystic_unyielding:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_Dazzle.Shallow_Grave", target)
	target:AddNewModifier(caster, self, "modifier_mystic_unyielding_buff", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_mystic_unyielding_buff = class({})
LinkLuaModifier("modifier_mystic_unyielding_buff", "heroes/mystic/mystic_unyielding.lua", 0)

function modifier_mystic_unyielding_buff:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_MIN_HEALTH,
					MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE,
					MODIFIER_EVENT_ON_TAKEDAMAGE}
	return funcs
end

function modifier_mystic_unyielding_buff:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		local ogHP = params.unit:GetHealth()
		self:GetParent():HealEvent(params.damage, self, self:GetCaster())
		params.unit:SetHealth(ogHP)
	end
end

function modifier_mystic_unyielding_buff:GetMinHealth()
	return 1
end

function modifier_mystic_unyielding_buff:GetModifierHealAmplify_Percentage()
	if self:GetCaster():HasTalent("mystic_unyielding_talent_1") then
		return 100
	end
end

function modifier_mystic_unyielding_buff:GetEffectName()
	return "particles/heroes/mystic/mystic_unyielding.vpcf"
end



