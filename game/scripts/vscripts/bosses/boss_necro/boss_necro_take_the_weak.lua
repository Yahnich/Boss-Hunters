boss_necro_take_the_weak = class({})

function boss_necro_take_the_weak:GetIntrinsicModifierName()
	return "modifier_boss_necro_take_the_weak"
end

modifier_boss_necro_take_the_weak = class({})
LinkLuaModifier("modifier_boss_necro_take_the_weak", "bosses/boss_necro/boss_necro_take_the_weak", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_necro_take_the_weak:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_necro_take_the_weak:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and not params.unit:IsRealHero() and not HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) and params.inflictor ~= self:GetAbility() then
		params.unit:AttemptKill(self:GetAbility(), params.attacker)
	end
end