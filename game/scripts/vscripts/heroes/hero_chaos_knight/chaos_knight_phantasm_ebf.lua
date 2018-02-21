chaos_knight_chaos_bolt_ebf = class({})

function chaos_knight_chaos_bolt_ebf:IsStealable()
	return true
end

function chaos_knight_chaos_bolt_ebf:IsHiddenWhenStolen()
	return false
end

if IsServer() then
	function chaos_knight_chaos_bolt_ebf:OnSpellStart()
		local projectile = {
			Target = self:GetCursorTarget(),
			Source = self:GetCaster(),
			Ability = self,
			EffectName = "particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf",
			bDodgable = true,
			bProvidesVision = false,
			iMoveSpeed = self:GetTalentSpecialValueFor("chaos_bolt_speed"),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		}
		ProjectileManager:CreateTrackingProjectile(projectile)
		EmitSoundOn("Hero_ChaosKnight.ChaosBolt.Cast", self:GetCaster())
	end

	function chaos_knight_chaos_bolt_ebf:OnProjectileHit(target, position)
		local caster = self:GetCaster()
		local target_location = target:GetAbsOrigin()
		EmitSoundOn("Hero_ChaosKnight.ChaosBolt.Impact", target)
		-- Ability variables
		local stun_min = self:GetTalentSpecialValueFor("stun_min")
		local stun_max = self:GetTalentSpecialValueFor("stun_max") 
		local damage_min = self:GetTalentSpecialValueFor("damage_min") 
		local damage_max = self:GetTalentSpecialValueFor("damage_max")
		local chaos_bolt_particle = "particles/units/heroes/hero_chaos_knight/chaos_knight_bolt_msg.vpcf"

		-- Calculate the stun and damage values
		local random = RandomFloat(0, 1)
		local stun = stun_min + (stun_max - stun_min) * random
		local damage = damage_min + (damage_max - damage_min) * (1 - random)

		-- Calculate the number of digits needed for the particle
		local stun_digits = string.len(tostring(math.floor(stun))) + 1
		local damage_digits = string.len(tostring(math.floor(damage))) + 1

		-- Create the stun and damage particle for the spell
		local particle = ParticleManager:CreateParticle(chaos_bolt_particle, PATTACH_OVERHEAD_FOLLOW, target)
		ParticleManager:SetParticleControl(particle, 0, target_location) 

		-- Damage particle
		ParticleManager:SetParticleControl(particle, 1, Vector(9,damage,4)) -- prefix symbol, number, postfix symbol
		ParticleManager:SetParticleControl(particle, 2, Vector(2,damage_digits,0)) -- duration, digits, 0

		-- Stun particle
		ParticleManager:SetParticleControl(particle, 3, Vector(8,stun,0)) -- prefix symbol, number, postfix symbol
		ParticleManager:SetParticleControl(particle, 4, Vector(2,stun_digits,0)) -- duration, digits, 0
		ParticleManager:ReleaseParticleIndex(particle)

		-- Apply the stun duration
		target:AddNewModifier(caster, self, "modifier_stunned", {duration = stun})

		-- Initialize the damage table and deal the damage
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType(), ability = self})
		if RollPercentage(self:GetTalentSpecialValueFor("bounce_chance")) then
			local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetCastRange(target:GetAbsOrigin(), target), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			if #units > 0 then
				for _,unit in pairs(units) do
					local projectile = {
						Target = unit,
						Source = target,
						Ability = self,
						EffectName = "particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf",
						bDodgable = true,
						bProvidesVision = false,
						iMoveSpeed = self:GetTalentSpecialValueFor("chaos_bolt_speed"),
						iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
					}
					ProjectileManager:CreateTrackingProjectile(projectile)
					break
				end
			end
		end
	end
end