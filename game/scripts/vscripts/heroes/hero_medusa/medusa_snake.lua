--Thanks Valve @Sidearms
medusa_snake = class({})
LinkLuaModifier("modifier_medusa_gaze_stun_lesser", "heroes/hero_medusa/medusa_gaze", LUA_MODIFIER_MOTION_NONE)

function medusa_snake:IsStealable()
	return true
end

function medusa_snake:IsHiddenWhenStolen()
	return false
end

function medusa_snake:OnSpellStart()
	local caster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	self.radius = self:GetTalentSpecialValueFor( "radius" )
	self.speed = 800
	self.snake_damage = self:GetTalentSpecialValueFor( "damage" )
	self.snake_mana_steal = self:GetTalentSpecialValueFor( "mana_steal" )
	self.snake_scale = self:GetTalentSpecialValueFor( "snake_scale" )
	self.snake_jumps = self:GetTalentSpecialValueFor( "jumps" )
	self.stone_duration = self:GetTalentSpecialValueFor( "stone_duration" )

	EmitSoundOn("Hero_Medusa.MysticSnake.Cast", caster)

	self:FireTrackingProjectile("particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile_initial.vpcf", hTarget, self.speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, 300)
	if caster:HasTalent("special_bonus_unique_medusa_snake_2") then
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange())
		for _,enemy in pairs(enemies) do
			if enemy ~= hTarget then
				self:FireTrackingProjectile("particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile_initial.vpcf", enemy, self.speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, 300)
				break
			end
		end
	end

	self.nCurJumpCount = 0
	self.nTotalMana = 0
	self.hHitEntities = {}

	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_mystic_snake_cast.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true )
	ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end

function medusa_snake:OnProjectileHit( hTarget, vLocation )
	if IsServer() then
		local caster = self:GetCaster()

		if hTarget ~= nil and not ( hTarget == caster ) then
			EmitSoundOn("Hero_Medusa.MysticSnake.Target", hTarget)

			-- Do damage and mana steal
			if hTarget:IsAlive() then
				local flManaSteal = self.snake_mana_steal

				--if hTarget has Mana
				if hTarget:GetMaxMana() > 0 then 
					hTarget:ReduceMana( flManaSteal )
				end

				self.nTotalMana = self.nTotalMana + flManaSteal
			end

			local iDamageType = self:GetAbilityDamageType()

			if hTarget:FindModifierByName( "modifier_medusa_gaze_stun" ) or hTarget:FindModifierByName( "modifier_medusa_gaze_stun_lesser" ) then
				iDamageType = DAMAGE_TYPE_PURE
			end

			self:DealDamage(caster, hTarget, self.snake_damage, {damage_type = iDamageType}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)

			if hTarget:IsAlive() and caster:HasScepter() then
				local ability = caster:FindAbilityByName("medusa_gaze")
				local durationIncrease = 0.3 * self.nCurJumpCount
				hTarget:AddNewModifier(caster, ability, "modifier_medusa_gaze_stun_lesser", {Duration = 1 + durationIncrease})
			end
			-- Scale up the damage now
			self.snake_damage = self.snake_damage + ( self.snake_damage * self.snake_scale ) / 100;
			self.nCurJumpCount = self.nCurJumpCount + 1

			table.insert( self.hHitEntities, hTarget )
		end

		-- Snake is hitting Medusa, give her the collected mana
		if hTarget == caster then
			EmitSoundOn("Hero_Medusa.MysticSnake.Return", caster)
			caster:GiveMana( self.nTotalMana )
			SendOverheadEventMessage( caster:GetPlayerOwner(), OVERHEAD_ALERT_MANA_ADD, caster, self.nTotalMana, nil )

			for k in pairs( self.hHitEntities ) do
				self.hHitEntities[ k ] = nil
			end

			return true
		end

		self:LaunchNextProjectile( hTarget )
	end

	return false
end

function medusa_snake:LaunchNextProjectile( hTarget )
	-- Find a new target
	if hTarget and self.nCurJumpCount < self.snake_jumps then
		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), hTarget:GetAbsOrigin(), self:GetCaster(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )

		local hJumpTarget
		while #enemies > 0 do
			local hPotentialJumpTarget = enemies[ 1 ]
			if hPotentialJumpTarget == nil or HasValInTable(self.hHitEntities, hPotentialJumpTarget) then
				table.remove( enemies, 1 )
			else
				hJumpTarget = hPotentialJumpTarget
				break
			end
		end

		-- We didn't find any jump targets, return to Medusa
		if #enemies == 0 then
			self:FireTrackingProjectile("particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile_return.vpcf", self:GetCaster(), self.speed, {source = hTarget}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, 300)
			return
		end

		-- Go to another target
		if hJumpTarget then
			self:FireTrackingProjectile("particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf", hJumpTarget, self.speed, {source = hTarget}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, 300)
			return
		end
	end

	-- We're out of jump targets, so return to the caster from here.
	self:FireTrackingProjectile("particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile_return.vpcf", self:GetCaster(), self.speed, {source = hTarget}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, 300)
end
