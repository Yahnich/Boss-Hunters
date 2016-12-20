LinkLuaModifier("modifier_charges", "lua_abilities/heroes/modifiers/modifier_charges", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kunkka_captains_rum", "lua_abilities/heroes/modifiers/modifier_kunkka_captains_rum", LUA_MODIFIER_MOTION_NONE)

kunkka_captains_rum = class({})


--------------------------------------------------------------------------------

function kunkka_captains_rum:OnSpellStart()
	self:GetCursorTarget():AddNewModifier(self:GetCursorTarget(), self, "modifier_kunkka_captains_rum", {duration = self:GetTalentSpecialValueFor("buff_duration")})
end

function kunkka_captains_rum:OnUpgrade()
	self.charges = self:GetCaster():GetModifierStackCount("modifier_charges", self:GetCaster())
	if self:GetLevel() == 1 and self.charges < 1 then self.charges = 1 end
	self:GetCaster():RemoveModifierByName("modifier_charges")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_charges",
        {
            max_count = self:GetTalentSpecialValueFor("charge_count"),
            start_count = self.charges,
            replenish_time = self:GetTalentSpecialValueFor("recharge_time")
        }
    )
end
