alchemist_acid_bomb = class({})

function alchemist_acid_bomb:IsStealable()
	return true
end

function alchemist_acid_bomb:IsHiddenWhenStolen()
	return false
end

function alchemist_acid_bomb:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function alchemist_acid_bomb:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local targetPos = self:GetCursorPosition()

	if target and target == caster then
		caster:AddNewModifier(caster, self, "modifier_alchemist_acid_bomb_thinker", {duration = self:GetSpecialValueFor("duration")})
	else
		CreateModifierThinker(caster, self, "modifier_alchemist_acid_bomb_thinker", {duration = self:GetSpecialValueFor("duration")}, targetPos, caster:GetTeamNumber(), false)
	end
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_alchemist/alchemist_acid_bomb_cast.vpcf", PATTACH_POINT_FOLLOW, caster, target or targetPos, {[15] = Vector(56, 128, 56)})
end

modifier_alchemist_acid_bomb_thinker = class({})
LinkLuaModifier("modifier_alchemist_acid_bomb_thinker", "heroes/hero_alchemist/alchemist_acid_bomb", LUA_MODIFIER_MOTION_NONE)

function modifier_alchemist_acid_bomb_thinker:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.linger = self:GetSpecialValueFor("aura_linger")
	if IsServer() then
		EmitSoundOn("Hero_Alchemist.AcidSpray", self:GetParent())
		nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_alchemist/alchemist_acid_bomb.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(nFX, 0, (Vector(0, 0, 0)))
		ParticleManager:SetParticleControl(nFX, 1, (Vector(self.radius, 1, 1)))
		ParticleManager:SetParticleControl(nFX, 15, (Vector(25, 150, 25)))
		ParticleManager:SetParticleControl(nFX, 16, (Vector(0, 0, 0)))
		self:AddEffect(nFX)
	end
end

function modifier_alchemist_acid_bomb_thinker:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_Alchemist.AcidSpray", self:GetParent())
	end
end

function modifier_alchemist_acid_bomb_thinker:IsAura()
	return true
end

function modifier_alchemist_acid_bomb_thinker:GetModifierAura()
	return "modifier_alchemist_acid_bomb_debuff"
end

function modifier_alchemist_acid_bomb_thinker:GetAuraRadius()
	return self.radius
end

function modifier_alchemist_acid_bomb_thinker:GetAuraDuration()
	return self.linger
end

function modifier_alchemist_acid_bomb_thinker:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_alchemist_acid_bomb_thinker:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_alchemist_acid_bomb_thinker:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end


modifier_alchemist_acid_bomb_debuff = class({})
LinkLuaModifier("modifier_alchemist_acid_bomb_debuff", "heroes/hero_alchemist/alchemist_acid_bomb", LUA_MODIFIER_MOTION_NONE)

function modifier_alchemist_acid_bomb_debuff:IsDebuff()
	return true
end

function modifier_alchemist_acid_bomb_debuff:OnCreated()
	self.armor = self:GetSpecialValueFor("armor_reduction")
	self.damage = self:GetSpecialValueFor("damage")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_alchemist_acid_bomb_1")
	self.talent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_alchemist_acid_bomb_1")
	self:StartIntervalThink(1)
end

function modifier_alchemist_acid_bomb_debuff:OnRefresh()
	self.armor = self:GetSpecialValueFor("armor_reduction")
	self.damage = self:GetSpecialValueFor("damage")
end

function modifier_alchemist_acid_bomb_debuff:OnIntervalThink()
	if IsServer() then 
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage)
	end
	if self.talent1 then
		self.armor = self.armor + self.talent1Val
	end
end

function modifier_alchemist_acid_bomb_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_alchemist_acid_bomb_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_alchemist_acid_bomb_debuff:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_acid_bomb_debuff.vpcf"
end