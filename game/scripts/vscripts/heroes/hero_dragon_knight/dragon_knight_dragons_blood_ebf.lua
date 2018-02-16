dragon_knight_dragons_blood_ebf = class({})

function dragon_knight_dragons_blood_ebf:GetIntrinsicModifierName()
	return "modifier_dragon_knight_dragons_blood_ebf_passive"
end

modifier_dragon_knight_dragons_blood_ebf_passive = class({})
LinkLuaModifier("modifier_dragon_knight_dragons_blood_ebf_passive", "heroes/hero_dragon_knight/dragon_knight_dragons_blood_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_dragon_knight_dragons_blood_ebf_passive:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.regen = self:GetTalentSpecialValueFor("bonus_health_regen")
	self.ms = self:GetTalentSpecialValueFor("bonus_movespeed")
	self:StartIntervalThink(1)
end

function modifier_dragon_knight_dragons_blood_ebf_passive:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.regen = self:GetTalentSpecialValueFor("bonus_health_regen")
	self.ms = self:GetTalentSpecialValueFor("bonus_movespeed")
	self.spellamp = self:GetCaster():FindTalentValue("special_bonus_unique_dragon_knight_dragons_blood_ebf_2")
end

function modifier_dragon_knight_dragons_blood_ebf_passive:OnIntervalThink()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.regen = self:GetTalentSpecialValueFor("bonus_health_regen")
	self.ms = self:GetTalentSpecialValueFor("bonus_movespeed")
	self.spellamp = self:GetCaster():FindTalentValue("special_bonus_unique_dragon_knight_dragons_blood_ebf_2")
end

function modifier_dragon_knight_dragons_blood_ebf_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_dragon_knight_dragons_blood_ebf_passive:GetModifierMoveSpeedBonus_Constant()
	local ms = self.ms
	if self:GetCaster():HasScepter() and self:GetCaster():HasModifier("modifier_dragon_knight_elder_dragon_berserker_active") then ms = ms * 2 end
	return ms
end

function modifier_dragon_knight_dragons_blood_ebf_passive:GetModifierPhysicalArmorBonus()
	local armor = self.armor
	if self:GetCaster():HasScepter() and self:GetCaster():HasModifier("modifier_dragon_knight_elder_dragon_berserker_active") then armor = armor * 2 end
	return armor
end

function modifier_dragon_knight_dragons_blood_ebf_passive:GetModifierConstantHealthRegen()
	local regen = self.regen
	if self:GetCaster():HasScepter() and self:GetCaster():HasModifier("modifier_dragon_knight_elder_dragon_berserker_active") then regen = regen * 2 end
	return regen
end

function modifier_dragon_knight_dragons_blood_ebf_passive:GetModifierSpellAmplify_Percentage()
	local spellamp = self.spellamp
	if self:GetCaster():HasScepter() and self:GetCaster():HasModifier("modifier_dragon_knight_elder_dragon_berserker_active") then spellamp = spellamp * 2 end
	return spellamp
end

function modifier_dragon_knight_dragons_blood_ebf_passive:IsHidden()
	return true
end