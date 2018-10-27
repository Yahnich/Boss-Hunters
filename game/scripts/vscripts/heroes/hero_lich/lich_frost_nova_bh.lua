lich_frost_nova_bh = class({})

function lich_frost_nova_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function lich_frost_nova_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local aoeDamage = self:GetTalentSpecialValueFor("aoe_damage")
	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetDuration()
	
	local hitTable = {}
	Timers:CreateTimer(function()
		self:DealDamage( caster, target )
		hitTable[target] = true
		ParticleManager:FireParticle("particles/units/heroes/hero_lich/lich_frost_nova.vpcf", PATTACH_POINT_FOLLOW, target)
		target:EmitSound("Ability.FrostNova")
		position = target:GetAbsOrigin()
		target = nil
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			self:DealDamage( caster, enemy, aoeDamage )
			enemy:AddNewModifier( caster, self, "modifier_lich_frost_nova_bh", {duration = duration})
			if not hitTable[enemy] then
				target = enemy
			end
		end
		if caster:HasTalent("special_bonus_unique_lich_frost_nova_1") and target then
			return 0.3
		end
	end)
end

modifier_lich_frost_nova_bh = class({})
LinkLuaModifier( "modifier_lich_frost_nova_bh", "heroes/hero_lich/lich_frost_nova_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lich_frost_nova_bh:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("slow_movement_speed")
	self.as = self:GetTalentSpecialValueFor("slow_attack_speed")
end

function modifier_lich_frost_nova_bh:OnRefresh()
	self.ms = self:GetTalentSpecialValueFor("slow_movement_speed")
	self.as = self:GetTalentSpecialValueFor("slow_attack_speed")
end

function modifier_lich_frost_nova_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_lich_frost_nova_bh:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_lich_frost_nova_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_lich_frost_nova_bh:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end