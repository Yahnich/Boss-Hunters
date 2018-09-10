terrorblade_metamorphosis_bh = class({})

function terrorblade_metamorphosis_bh:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_terrorblade_metamorphosis_bh", {duration = self:GetTalentSpecialValueFor("duration")} )
end

modifier_terrorblade_metamorphosis_bh = class({})
LinkLuaModifier("modifier_terrorblade_metamorphosis_bh", "heroes/hero_terrorblade/terrorblade_metamorphosis_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_terrorblade_metamorphosis_bh:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("metamorph_aura_tooltip")
end

function modifier_terrorblade_metamorphosis_bh:IsAura()
	return true
end

function modifier_terrorblade_metamorphosis_bh:GetModifierAura()
	return "modifier_terrorblade_metamorphosis_bh_aura"
end

function modifier_terrorblade_metamorphosis_bh:GetAuraRadius()
	return self.radius
end

function modifier_terrorblade_metamorphosis_bh:GetAuraDuration()
	return 0.5
end

function modifier_terrorblade_metamorphosis_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_terrorblade_metamorphosis_bh:GetAuraEntityReject(entity)
	if entity == self:GetParent() 
	or entity:GetUnitName() == self:GetParent():GetUnitName() 
	or ( self:GetParent():HasTalent("special_bonus_unique_terrorblade_metamorphosis_1") and entity:IsRealHero() ) then 
		return false
	else
		return true
	end
end

function modifier_terrorblade_metamorphosis_bh:IsHidden()
	return true
end

function modifier_terrorblade_metamorphosis_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

modifier_terrorblade_metamorphosis_bh_aura = class({})
LinkLuaModifier( "modifier_terrorblade_metamorphosis_bh_aura", "heroes/hero_terrorblade/terrorblade_metamorphosis_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_terrorblade_metamorphosis_bh_aura:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("bonus_damage")
	self.movespeed = self:GetTalentSpecialValueFor("speed_loss")
	self.range = self:GetTalentSpecialValueFor("bonus_range")
end

function modifier_terrorblade_metamorphosis_bh_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MODEL_CHANGE, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

OnModelChange
GetModifierBaseAttack_BonusDamage
GetModifierMoveSpeedBonus_Constant