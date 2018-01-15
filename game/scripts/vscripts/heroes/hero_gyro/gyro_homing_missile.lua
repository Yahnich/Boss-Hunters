gyro_homing_missile = class({})
LinkLuaModifier( "modifier_homing_missile", "heroes/hero_gyro/gyro_homing_missile.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_restricted", "heroes/hero_gyro/gyro_homing_missile.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_frozen_fakie", "heroes/hero_gyro/gyro_homing_missile.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_homing_missile_mr", "heroes/hero_gyro/gyro_homing_missile.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )

function gyro_homing_missile:PiercesDisableResistance()
    return true
end

function gyro_homing_missile:GetIntrinsicModifierName()
	return "modifier_homing_missile"
end

modifier_homing_missile = class({})
 
function modifier_homing_missile:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(self:GetTalentSpecialValueFor("missile_recharge_time"))
	end
end

function modifier_homing_missile:OnIntervalThink()
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("search_radius"), {})
	for _,enemy in pairs(enemies) do
		self:LaunchMissile(enemy)
		break
	end
end

function modifier_homing_missile:LaunchMissile(hTarget)
	local caster = self:GetCaster()
	local target = hTarget 
	local ability = self:GetAbility()
	local fire = 0

	local missile_recharge_time = self:GetSpecialValueFor("missile_recharge_time")

	--create the missile and apply the restricted modifier
	local homingMissile = CreateUnitByName("npc_dota_gyrocopter_homing_missile",caster:GetAbsOrigin(),true,caster,caster:GetOwnerEntity(),caster:GetTeam())
	ability:StartCooldown(missile_recharge_time)
	homingMissile:AddNewModifier(caster, ability, "modifier_restricted", {})
	homingMissile:AddNewModifier(caster, ability, "modifier_movespeed_cap", {})
	
	--set the missile move speed to the targets move speed plus 100
	homingMissile:SetBaseMoveSpeed(340)

	EmitSoundOn("Hero_Gyrocopter.HomingMissile",homingMissile)
	
	--fuse particle
	local fuse = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_homing_missile_fuse.vpcf", PATTACH_ABSORIGIN_FOLLOW, homingMissile) 
	ParticleManager:SetParticleControlEnt(fuse, 0, homingMissile, PATTACH_POINT_FOLLOW, "attach_hitloc", homingMissile:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(fuse, 1, homingMissile, PATTACH_POINT_FOLLOW, "attach_hitloc", homingMissile:GetAbsOrigin(), true)

	--annoying fix to keep the missile from hopping up, after a 1 second delay because of spawn animation
	Timers:CreateTimer(1.0, function()
		homingMissile:AddNewModifier(caster, ability, "modifier_frozen_fakie", {})
		return nil
	end)

	--after 2.5 seconds launch the missile to the target pos, updating every 0.1 seconds.
	--After hitting the enemy cause an explosion.
	Timers:CreateTimer(2.5, function()
		--remove the fuse just incase
		if fuse then
			ParticleManager:DestroyParticle(fuse,false)
		end

		--if the missile is alive. If the missile gets destoryed before reaching the target location, remove the fire particle
		if homingMissile:IsAlive() then
			--if we dont have the particles
			if fire == 0 then
				fire = ParticleManager:CreateParticle("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile.vpcf", PATTACH_ABSORIGIN_FOLLOW, homingMissile) 
				ParticleManager:SetParticleControlEnt(fire, 0, homingMissile, PATTACH_POINT_FOLLOW, "attach_hitloc", homingMissile:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(fire, 1, homingMissile, PATTACH_POINT_FOLLOW, "attach_hitloc", homingMissile:GetAbsOrigin(), true)
			end

			--removing the animation dummy holder
			if homingMissile:HasModifier("modifier_frozen_fakie") then
				homingMissile:RemoveModifierByName("modifier_frozen_fakie")
			end

			--if the target is alive otherwise forcekill
			if target:IsAlive() then
				--Move the missile to the target location
				homingMissile:MoveToPosition(target:GetAbsOrigin())
				homingMissile:SetBaseMoveSpeed(homingMissile:GetBaseMoveSpeed()+100)

				-- Find all nearby units
				local enemies = self:GetCaster():FindEnemyUnitsInRadius(homingMissile:GetAbsOrigin(), 150, {})
				for _,enemy in pairs(enemies) do
					if target == enemy then
  						local explosion = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) 
						ParticleManager:SetParticleControlEnt(explosion, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

						ParticleManager:DestroyParticle(fire,false)

						homingMissile:StopSound("Hero_Gyrocopter.HomingMissile")
						EmitSoundOn("Hero_Gyrocopter.HomingMissile.Destroy",homingMissile)
						homingMissile:AddNoDraw()
						homingMissile:ForceKill(false)
						return nil
  					end
				end
 	  			
 	  			--Checks to see if missile has reached destination, fail safe
 	  			if homingMissile:GetAbsOrigin() == target:GetAbsOrigin() and homingMissile:IsAlive() then
					local explosion = ParticleManager:CreateParticle(keys.particle2, PATTACH_ABSORIGIN_FOLLOW, target) 
					ParticleManager:SetParticleControlEnt(explosion, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

					ParticleManager:DestroyParticle(fire,false)

					homingMissile:StopSound("Hero_Gyrocopter.HomingMissile")
					homingMissile:AddNoDraw()
					homingMissile:ForceKill(false)
					return nil
				else
					return 0.1 --rerun interval
 	  			end--if end
			else
				ParticleManager:DestroyParticle(fire,false)
				homingMissile:StopSound("Hero_Gyrocopter.HomingMissile")
				homingMissile:AddNoDraw()
				homingMissile:ForceKill(false)
				return nil
			end
		else
			if fire then
				ParticleManager:DestroyParticle(fire,false)
			end
			return nil
		end		
	end)--timer, after 2.5 delay, 0.1 interval
end

function modifier_homing_missile:IsHidden()
	return true
end

modifier_restricted = class({})
function modifier_restricted:CheckState()
	local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,
					[MODIFIER_STATE_ATTACK_IMMUNE] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true
				}
	return state
end

function modifier_restricted:OnRemoved()
	if IsServer() then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("missile_explos_radius"), false)
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("missile_explos_radius"), {})
		for _,enemy in pairs(enemies) do
			self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetCaster():GetAttackDamage() * self:GetSpecialValueFor("missile_damage")/100, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			enemy:ApplyKnockBack(self:GetParent():GetAbsOrigin(), 0.5, 0.5, self:GetSpecialValueFor("missile_explos_radius"), 100, self:GetCaster(), self:GetAbility())
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_homing_missile_mr", {Duration = self:GetSpecialValueFor("duration")})
		end
	end
end

modifier_frozen_fakie = class({})
function modifier_frozen_fakie:CheckState()
	local state = { [MODIFIER_STATE_FROZEN] = true
				}
	return state
end

modifier_homing_missile_mr = class({})
function modifier_homing_missile_mr:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end

function modifier_homing_missile_mr:GetModifierMagicalResistanceBonus()
	return self:GetTalentSpecialValueFor("magic_reduction")
end

function modifier_homing_missile_mr:IsDebuff()
	return true
end