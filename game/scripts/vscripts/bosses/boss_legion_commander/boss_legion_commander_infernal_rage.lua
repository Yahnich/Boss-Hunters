boss_legion_commander_infernal_rage = class({})

function boss_legion_commander_infernal_rage:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_boss_legion_commander_infernal_rage", {duration = self:GetSpecialValueFor("duration")} )
	caster:EmitSound("Hero_LegionCommander.Duel.Cast.Arcana")
	ParticleManager:FireParticle( "particles/units/heroes/hero_legion_commander/legion_duel.vpcf", PATTACH_POINT_FOLLOW, caster )
	ParticleManager:FireParticle( "particles/units/heroes/hero_legion_commander/legion_commander_duel_body.vpcf", PATTACH_POINT_FOLLOW, caster )
end

modifier_boss_legion_commander_infernal_rage = class({})
LinkLuaModifier( "modifier_boss_legion_commander_infernal_rage", "bosses/boss_legion_commander/boss_legion_commander_infernal_rage", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_legion_commander_infernal_rage:OnCreated()
	self.red = self:GetSpecialValueFor("dmg_reduction")
	self.ms = self:GetSpecialValueFor("bonus_ms")
	self.amp = self:GetSpecialValueFor("bonus_dmg")
end

function modifier_boss_legion_commander_infernal_rage:OnRefresh()
	self:OnCreated()
end

function modifier_boss_legion_commander_infernal_rage:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_boss_legion_commander_infernal_rage:GetModifierIncomingDamage_Percentage()
	return self.red
end

function modifier_boss_legion_commander_infernal_rage:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_boss_legion_commander_infernal_rage:GetModifierBaseDamageOutgoing_Percentage()
	return self.amp
end

function modifier_boss_legion_commander_infernal_rage:GetEffectName()
	return "particles/units/heroes/hero_legion_commander/legion_commander_duel_buff.vpcf"
end

function modifier_boss_legion_commander_infernal_rage:GetStatusEffectName()
	return "particles/status_fx/status_effect_legion_commander_duel.vpcf"
end

function modifier_boss_legion_commander_infernal_rage:StatusEffectPriority()
	return 10
end