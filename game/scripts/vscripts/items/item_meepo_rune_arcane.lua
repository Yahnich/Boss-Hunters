item_meepo_rune_arcane = class({})
LinkLuaModifier( "modifier_item_meepo_rune_arcane_buff", "items/item_meepo_rune_arcane.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_meepo_rune_arcane:OnSpellStart()
	local caster = self:GetCaster()

	if caster:IsAlive() then
		EmitSoundOn("Rune.Arcane", caster)
		
		local duration = self:GetSpecialValueFor("duration")

		caster:AddNewModifier(caster, self, "modifier_item_meepo_rune_arcane_buff", {Duration = duration})
		self:Destroy()
	end
end

modifier_item_meepo_rune_arcane_buff = class({})
function modifier_item_meepo_rune_arcane_buff:OnCreated(table)
	self.cdr = self:GetSpecialValueFor("cdr")
	self.mana_reduc = self:GetSpecialValueFor("mana_reduc")
end

function modifier_item_meepo_rune_arcane_buff:OnRefresh(table)
	self.cdr = self:GetSpecialValueFor("cdr")
	self.mana_reduc = self:GetSpecialValueFor("mana_reduc")
end

function modifier_item_meepo_rune_arcane_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
			MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING}
end

function modifier_item_meepo_rune_arcane_buff:GetModifierPercentageManacost()
    return self.mana_reduc
end

function modifier_item_meepo_rune_arcane_buff:GetModifierPercentageCooldownStacking()
    return self.cdr
end

function modifier_item_meepo_rune_arcane_buff:GetEffectName()
    return "particles/generic_gameplay/rune_arcane_owner.vpcf"
end

function modifier_item_meepo_rune_arcane_buff:GetTexture()
    return "rune_arcane"
end

function modifier_item_meepo_rune_arcane_buff:IsDebuff()
    return false
end

function modifier_item_meepo_rune_arcane_buff:IsPurgable()
    return true
end