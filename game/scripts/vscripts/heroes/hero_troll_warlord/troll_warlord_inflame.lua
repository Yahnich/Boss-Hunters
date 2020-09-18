troll_warlord_inflame = class({})

function troll_warlord_inflame:GetIntrinsicModifierName()
	if not self:IsHidden() then
		return "modifier_troll_warlord_inflame"
	end
end

function troll_warlord_inflame:SwapTo()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_troll_warlord_focus")
	caster:AddNewModifier(caster, self, "modifier_troll_warlord_inflame", {})
end

modifier_troll_warlord_inflame = class(toggleModifierBaseClass)
LinkLuaModifier( "modifier_troll_warlord_inflame", "heroes/hero_troll_warlord/troll_warlord_inflame", LUA_MODIFIER_MOTION_NONE )

function modifier_troll_warlord_inflame:OnCreated()
	self.dmg = self:GetTalentSpecialValueFor("bonus_dmg")
	self.ms = self:GetTalentSpecialValueFor("bonus_ms")
end

function modifier_troll_warlord_inflame:OnRefresh()
	self.dmg = self:GetTalentSpecialValueFor("bonus_dmg")
	self.ms = self:GetTalentSpecialValueFor("bonus_ms")
end

function modifier_troll_warlord_inflame:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE}
end

function modifier_troll_warlord_inflame:GetModifierMoveSpeedBonus_Constant()
	local value = self.ms
	if self:GetCaster():HasModifier("modifier_troll_warlord_battle_trance_bh") and self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_battle_trance_2") then
		value = value * self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_2")
	end
	return value
end

function modifier_troll_warlord_inflame:GetModifierBaseAttack_BonusDamage()
	local value = self.dmg
	if self:GetCaster():HasModifier("modifier_troll_warlord_battle_trance_bh") and self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_battle_trance_2") then
		value = value * self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_2")
	end
	return value
end

function modifier_troll_warlord_inflame:GetModifierMoveSpeed_Absolute()
	if self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_inflame_1") then
		return 550
	end
end

function modifier_troll_warlord_inflame:IsHidden()
	return true
end
