abaddon_death_coil_ebf = class({})

function abaddon_death_coil_ebf:IsStealable()
	return true
end

function abaddon_death_coil_ebf:IsHiddenWhenStolen()
	return false
end

function abaddon_death_coil_ebf:CastFilterResultTarget(target)
	if target == self:GetCaster() then
		return UF_FAIL_CUSTOM
	else
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, target:GetTeamNumber())
	end
end

function abaddon_death_coil_ebf:GetCustomCastErrorTarget(target)
	return "Cannot target caster"
end

function abaddon_death_coil_ebf:OnSpellStart()
	-- Variables
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local projectile_speed = self:GetTalentSpecialValueFor( "projectile_speed" )

	-- Play the ability sound
	caster:EmitSound("Hero_Abaddon.DeathCoil.Cast")

	local heal_pct = self:GetTalentSpecialValueFor( "heal_pct" ) / 100
	local self_heal = self:GetTalentSpecialValueFor( "self_heal" )

	self:CreateMistCoil(target, source)
	if not caster:HasTalent("special_bonus_unique_abaddon_death_coil_2") then
		self:DealDamage( caster, caster, self_heal, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL })
	else
		caster:HealEvent(self_heal, self, caster)
	end
end

function abaddon_death_coil_ebf:CreateMistCoil(target, source)
	local projectile = {
		Target = target,
		Source = source or self:GetCaster(),
		Ability = self,
		EffectName = "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf",
		bDodgable = false,
		bProvidesVision = false,
		iMoveSpeed = self:GetTalentSpecialValueFor( "projectile_speed" ),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
	}
	ProjectileManager:CreateTrackingProjectile(projectile)
end

function abaddon_death_coil_ebf:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	if target then
		target:EmitSound("Hero_Abaddon.DeathCoil.Target")
		
		local damage = self:GetTalentSpecialValueFor( "target_damage")
		local heal = self:GetTalentSpecialValueFor( "heal_amount" )

		-- If the target and caster are on a different team, do Damage. Heal otherwise
		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			ApplyDamage({ victim = target, attacker = caster, damage = damage,	damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
		else
			target:HealEvent(heal, self, caster)
		end
		if caster:HasTalent("special_bonus_unique_abaddon_death_coil_1") and not self.duplicateProjectile then
			self.duplicateProjectile = true
			local search_radius = caster:FindTalentValue("special_bonus_unique_abaddon_death_coil_1")
			local allies = caster:FindFriendlyUnitsInRadius( target:GetAbsOrigin(), search_radius )
			local targetAllies = RollPercentage(50) and (#allies > 0)
			if targetAllies then
				for _, ally in ipairs( allies ) do
					if ally:IsRealHero() and not ally:IsFakeHero() and ally ~= target then
						self:CreateMistCoil(ally, target)
						return
					end
				end
				for _, ally in ipairs( allies ) do
					if ally ~= target then
						self:CreateMistCoil(ally, target)
						return
					end
				end
			else
				local enemies = caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), search_radius )
				for _, enemy in ipairs( enemies ) do
					if not enemy:IsMinion() and enemy ~= target then
						self:CreateMistCoil(enemy, target)
						return
					end
				end
				for _, enemy in ipairs( enemies ) do
					if enemy ~= target then
						self:CreateMistCoil(enemy, target)
						return
					end
				end
			end
		elseif self.duplicateProjectile then
			self.duplicateProjectile = false
		end
	end
end