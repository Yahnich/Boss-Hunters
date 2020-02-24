sniper_take_aim_bh = class({})
LinkLuaModifier( "modifier_sniper_take_aim_bh","heroes/hero_sniper/sniper_take_aim_bh.lua",LUA_MODIFIER_MOTION_NONE )

function sniper_take_aim_bh:GetIntrinsicModifierName()
	return "modifier_sniper_take_aim_bh"
end

modifier_sniper_take_aim_bh = class({})
function modifier_sniper_take_aim_bh:OnCreated(table)
	self.damage = self:GetTalentSpecialValueFor("range_damage") / 100
	self:StartIntervalThink(0.25)
end

function modifier_sniper_take_aim_bh:OnIntervalThink()
	self.range = self:GetTalentSpecialValueFor("base_range") + self:GetTalentSpecialValueFor("range_per_lvl") * self:GetCaster():GetLevel()
end

function modifier_sniper_take_aim_bh:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_sniper_take_aim_bh:GetModifierAttackRangeBonus()
	return self.range
end

function modifier_sniper_take_aim_bh:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:GetAbility():DealDamage( params.attacker, params.target, CalculateDistance( params.attacker, params.target ) * self.damage, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE )
	end
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