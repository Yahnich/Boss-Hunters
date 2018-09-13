troll_warlord_focus = class({})

function troll_warlord_focus:GetIntrinsicModifierName()
	if not self:IsHidden() then
		return "modifier_troll_warlord_focus"
	end
end

function troll_warlord_focus:SwapTo()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_troll_warlord_inflame")
	caster:AddNewModifier(caster, self, "modifier_troll_warlord_focus", {})
end

modifier_troll_warlord_focus = class({})
LinkLuaModifier( "modifier_troll_warlord_focus", "heroes/hero_troll_warlord/troll_warlord_focus", LUA_MODIFIER_MOTION_NONE )

function modifier_troll_warlord_focus:OnCreated()
	self.ar = self:GetTalentSpecialValueFor("bonus_range")
	self.acc = self:GetTalentSpecialValueFor("bonus_acc")
end

function modifier_troll_warlord_focus:OnRefresh()
	self.ar = self:GetTalentSpecialValueFor("bonus_range")
	self.acc = self:GetTalentSpecialValueFor("bonus_acc")
end

function modifier_troll_warlord_focus:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function modifier_troll_warlord_focus:GetModifierAttackRangeBonus()
	local value = self.ar
	if self:GetCaster():HasModifier("modifier_troll_warlord_battle_trance_bh") and self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_battle_trance_2") then
		value = value * self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_2")
	end
	return value
end

function modifier_troll_warlord_focus:GetAccuracy()
	if self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_focus_1") then
		return 100
	else
		local value = self.acc
		if self:GetCaster():HasModifier("modifier_troll_warlord_battle_trance_bh") and self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_battle_trance_2") then
			value = value * self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_2")
		end
		return value
	end
end

function modifier_troll_warlord_focus:IsHidden()
	return true
end