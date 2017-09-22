forest_vine_whip = class({})

function forest_vine_whip:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local vDir = CalculateDirection( self:GetCursorPosition(), caster ) * Vector(1,1,0)
	
	local distance = self:GetTrueCastRange()
	local speed = self:GetSpecialValueFor("speed") * FrameTime()
	local width = self:GetSpecialValueFor("width")
	local damage = self:GetSpecialValueFor("damage")
	local stunDuration = self:GetSpecialValueFor("stun_duration")

	local projectilePos = caster:GetAbsOrigin() + Vector(0,0,100)
	
	EmitSoundOn("Hero_Enchantress.EnchantCast", caster)
	
	local projectile = ParticleManager:CreateParticle("particles/heroes/forest/forest_vine_whip_projectile.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(projectile, 0, projectilePos)
	ParticleManager:SetParticleControlEnt(projectile, 3, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	
	local distTravelled = 0
	hitTargets = {}
	Timers:CreateTimer(function()
		projectilePos = projectilePos + vDir * speed
		ParticleManager:SetParticleControl(projectile, 0, projectilePos)
		distTravelled = distTravelled + speed
		
		local enemies = caster:FindEnemyUnitsInRadius(projectilePos, width)
		for _, enemy in ipairs(enemies) do
			if not hitTargets[enemy:entindex()] then
				ability:DealDamage(caster, enemy, damage)
				enemy:AddNewModifier(caster, ability, "modifier_stunned_generic", {duration = stunDuration})
				hitTargets[enemy:entindex()] = true
				EmitSoundOn("Hero_Enchantress.Untouchable", caster)
			end
		end
		if caster:HasTalent("forest_vine_whip_talent_1") then
			local allies = caster:FindFriendlyUnitsInRadius(projectilePos, width)
			for _, ally in ipairs(allies) do
				if not hitTargets[ally:entindex()] then
					ally:HealEvent(damage, ability, caster)
					ally:Dispel(caster, true)
					hitTargets[ally:entindex()] = true
					EmitSoundOn("Hero_Enchantress.Untouchable", caster)
				end
			end
		end
		
		if distTravelled < distance then
			return FrameTime()
		else
			ParticleManager:DestroyParticle(projectile, true)
			ParticleManager:ReleaseParticleIndex(projectile)
		end
	end)
end


modifier_forest_vine_whip_talent_1 = class({IsHidden = function(self) return true end, RemoveOnDeath = function(self) return false end, AllowIllusionDuplicate = function(self) return true end})