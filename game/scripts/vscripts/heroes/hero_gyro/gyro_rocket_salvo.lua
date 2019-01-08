gyro_rocket_salvo = class({})
LinkLuaModifier( "modifier_rocket_salvo", "heroes/hero_gyro/gyro_rocket_salvo.lua",LUA_MODIFIER_MOTION_NONE )

function gyro_rocket_salvo:IsStealable()
	return true
end

function gyro_rocket_salvo:IsHiddenWhenStolen()
	return false
end

function gyro_rocket_salvo:OnToggle()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Gyrocopter.Rocket_Barrage", caster)
	if self:GetToggleState() == true then
		caster:AddNewModifier(caster, self, "modifier_rocket_salvo", {})
		self:EndCooldown()
	else
		caster:RemoveModifierByName("modifier_rocket_salvo")
		self:SetCooldown()
	end
end

function gyro_rocket_salvo:OnProjectileHit(hTarget, vLocation)
	EmitSoundOn("Hero_Gyrocopter.Rocket_Barrage.Impact", caster)
	self:DealDamage( self:GetCaster(), hTarget, self:GetSpecialValueFor("damage") )
end

modifier_rocket_salvo = class(toggleModifierBaseClass)

function modifier_rocket_salvo:OnCreated(table)
	if IsServer() then
		self.drainThink = 0
		self.tick = self:GetTalentSpecialValueFor("fire_rate")
		self:StartIntervalThink(self.tick)
	end
end

function modifier_rocket_salvo:OnRefresh(kv)
	if IsServer() then
		self.tick = self:GetTalentSpecialValueFor("fire_rate")
		self:StartIntervalThink(self.tick)
	end
end

function modifier_rocket_salvo:OnRemoved()
	if IsServer() then
		self:GetCaster():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
	end
end

function modifier_rocket_salvo:OnIntervalThink()
	local caster = self:GetCaster()

	caster:StartGestureWithPlaybackRate(ACT_DOTA_OVERRIDE_ABILITY_1, 0.5)
	self.drainThink = self.drainThink + self.tick
	if self.drainThink >= 1 then
		caster:SpendMana( self:GetAbility():GetManaCost(-1) )
		self.drainThink = 0
	end
	if caster:GetMana() >= self:GetAbility():GetManaCost(-1) then
		local currentTargets = 0
		local enemies = caster:FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), caster:GetAttackRange() + self:GetSpecialValueFor("radius"), {})
		if #enemies > 0 then
			EmitSoundOn("Hero_Gyrocopter.Rocket_Barrage.Launch", caster)
			
			for _,enemy in pairs(enemies) do
				if currentTargets < self:GetTalentSpecialValueFor("max_targets") then
					if RollPercentage(50) then
						local info = 
						{
							Target = enemy,
							Source = caster,
							Ability = self:GetAbility(),	
							EffectName = "particles/units/heroes/hero_gyrocopter/gyro_rocket_barrage.vpcf",
						    iMoveSpeed = 1000,
							iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
							bDrawsOnMinimap = false,                          -- Optional
					        bDodgeable = false,                                -- Optional
					        bIsAttack = false,                                -- Optional
					        bVisibleToEnemies = true,                         -- Optional
					        bReplaceExisting = false,                         -- Optional
					        flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
							bProvidesVision = true,                           -- Optional
							iVisionRadius = 100,                              -- Optional
							iVisionTeamNumber = caster:GetTeamNumber(),        -- Optional
						}
						ProjectileManager:CreateTrackingProjectile(info)
					else
						local info2 = 
						{
							Target = enemy,
							Source = caster,
							Ability = self:GetAbility(),	
							EffectName = "particles/units/heroes/hero_gyrocopter/gyro_rocket_barrage.vpcf",
						    iMoveSpeed = 1000,
							iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
							bDrawsOnMinimap = false,                          -- Optional
					        bDodgeable = false,                                -- Optional
					        bIsAttack = false,                                -- Optional
					        bVisibleToEnemies = true,                         -- Optional
					        bReplaceExisting = false,                         -- Optional
					        flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
							bProvidesVision = true,                           -- Optional
							iVisionRadius = 100,                              -- Optional
							iVisionTeamNumber = caster:GetTeamNumber(),        -- Optional
						}
						ProjectileManager:CreateTrackingProjectile(info2)
					end
					currentTargets = currentTargets + 1
				end
			end
		end
	else
		self:GetAbility():ToggleAbility()
	end
end