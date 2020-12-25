boss18b_corrupted_huntress = class({})

function boss18b_corrupted_huntress:GetIntrinsicModifierName()
	return "modifier_boss18b_corrupted_huntress_passive"
end

modifier_boss18b_corrupted_huntress_passive = class({})
LinkLuaModifier("modifier_boss18b_corrupted_huntress_passive", "bosses/boss18b/boss18b_corrupted_huntress.lua", 0)

function modifier_boss18b_corrupted_huntress_passive:OnCreated()
	self.radius = self:GetSpecialValueFor("aura_radius")
end

function modifier_boss18b_corrupted_huntress_passive:OnRefresh()
	self.radius = self:GetSpecialValueFor("aura_radius")
end

function modifier_boss18b_corrupted_huntress_passive:IsHidden()
	return true
end

function modifier_boss18b_corrupted_huntress_passive:IsAura()
	return not self:GetParent():PassivesDisabled()
end

function modifier_boss18b_corrupted_huntress_passive:GetModifierAura()
	return "modifier_boss18b_corrupted_huntress_debuff"
end

function modifier_boss18b_corrupted_huntress_passive:GetAuraRadius()
	return 500
end

function modifier_boss18b_corrupted_huntress_passive:GetAuraDuration()
	return 0.5
end

function modifier_boss18b_corrupted_huntress_passive:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss18b_corrupted_huntress_passive:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss18b_corrupted_huntress_passive:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/wraith_king_ambient.vpcf"
end

function modifier_boss18b_corrupted_huntress_passive:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function modifier_boss18b_corrupted_huntress_passive:StatusEffectPriority()
	return 50
end

modifier_boss18b_corrupted_huntress_debuff = class({})
LinkLuaModifier("modifier_boss18b_corrupted_huntress_debuff", "bosses/boss18b/boss18b_corrupted_huntress.lua", 0)

function modifier_boss18b_corrupted_huntress_debuff:OnCreated()
	self.armor = self:GetSpecialValueFor("armor_reduction")
	self.damage = self:GetSpecialValueFor("damage_per_sec")
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_boss18b_corrupted_huntress_debuff:OnRefresh()
	self.armor = self:GetSpecialValueFor("armor_reduction")
	self.damage = self:GetSpecialValueFor("damage_per_sec")
end

function modifier_boss18b_corrupted_huntress_debuff:OnIntervalThink()
	if not self:GetCaster() or self:GetCaster():IsNull()
	or not self:GetParent() or self:GetParent():IsNull()
	or not self:GetAbility() or self:GetAbility():IsNull() then
		self:Destroy()
		return
	end
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage )
end

function modifier_boss18b_corrupted_huntress_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_boss18b_corrupted_huntress_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end