sven_gods_strength_bh = class({})

function sven_gods_strength_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_sven_gods_strength_bonus_strength", {duration = duration})
	caster:AddNewModifier(caster, self, "modifier_sven_gods_strength_bonus_damage", {duration = duration})
	ParticleManager:FireParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	if caster:HasTalent("special_bonus_unique_sven_gods_strength_2") then
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius_scepter") ) ) do
			ally:AddNewModifier(caster, self, "modifier_sven_gods_strength_bonus_strength", {duration = duration})
			ParticleManager:FireParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
		end
	end
	caster:EmitSound("Hero_Sven.GodsStrength")
end


modifier_sven_gods_strength_bonus_damage = class({})
LinkLuaModifier("modifier_sven_gods_strength_bonus_damage", "heroes/hero_sven/sven_gods_strength_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_sven_gods_strength_bonus_damage:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius_scepter")
	self.damage = self:GetTalentSpecialValueFor("gods_strength_damage")
	if IsServer() then
		local gFX = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength_ambient.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(gFX, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(gFX)
		ParticleManager:ReleaseParticleIndex(gFX)
	end
end

function modifier_sven_gods_strength_bonus_damage:IsAura()
	return self:GetCaster():HasScepter()
end

function modifier_sven_gods_strength_bonus_damage:GetModifierAura()
	return "modifier_sven_gods_strength_bonus_damage_ally"
end

function modifier_sven_gods_strength_bonus_damage:GetAuraRadius()
	return self.radius
end

function modifier_sven_gods_strength_bonus_damage:GetAuraEntityReject(entity)
	if entity == self:GetParent() then 
		return true
	else
		return not self:GetCaster():HasScepter()
	end
end

function modifier_sven_gods_strength_bonus_damage:GetAuraDuration()
	return 0.5
end

function modifier_sven_gods_strength_bonus_damage:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_sven_gods_strength_bonus_damage:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_HERO
end

function modifier_sven_gods_strength_bonus_damage:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_sven_gods_strength_bonus_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_sven_gods_strength_bonus_damage:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage
end

modifier_sven_gods_strength_bonus_damage_ally = class({})
LinkLuaModifier("modifier_sven_gods_strength_bonus_damage_ally", "heroes/hero_sven/sven_gods_strength_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_sven_gods_strength_bonus_damage_ally:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius_scepter")
	self.damage = self:GetTalentSpecialValueFor("gods_strength_damage_scepter")
	if IsServer() then
		local gFX = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength_ambient.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(gFX, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(gFX)
		ParticleManager:ReleaseParticleIndex(gFX)
	end
end

function modifier_sven_gods_strength_bonus_damage_ally:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_sven_gods_strength_bonus_damage_ally:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage
end

modifier_sven_gods_strength_bonus_strength = class({})
LinkLuaModifier("modifier_sven_gods_strength_bonus_strength", "heroes/hero_sven/sven_gods_strength_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_sven_gods_strength_bonus_strength:OnCreated()
	self.str = self:GetTalentSpecialValueFor("gods_strength_bonus_str")
	if IsServer() then
		self:GetCaster():CalculateStatBonus()
		if self:GetCaster():HasTalent("special_bonus_unique_sven_gods_strength_1") then
			self.bonusStr = self:GetCaster():FindTalentValue("special_bonus_unique_sven_gods_strength_1")
			self:StartIntervalThink(0.5)
		end
	end
end
	
function modifier_sven_gods_strength_bonus_strength:OnRefresh()
	self.str = self:GetTalentSpecialValueFor("gods_strength_bonus_str")
	if IsServer() then
		self:GetCaster():CalculateStatBonus()
	end
end

function modifier_sven_gods_strength_bonus_strength:OnIntervalThink()
	self.str = self.str +  	aself.bonusStr * 0.5
	self:GetCaster():CalculateStatBonus()
end

function modifier_sven_gods_strength_bonus_strength:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_sven_gods_strength_bonus_strength:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_sven_gods_strength_bonus_strength:GetStatusEffectName()
	return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function modifier_sven_gods_strength_bonus_strength:StatusEffectPriority()
	return 25
end

function modifier_sven_gods_strength_bonus_strength:GetHeroEffectName()
	return "particles/units/heroes/hero_sven/sven_gods_strength_hero_effect.vpcf"
end

function modifier_sven_gods_strength_bonus_strength:HeroEffectPriority()
	return 25
end

function modifier_sven_gods_strength_bonus_strength:IsHidden()
	return self:GetParent():HasModifier("modifier_sven_gods_strength_bonus_damage") or self:GetParent():HasModifier("modifier_sven_gods_strength_bonus_damage_ally")
end