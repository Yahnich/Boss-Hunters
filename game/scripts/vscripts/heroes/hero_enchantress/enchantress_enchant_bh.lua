enchantress_enchant_bh = class({})
LinkLuaModifier("modifier_enchantress_enchant_bh_slow", "heroes/hero_enchantress/enchantress_enchant_bh", LUA_MODIFIER_MOTION_NONE)

function enchantress_enchant_bh:IsStealable()
    return true
end

function enchantress_enchant_bh:IsHiddenWhenStolen()
    return false
end

function enchantress_enchant_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetTalentSpecialValueFor("duration")

	EmitSoundOn("Hero_Enchantress.EnchantCast", caster)
	EmitSoundOn("Hero_Enchantress.EnchantHero", target)

	target:Charm(self, caster, duration)
	target:AddNewModifier(caster, self, "modifier_enchantress_enchant_bh_slow", {Duration = duration})

	self:StartDelayedCooldown()
end

modifier_enchantress_enchant_bh_slow = class({})
function modifier_enchantress_enchant_bh_slow:OnCreated(table)
	self.slow_ms = self:GetTalentSpecialValueFor("slow_ms")

	if self:GetCaster():HasTalent("special_bonus_unique_enchantress_enchant_bh_1") then
		self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_enchantress_enchant_bh_1")
	end

	if self:GetCaster():HasTalent("special_bonus_unique_enchantress_enchant_bh_1") then
		self.lifesteal = self:GetCaster():FindTalentValue("special_bonus_unique_enchantress_enchant_bh_2")
	end
end

function modifier_enchantress_enchant_bh_slow:OnRefresh(table)
	self.slow_ms = self:GetTalentSpecialValueFor("slow_ms")

	if self:GetCaster():HasTalent("special_bonus_unique_enchantress_enchant_bh_1") then
		self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_enchantress_enchant_bh_1")
	end

	if self:GetCaster():HasTalent("special_bonus_unique_enchantress_enchant_bh_1") then
		self.lifesteal = self:GetCaster():FindTalentValue("special_bonus_unique_enchantress_enchant_bh_2")
	end
end

function modifier_enchantress_enchant_bh_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_EVENT_ON_ATTACKED}
end

function modifier_enchantress_enchant_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_ms
end

function modifier_enchantress_enchant_bh_slow:GetModifierIncomingDamage_Percentage()
	return self.damage
end

function modifier_enchantress_enchant_bh_slow:OnAttacked(params)
	if IsServer() then
		local caster = self:GetCaster()
		local attacker = params.attacker
		local target = params.target

		if caster:HasTalent("special_bonus_unique_enchantress_enchant_bh_2") then
			if attacker:GetTeam() == caster:GetTeam() then
				attacker:Lifesteal(nil, self.lifesteal, params.damage, nil, 0, DOTA_LIFESTEAL_SOURCE_NONE, true)
			end
		end
	end
end

function modifier_enchantress_enchant_bh_slow:GetEffectName()
	return "particles/units/heroes/hero_enchantress/enchantress_enchant_slow.vpcf"
end

function modifier_enchantress_enchant_bh_slow:OnRemoved()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_enchantress_enchant_bh_slow:IsDebuff()
	return true
end

function modifier_enchantress_enchant_bh_slow:IsHidden()
	return true
end

function modifier_enchantress_enchant_bh_slow:IsPurgable()
	return true
end