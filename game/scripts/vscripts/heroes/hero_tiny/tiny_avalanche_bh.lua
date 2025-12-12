--Thanks Dota Imba
tiny_avalanche_bh = class({})

function tiny_avalanche_bh:IsStealable()
    return true
end

function tiny_avalanche_bh:IsHiddenWhenStolen()
    return false
end

function tiny_avalanche_bh:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_tiny_avalanche_bh_1") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_tiny_avalanche_bh_1") end
    return cooldown
end

function tiny_avalanche_bh:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function tiny_avalanche_bh:OnSpellStart()
    local vPos = self:GetCursorPosition()
    local caster = self:GetCaster()

    local delay = self:GetSpecialValueFor("projectile_duration")
    self.casterPos = caster:GetAbsOrigin()
    local distance = CalculateDistance(vPos, self.casterPos)
    self.direction = CalculateDirection(vPos, self.casterPos)
    local velocity = distance/delay * self.direction
    local ticks = 1 / self:GetSpecialValueFor("tick_interval")
    velocity.z = 0

    local info = 
    {
        Ability = self,
        EffectName = "particles/units/heroes/hero_tiny/tiny_avalanche_projectile.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = distance,
        fStartRadius = 0,
        fEndRadius = 0,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = false,
        vVelocity = velocity,
        bProvidesVision = true,
        iVisionRadius = 200,
        iVisionTeamNumber = caster:GetTeamNumber(),
        ExtraData = {ticks = ticks}
    }
    ProjectileManager:CreateLinearProjectile(info)
    EmitSoundOnLocationWithCaster(vPos, "Ability.Avalanche", caster)
end

function tiny_avalanche_bh:OnProjectileHit_ExtraData(hTarget, vLocation, extradata)
    local caster = self:GetCaster()
	
    local duration = self:GetSpecialValueFor("stun_duration")
    local radius = self:GetSpecialValueFor("radius")

    local interval = self:GetSpecialValueFor("tick_interval")
    local damage = self:GetSpecialValueFor("damage") * self:GetSpecialValueFor("tick_interval")
    self.repeat_increase = false
    local avalanche = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_avalanche.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(avalanche, 0, vLocation + self.direction)
    ParticleManager:SetParticleControlOrientation(avalanche, 0, self.direction, self.direction, caster:GetUpVector())
    ParticleManager:SetParticleControl(avalanche, 1, Vector(radius, 1, radius/2))
    local offset = 0
    local ticks = extradata.ticks
    local hitLoc = vLocation
	local spellBlocked = {}
    Timers:CreateTimer(function()
        GridNav:DestroyTreesAroundPoint(hitLoc, radius, false)
        local enemies_tick = caster:FindEnemyUnitsInRadius(hitLoc, radius)
        for _,enemy in pairs(enemies_tick) do
			if not spellBlocked[enemy] and not enemy:TriggerSpellAbsorb( self ) then
				if enemy:HasModifier("modifier_tiny_toss_bh") and not self.repeat_increase then
					damage = damage * 2
					self.repeat_increase = true
				end
				self:DealDamage(caster, enemy, damage, {}, 0)

				if caster:HasScepter() then
					enemy:ApplyKnockBack(self.casterPos, duration, duration, radius, 0, caster, self)
				else
					self:Stun(enemy, duration, false)
				end
			else
				spellBlocked[enemy] = true
			end
        end
        hitLoc = hitLoc + offset / ticks
        extradata.ticks = extradata.ticks - 1
        if extradata.ticks > 0 then
            return interval
        else
            ParticleManager:DestroyParticle(avalanche, false)
            ParticleManager:ReleaseParticleIndex(avalanche)
        end
    end)
end