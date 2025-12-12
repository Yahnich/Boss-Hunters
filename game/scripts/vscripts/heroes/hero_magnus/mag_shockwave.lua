mag_shockwave = class({})

function mag_shockwave:IsStealable()
    return true
end

function mag_shockwave:IsHiddenWhenStolen()
    return false
end

function mag_shockwave:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Magnataur.ShockWave.Cast", self:GetCaster())
	return true
end

function mag_shockwave:OnSpellStart()
    local caster = self:GetCaster()
	self.startPos = caster:GetAbsOrigin()

	EmitSoundOn("Hero_Magnataur.ShockWave.Particle", caster)

    local dir = CalculateDirection(self:GetCursorPosition(), self.startPos)
    self.vel = dir * self:GetSpecialValueFor("speed")

	self.proj = self:FireLinearProjectile("particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf", self.vel, self:GetTrueCastRange(), self:GetSpecialValueFor("width"), {team=DOTA_UNIT_TARGET_TEAM_BOTH})

	if caster:HasTalent("special_bonus_unique_mag_shockwave_2") then
        local delay = caster:FindTalentValue("special_bonus_unique_mag_shockwave_2")
        Timers:CreateTimer(delay, function()
            self:FireLinearProjectile("particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf", self.vel, self:GetTrueCastRange(), self:GetSpecialValueFor("width"), {origin=self.startPos, team=DOTA_UNIT_TARGET_TEAM_BOTH})
        end)
    end
end

function mag_shockwave:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
    local caster = self:GetCaster()
    if hTarget ~= nil and not hTarget:TriggerSpellAbsorb( self ) then
    	if hTarget:GetTeam() ~= caster:GetTeam() then
    		EmitSoundOn("Hero_Magnataur.ShockWave.Target", hTarget)
        	ParticleManager:FireParticle("particles/units/heroes/hero_magnataur/magnataur_shockwave_hit.vpcf", PATTACH_POINT, hTarget, {})
            if iProjectileHandle ~= self.proj then
                self:DealDamage(caster, hTarget, self:GetSpecialValueFor("damage")/2, {}, 0)
            else
                self:DealDamage(caster, hTarget, self:GetSpecialValueFor("damage"), {}, 0)
            end

            if self:GetCaster():HasTalent("special_bonus_unique_mag_shockwave_1") and not hTarget:IsKnockedBack() then
                hTarget:ApplyKnockBack(vLocation, 0.25, 0.25, 0, 100, caster, self)
				self:DealDamage(caster, hTarget, caster:GetIntellect( false) * caster:FindTalentValue("special_bonus_unique_mag_shockwave_1") / 100)
            end
        else
        	if hTarget:HasModifier("modifier_mag_magnet") and hTarget ~= self:GetCaster() then
        		EmitSoundOn("Hero_Magnataur.ShockWave.Cast", hTarget)

        		ParticleManager:FireParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start.vpcf", PATTACH_POINT, hTarget, {})

        		local distance = CalculateDistance(hTarget:GetAbsOrigin(), self.startPos)
        		self:FireLinearProjectile("particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf", -2*self.vel, self:GetTrueCastRange(), self:GetSpecialValueFor("width"), {source=hTarget, origin=hTarget:GetAbsOrigin()})
        		
        		local enemies = self:GetCaster():FindEnemyUnitsInRadius(hTarget:GetAbsOrigin(), self:GetSpecialValueFor("magnet_radius"))
        		for _,enemy in pairs(enemies) do
					if not enemy:TriggerSpellAbsorb( self ) then
						enemy:ApplyKnockBack(hTarget:GetAbsOrigin(), 1.0, 1.0, self:GetSpecialValueFor("magnet_radius")/2, 200, self:GetCaster(), self)
						self:DealDamage(self:GetCaster(), enemy, self:GetSpecialValueFor("damage_magnet"), {}, 0)
					end
        		end
        		ProjectileManager:DestroyLinearProjectile(iProjectileHandle)
        	end
        end
    end
end