guardian_punish = class({})

function guardian_punish:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster, self, "modifier_guardian_punish_debuff", {duration = self:GetTalentSpecialValueFor("debuff_duration")})
	self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"))
	
	EmitSoundOn("Hero_Sven.StormBoltImpact", target)
	ParticleManager:FireParticle("particles/heroes/guardian/guardian_punish.vpcf", PATTACH_POINT_FOLLOW, target)
	
	if caster:HasTalent("guardian_punish_talent_1") then
		caster:AddBarrier( caster:GetMaxHealth() * caster:FindTalentValue("guardian_punish_talent_1") / 100)
	end
end


modifier_guardian_punish_debuff = class({})
LinkLuaModifier("modifier_guardian_punish_debuff", "heroes/guardian/guardian_punish.lua", 0)

function modifier_guardian_punish_debuff:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("armor_reduction")
	self.magic = self:GetAbility():GetSpecialValueFor("magic_reduction")
	self.stun = self:GetAbility():GetSpecialValueFor("stun_reduction")
	self.debuff = self:GetAbility():GetSpecialValueFor("debuff_duration")
end

function modifier_guardian_punish_debuff:OnRefresh()
	self.armor = self:GetAbility():GetSpecialValueFor("armor_reduction")
	self.magic = self:GetAbility():GetSpecialValueFor("magic_reduction")
	self.stun = self:GetAbility():GetSpecialValueFor("stun_reduction")
	self.debuff = self:GetAbility():GetSpecialValueFor("debuff_duration")
end

function modifier_guardian_punish_debuff:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
	return funcs
end

function modifier_guardian_punish_debuff:GetModifierMagicalResistanceBonus()
	return self.magic
end

function modifier_guardian_punish_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_guardian_punish_debuff:GetModifierBonusStunResistance_Constant()
	return self.stun
end

function modifier_guardian_punish_debuff:BonusDebuffDuration_Constant()
	return self.debuff
end