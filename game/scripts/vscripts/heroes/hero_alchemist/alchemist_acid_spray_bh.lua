alchemist_acid_spray_bh = class({})

function alchemist_acid_spray_bh:IsStealable()
	return true
end

function alchemist_acid_spray_bh:IsHiddenWhenStolen()
	return false
end

function alchemist_acid_spray_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function alchemist_acid_spray_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local targetPos = self:GetCursorPosition()

	if target and target == caster then
		caster:AddNewModifier(caster, self, "modifier_alchemist_acid_spray_bh_thinker", {duration = self:GetTalentSpecialValueFor("duration")})
	else
		CreateModifierThinker(caster, self, "modifier_alchemist_acid_spray_bh_thinker", {duration = self:GetTalentSpecialValueFor("duration")}, targetPos, caster:GetTeamNumber(), false)
	end
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_alchemist/alchemist_acid_spray_cast.vpcf", PATTACH_POINT_FOLLOW, caster, target or targetPos, {[15] = Vector(56, 128, 56)})
end

modifier_alchemist_acid_spray_bh_thinker = class({})
LinkLuaModifier("modifier_alchemist_acid_spray_bh_thinker", "heroes/hero_alchemist/alchemist_acid_spray_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_alchemist_acid_spray_bh_thinker:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.linger = self:GetTalentSpecialValueFor("aura_linger")
	if IsServer() then
		EmitSoundOn("Hero_Alchemist.AcidSpray", self:GetParent())
		nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(nFX, 0, (Vector(0, 0, 0)))
		ParticleManager:SetParticleControl(nFX, 1, (Vector(self.radius, 1, 1)))
		ParticleManager:SetParticleControl(nFX, 15, (Vector(25, 150, 25)))
		ParticleManager:SetParticleControl(nFX, 16, (Vector(0, 0, 0)))
		self:AddEffect(nFX)
	end
end

function modifier_alchemist_acid_spray_bh_thinker:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_Alchemist.AcidSpray", self:GetParent())
	end
end

function modifier_alchemist_acid_spray_bh_thinker:IsAura()
	return true
end

function modifier_alchemist_acid_spray_bh_thinker:GetModifierAura()
	return "modifier_alchemist_acid_spray_bh_debuff"
end

function modifier_alchemist_acid_spray_bh_thinker:GetAuraRadius()
	return self.radius
end

function modifier_alchemist_acid_spray_bh_thinker:GetAuraDuration()
	return self.linger
end

function modifier_alchemist_acid_spray_bh_thinker:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_alchemist_acid_spray_bh_thinker:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_alchemist_acid_spray_bh_thinker:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end


modifier_alchemist_acid_spray_bh_debuff = class({})
LinkLuaModifier("modifier_alchemist_acid_spray_bh_debuff", "heroes/hero_alchemist/alchemist_acid_spray_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_alchemist_acid_spray_bh_debuff:IsDebuff()
	return true
end

function modifier_alchemist_acid_spray_bh_debuff:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("armor_reduction")
	self.damage = self:GetTalentSpecialValueFor("damage")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_alchemist_acid_spray_1")
	self.talent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_alchemist_acid_spray_1")
	self:StartIntervalThink(1)
end

function modifier_alchemist_acid_spray_bh_debuff:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("armor_reduction")
	self.damage = self:GetTalentSpecialValueFor("damage")
end

function modifier_alchemist_acid_spray_bh_debuff:OnIntervalThink()
	if IsServer() then 
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage)
	end
	if self.talent1 then
		self.armor = self.armor + self.talent1Val
	end
end

function modifier_alchemist_acid_spray_bh_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_alchemist_acid_spray_bh_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_alchemist_acid_spray_bh_debuff:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_acid_spray_debuff.vpcf"
end