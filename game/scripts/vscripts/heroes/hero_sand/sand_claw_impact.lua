sand_claw_impact = class({})
LinkLuaModifier( "modifier_caustics_enemy", "heroes/hero_sand/sand_caustics.lua" ,LUA_MODIFIER_MOTION_NONE )

function sand_claw_impact:IsStealable()
    return true
end

function sand_claw_impact:IsHiddenWhenStolen()
    return false
end

function sand_claw_impact:GetCooldown(iLvl)
	local cooldown = self.BaseClass.GetCooldown(self, iLvl)
	if self:GetCaster():HasTalent("special_bonus_unique_sand_claw_impact_1") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_sand_claw_impact_1") end
	return cooldown
end

function sand_claw_impact:PiercesDisableResistance()
    return true
end

function sand_claw_impact:OnSpellStart()
    local caster = self:GetCaster()

    local point = self:GetCursorPosition()
	
	self.projectiles = self.projectiles or {}
	
    if self:GetCursorTarget() then
        point = self:GetCursorTarget():GetAbsOrigin()
    end

    local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local casterPos = caster:GetAbsOrigin()
    local spawn_point = casterPos + direction * self:GetTrueCastRange() 

    -- Set QAngles
    local left_QAngle = QAngle(0, 30, 0)
    local right_QAngle = QAngle(0, -30, 0)

    -- Left arrow variables
    local left_spawn_point = RotatePosition(caster:GetAbsOrigin(), left_QAngle, spawn_point)
    local left_direction = (left_spawn_point - caster:GetAbsOrigin()):Normalized()                

    -- Right arrow variables
    local right_spawn_point = RotatePosition(caster:GetAbsOrigin(), right_QAngle, spawn_point)
    local right_direction = (right_spawn_point - caster:GetAbsOrigin()):Normalized()        
    
	EmitSoundOn("hero_sandking.attack", caster)
	EmitSoundOn("Hero_Rattletrap.Chasm_Strike", caster)
	
    self:SpikeLaunch(casterPos, caster:GetForwardVector())
    self:SpikeLaunch(casterPos, left_direction)
    self:SpikeLaunch(casterPos, right_direction)
end

function sand_claw_impact:SpikeLaunch(position, direction, talent)
    local caster = self:GetCaster()
	local talent = talent
    local info = 
    {
        Ability = self,
        EffectName = "particles/units/heroes/hero_lion/lion_spell_impale.vpcf",
        vSpawnOrigin = position,
        fDistance = self:GetTrueCastRange(),
        fStartRadius = 100,
        fEndRadius = 100,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = true,
        vVelocity = direction * 1800 * Vector(1, 1, 0),
        bProvidesVision = true,
        iVisionRadius = 1000,
        iVisionTeamNumber = caster:GetTeamNumber(),
    }
	local projectileID = ProjectileManager:CreateLinearProjectile(info)
    self.projectiles[tostring(projectileID)] = talent
end

function sand_claw_impact:OnProjectileHitHandle(hTarget, vLocation, projectileID)
    local caster = self:GetCaster()

    if hTarget ~= nil then
        if not hTarget:HasModifier("modifier_knockback")  then
            local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf", PATTACH_POINT, caster)
            ParticleManager:SetParticleControl(nfx, 0, hTarget:GetAbsOrigin())
            ParticleManager:SetParticleControl(nfx, 1, hTarget:GetAbsOrigin())
            ParticleManager:SetParticleControl(nfx, 2, hTarget:GetAbsOrigin())
			EmitSoundOn("Hero_Rattletrap.Chasm_Strike.Target", hTarget)
            hTarget:ApplyKnockBack(hTarget:GetAbsOrigin(), 0.5, 0.5, 0, 350, caster, self)
			
			local talentTarget
			if caster:HasTalent("special_bonus_unique_sand_claw_impact_2") and self.projectiles[tostring(projectileID)] == nil then -- need tri-state
				for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(hTarget:GetAbsOrigin(), self:GetTrueCastRange(), {order = FIND_CLOSEST} ) ) do
					if hTarget ~= enemy then
						talentTarget = enemy
						self.projectiles[tostring(projectileID)] = false -- keep original damage, but prevent splintering
						break
					end
				end
			end
			
            Timers:CreateTimer(0.5,function()
                self:Stun(hTarget, self:GetTalentSpecialValueFor("duration"), false)
				if not self.projectiles[tostring(projectileID)] then -- false or nil
					self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
				else
					self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage") * caster:FindTalentValue("special_bonus_unique_sand_claw_impact_2") / 100, {}, 0)
				end
				
                if talentTarget then -- need tri-state
					self:SpikeLaunch(hTarget:GetAbsOrigin(), CalculateDirection(talentTarget, hTarget), true)
					self.projectiles[tostring(projectileID)] = false -- keep original damage, but prevent splintering
                end
            end)
        end
	else
		print("deleting")
		self.projectiles[tostring(projectileID)] = nil
    end
end