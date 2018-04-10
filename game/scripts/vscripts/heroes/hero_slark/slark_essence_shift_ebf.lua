slark_essence_shift_ebf = class({})

function slark_essence_shift_ebf:GetIntrinsicModifierName()
	return "modifier_slark_essence_shift_handler"
end

function slark_essence_shift_ebf:ShouldUseResources()
	return true
end

modifier_slark_essence_shift_handler = class({})
LinkLuaModifier("modifier_slark_essence_shift_handler", "heroes/hero_slark/slark_essence_shift_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_essence_shift_handler:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED,
			}
	return funcs
end

function modifier_slark_essence_shift_handler:OnAttackLanded(params)
	local ability = self:GetAbility()
	if params.attacker == self:GetParent() and ability:IsCooldownReady() then
		ability:SetCooldown()
		local caster = self:GetCaster()
		local duration = self:GetTalentSpecialValueFor("duration")

		params.target:AddNewModifier(caster, ability, "modifier_slark_essence_shift_attr_debuff", {duration = duration})
		if not caster:HasTalent("special_bonus_unique_slark_essence_shift_1") then
			caster:AddNewModifier(caster, ability, "modifier_slark_essence_shift_agi_buff", {duration = duration})
		else
			caster:AddNewModifier(caster, ability, "modifier_slark_essence_shift_talent", {duration = duration})
		end
		if caster:HasTalent("special_bonus_unique_slark_essence_shift_2") then
			ability:DealDamage( caster, params.target, caster:GetPrimaryStatValue() * caster:FindTalentValue("special_bonus_unique_slark_essence_shift_2") / 100, {damage_type = DAMAGE_TYPE_PURE})
		end
	end
end

function modifier_slark_essence_shift_handler:IsHidden()
	return true
end

modifier_slark_essence_shift_attr_debuff = class({})
LinkLuaModifier("modifier_slark_essence_shift_attr_debuff", "heroes/hero_slark/slark_essence_shift_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_essence_shift_attr_debuff:OnCreated()
	self.ad = self:GetTalentSpecialValueFor("ad_loss")
	self.as = self:GetTalentSpecialValueFor("as_loss")
	self.hp = self:GetTalentSpecialValueFor("hp_loss")
	self.ar = self:GetTalentSpecialValueFor("ar_loss")
	self:AddIndependentStack(self:GetRemainingTime())
end

function modifier_slark_essence_shift_attr_debuff:OnRefresh()
	self.ad = self:GetTalentSpecialValueFor("ad_loss")
	self.as = self:GetTalentSpecialValueFor("as_loss")
	self.hp = self:GetTalentSpecialValueFor("hp_loss")
	self.ar = self:GetTalentSpecialValueFor("ar_loss")

	self:AddIndependentStack(self:GetRemainingTime())
end

function modifier_slark_essence_shift_attr_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_slark_essence_shift_attr_debuff:GetModifierPreAttack_BonusDamage()
	return self.ad * self:GetStackCount()
end

function modifier_slark_essence_shift_attr_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.as * self:GetStackCount()
end

function modifier_slark_essence_shift_attr_debuff:GetModifierExtraHealthBonus()
	return self.hp * self:GetStackCount()
end

function modifier_slark_essence_shift_attr_debuff:GetModifierPhysicalArmorBonus()
	return self.ar * self:GetStackCount()
end

modifier_slark_essence_shift_agi_buff = class({})
LinkLuaModifier("modifier_slark_essence_shift_agi_buff", "heroes/hero_slark/slark_essence_shift_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_essence_shift_agi_buff:OnCreated()
	self.agi = self:GetTalentSpecialValueFor("agi_gain")
	self:AddIndependentStack(self:GetRemainingTime())
end

function modifier_slark_essence_shift_agi_buff:OnRefresh()
	self.agi = self:GetTalentSpecialValueFor("agi_gain")
	self:AddIndependentStack(self:GetRemainingTime())
end

function modifier_slark_essence_shift_agi_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_slark_essence_shift_agi_buff:GetModifierBonusStats_Agility()
	return self.agi * self:GetStackCount()
end

modifier_slark_essence_shift_talent = class({})
LinkLuaModifier("modifier_slark_essence_shift_talent", "heroes/hero_slark/slark_essence_shift_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_essence_shift_talent:OnCreated()
	self.all = self:GetTalentSpecialValueFor("agi_gain") / 3
	self:AddIndependentStack(self:GetRemainingTime())
end

function modifier_slark_essence_shift_talent:OnRefresh()
	self.all = self:GetTalentSpecialValueFor("agi_gain") / 3
	self:AddIndependentStack(self:GetRemainingTime())
end

function modifier_slark_essence_shift_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_slark_essence_shift_talent:GetModifierBonusStats_Strength()
	return self.all * self:GetStackCount()
end

function modifier_slark_essence_shift_talent:GetModifierBonusStats_Agility()
	return self.all * self:GetStackCount()
end

function modifier_slark_essence_shift_talent:GetModifierBonusStats_Intellect()
	return self.all * self:GetStackCount()
end