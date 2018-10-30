slardar_oathkeeper = class({})

function slardar_oathkeeper:IsStealable()
	return false
end

function slardar_oathkeeper:GetIntrinsicModifierName()
	if not self:IsHidden() then
		return "modifier_slardar_oathkeeper"
	end
end

function slardar_oathkeeper:OnSpellStart()
	local caster = self:GetCaster()
	caster:SwapAbilities( "slardar_oathkeeper", "slardar_oathbreaker", false, true )
	caster:RemoveModifierByName("modifier_slardar_oathkeeper")
	caster:AddNewModifier( caster, caster:FindAbilityByName("slardar_oathbreaker"), "modifier_slardar_oathbreaker", {} )
end

modifier_slardar_oathkeeper = class({})
LinkLuaModifier( "modifier_slardar_oathkeeper", "heroes/hero_slardar/slardar_oathkeeper", LUA_MODIFIER_MOTION_NONE )

function modifier_slardar_oathkeeper:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.mr = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_oathkeeper_1")
end

function modifier_slardar_oathkeeper:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.mr = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_oathkeeper_1")
end

function modifier_slardar_oathkeeper:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_slardar_oathkeeper:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_slardar_oathkeeper:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_slardar_oathkeeper:IsHidden()
	return true
end

function modifier_slardar_oathkeeper:IsPurgable()
	return false
end