item_gem_of_inner_power = class({})
LinkLuaModifier( "modifier_item_gem_of_inner_power_passive", "items/item_gem_of_inner_power.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_gem_of_inner_power:OnSpellStart()
	local caster = self:GetCaster()
	
	local heal = math.min(caster:GetHealthDeficit(), caster:GetMaxHealth() * self:GetSpecialValueFor("max_hp_heal") / 100)
	local radius = self:GetSpecialValueFor("radius")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius")) ) do
		self:DealDamage( caster, enemy, heal, {damage_type = DAMAGE_TYPE_MAGICAL} )
	end
	caster:HealEvent(heal, self, caster)
	caster:Dispel(caster, false)
	ParticleManager:FireParticle("particles/titan_selfheal_flare.vpcf", PATTACH_POINT_FOLLOW, caster)
end

function item_gem_of_inner_power:GetIntrinsicModifierName()
	return "modifier_item_gem_of_inner_power_passive"
end

modifier_item_gem_of_inner_power_passive = class(itemBaseClass)

function modifier_item_gem_of_inner_power_passive:OnCreated()
	self.hpBonus = self:GetSpecialValueFor("bonus_health")
	self.hpPerStr = self:GetSpecialValueFor("hp_per_str")
end

function modifier_item_gem_of_inner_power_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_item_gem_of_inner_power_passive:GetModifierHealthBonus()
	return self:GetParent():GetStrength() * self.hpPerStr + self.hpBonus
end

function modifier_item_gem_of_inner_power_passive:IsHidden()
	return true
end

function modifier_item_gem_of_inner_power_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end