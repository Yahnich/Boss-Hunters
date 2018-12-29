item_borealis_cloak = class({})

function item_borealis_cloak:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = 0
	local maxRadius = self:GetSpecialValueFor("active_radius")
	local speed = self:GetSpecialValueFor("active_speed")
	local growth = ( maxRadius - radius / speed ) * 0.1
	local damage = self:GetSpecialValueFor("active_damage")
	local duration = self:GetSpecialValueFor("debuff_duration")
	local hitUnits = {}
	ParticleManager:FireParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_POINT_FOLLOW, caster, {[1] = Vector( maxRadius, 3, speed )})
	caster:EmitSound("DOTA_Item.ShivasGuard.Activate")
	Timers:CreateTimer(function()
		for _, unit in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
			if not hitUnits[unit] then
				self:DealDamage( caster, unit, damage )
				unit:AddNewModifier( caster, self, "modifier_item_borealis_cloak_debuff", {duration = duration})
				ParticleManager:FireParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_POINT_FOLLOW, unit )
				hitUnits[unit] = true
			end
		end
		radius = radius + growth
		if radius <= maxRadius then
			return 0.1
		end
	end)
end

function item_borealis_cloak:GetIntrinsicModifierName()
	return "modifier_item_borealis_cloak"
end

modifier_item_borealis_cloak = class(itemBaseClass)
LinkLuaModifier("modifier_item_borealis_cloak", "items/item_borealis_cloak", LUA_MODIFIER_MOTION_NONE)

function modifier_item_borealis_cloak:OnCreated()
	self.int = self:GetSpecialValueFor("bonus_agility")
	self.armor = self:GetSpecialValueFor("bonus_attackspeed")
	self.regen = self:GetSpecialValueFor("bonus_attackspeed")
	
	self.duration = self:GetSpecialValueFor("debuff_duration")
end

function modifier_item_borealis_cloak:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_EVENT_ON_ATTACK_LANDED
			}
end

function modifier_item_borealis_cloak:GetModifierBonusStats_Intellect()
	return self.attackSpeed
end

function modifier_item_borealis_cloak:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_borealis_cloak:GetModifierConstantManaRegen()
	return self.regen
end

function modifier_item_borealis_cloak:OnAttackLanded(params)
	if params.target == self:GetParent() then
		params.attacker:AddNewModifier( params.target, self:GetAbility(), "modifier_item_borealis_cloak_debuff", {duration = self.duration})
	end
end

modifier_item_borealis_cloak_debuff = class({})
LinkLuaModifier("modifier_item_borealis_cloak_debuff", "items/item_borealis_cloak", LUA_MODIFIER_MOTION_NONE)

function modifier_item_borealis_cloak_debuff:OnCreated()
	self.ms = self:GetAbility():GetSpecialValueFor("debuff_ms")
	self.as = self:GetAbility():GetSpecialValueFor("debuff_as")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("debuff_damage")
		self:StartIntervalThink(1)
	end
end

function modifier_item_borealis_cloak_debuff:OnRefresh()
	self.ms = self:GetAbility():GetSpecialValueFor("debuff_ms")
	self.as = self:GetAbility():GetSpecialValueFor("debuff_as")
end

function modifier_item_borealis_cloak_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_item_borealis_cloak_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_item_borealis_cloak_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_item_borealis_cloak_debuff:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_item_borealis_cloak_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end