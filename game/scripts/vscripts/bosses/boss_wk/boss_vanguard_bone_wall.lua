boss_vanguard_bone_wall = class({})

function boss_vanguard_bone_wall:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_boss_vanguard_bone_wall", {duration = self:GetSpecialValueFor("duration")})
end

modifier_boss_vanguard_bone_wall = class({})
LinkLuaModifier("modifier_boss_vanguard_bone_wall", "bosses/boss_wk/boss_vanguard_bone_wall", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_vanguard_bone_wall:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_vanguard_bone_wall:GetModifierIncomingDamage_Percentage()
	return self:GetSpecialValueFor("damage_red")
end

function modifier_boss_vanguard_bone_wall:GetModifierMoveSpeedBonus_Percentage()
	return self:GetSpecialValueFor("slow")
end

function modifier_boss_vanguard_bone_wall:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_willow_wisp_fear.vpcf"
end

function modifier_boss_vanguard_bone_wall:StatusEffectPriority()
	return 15
end