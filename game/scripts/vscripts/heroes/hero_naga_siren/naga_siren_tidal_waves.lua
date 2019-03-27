naga_siren_tidal_waves = class({})

function naga_siren_tidal_waves:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function naga_siren_tidal_waves:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_naga_siren_tidal_waves_1", "cd")
end

function naga_siren_tidal_waves:OnSpellStart()
	local caster = self:GetCaster()
	
	self.hitUnits = {}
	local illusions = caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 )
	for _, illusion in ipairs( illusions ) do
		if illusion:IsIllusion() and illusion:GetParentUnit() == caster then
			self:FireTidal( illusion )
		end
	end
	
	self:FireTidal( caster )
	self.hitUnits = {}
end

function naga_siren_tidal_waves:FireTidal( origin, fProcValue )
	local caster = self:GetCaster()
	local ability = self
	
	local radius = ability:GetTalentSpecialValueFor("radius")
	local duration = ability:GetTalentSpecialValueFor("duration") * (fProcValue or 100) / 100
	local damage = ability:GetAbilityDamage() * (fProcValue or 100) / 100
	
	
	if fProcValue then
		self.hitUnits = {}
	end
	if caster:HasTalent("special_bonus_unique_naga_siren_tidal_waves_2") then
		local modifierName = "modifier_naga_siren_tidal_waves_rip_tide_buff"
		if fProcValue then
			modifierName = "modifier_naga_siren_tidal_waves_rip_tide_buff_weak"
		end
		origin:AddNewModifier(caster, ability, modifierName, {duration = duration})
	end
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( origin:GetAbsOrigin(), radius ) ) do
		if not self.hitUnits[enemy] then
			ability:DealDamage(caster, enemy, damage)
			enemy:AddNewModifier(caster, ability, "modifier_naga_siren_tidal_waves_rip_tide_debuff", {duration = duration})
			self.hitUnits[enemy] = true
		end
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_siren/naga_siren_riptide.vpcf", PATTACH_POINT_FOLLOW, origin, {[1] = Vector(radius * 1.25, 1, 1)})
	
	origin:EmitSound("Hero_NagaSiren.Riptide.Cast")
	origin:StartGesture(ACT_DOTA_CAST_ABILITY_3)
end

-- modifier_naga_siren_tidal_waves_dead_tide = class({})
-- LinkLuaModifier("modifier_naga_siren_tidal_waves_dead_tide", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)
-- modifier_naga_siren_tidal_waves_spring_tide = class({})
-- LinkLuaModifier("modifier_naga_siren_tidal_waves_spring_tide", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)
-- modifier_naga_siren_tidal_waves_rip_tide = class({})
-- LinkLuaModifier("modifier_naga_siren_tidal_waves_rip_tide", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)

-- modifier_naga_siren_tidal_waves_dead_tide_debuff = class({})
-- LinkLuaModifier("modifier_naga_siren_tidal_waves_dead_tide_debuff", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)

-- function modifier_naga_siren_tidal_waves_dead_tide_debuff:OnCreated()
	-- self.loss = self:GetTalentSpecialValueFor("damage_reduction")
-- end

-- function modifier_naga_siren_tidal_waves_dead_tide_debuff:OnRefresh()
	-- self.loss = self:GetTalentSpecialValueFor("damage_reduction")
-- end

-- function modifier_naga_siren_tidal_waves_dead_tide_debuff:DeclareFunctions()
	-- return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
-- end

-- function modifier_naga_siren_tidal_waves_dead_tide_debuff:GetModifierBaseDamageOutgoing_Percentage()
	-- return self.loss
-- end

-- function modifier_naga_siren_tidal_waves_dead_tide_debuff:GetEffectName()
	-- return "particles/units/heroes/hero_siren/naga_siren_riptide_debuff.vpcf"
-- end

-- modifier_naga_siren_tidal_waves_spring_tide_debuff = class({})
-- LinkLuaModifier("modifier_naga_siren_tidal_waves_spring_tide_debuff", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)

-- function modifier_naga_siren_tidal_waves_spring_tide_debuff:OnCreated()
	-- self.loss = self:GetTalentSpecialValueFor("mr_reduction")
-- end

-- function modifier_naga_siren_tidal_waves_spring_tide_debuff:OnRefresh()
	-- self.loss = self:GetTalentSpecialValueFor("mr_reduction")
-- end

-- function modifier_naga_siren_tidal_waves_spring_tide_debuff:DeclareFunctions()
	-- return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
-- end

-- function modifier_naga_siren_tidal_waves_spring_tide_debuff:GetModifierMagicalResistanceBonus()
	-- return self.loss
-- end

-- function modifier_naga_siren_tidal_waves_spring_tide_debuff:GetEffectName()
	-- return "particles/units/heroes/hero_siren/naga_siren_riptide_debuff.vpcf"
-- end

modifier_naga_siren_tidal_waves_rip_tide_buff = class({})
LinkLuaModifier("modifier_naga_siren_tidal_waves_rip_tide_buff", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_tidal_waves_rip_tide_buff:OnCreated()
	self.loss = -self:GetTalentSpecialValueFor("armor_reduction")
end

function modifier_naga_siren_tidal_waves_rip_tide_buff:OnRefresh()
	self.loss = -self:GetTalentSpecialValueFor("armor_reduction")
end

function modifier_naga_siren_tidal_waves_rip_tide_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_naga_siren_tidal_waves_rip_tide_buff:GetModifierPhysicalArmorBonus()
	return self.loss
end

function modifier_naga_siren_tidal_waves_rip_tide_buff:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_riptide_debuff.vpcf"
end

modifier_naga_siren_tidal_waves_rip_tide_buff_weak = class({})
LinkLuaModifier("modifier_naga_siren_tidal_waves_rip_tide_buff_weak", "heroes/hero_naga_siren/naga_siren_tidal_waves", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_tidal_waves_rip_tide_buff_weak:OnCreated()
	self.loss = self:GetTalentSpecialValueFor("armor_reduction") / (-2)
end

function modifier_naga_siren_tidal_waves_rip_tide_buff_weak:OnRefresh()
	self.loss = self:GetTalentSpecialValueFor("armor_reduction") / (-2)
end

function modifier_naga_siren_tidal_waves_rip_tide_buff_weak:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_naga_siren_tidal_waves_rip_tide_buff_weak:GetModifierPhysicalArmorBonus()
	if not self:GetParent():HasModifier("modifier_naga_siren_tidal_waves_rip_tide_buff") then return self.loss end
end

function modifier_naga_siren_tidal_waves_rip_tide_buff_weak:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_riptide_debuff.vpcf"
end

function modifier_naga_siren_tidal_waves_rip_tide_buff_weak:IsHidden()
	return self:GetParent():HasModifier("modifier_naga_siren_tidal_waves_rip_tide_buff")
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