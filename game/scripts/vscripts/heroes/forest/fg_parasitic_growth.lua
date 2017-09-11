fg_parasitic_growth = class({})
LinkLuaModifier( "modifier_fg_parasitic_growth_lua", "heroes/hero_fg/fg_parasitic_growth.lua" ,LUA_MODIFIER_MOTION_NONE )
--LinkLuaModifier( "modifier_fg_parasitic_growth_lua", "heroes/forest/fg_parasitic_growth.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function fg_parasitic_growth:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	self.duration = self:GetSpecialValueFor( "duration" )
	self.heal = self:GetSpecialValueFor( "heal" )

	if hCaster == nil and hTarget == nil then
		return
	end

	if not hTarget:IsMagicImmune() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_treant/treant_leech_seed.vpcf", PATTACH_CUSTOMORIGIN, hCaster )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack1", hCaster:GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		hTarget:AddNewModifier(hCaster,self,"modifier_fg_parasitic_growth_lua",{Duration=self.duration})

		EmitSoundOn("Hero_Treant.LeechSeed.Cast",hCaster)
	end
end

function fg_parasitic_growth:OnProjectileHit( hTarget, vLocation )
	hTarget:Heal(self.heal,self:GetCaster())
	return true
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
modifier_fg_parasitic_growth_lua = class({})

function modifier_fg_parasitic_growth_lua:OnCreated( kv )
	
	self.pulse_interval = self:GetAbility():GetSpecialValueFor( "pulse_interval" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.move_speed = self:GetAbility():GetSpecialValueFor( "move_speed" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )

	self:OnIntervalThink()
	self:StartIntervalThink(self.pulse_interval)

	EmitSoundOn("Hero_Treant.LeechSeed.Target",self:GetParent())
end

function modifier_fg_parasitic_growth_lua:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster()
		local hTarget = self:GetParent()

		local damage = {
			victim = hTarget,
			attacker = hCaster,
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()
		}

		ApplyDamage( damage )

		local units = FindUnitsInRadius(hCaster:GetTeamNumber(),hTarget:GetAbsOrigin(),nil,self.radius,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
		for _,unit in pairs(units) do
			if unit:GetTeamNumber() == hCaster:GetTeamNumber() then
				local info = {
					Target = unit,
					Source = hTarget,
					Ability = self:GetAbility(),	
					EffectName = "particles/units/heroes/hero_treant/treant_leech_seed_projectile.vpcf",
        			iMoveSpeed = 400,
					bDrawsOnMinimap = false,                          -- Optional
        			bDodgeable = false,                                -- Optional
        			bIsAttack = false,                                -- Optional
        			bVisibleToEnemies = true,                         -- Optional
       				bReplaceExisting = false,                         -- Optional
        			flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
					bProvidesVision = true,                           -- Optional
					iVisionRadius = 400,                              -- Optional
					iVisionTeamNumber = hCaster:GetTeamNumber()        -- Optional
				}
				projectile = ProjectileManager:CreateTrackingProjectile(info)
			elseif unit:GetTeamNumber() ~= hCaster:GetTeamNumber() and hCaster:HasTalent("special_bonus_unique_treant_2") and not unit:HasModifier("modifier_fg_parasitic_growth_lua") then
				local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_treant/treant_leech_seed.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
				ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
				ParticleManager:SetParticleControlEnt( nFXIndex, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true )
				ParticleManager:ReleaseParticleIndex( nFXIndex )

				unit:AddNewModifier(hCaster,self:GetAbility(),"modifier_fg_parasitic_growth_lua",{Duration=self.duration})

				EmitSoundOn("Hero_Treant.LeechSeed.Cast",hTarget)
			end
		end

		EmitSoundOn("Hero_Treant.LeechSeed.Tick",hTarget)
	end
end

function modifier_fg_parasitic_growth_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_fg_parasitic_growth_lua:GetModifierMoveSpeedBonus_Percentage( params )
	return self.move_speed
end
