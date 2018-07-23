naga_siren_tidal_waves = class({})

function naga_siren_tidal_waves:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_naga_siren_tidal_waves_dead_tide") then
		return "custom/naga_siren_dead_tide"
	elseif self:GetCaster():HasModifier("modifier_naga_siren_tidal_waves_spring_tide") then
		return "custom/naga_siren_spring_tide"
	else
		return "naga_siren_rip_tide"
	end
end

function naga_siren_tidal_waves:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function naga_siren_tidal_waves:GetIntrinsicModifierName()
	return "modifier_naga_siren_tidal_waves_rip_tide"
end

function naga_siren_tidal_waves:OnSpellStart()
	local caster = self:GetCaster()
	
	self.state = self.state or "rip"
	if caster:HasTalent("special_bonus_unique_naga_siren_tidal_waves_1") then
		self.cooldownTracker = self.cooldownTracker or {}
		self.cooldownTracker[self.state] = GameRules:GetGameTime() + self:GetCooldownTimeRemaining()
		self:EndCooldown()
	end
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("duration")
	local damage = self:GetAbilityDamage()
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		self:DealDamage(caster, enemy, damage)
		if self.state == "rip" then
			enemy:AddNewModifier(caster, self, "modifier_naga_siren_tidal_waves_rip_tide_debuff", {duration = duration})
		elseif self.state == "dead" then
			enemy:AddNewModifier(caster, self, "modifier_naga_siren_tidal_waves_dead_tide_debuff", {duration = duration})
		elseif self.state == "spring" then
			enemy:AddNewModifier(caster, self, "modifier_naga_siren_tidal_waves_spring_tide_debuff", {duration = duration})
		end
	end
	
	if self.state == "dead" then
		caster:RemoveModifierByName("modifier_naga_siren_tidal_waves_dead_tide")
		caster:AddNewModifier(caster, self, "modifier_naga_siren_tidal_waves_spring_tide", {})
		
		ParticleManager:FireParticle("particles/naga_siren_deadtide.vpcf", PATTACH_POINT_FOLLOW, caster, {[1] = Vector(radius, 1, 1)})
		
		self.state = "spring"
	elseif self.state == "spring" then
		caster:RemoveModifierByName("modifier_naga_siren_tidal_waves_spring_tide")
		caster:AddNewModifier(caster, self, "modifier_naga_siren_tidal_waves_rip_tide", {})
		
		ParticleManager:FireParticle("particles/naga_siren_springtide.vpcf", PATTACH_POINT_FOLLOW, caster, {[1] = Vector(radius, 1, 1)})
		
		self.state = "rip"
	elseif self.state == "rip" then
		caster:RemoveModifierByName("modifier_naga_siren_tidal_waves_rip_tide")
		caster:AddNewModifier(caster, self, "modifier_naga_siren_tidal_waves_dead_tide", {})
		
		ParticleManager:FireParticle("particles/units/heroes/hero_siren/naga_siren_riptide.vpcf", PATTACH_POINT_FOLLOW, caster, {[1] = Vector(radius, 1, 1)})
		
		self.state = "dead"
	end
	caster:EmitSound("Hero_NagaSiren.Riptide.Cast")
	if caster:HasTalent("special_bonus_unique_naga_siren_tidal_waves_1") then
		self.cooldownTracker = self.cooldownTracker or {}
		local cd = self.cooldownTracker[self.state]
		if cd and cd > GameRules:GetGameTime() then
			self:StartCooldown( cd - GameRules:GetGameTime() )
		end
	end
end

modifier_naga_siren_tidal_waves_dead_tide = class({})
LinkLuaModifier("modifier_naga_siren_tidal_waves_dead_tide", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)
modifier_naga_siren_tidal_waves_spring_tide = class({})
LinkLuaModifier("modifier_naga_siren_tidal_waves_spring_tide", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)
modifier_naga_siren_tidal_waves_rip_tide = class({})
LinkLuaModifier("modifier_naga_siren_tidal_waves_rip_tide", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)

modifier_naga_siren_tidal_waves_dead_tide_debuff = class({})
LinkLuaModifier("modifier_naga_siren_tidal_waves_dead_tide_debuff", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_tidal_waves_dead_tide_debuff:OnCreated()
	self.loss = self:GetTalentSpecialValueFor("damage_reduction")
end

function modifier_naga_siren_tidal_waves_dead_tide_debuff:OnRefresh()
	self.loss = self:GetTalentSpecialValueFor("damage_reduction")
end

function modifier_naga_siren_tidal_waves_dead_tide_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_naga_siren_tidal_waves_dead_tide_debuff:GetModifierBaseDamageOutgoing_Percentage()
	return self.loss
end

function modifier_naga_siren_tidal_waves_dead_tide_debuff:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_riptide_debuff.vpcf"
end

modifier_naga_siren_tidal_waves_spring_tide_debuff = class({})
LinkLuaModifier("modifier_naga_siren_tidal_waves_spring_tide_debuff", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_tidal_waves_spring_tide_debuff:OnCreated()
	self.loss = self:GetTalentSpecialValueFor("mr_reduction")
end

function modifier_naga_siren_tidal_waves_spring_tide_debuff:OnRefresh()
	self.loss = self:GetTalentSpecialValueFor("mr_reduction")
end

function modifier_naga_siren_tidal_waves_spring_tide_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_naga_siren_tidal_waves_spring_tide_debuff:GetModifierMagicalResistanceBonus()
	return self.loss
end

function modifier_naga_siren_tidal_waves_spring_tide_debuff:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_riptide_debuff.vpcf"
end

modifier_naga_siren_tidal_waves_rip_tide_debuff = class({})
LinkLuaModifier("modifier_naga_siren_tidal_waves_rip_tide_debuff", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_tidal_waves_rip_tide_debuff:OnCreated()
	self.loss = self:GetTalentSpecialValueFor("armor_reduction")
end

function modifier_naga_siren_tidal_waves_rip_tide_debuff:OnRefresh()
	self.loss = self:GetTalentSpecialValueFor("armor_reduction")
end

function modifier_naga_siren_tidal_waves_rip_tide_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_naga_siren_tidal_waves_rip_tide_debuff:GetModifierPhysicalArmorBonus()
	return self.loss
end

function modifier_naga_siren_tidal_waves_rip_tide_debuff:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_riptide_debuff.vpcf"
end