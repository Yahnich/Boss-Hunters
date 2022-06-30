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

modifier_troll_warlord_focus = class(toggleModifierBaseClass)
LinkLuaModifier( "modifier_troll_warlord_focus", "heroes/hero_troll_warlord/troll_warlord_focus", LUA_MODIFIER_MOTION_NONE )

function modifier_troll_warlord_focus:OnCreated()
	self:OnRefresh()
end

function modifier_troll_warlord_focus:OnRefresh()
	self.ar = self:GetTalentSpecialValueFor("bonus_range")
	self.axe_dmg = self:GetTalentSpecialValueFor("bonus_axe_dmg")
	self.axe_throw = self:GetCaster():FindAbilityByName("troll_warlord_axe_throw")
	
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_focus_1")
	self.talent2Dur = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_focus_1", "duration")
end

function modifier_troll_warlord_focus:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_troll_warlord_focus:GetModifierAttackRangeBonus()
	local value = self.ar
	if self:GetCaster():HasModifier("modifier_troll_warlord_battle_trance_bh") and self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_battle_trance_2") then
		value = value * self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_2")
	end
	return value
end

function modifier_troll_warlord_focus:GetModifierCastRangeBonusStacking()
	local value = self.ar
	if self:GetCaster():HasModifier("modifier_troll_warlord_battle_trance_bh") and self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_battle_trance_2") then
		value = value * self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_2")
	end
	return value
end

function modifier_troll_warlord_focus:GetModifierOverrideAbilitySpecial(params)
	if params.ability == self.axe_throw then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "axe_damage" then
			return 1
		end
	end
end

function modifier_troll_warlord_focus:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability == self.axe_throw then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "axe_damage"then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			local value = self.axe_dmg
			if self:GetCaster():HasModifier("modifier_troll_warlord_battle_trance_bh") and self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_battle_trance_2") then
				value = value * self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_2")
			end
			return flBaseValue + value
		end
	end
end

function modifier_troll_warlord_focus:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self.talent2 then
		params.target:AddNewModifier( params.attacker, self:GetAbility(), "modifier_troll_warlord_focus_slow", {duration = self.talent2Dur} )
	end
end

function modifier_troll_warlord_focus:IsHidden()
	return true
end

modifier_troll_warlord_focus_slow = class({})
LinkLuaModifier( "modifier_troll_warlord_focus_slow", "heroes/hero_troll_warlord/troll_warlord_focus", LUA_MODIFIER_MOTION_NONE )

function modifier_troll_warlord_focus_slow:OnCreated()
	self:OnRefresh()
end

function modifier_troll_warlord_focus_slow:OnRefresh()
	self.slow = -self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_focus_1", "slow")
	if self:GetCaster():HasModifier("modifier_troll_warlord_battle_trance_bh") and self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_battle_trance_2") then
		self.slow = self.slow * self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_2")
	end
end

function modifier_troll_warlord_focus_slow:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE  }
end

function modifier_troll_warlord_focus_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_troll_warlord_focus_slow:GetEffectName()
	return "particles/items3_fx/silver_edge_slow.vpcf"
end