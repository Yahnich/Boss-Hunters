shadow_shaman_snake_totem = class({})

function shadow_shaman_snake_totem:OnSpellStart()
	local caster = self:GetCaster()
	local ward = caster:CreateSummon("npc_dota_shadow_shaman_ward_1", self:GetCursorPosition(), self:GetTalentSpecialValueFor("duration"))
	if caster:HasTalent("special_bonus_unique_shadow_shaman_snake_totem_2") then
		local ward = caster:CreateSummon("npc_dota_shadow_shaman_ward_1", self:GetCursorPosition(), self:GetTalentSpecialValueFor("duration"))
	end
end

function modifier_shadow_shaman_snake_totem_damage_aura:OnCreated()
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_shadow_shaman_snake_totem_1")
end

function modifier_shadow_shaman_snake_totem_damage_aura:IsAura()
	return true
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetModifierAura()
	return "modifier_shadow_shaman_snake_totem_damage_buff"
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetAuraRadius()
	return self.radius
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetAuraDuration()
	return 0.5
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end


modifier_shadow_shaman_snake_totem_damage_buff = class({})
LinkLuaModifier("modifier_shadow_shaman_snake_totem_damage_buff", "heroes/hero_shadow_shaman/shadow_shaman_snake_totem", LUA_MODIFIER_MOTION_NONE)

function modifier_shadow_shaman_snake_totem_damage_buff:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage")
end

function modifier_shadow_shaman_snake_totem_damage_buff:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("damage")
end

function modifier_shadow_shaman_snake_totem_damage_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_shadow_shaman_snake_totem_damage_buff:GetModifierPreAttack_BonusDamage()
	return self.damage
end