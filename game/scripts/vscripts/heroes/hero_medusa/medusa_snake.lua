--Thanks Valve @Sidearms
medusa_snake = class({})

function medusa_snake:IsStealable()
	return true
end

function medusa_snake:IsHiddenWhenStolen()
	return false
end

function medusa_snake:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	self.projectiles = self.projectiles or {}
	
	if caster:HasTalent("special_bonus_unique_medusa_snake_2") then
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange())
		for _,enemy in pairs(enemies) do
			if enemy ~= target then
				Timers:CreateTimer( 0.3, function() self:FireMysticSnake( enemy, caster ) end )
				break
			end
		end
	end
	self:FireMysticSnake( target, caster )
	
end

function medusa_snake:FireMysticSnake( target, source )
	local caster = self:GetCaster()
	
	local snake_damage = self:GetSpecialValueFor( "damage" )
	local snake_jumps = self:GetSpecialValueFor( "jumps" )
	
	local FX = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile_initial.vpcf"
	if target == caster then
		FX = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile_return.vpcf"
	end
	local projectile = self:FireTrackingProjectile(FX, target, 800, {source = source}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, 300)
	self.projectiles[projectile] = {bounces = snake_jumps, damage = snake_damage, mana = 0, units = {}}
	if caster:HasTalent("special_bonus_unique_medusa_snake_1") then
		self.projectiles[projectile].petrify = caster:FindTalentValue("special_bonus_unique_medusa_snake_1")
		self.projectiles[projectile].petrify_increase = caster:FindTalentValue("special_bonus_unique_medusa_snake_1", "value")
	end
	if source == caster then
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_medusa/medusa_mystic_snake_cast.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		
		EmitSoundOn("Hero_Medusa.MysticSnake.Cast", caster)
	end
	return projectile
end

function medusa_snake:OnProjectileHitHandle( target, position, projectile )
	if IsServer() then
		local caster = self:GetCaster()
		if target ~= caster and target:TriggerSpellAbsorb(self) then return true end
		if target ~= nil and not ( target == caster ) then
			EmitSoundOn("Hero_Medusa.MysticSnake.Target", target)
			
			if target:IsAlive() and self.projectiles[projectile].petrify then
				local gaze = caster:FindAbilityByName("medusa_gaze")
				if gaze then
					target:AddNewModifier(caster, gaze, "modifier_medusa_gaze_stun_lesser", {Duration = self.projectiles[projectile].petrify})
				end
			end
			local damage = self:DealDamage( caster, target, self.projectiles[projectile].damage )
			target:AddNewModifier( caster, self, "modifier_medusa_snake_slow", {duration = self:GetSpecialValueFor("slow_duration")} )
			self.projectiles[projectile].mana = (self.projectiles[projectile].mana or 0) + damage * self:GetSpecialValueFor("mana_steal") / 100
			self.projectiles[projectile].units[target] = true
			
			local delay = self:GetSpecialValueFor("jump_delay")
			if self.projectiles[projectile].bounces > 0 then
				local radius = self:GetSpecialValueFor("radius")
				
				local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius, {order = FIND_CLOSEST})
				for _,enemy in pairs(enemies) do
					if enemy ~= target and not self.projectiles[projectile].units[enemy] then
						Timers:CreateTimer( delay, function()
							local newProj = self:FireMysticSnake( enemy, target ) 
							self.projectiles[newProj] = {}
							self.projectiles[newProj].damage = self.projectiles[projectile].damage + self:GetSpecialValueFor( "damage" ) * self:GetSpecialValueFor( "snake_scale" )/100
							self.projectiles[newProj].mana = self.projectiles[projectile].mana
							self.projectiles[newProj].units = self.projectiles[projectile].units
							self.projectiles[newProj].bounces = self.projectiles[projectile].bounces - 1
							if self.projectiles[projectile].petrify then
								self.projectiles[newProj].petrify = self.projectiles[projectile].petrify + self.projectiles[projectile].petrify_increase
								self.projectiles[newProj].petrify_increase = self.projectiles[projectile].petrify_increase
							end
							self.projectiles[projectile] = nil
						end )
						return
					end
				end
			end
			Timers:CreateTimer( delay, function() 
				local newProj = self:FireMysticSnake( caster, target )
				self.projectiles[newProj].mana = self.projectiles[projectile].mana
			end )
			
			ParticleManager:FireParticle( "particles/units/heroes/hero_medusa/medusa_mystic_snake_impact.vpcf", PATTACH_POINT_FOLLOW, target )
		end

		-- Snake is hitting Medusa, give her the collected mana
		if target == caster then
			EmitSoundOn("Hero_Medusa.MysticSnake.Return", caster)
			caster:RestoreMana( self.projectiles[projectile].mana )
			self.projectiles[projectile] = nil
		end
	end

	return false
end

modifier_medusa_snake_slow = class({})
LinkLuaModifier("modifier_medusa_snake_slow", "heroes/hero_medusa/medusa_snake", LUA_MODIFIER_MOTION_NONE)

function modifier_medusa_snake_slow:OnCreated()
	self:OnRefresh()
end

function modifier_medusa_snake_slow:OnRefresh()
	self.movespeed = self:GetSpecialValueFor("move_slow")
	self.turn = self:GetSpecialValueFor("turn_slow")
end

function modifier_medusa_snake_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_medusa_snake_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_medusa_snake_slow:GetModifierTurnRate_Percentage()
	return self.turn
end
