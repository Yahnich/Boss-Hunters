sniper_take_aim_bh = class({})
LinkLuaModifier( "modifier_sniper_take_aim_bh","heroes/hero_sniper/sniper_take_aim_bh.lua",LUA_MODIFIER_MOTION_NONE )

function sniper_take_aim_bh:GetIntrinsicModifierName()
	return "modifier_sniper_take_aim_bh"
end

modifier_sniper_take_aim_bh = class({})
function modifier_sniper_take_aim_bh:OnCreated(table)
	self:StartIntervalThink(FrameTime())
end

function modifier_sniper_take_aim_bh:OnIntervalThink()
	self.range = self:GetTalentSpecialValueFor("range_per_lvl") * self:GetCaster():GetLevel()
	self.damage = self:GetCaster():GetAttackRange() * self:GetTalentSpecialValueFor("range_damage")/100
end

function modifier_sniper_take_aim_bh:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function modifier_sniper_take_aim_bh:GetModifierAttackRangeBonus()
	return self.range
end

function modifier_sniper_take_aim_bh:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_sniper_take_aim_bh:IsPurgeException()
	return false
end

function modifier_sniper_take_aim_bh:IsPurgable()
	return false
end

function modifier_sniper_take_aim_bh:IsHidden()
	return true
end