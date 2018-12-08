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
	
	if caster.liquidIllusions then
		for _, illusion in ipairs( caster.liquidIllusions ) do
			if not illusion:IsNull() and illusion:IsAlive() then
				self:FireTidal( illusion )
			end
		end
	end
	self:FireTidal( caster )
	
	if caster:HasTalent("special_bonus_unique_naga_siren_tidal_waves_1") then
		self.cooldownTracker = self.cooldownTracker or {}
		local cd = self.cooldownTracker[self.state]
		if cd and cd > GameRules:GetGameTime() then
			self:StartCooldown( cd - GameRules:GetGameTime() )
		end
	end
end

function naga_siren_tidal_waves:FireTidal( origin, fProcValue )
	local caster = self:GetCaster()
	local ability = self
	
	local radius = ability:GetTalentSpecialValueFor("radius")
	local duration = ability:GetTalentSpecialValueFor("duration") * (fProcValue or 100) / 100
	local damage = ability:GetAbilityDamage() * (fProcValue or 100) / 100
	
	local hitUnits = {}
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( origin:GetAbsOrigin(), radius ) ) do
		if not hitUnits[enemy] then
			ability:DealDamage(caster, enemy, damage)
			if ability.state == "rip" then
				enemy:AddNewModifier(caster, ability, "modifier_naga_siren_tidal_waves_rip_tide_debuff", {duration = duration})
			elseif ability.state == "dead" then
				enemy:AddNewModifier(caster, ability, "modifier_naga_siren_tidal_waves_dead_tide_debuff", {duration = duration})
			elseif ability.state == "spring" then
				enemy:AddNewModifier(caster, ability, "modifier_naga_siren_tidal_waves_spring_tide_debuff", {duration = duration})
			end
			hitUnits[enemy] = true
		end
	end
	
	if ability.state == "dead" then
		if caster:IsRealHero() and not fProcValue then
			caster:RemoveModifierByName("modifier_naga_siren_tidal_waves_dead_tide")
			caster:AddNewModifier(caster, ability, "modifier_naga_siren_tidal_waves_spring_tide", {})
			ability.state = "spring"
		end
		ParticleManager:FireParticle("particles/naga_siren_deadtide.vpcf", PATTACH_POINT_FOLLOW, origin, {[1] = Vector(radius, 1, 1)})
	elseif ability.state == "spring" then
		if caster == origin and not fProcValue then
			caster:RemoveModifierByName("modifier_naga_siren_tidal_waves_spring_tide")
			caster:AddNewModifier(caster, ability, "modifier_naga_siren_tidal_waves_rip_tide", {})
			ability.state = "rip"
		end
		ParticleManager:FireParticle("particles/naga_siren_springtide.vpcf", PATTACH_POINT_FOLLOW, origin, {[1] = Vector(radius, 1, 1)})
	elseif ability.state == "rip" then
		if caster == origin and not fProcValue then
			caster:RemoveModifierByName("modifier_naga_siren_tidal_waves_rip_tide")
			caster:AddNewModifier(caster, ability, "modifier_naga_siren_tidal_waves_dead_tide", {})
			ability.state = "dead"
		end
		ParticleManager:FireParticle("particles/units/heroes/hero_siren/naga_siren_riptide.vpcf", PATTACH_POINT_FOLLOW, origin, {[1] = Vector(radius, 1, 1)})
	end
	
	origin:EmitSound("Hero_NagaSiren.Riptide.Cast")
	origin:StartGesture(ACT_DOTA_CAST_ABILITY_3)
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