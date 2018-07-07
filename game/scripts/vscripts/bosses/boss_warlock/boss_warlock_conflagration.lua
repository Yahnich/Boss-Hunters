boss_warlock_conflagration = class({})
LinkLuaModifier( "modifier_boss_warlock_conflagration", "bosses/boss_warlock/boss_warlock_conflagration", LUA_MODIFIER_MOTION_NONE )

function boss_warlock_conflagration:OnSpellStart()
	local caster = self:GetCaster()

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
	for _,enemy in pairs(enemies) do
		if enemy:IsHero() then
			enemy:AddNewModifier(caster, self, "modifier_boss_warlock_conflagration", {Duration = self:GetSpecialValueFor("duration")})
			enemy:Daze(self, caster, self:GetSpecialValueFor("duration"))
			break
		end
	end
end

modifier_boss_warlock_conflagration = class({})
function modifier_boss_warlock_conflagration:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_boss_warlock_conflagration:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	self:GetAbility():DealDamage(caster, parent, self:GetSpecialValueFor("damage"), {}, 0)
	if RollPercentage(self:GetSpecialValueFor("chance")) then
		local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self:GetAbility():GetTrueCastRange())
		for _,enemy in pairs(enemies) do
			if enemy ~= parent then
				self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("damage")/#enemies, {}, 0)
			end
		end
	end
	self:StartIntervalThink(0.5)
end

function modifier_boss_warlock_conflagration:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_boss_warlock_conflagration:GetStatusEffectName()
	return "particles/status_fx/status_effect_burn.vpcf"
end

function modifier_boss_warlock_conflagration:StatusEffectPriority()
	return 12
end

function modifier_boss_warlock_conflagration:IsDebuff()
	return true
end