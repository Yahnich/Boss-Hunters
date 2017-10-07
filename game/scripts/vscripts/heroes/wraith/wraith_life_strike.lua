wraith_life_strike = class({})

function wraith_life_strike:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Magnataur.ShockWave.Cast", self:GetCaster())
	self.warmUp = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_warmup.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.warmUp, 0, self:GetCaster(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	return true
end

function wraith_life_strike:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Magnataur.ShockWave.Cast", self:GetCaster())
	ParticleManager:DestroyParticle(self.warmUp ,false)
	ParticleManager:ReleaseParticleIndex(self.warmUp)
end

function wraith_life_strike:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local vDir = CalculateDirection(position, caster)
	local speed = self:GetSpecialValueFor("wave_speed")
	local velocity = vDir * speed
	local distance = self:GetSpecialValueFor("wave_distance")
	local width = self:GetSpecialValueFor("wave_width")
	self:FireLinearProjectile("particles/heroes/wraith/wraith_life_strikewave.vpcf", velocity, distance, width)
	if self:GetCaster():HasTalent("wraith_life_strike_talent_1") then
		local strikes = 8
		local angleVel = ToRadians(360/strikes)
		for i = 1, strikes do
			vDir = RotateVector2D(vDir, angleVel)
			velocity = vDir * speed
			self:FireLinearProjectile("particles/heroes/wraith/wraith_life_strikewave.vpcf", velocity, distance, width)
		end
	end
end

function wraith_life_strike:OnProjectileHit(target, position)
	if not target then return end
	local caster = self:GetCaster()
	
	local damage = self:GetSpecialValueFor("wave_damage")
	local healPerc = self:GetTalentSpecialValueFor("life_leeched") / 100
	local heal = damage * healPerc
	if caster:GetHealth() + heal > caster:GetMaxHealth() then
		local difference = caster:GetMaxHealth() - caster:GetHealth()
		caster:HealEvent(difference, self, caster)
		local particle1 = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle1, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true) 
		ParticleManager:SetParticleControlEnt(particle1, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle1)
		local spreadheal = heal - difference
		print(difference, spreadheal, "first spread")	
		local allies = FindUnitsInRadius(caster:GetTeam(),
                              caster:GetAbsOrigin(),
                              caster,
                              900,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
		for _, ally in pairs(allies) do
			if spreadheal > 0 and ally ~= caster then
				print("spreading", ally:GetHealth(), ally:GetMaxHealth())
				if ally:GetHealth() < ally:GetMaxHealth() then
					if ally:GetHealth() + spreadheal > ally:GetMaxHealth() then
						local consumed = ally:GetMaxHealth() - ally:GetHealth()
						ally:HealEvent(consumed, self, caster)
						local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
						ParticleManager:SetParticleControlEnt(particle2, 0, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true) 
						ParticleManager:SetParticleControlEnt(particle2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
						ParticleManager:ReleaseParticleIndex(particle2)
						spreadheal = heal - consumed
					else
						ally:HealEvent(spreadheal, self, caster)
						local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
						ParticleManager:SetParticleControlEnt(particle2, 0, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true) 
						ParticleManager:SetParticleControlEnt(particle2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(particle2)
						break
					end
				end
			else
				break
			end
		end
	else
		caster:HealEvent(heal, self, caster)
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true) 
		ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)
	end
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType(), ability = self})
end