morph_str_morph = class({})
LinkLuaModifier( "modifier_morph_str_morph", "heroes/hero_morphling/morph_str_morph.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_morph_str_bonus", "heroes/hero_morphling/morph_str_morph.lua" ,LUA_MODIFIER_MOTION_NONE )

function morph_str_morph:IsStealable()
    return false
end

function morph_str_morph:IsHiddenWhenStolen()
    return false
end

function morph_str_morph:GetIntrinsicModifierName()
    return "modifier_morph_str_bonus"
end

function morph_str_morph:OnToggle()
	local caster = self:GetCaster()
	
	if self:GetToggleState() then
		StopSoundOn("Hero_Morphling.MorphStrengh", caster)
		caster:AddNewModifier(caster, self, "modifier_morph_str_morph", {})
	else
		EmitSoundOn("Hero_Morphling.MorphStrengh", caster)
		caster:RemoveModifierByName("modifier_morph_str_morph")
	end
end

modifier_morph_str_morph = class({})
function modifier_morph_str_morph:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_morphling/morphling_morph_str.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)

		self:AttachEffect(nfx)

		self.casterAgi = caster:GetBaseAgility()
		self.casterStr = caster:GetBaseStrength()

		self.bonusAgi = self:GetTalentSpecialValueFor("morph_rate")
		self.negativeStr = self:GetTalentSpecialValueFor("morph_rate")
		
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_morph_str_morph:OnIntervalThink()
	local caster = self:GetCaster()
	if self:GetAbility():GetToggleState() then
		if caster:GetBaseAgility() >= (10 + self.bonusAgi) then
			caster:SetBaseAgility(caster:GetBaseAgility() - self.bonusAgi)
			caster:SetBaseStrength(caster:GetBaseStrength() + self.negativeStr)
		end
	end

	if caster:GetBaseAgility() < caster:GetBaseStrength() and (caster:GetPrimaryAttribute() ~= DOTA_ATTRIBUTE_STRENGTH) then
		caster:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
	end

	caster:CalculateStatBonus()
end

modifier_morph_str_bonus = class({})
function modifier_morph_str_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_morph_str_bonus:GetModifierBonusStats_Strength()
	return self:GetTalentSpecialValueFor("bonus_str") * self:GetCaster():GetLevel()
end

function modifier_morph_str_bonus:IsHidden()
	return true
end