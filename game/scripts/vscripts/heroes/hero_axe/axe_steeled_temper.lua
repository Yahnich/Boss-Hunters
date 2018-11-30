axe_steeled_temper = class({})

function axe_steeled_temper:GetIntrinsicModifierName()
	return "modifier_axe_steeled_temper"
end

modifier_axe_steeled_temper = class({})
LinkLuaModifier("modifier_axe_steeled_temper", "heroes/hero_axe/axe_steeled_temper", LUA_MODIFIER_MOTION_NONE)

function modifier_axe_steeled_temper:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("str_to_armor")
	self.as = self:GetTalentSpecialValueFor("scepter_str_to_as")
end

function modifier_axe_steeled_temper:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_axe_steeled_temper:GetModifierAttackSpeedBonus()
	if self:GetCaster():HasScepter() then
		return self:GetCaster():GetStrength() * self.as
	end
end

function modifier_axe_steeled_temper:GetModifierPhysicalArmorBonus()
	return self:GetCaster():GetStrength() * self.armor
end