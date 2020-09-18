lich_frost_armor_bh = class({})

function lich_frost_armor_bh:GetCastAnimation()
	return ACT_DOTA_CAST2_STATUE
end

function lich_frost_armor_bh:GetBehavior()
	local flags = DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
	-- if self:GetCaster():HasTalent("special_bonus_unique_lich_frost_armor_2") then
		-- return flags + DOTA_ABILITY_BEHAVIOR_NO_TARGET
	-- else
		return flags + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	-- end
end

function lich_frost_armor_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("buff_duration")
	-- if caster:HasTalent("special_bonus_unique_lich_frost_armor_2") then
		-- for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() ) ) do
			-- ally:AddNewModifier(caster, self, "modifier_lich_frost_armor_bh", {duration = duration})
		-- end
	-- else
		local target = self:GetCursorTarget()
		target:AddNewModifier(caster, self, "modifier_lich_frost_armor_bh", {duration = duration})
	-- end
	caster:EmitSound("Hero_Lich.IceAge")
end

modifier_lich_frost_armor_bh = class({})
LinkLuaModifier( "modifier_lich_frost_armor_bh", "heroes/hero_lich/lich_frost_armor_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lich_frost_armor_bh:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("armor_bonus")
	self.duration = self:GetTalentSpecialValueFor("slow_duration")
	self.radius = self:GetTalentSpecialValueFor("pulse_radius")
	self.damage = self:GetTalentSpecialValueFor("pulse_damage")
	self.interval = self:GetTalentSpecialValueFor("pulse_interval")
	self.regen = self:GetCaster():FindTalentValue("special_bonus_unique_lich_frost_armor_1")
	self.dmg = self.armor * self:GetCaster():FindTalentValue("special_bonus_unique_lich_frost_armor_2")
	self.amp = self.armor * self:GetCaster():FindTalentValue("special_bonus_unique_lich_frost_armor_2")
	if IsServer() then
		local hullRadius = self:GetParent():GetHullRadius() * 2
		local nFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_lich/lich_ice_age.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(nFX, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(nFX, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl( nFX, 2, Vector( self.radius, self.radius, self.radius ) )
		self:AddEffect(nFX)
		self:OnIntervalThink()
		self:StartIntervalThink(self.interval)
	end
end

function modifier_lich_frost_armor_bh:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("armor_bonus")
	self.duration = self:GetTalentSpecialValueFor("slow_duration")
	self.radius = self:GetTalentSpecialValueFor("pulse_radius")
	self.damage = self:GetTalentSpecialValueFor("pulse_damage")
	self.interval = self:GetTalentSpecialValueFor("pulse_interval")
	self.regen = self:GetCaster():FindTalentValue("special_bonus_unique_lich_frost_armor_1")
	self.dmg = self.armor * self:GetCaster():FindTalentValue("special_bonus_unique_lich_frost_armor_2")
	self.amp = self.armor * self:GetCaster():FindTalentValue("special_bonus_unique_lich_frost_armor_2")
end

function modifier_lich_frost_armor_bh:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
		ability:DealDamage( caster, enemy, self.damage, {damage_type = DAMAGE_TYPE_MAGICAL} )
		enemy:AddNewModifier( caster, ability, "modifier_lich_frost_armor_bh_slow", {duration = self.duration} )
		enemy:EmitSound("Hero_Lich.IceAge.Damage")
	end
	parent:EmitSound("Hero_Lich.IceAge.Tick")
	ParticleManager:FireParticle( "particles/units/heroes/hero_lich/lich_ice_age_dmg.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {[0] = "attach_hitloc",
																																		 [1] = "attach_hitloc",
																																		 [2] = Vector( self.radius, self.radius, self.radius )} )
end

function modifier_lich_frost_armor_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, 
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
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

function modifier_lich_frost_armor_bh:GetModifierBaseDamageOutgoing_Percentage()
	return self.dmg
end

function modifier_lich_frost_armor_bh:GetModifierSpellAmplify_Percentage()
	return self.amp
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
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_lich_frost_armor_bh_slow:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_lich_frost_armor_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_lich_frost_armor_bh:GetEffectName()
	return "particles/units/heroes/hero_lich/lich_ice_age_debuff.vpcf"
end