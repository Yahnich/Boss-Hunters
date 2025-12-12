tinker_missile_ebf = class({})

function tinker_missile_ebf:OnSpellStart()
	local caster = self:GetCaster()

    local particleName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf"
    local projectileSpeed = self:GetSpecialValueFor( "speed")
    local radius = self:GetSpecialValueFor( "radius")
    local max_targets = self:GetSpecialValueFor( "targets")

    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius, {order = FIND_CLOSEST}) 
    if #enemies > 0 then
	    EmitSoundOn("Hero_Tinker.Heat-Seeking_Missile", caster)
	    local count = 0
	    for _,enemy in pairs( enemies ) do
	        if count < max_targets then
	            self:FireTrackingProjectile(particleName, enemy, projectileSpeed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_3, false, true, 100)
	            count = count + 1
	        else
	            break
	        end
	    end
	else
		self:EndCooldown()
		self:RefundManaCost()
	end
end

function tinker_missile_ebf:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget ~= nil and not hTarget:TriggerSpellAbsorb( self ) then
		EmitSoundOn("Hero_Tinker.Heat-Seeking_Missile.Impact", hTarget)
		ParticleManager:FireParticle("particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf", PATTACH_POINT, hTarget, {})

		if caster:HasTalent("special_bonus_unique_tinker_missile_ebf_2") then
			self:Stun(hTarget, caster:FindTalentValue("special_bonus_unique_tinker_missile_ebf_2"), false)
		end

		self:DealDamage(caster, hTarget, self:GetSpecialValueFor("damage"), {}, 0)
	end
end