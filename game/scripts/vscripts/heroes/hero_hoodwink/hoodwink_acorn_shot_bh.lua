hoodwink_acorn_shot_bh = class({})

function hoodwink_acorn_shot_bh:GetCastRange( target, position )
	return self:GetCaster():GetAttackRange() + self:GetSpecialValueFor("bonus_range")
end

function hoodwink_acorn_shot_bh:GetBehavior( )
	local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT
	if self:GetCaster():HasTalent("special_bonus_unique_hoodwink_acorn_shot_1") then
		behavior = behavior + DOTA_ABILITY_BEHAVIOR_AOE
	end
	return behavior
end

function hoodwink_acorn_shot_bh:GetAOERadius( )
	return self:GetCaster():FindTalentValue("special_bonus_unique_hoodwink_acorn_shot_1", "radius")
end

function hoodwink_acorn_shot_bh:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl )
end

function hoodwink_acorn_shot_bh:GetManaCost( iLvl )
	if self:GetCaster():HasTalent("special_bonus_unique_hoodwink_acorn_shot_2") then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function hoodwink_acorn_shot_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or self:GetCursorPosition()
	local position = self:GetCursorPosition()
	
	self.projectileData = self.projectileData or {}
	self:FireAcorn( target )
	
	if caster:HasTalent("special_bonus_unique_hoodwink_acorn_shot_1") then
		local radius = caster:FindTalentValue("special_bonus_unique_hoodwink_acorn_shot_1", "radius")
		local enemies = caster:FindEnemyUnitsInRadius( position, radius )
		print( "enemies:", #enemies )
		if #enemies <= 1 then
			local acorns = caster:FindTalentValue("special_bonus_unique_hoodwink_acorn_shot_1", "value2")
			for i = 1, acorns do
				self:FireAcorn( position + ActualRandomVector( radius ), 1 )
			end
		else
			for _, enemy in ipairs( enemies ) do
				if enemy ~= target then
					self:FireAcorn( enemy, 0 )
				end
			end
		end
	end
	
	EmitSoundOn( "Hero_Hoodwink.AcornShot.Cast", caster )
end

function hoodwink_acorn_shot_bh:FireAcorn( target, bounces )
	local caster = self:GetCaster()
	local bounces = bounces or self:GetSpecialValueFor("bounce_count")
	if not target.GetAbsOrigin then -- vector
		local direction = CalculateDirection( target, caster )
		local distance = CalculateDistance( target, caster )
		local projIndex = self:FireLinearProjectile("particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_initial.vpcf", self:GetSpecialValueFor("projectile_speed") * direction, distance, 100, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 200)
		self.projectileData[projIndex] = {}
		self.projectileData[projIndex].isTracking = false
		self.projectileData[projIndex].bounces = bounces
	else -- vector
		local projIndex = self:FireTrackingProjectile("particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tracking.vpcf", target, self:GetSpecialValueFor("projectile_speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 200)
		self.projectileData[projIndex] = {}
		self.projectileData[projIndex].isTracking = true
		self.projectileData[projIndex].bounces = bounces
	end
end

function hoodwink_acorn_shot_bh:OnProjectileHitHandle( target, position, projectile )
	local data = self.projectileData[projectile]
	local caster = self:GetCaster()
	if data then
		if data.isTracking then
			if target then
				caster:PerformGenericAttack(target, true, self:GetSpecialValueFor("bonus_damage"))
				target:AddNewModifier( caster, self, "modifier_hoodwink_acorn_shot_bh_slow", { duration = self:GetSpecialValueFor("debuff_duration")} )
				EmitSoundOn( "Hero_Hoodwink.AcornShot.Target", caster )
				EmitSoundOn( "Hero_Hoodwink.AcornShot.Slow", caster )
				if self.projectileData[projectile].bounces > 0 then
					for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(position, self:GetSpecialValueFor("bounce_range")) ) do
						if enemy ~= target then
							EmitSoundOn( "Hero_Hoodwink.AcornShot.Bounce", caster )
							local projIndex = self:FireTrackingProjectile("particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tracking.vpcf", enemy, self:GetSpecialValueFor("projectile_speed"), {source = target}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 200)
							self.projectileData[projIndex] = {}
							self.projectileData[projIndex].isTracking = true
							self.projectileData[projIndex].bounces = self.projectileData[projectile].bounces - 1
							self.projectileData[projectile] = nil
							break
						end
					end
				end
			end
		elseif not target then
			EmitSoundOn( "Hero_Hoodwink.AcornShot.Target", caster )
			local dummy = caster:CreateDummy( position, 20 )
			dummy:AddNewModifier( caster, self, "hoodwink_acorn_shot_bh_dummy", {} )
			AddFOWViewer( caster:GetTeam(), position, 200, 20, false )
			CreateTempTree( position, 20 )
			ResolveNPCPositions( position, 128 )
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(position, self:GetSpecialValueFor("bounce_range")) ) do
				if enemy ~= target then
					EmitSoundOn( "Hero_Hoodwink.AcornShot.Bounce", caster )
					local projIndex = self:FireTrackingProjectile("particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tracking.vpcf", enemy, self:GetSpecialValueFor("projectile_speed"), {source = dummy}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 200)
					self.projectileData[projIndex] = {}
					self.projectileData[projIndex].isTracking = true
					self.projectileData[projIndex].bounces = data.bounces
					self.projectileData[projectile] = nil
					break
				end
			end
		end
	end
end

modifier_hoodwink_acorn_shot_bh_slow = class({})
LinkLuaModifier("modifier_hoodwink_acorn_shot_bh_slow", "heroes/hero_hoodwink/hoodwink_acorn_shot_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_hoodwink_acorn_shot_bh_slow:OnCreated()
	self:OnRefresh()
end

function modifier_hoodwink_acorn_shot_bh_slow:OnRefresh()
	self.moveslow = self:GetSpecialValueFor("slow")
	if self:GetCaster():FindTalentValue("special_bonus_unique_hoodwink_acorn_shot_2") then
		self.attackslow = self.moveslow * self:GetSpecialValueFor("slow") / 100
	end
end

function modifier_hoodwink_acorn_shot_bh_slow:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_hoodwink_acorn_shot_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.moveslow
end

function modifier_hoodwink_acorn_shot_bh_slow:GetModifierAttackSpeedBonus_Constant()
	return -self.attackslow
end

hoodwink_acorn_shot_bh_dummy = class({})
LinkLuaModifier("hoodwink_acorn_shot_bh_dummy", "heroes/hero_hoodwink/hoodwink_acorn_shot_bh", LUA_MODIFIER_MOTION_NONE)

function hoodwink_acorn_shot_bh_dummy:GetEffectName()
	return "particles/units/heroes/hero_hoodwink/hoodwink_acorn_shot_tree.vpcf"
end