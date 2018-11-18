morph_agi_morph = class({})
LinkLuaModifier( "modifier_morph_agi_morph", "heroes/hero_morphling/morph_agi_morph.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_morph_agi_bonus", "heroes/hero_morphling/morph_agi_morph.lua" ,LUA_MODIFIER_MOTION_NONE )

function morph_agi_morph:IsStealable()
    return false
end

function morph_agi_morph:IsHiddenWhenStolen()
    return false
end

function morph_agi_morph:IsHiddenWhenStolen()
    return false
end

function morph_agi_morph:GetIntrinsicModifierName()
    return "modifier_morph_agi_bonus"
end

function morph_agi_morph:OnToggle()
	local caster = self:GetCaster()
	
	if self:GetToggleState() then
		StopSoundOn("Hero_Morphling.MorphAgility", caster)
		caster:AddNewModifier(caster, self, "modifier_morph_agi_morph", {})
	else
		EmitSoundOn("Hero_Morphling.MorphAgility", caster)
		caster:RemoveModifierByName("modifier_morph_agi_morph")
	end
end

modifier_morph_agi_morph = class({})
function modifier_morph_agi_morph:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_morphling/morphling_morph_agi.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)

		self:AttachEffect(nfx)

		self.casterAgi = caster:GetBaseAgility()
		self.casterStr = caster:GetBaseStrength()

		self.bonusAgi = self:GetTalentSpecialValueFor("morph_rate")
		self.negativeStr = self:GetTalentSpecialValueFor("morph_rate")
		
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_morph_agi_morph:OnIntervalThink()
	local caster = self:GetCaster()
	if self:GetAbility():GetToggleState() then
		if caster:GetBaseStrength() >= (10 + self.negativeStr) then
			caster:SetBaseAgility(caster:GetBaseAgility() + self.bonusAgi)
			caster:SetBaseStrength(caster:GetBaseStrength() - self.negativeStr)
		end
	end

	if caster:GetBaseAgility() > caster:GetBaseStrength() and (caster:GetPrimaryAttribute() ~= DOTA_ATTRIBUTE_AGILITY) then
		caster:SetPrimaryAttribute(DOTA_ATTRIBUTE_AGILITY)
	end

	caster:CalculateStatBonus()
end

modifier_morph_agi_bonus = class({})
function modifier_morph_agi_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_morph_agi_bonus:GetModifierBonusStats_Agility()
	return self:GetTalentSpecialValueFor("bonus_agi") * self:GetCaster():GetLevel()
end

function modifier_morph_agi_bonus:IsHidden()
	return true
end