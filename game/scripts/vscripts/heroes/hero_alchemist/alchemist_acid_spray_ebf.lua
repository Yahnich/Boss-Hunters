alchemist_acid_spray_ebf = class({})

function alchemist_acid_spray_ebf:IsStealable()
	return true
end

function alchemist_acid_spray_ebf:IsHiddenWhenStolen()
	return false
end

function alchemist_acid_spray_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local targetPos = self:GetCursorPosition()

	if target and target == caster then
		caster:AddNewModifier(caster, self, "modifier_alchemist_acid_spray_ebf_thinker", {duration = self:GetTalentSpecialValueFor("duration")})
	else
		CreateModifierThinker(caster, self, "modifier_alchemist_acid_spray_ebf_thinker", {duration = self:GetTalentSpecialValueFor("duration")}, targetPos, caster:GetTeamNumber(), false)
	end
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_alchemist/alchemist_acid_spray_cast.vpcf", PATTACH_POINT_FOLLOW, caster, target or targetPos, {[15] = Vector(56, 128, 56)})
end

modifier_alchemist_acid_spray_ebf_thinker = class({})
LinkLuaModifier("modifier_alchemist_acid_spray_ebf_thinker", "heroes/hero_alchemist/alchemist_acid_spray_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_alchemist_acid_spray_ebf_thinker:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
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

function modifier_alchemist_acid_spray_ebf_thinker:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_Alchemist.AcidSpray", self:GetParent())
	end
end

function modifier_alchemist_acid_spray_ebf_thinker:IsAura()
	return true
end

function modifier_alchemist_acid_spray_ebf_thinker:GetModifierAura()
	return "modifier_alchemist_acid_spray_ebf_debuff"
end

function modifier_alchemist_acid_spray_ebf_thinker:GetAuraRadius()
	return self.radius
end

function modifier_alchemist_acid_spray_ebf_thinker:GetAuraDuration()
	return 0.5
end

function modifier_alchemist_acid_spray_ebf_thinker:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_alchemist_acid_spray_ebf_thinker:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_alchemist_acid_spray_ebf_thinker:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end


modifier_alchemist_acid_spray_ebf_debuff = class({})
LinkLuaModifier("modifier_alchemist_acid_spray_ebf_debuff", "heroes/hero_alchemist/alchemist_acid_spray_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_alchemist_acid_spray_ebf_debuff:IsDebuff()
	return true
end

function modifier_alchemist_acid_spray_ebf_debuff:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("armor_reduction") * (-1)
	self.damage = self:GetTalentSpecialValueFor("damage")
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_alchemist_acid_spray_ebf_debuff:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("armor_reduction")
	self.damage = self:GetTalentSpecialValueFor("damage")
end

function modifier_alchemist_acid_spray_ebf_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage)
end

function modifier_alchemist_acid_spray_ebf_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_alchemist_acid_spray_ebf_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end