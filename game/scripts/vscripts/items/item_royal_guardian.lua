item_royal_guardian = class({})

function item_royal_guardian:GetIntrinsicModifierName()
	return "modifier_item_royal_guardian"
end

function item_royal_guardian:OnSpellStart()
	local caster = self:GetCaster()
	
	local slamBlind = self:GetSpecialValueFor("blind")
	local slamDamage = self:GetSpecialValueFor("armor_damage")
	local slamRange = self:GetSpecialValueFor("slam_distance")
	local slamRadius = self:GetSpecialValueFor("slam_radius")
	local slamDuration = self:GetSpecialValueFor("slam_duration")
	ParticleManager:FireParticle("particles/econ/items/centaur/centaur_ti6_gold/centaur_ti6_warstomp_gold.vpcf", PATTACH_POINT_FOLLOW, caster, {[1] = Vector(slamRadius, 0, 0)})
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInCone(caster:GetForwardVector(), caster:GetAbsOrigin(), slamRadius, slamRange) ) do
		self:DealDamage( caster, enemy, slamDamage * caster:GetPhysicalArmorValue(), {damage_type = DAMAGE_TYPE_PHYSICAL} )
		enemy:Blind(slamBlind, self, caster, slamDuration)
	end
end

modifier_item_royal_guardian = class({})
LinkLuaModifier( "modifier_item_royal_guardian", "items/item_royal_guardian.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_royal_guardian:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_block")
	self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
	self.hp_regen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_royal_guardian:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_royal_guardian:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_item_royal_guardian:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_royal_guardian:GetModifierTotal_ConstantBlock(params)
	if RollPercentage(self.chance) and params.attacker ~= self:GetParent() then
		return self.block
	end
end

function modifier_item_royal_guardian:IsHidden()
	return true
end

function modifier_item_royal_guardian:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end