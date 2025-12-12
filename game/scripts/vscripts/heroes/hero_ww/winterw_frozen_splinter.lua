winterw_frozen_splinter = class({})
LinkLuaModifier( "modifier_frozen_splinter", "heroes/hero_ww/winterw_frozen_splinter.lua" ,LUA_MODIFIER_MOTION_NONE )

function winterw_frozen_splinter:IsStealable()
	return true
end

function winterw_frozen_splinter:IsHiddenWhenStolen()
	return false
end

function winterw_frozen_splinter:PiercesDisableResistance()
    return true
end

function winterw_frozen_splinter:OnSpellStart()
	local caster = self:GetCaster()

	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Winter_Wyvern.SplinterBlast.Cast", caster)
	
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_winter_wyvern/wyvern_splinter.vpcf",
	    iMoveSpeed = 1000,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDrawsOnMinimap = false,                          -- Optional
        bDodgeable = true,                                -- Optional
        bIsAttack = false,                                -- Optional
        bVisibleToEnemies = true,                         -- Optional
        bReplaceExisting = false,                         -- Optional
        flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
		bProvidesVision = true,                           -- Optional
		iVisionRadius = 400,                              -- Optional
		iVisionTeamNumber = caster:GetTeamNumber(),        -- Optional
		ExtraData = {name = "firstProj"}
	}
	ProjectileManager:CreateTrackingProjectile(info)

	if caster:HasTalent("special_bonus_unique_winterw_frozen_splinter_2") then
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange(), {})
		local bonusTargets = caster:FindTalentValue("special_bonus_unique_winterw_frozen_splinter_2")
		for _,enemy in pairs(enemies) do
			local info =
			{
				Target = enemy,
				Source = caster,
				Ability = self,	
				EffectName = "particles/units/heroes/hero_winter_wyvern/wyvern_splinter.vpcf",
				iMoveSpeed = 1000,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				bDrawsOnMinimap = false,                          -- Optional
				bDodgeable = true,                                -- Optional
				bIsAttack = false,                                -- Optional
				bVisibleToEnemies = true,                         -- Optional
				bReplaceExisting = false,                         -- Optional
				flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
				bProvidesVision = true,                           -- Optional
				iVisionRadius = 400,                              -- Optional
				iVisionTeamNumber = caster:GetTeamNumber(),        -- Optional
				ExtraData = {name = "firstProj"}
			}
			ProjectileManager:CreateTrackingProjectile(info)
			bonusTargets = bonusTargets - 1
			if bonusTargets <= 0 then return end
		end
	end
end

function winterw_frozen_splinter:CreateFrozenSplinters( target )
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetSpecialValueFor("search_radius"), {})
	local i = 0
	for _,enemy in pairs(enemies) do
		if enemy ~= target then
			if i < 2 then
				local info = 
				{
					Target = enemy,
					Source = target,
					Ability = self,	
					EffectName = "particles/units/heroes/hero_winter_wyvern/wyvern_splinter_blast.vpcf",
					iMoveSpeed = 750,
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
					bDrawsOnMinimap = false,                          -- Optional
					bDodgeable = true,                                -- Optional
					bIsAttack = false,                                -- Optional
					bVisibleToEnemies = true,                         -- Optional
					bReplaceExisting = false,                         -- Optional
					flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
					bProvidesVision = true,                           -- Optional
					iVisionRadius = 400,                              -- Optional
					iVisionTeamNumber = self:GetCaster():GetTeamNumber(),        -- Optional
					ExtraData = {name = "secondProj"}
				}
				ProjectileManager:CreateTrackingProjectile(info)
				i = i + 1
			else
				break
			end
		end
	end
end

function winterw_frozen_splinter:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	if hTarget and hTarget:IsAlive() and not hTarget:TriggerSpellAbsorb( self ) then
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_frozen_splinter", {Duration = self:GetSpecialValueFor("slow_duration")})
		if self:GetCaster():HasTalent("special_bonus_unique_winterw_frozen_splinter_1") then
			self:Stun(hTarget, self:GetCaster():FindTalentValue("special_bonus_unique_winterw_frozen_splinter_1"), false)
		end

		if table.name == "firstProj" then
			EmitSoundOn("Hero_Winter_Wyvern.SplinterBlast.Target", hTarget)

			self:DealDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			
			self:CreateFrozenSplinters( hTarget )
		elseif table.name == "secondProj" then
			EmitSoundOn("Hero_Winter_Wyvern.SplinterBlast.Splinter", hTarget)

			self:DealDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("damage")/2, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			local i = 0

			local enemies = self:GetCaster():FindEnemyUnitsInRadius(hTarget:GetAbsOrigin(), self:GetSpecialValueFor("search_radius"), {})
			for _,enemy in pairs(enemies) do
				if enemy ~= hTarget then
					if i < 2 then
						local info = 
						{
							Target = enemy,
							Source = hTarget,
							Ability = self,	
							EffectName = "particles/units/heroes/hero_winter_wyvern/wyvern_splinter_blast.vpcf",
						    iMoveSpeed = 750,
							iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
							bDrawsOnMinimap = false,                          -- Optional
					        bDodgeable = true,                                -- Optional
					        bIsAttack = false,                                -- Optional
					        bVisibleToEnemies = true,                         -- Optional
					        bReplaceExisting = false,                         -- Optional
					        flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
							bProvidesVision = true,                           -- Optional
							iVisionRadius = 400,                              -- Optional
							iVisionTeamNumber = self:GetCaster():GetTeamNumber(),        -- Optional
							ExtraData = {name = "thirdProj"}
						}
						ProjectileManager:CreateTrackingProjectile(info)
						i = i + 1
					else
						break
					end
				end
			end
		elseif table.name == "thirdProj" then
			EmitSoundOn("Hero_Winter_Wyvern.SplinterBlast.Splinter", hTarget)

			self:DealDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("damage")/4, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
	end
	return false
end

modifier_frozen_splinter = ({})
function modifier_frozen_splinter:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_frozen_splinter:GetModifierMoveSpeedBonus_Percentage()
    return self:GetSpecialValueFor("move_slow")
end

function modifier_frozen_splinter:IsDebuff()
    return true
end

function modifier_frozen_splinter:GetEffectName()
    return "particles/units/heroes/hero_winter_wyvern/wyvern_splinter_blast_slow.vpcf"
end