item_meepo_rune_haste = class({})
LinkLuaModifier( "modifier_item_meepo_rune_haste_buff", "items/item_meepo_rune_haste.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_meepo_rune_haste:OnSpellStart()
	local caster = self:GetCaster()

	if caster:IsAlive() then
		EmitSoundOn("Rune.Haste", caster)
		
		local duration = self:GetSpecialValueFor("duration")

		caster:AddNewModifier(caster, self, "modifier_item_meepo_rune_haste_buff", {Duration = duration})
		self:Destroy()
	end
end

modifier_item_meepo_rune_haste_buff = class({})
function modifier_item_meepo_rune_haste_buff:OnCreated(table)
	self.bonus_ms = self:GetSpecialValueFor("bonus_ms")
	self.bonus_as = self:GetSpecialValueFor("bonus_as")
end

function modifier_item_meepo_rune_haste_buff:OnRefresh(table)
	self.bonus_ms = self:GetSpecialValueFor("bonus_ms")
	self.bonus_as = self:GetSpecialValueFor("bonus_as")
end

function modifier_item_meepo_rune_haste_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

function modifier_item_meepo_rune_haste_buff:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_ms
end

function modifier_item_meepo_rune_haste_buff:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end

function modifier_item_meepo_rune_haste_buff:GetActivityTranslationModifiers()
    return "haste"
end

function modifier_item_meepo_rune_haste_buff:GetEffectName()
    return "particles/generic_gameplay/rune_haste_owner.vpcf"
end

function modifier_item_meepo_rune_haste_buff:GetTexture()
    return "rune_haste"
end

function modifier_item_meepo_rune_haste_buff:IsDebuff()
    return false
end

function modifier_item_meepo_rune_haste_buff:IsPurgable()
    return true
end