boss_reaper_multi_shot = class({})

function boss_reaper_multi_shot:GetIntrinsicModifierName()
	return "modifier_boss_reaper_multi_shot"
end

function boss_reaper_multi_shot:OnProjectileHit(target, position)
	if target then
		self:DealDamage(self:GetCaster(), target, self:GetCaster():GetAttackDamage(), {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
	end
end

modifier_boss_reaper_multi_shot = class({})
LinkLuaModifier("modifier_boss_reaper_multi_shot", "bosses/boss_wk/boss_reaper_multi_shot", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_reaper_multi_shot:OnCreated()
	self.procHit = self:GetSpecialValueFor("attacks_to_proc")
	self.radius = self:GetSpecialValueFor("search_radius")
	self.hits = 0
end

function modifier_boss_reaper_multi_shot:OnRefresh()
	self.procHit = self:GetSpecialValueFor("attacks_to_proc")
	self.radius = self:GetSpecialValueFor("search_radius")
end

function modifier_boss_reaper_multi_shot:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK}
end

function modifier_boss_reaper_multi_shot:OnAttack(params)
	if params.attacker == self:GetParent() and not params.attacker:PassivesDisabled() then
		if self.hits > self.procHit then
			self.hits = 0
			for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.radius ) ) do
				if params.target ~= enemy then
					self:GetAbility():FireTrackingProjectile( params.attacker:GetRangedProjectileName(), enemy, params.attacker:GetProjectileSpeed() )
				end
			end
		end
		self.hits = self.hits + 1
	end
end

function modifier_boss_reaper_multi_shot:IsHidden()
	return true
end