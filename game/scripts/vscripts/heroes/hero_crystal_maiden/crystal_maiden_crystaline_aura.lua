crystal_maiden_crystalline_aura = class({})

function crystal_maiden_crystalline_aura:GetIntrinsicModifierName()
	return "modifier_crystal_maiden_crystalline_aura"
end

modifier_crystal_maiden_crystalline_aura = class({})
LinkLuaModifier("modifier_crystal_maiden_crystalline_aura", "heroes/hero_crystal_maiden/crystal_maiden_crystalline_aura", LUA_MODIFIER_MOTION_NONE)

function modifier_crystal_maiden_crystalline_aura:IsAura()
	return true
end

function modifier_crystal_maiden_crystalline_aura:GetModifierAura()
	return "modifier_crystal_maiden_crystalline_aura_buff"
end

function modifier_crystal_maiden_crystalline_aura:GetAuraRadius()
	return -1
end

function modifier_crystal_maiden_crystalline_aura:GetAuraDuration()
	return 0.5
end

function modifier_crystal_maiden_crystalline_aura:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_crystal_maiden_crystalline_aura:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_HERO
end

function modifier_crystal_maiden_crystalline_aura:IsHidden()
	return true
end

modifier_crystal_maiden_crystalline_aura_buff = class({})
LinkLuaModifier("modifier_crystal_maiden_crystalline_aura_buff", "heroes/hero_crystal_maiden/crystal_maiden_crystalline_aura", LUA_MODIFIER_MOTION_NONE)

function modifier_crystal_maiden_crystalline_aura_buff:OnCreated()
	if self:GetParent() == self:GetCaster() then
		self.regen = self:GetTalentSpecialValueFor("mana_regen_self")
		self.manacost = self:GetTalentSpecialValueFor("manacost_self")
		self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_crystal_maiden_crystalline_aura_1", "self")
		self.amp = self:GetCaster():FindTalentValue("special_bonus_unique_crystal_maiden_crystalline_aura_2", "self")
	else
		self.regen = self:GetTalentSpecialValueFor("mana_regen")
		self.manacost = self:GetTalentSpecialValueFor("manacost")
		self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_crystal_maiden_crystalline_aura_1")
		self.amp = self:GetCaster():FindTalentValue("special_bonus_unique_crystal_maiden_crystalline_aura_2")
	end
	self:StartIntervalThink(0.5)
end

function modifier_crystal_maiden_crystalline_aura_buff:OnIntervalThink()
	if self:GetParent() == self:GetCaster() then
		self.regen = self:GetTalentSpecialValueFor("mana_regen_self")
		self.manacost = self:GetTalentSpecialValueFor("manacost_self")
		self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_crystal_maiden_crystalline_aura_1", "self")
		self.amp = self:GetCaster():FindTalentValue("special_bonus_unique_crystal_maiden_crystalline_aura_2", "self")
	else
		self.regen = self:GetTalentSpecialValueFor("mana_regen")
		self.manacost = self:GetTalentSpecialValueFor("manacost")
		self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_crystal_maiden_crystalline_aura_1")
		self.amp = self:GetCaster():FindTalentValue("special_bonus_unique_crystal_maiden_crystalline_aura_2")
	end
end

function modifier_crystal_maiden_crystalline_aura_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_LESS_MANA_PLS, MODIFIER_PROPERTY_MORE_MANA_PLS, MODIFIER_PROPERTY_MORE_DMG_PLS}
end

function modifier_crystal_maiden_crystalline_aura_buff:armor()
	return self.armor
end

function modifier_crystal_maiden_crystalline_aura_buff:amp()
	return self.amp
end

function modifier_crystal_maiden_crystalline_aura_buff:manacost()
	return self.manacost
end

function modifier_crystal_maiden_crystalline_aura_buff:regen()
	return self.regen
end