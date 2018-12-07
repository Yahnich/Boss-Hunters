lich_frost_armor_bh = class({})

function lich_frost_armor_bh:GetBehavior()
	local flags = DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
	if self:GetCaster():HasTalent("special_bonus_unique_lich_frost_armor_2") then
		return flags + DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return flags + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function lich_frost_armor_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetDuration()
	if caster:HasTalent("special_bonus_unique_lich_frost_armor_2") then
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() ) ) do
			ally:AddNewModifier(caster, self, "modifier_lich_frost_armor_bh", {duration = duration})
		end
	else
		local target = self:GetCursorTarget()
		target:AddNewModifier(caster, self, "modifier_lich_frost_armor_bh", {duration = duration})
	end
	caster:EmitSound("Hero_Lich.FrostArmor")
end

modifier_lich_frost_armor_bh = class({})
LinkLuaModifier( "modifier_lich_frost_armor_bh", "heroes/hero_lich/lich_frost_armor_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lich_frost_armor_bh:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("armor_bonus")
	self.duration = self:GetTalentSpecialValueFor("slow_duration")
	self.regen = self:GetCaster():FindTalentValue("special_bonus_unique_lich_frost_armor_1")
	if IsServer() then
		local hullRadius = self:GetParent():GetHullRadius() * 2
		local nFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_lich/lich_frost_armor.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( nFX, 1, Vector( hullRadius, hullRadius, hullRadius ) )
		self:AddEffect(nFX)
	end
end

function modifier_lich_frost_armor_bh:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("armor_bonus")
	self.duration = self:GetTalentSpecialValueFor("slow_duration")
	self.regen = self:GetCaster():FindTalentValue("special_bonus_unique_lich_frost_armor_1")
end

function modifier_lich_frost_armor_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_lich_frost_armor_bh:OnAttackLanded(params)
	if params.target == self:GetParent() then
		params.attacker:AddNewModifier( params.target, self:GetAbility(), "modifier_lich_frost_armor_bh_slow", {duration = self.duration} )
		params.target:EmitSound("Hero_Lich.FrostArmorDamage")
	end
end

function modifier_lich_frost_armor_bh:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_lich_frost_armor_bh:GetModifierConstantHealthRegen()
	return self.regen
end

modifier_lich_frost_armor_bh_slow = class({})
LinkLuaModifier( "modifier_lich_frost_armor_bh_slow", "heroes/hero_lich/lich_frost_armor_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lich_frost_armor_bh_slow:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("slow_movement_speed")
	self.as = self:GetTalentSpecialValueFor("slow_attack_speed")
end

function modifier_lich_frost_armor_bh_slow:OnRefresh()
	self.ms = self:GetTalentSpecialValueFor("slow_movement_speed")
	self.as = self:GetTalentSpecialValueFor("slow_attack_speed")
end

function modifier_lich_frost_armor_bh_slow:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_lich_frost_armor_bh_slow:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_lich_frost_armor_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_lich_frost_armor_bh:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end