item_meepo_rune_dd = class({})
LinkLuaModifier( "modifier_item_meepo_rune_dd_buff", "items/item_meepo_rune_dd.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_meepo_rune_dd:OnSpellStart()
	local caster = self:GetCaster()

	if caster:IsAlive() then
		EmitSoundOn("Rune.DD", caster)
		
		local duration = self:GetSpecialValueFor("duration")

		caster:AddNewModifier(caster, self, "modifier_item_meepo_rune_dd_buff", {Duration = duration})
		self:Destroy()
	end
end

modifier_item_meepo_rune_dd_buff = class({})
function modifier_item_meepo_rune_dd_buff:OnCreated(table)
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_meepo_rune_dd_buff:OnRefresh(table)
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_meepo_rune_dd_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_item_meepo_rune_dd_buff:GetModifierTotalDamageOutgoing_Percentage()
    return self.bonus_damage
end

function modifier_item_meepo_rune_dd_buff:GetEffectName()
    return "particles/generic_gameplay/rune_doubledamage_owner.vpcf"
end

function modifier_item_meepo_rune_dd_buff:GetTexture()
    return "rune_doubledamage"
end

function modifier_item_meepo_rune_dd_buff:IsDebuff()
    return false
end

function modifier_item_meepo_rune_dd_buff:IsPurgable()
    return true
end