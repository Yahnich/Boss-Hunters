boss_durva_all_is_linked = class({})

function boss_durva_all_is_linked:GetIntrinsicModifierName()
	return "modifier_boss_durva_all_is_linked"
end

modifier_boss_durva_all_is_linked = class({})
LinkLuaModifier( "modifier_boss_durva_all_is_linked", "bosses/boss_durva/boss_durva_all_is_linked", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_durva_all_is_linked:OnCreated()
	self.dmg_spread = self:GetSpecialValueFor("damage_spread") / 100
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_durva_all_is_linked:OnRefresh()
	self:OnCreated()
end

function modifier_boss_durva_all_is_linked:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_durva_all_is_linked:OnTakeDamage(params)
	local ability = self:GetAbility()
	if params.attacker == self:GetParent() and params.inflictor ~= ability then
		local damage = params.original_damage * self.dmg_spread
		for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.unit:GetAbsOrigin(), self.radius ) ) do
			if enemy ~= params.unit then
				ability:DealDamage( params.attacker, enemy, damage, { damage_type = params.damage_type, damage_flags = params.damage_flags } )
				ParticleManager:FireRopeParticle( "particles/units/heroes/hero_warlock/warlock_fatal_bonds_pulse.vpcf", PATTACH_POINT_FOLLOW, params.unit, enemy )
			end
		end
	end
end

function modifier_boss_durva_all_is_linked:IsHidden()
	return true
end