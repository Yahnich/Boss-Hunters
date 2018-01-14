gyro_rocket_salvo = class({})
LinkLuaModifier( "modifier_rocket_salvo", "heroes/hero_gyro/gyro_rocket_salvo.lua",LUA_MODIFIER_MOTION_NONE )

function gyro_rocket_salvo:OnToggle()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Gyrocopter.Rocket_Barrage", caster)
	if self:GetToggleState() == true then
		caster:AddNewModifier(caster, self, "modifier_rocket_salvo", {})
		self:EndCooldown()
	else
		caster:RemoveModifierByName("modifier_rocket_salvo")
		self:RefundManaCost()
	end
end

function gyro_rocket_salvo:OnProjectileHit(hTarget, vLocation)
	EmitSoundOn("Hero_Gyrocopter.Rocket_Barrage.Impact", caster)
	self:DealDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
end

modifier_rocket_salvo = class({})

function modifier_rocket_salvo:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(self:GetSpecialValueFor("fire_rate"))
	end
end

function modifier_rocket_salvo:OnIntervalThink()
	local caster = self:GetCaster()

	if caster:GetMana() >= self:GetAbility():GetManaCost(self:GetAbility():GetLevel()) then
		local currentTargets = 0
		local enemies = caster:FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
		if #enemies > 0 then
			EmitSoundOn("Hero_Gyrocopter.Rocket_Barrage.Launch", caster)
			caster:SpendMana(self:GetAbility():GetManaCost(self:GetAbility():GetLevel()), self:GetAbility())
			for _,enemy in pairs(enemies) do
				if currentTargets < self:GetSpecialValueFor("max_targets") then
					if RollPercentage(50) then
						local info = 
						{
							Target = enemy,
							Source = caster,
							Ability = self,	
							EffectName = "particles/units/heroes/hero_gyrocopter/gyro_rocket_barrage.vpcf",
						    iMoveSpeed = 1000,
							iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
							bDrawsOnMinimap = false,                          -- Optional
					        bDodgeable = true,                                -- Optional
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
						local info = 
						{
							Target = enemy,
							Source = caster,
							Ability = self,	
							EffectName = "particles/units/heroes/hero_gyrocopter/gyro_rocket_barrage.vpcf",
						    iMoveSpeed = 1000,
							iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
							bDrawsOnMinimap = false,                          -- Optional
					        bDodgeable = true,                                -- Optional
					        bIsAttack = false,                                -- Optional
					        bVisibleToEnemies = true,                         -- Optional
					        bReplaceExisting = false,                         -- Optional
					        flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
							bProvidesVision = true,                           -- Optional
							iVisionRadius = 100,                              -- Optional
							iVisionTeamNumber = caster:GetTeamNumber(),        -- Optional
						}
						ProjectileManager:CreateTrackingProjectile(info)
					end
					currentTargets = currentTargets + 1
				end
			end
		end
	else
		self:GetAbility():ToggleAbility()
	end
end