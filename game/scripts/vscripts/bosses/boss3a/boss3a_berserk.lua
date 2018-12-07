boss3a_berserk = class({})

function boss3a_berserk:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle(self:GetCaster())
	EmitSoundOn("DOTA_Item.Armlet.Activate", self:GetCaster())
	EmitSoundOn("DOTA_Item.Armlet.DeActivate", self:GetCaster())
	return true
end

function boss3a_berserk:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_boss3a_berserk", {duration = self:GetSpecialValueFor("duration")})
end

modifier_boss3a_berserk = class({})
LinkLuaModifier("modifier_boss3a_berserk", "bosses/boss3a/boss3a_berserk.lua", 0)

function modifier_boss3a_berserk:OnCreated()
	self.ms = self:GetSpecialValueFor("bonus_movement_speed")
	self.as = self:GetSpecialValueFor("bonus_attack_speed")
end

function modifier_boss3a_berserk:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, }
end

function modifier_boss3a_berserk:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_boss3a_berserk:GetModifierMoveSpeedBonus_Constant()
	return self.ms
end

function modifier_boss3a_berserk:GetEffectName()
	return "particles/items2_fx/mask_of_madness.vpcf"
end