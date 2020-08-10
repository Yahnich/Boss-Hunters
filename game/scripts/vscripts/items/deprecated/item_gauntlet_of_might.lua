item_gauntlet_of_might = class({})

function item_gauntlet_of_might:GetIntrinsicModifierName()
	return "modifier_gauntlet_of_might_passive"
end

function item_gauntlet_of_might:OnSpellStart()
	local caster = self:GetCaster()
	
	local heal = math.min(caster:GetHealthDeficit(), caster:GetMaxHealth() * self:GetSpecialValueFor("max_hp_heal") / 100)
	local radius = self:GetSpecialValueFor("radius")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius")) ) do
		self:DealDamage( caster, enemy, heal, {damage_type = DAMAGE_TYPE_MAGICAL} )
	end
	caster:HealEvent(heal, self, caster)
	caster:Dispel(caster, true)
	
	ParticleManager:FireParticle("particles/titan_selfheal_flare.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:FireParticle("particles/generic_gameplay/generic_purge.vpcf", PATTACH_POINT_FOLLOW, caster)
	
	EmitSoundOn("DOTA_Item.Tango.Activate", caster)
end

modifier_gauntlet_of_might_passive = class(itemBaseClass)
LinkLuaModifier("modifier_gauntlet_of_might_passive", "items/item_gauntlet_of_might", LUA_MODIFIER_MOTION_NONE)

function modifier_gauntlet_of_might_passive:OnCreated()
	self.armor = self:GetSpecialValueFor("armor")
	self.radius = self:GetSpecialValueFor("radius")
	self.bonusHP = self:GetSpecialValueFor("bonus_health")
	self.hpPerStr = self:GetSpecialValueFor("hp_per_str")
end

function modifier_gauntlet_of_might_passive:CheckState()
	return {[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_UNSLOWABLE] = true}
end

function modifier_gauntlet_of_might_passive:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_gauntlet_of_might_passive:DeclareFunctions()
	funcs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			 MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
	return funcs
end

function modifier_gauntlet_of_might_passive:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_gauntlet_of_might_passive:GetModifierExtraHealthBonus()
	return self:GetParent():GetStrength() * self.hpPerStr + self.bonusHP
end

function modifier_gauntlet_of_might_passive:IsAura()
	return true
end

function modifier_gauntlet_of_might_passive:GetModifierAura()
	return "modifier_gauntlet_of_might_aura"
end

function modifier_gauntlet_of_might_passive:GetAuraRadius()
	return self.radius
end

function modifier_gauntlet_of_might_passive:GetAuraDuration()
	return 0.5
end

function modifier_gauntlet_of_might_passive:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_gauntlet_of_might_passive:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_gauntlet_of_might_passive:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_gauntlet_of_might_passive:IsHidden()
	return true
end

function modifier_gauntlet_of_might_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_gauntlet_of_might_aura = class({})
LinkLuaModifier("modifier_gauntlet_of_might_aura", "items/item_gauntlet_of_might", LUA_MODIFIER_MOTION_NONE)

function modifier_gauntlet_of_might_aura:OnCreated()
	self.armor = self:GetSpecialValueFor("armor_aura")
end

function modifier_gauntlet_of_might_aura:OnRefresh()
	self.armor = self:GetSpecialValueFor("armor_aura")
end

function modifier_gauntlet_of_might_aura:DeclareFunctions()
	funcs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
	return funcs
end

function modifier_gauntlet_of_might_aura:GetModifierPhysicalArmorBonus()
	return self.armor
end