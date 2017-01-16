function VampiricHeal(keys)
	local caster = keys.caster
	local target = keys.attacker
	local ability = keys.ability
	
	local hpMax = target:GetMaxHealth()
	local hpPerc = ability:GetTalentSpecialValueFor("aura_lifesteal") / 100
	if keys.target:HasModifier("modifier_skeleton_king_wraithfire_blast_dot") then
		local wraithfire = caster:FindAbilityByName("skeleton_king_wraithfire_blast_ebf")
		local bonusheal = wraithfire:GetTalentSpecialValueFor("blast_dot_lifesteal") / 100
		hpPerc = hpPerc + bonusheal
	end
	print(hpPerc)
	target:Heal(hpMax*hpPerc, caster)
end

function VampiricActiveHeal(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local healPerc = ability:GetTalentSpecialValueFor("life_leeched") / 100
	local heal = ability:GetAbilityDamage() * healPerc
	if caster:GetHealth() + heal > caster:GetMaxHealth() then
		local difference = caster:GetMaxHealth() - caster:GetHealth()
		caster:Heal(difference, caster)
		local particle1 = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle1, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true) 
		ParticleManager:SetParticleControlEnt(particle1, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle1)
		local spreadheal = heal - difference
		local allies = FindUnitsInRadius(caster:GetTeam(),
                              caster:GetAbsOrigin(),
                              caster,
                              ability:GetTalentSpecialValueFor("aura_radius"),
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
		for _, ally in pairs(allies) do
			if spreadheal > 0 then
				if ally:GetHealth() < ally:GetMaxHealth() then
					if ally:GetHealth() + spreadheal > ally:GetMaxHealth() then
						local consumed = ally:GetMaxHealth() - ally:GetHealth()
						ally:Heal(consumed, caster)
						local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
						ParticleManager:SetParticleControlEnt(particle2, 0, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true) 
						ParticleManager:SetParticleControlEnt(particle2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
						ParticleManager:ReleaseParticleIndex(particle2)
						spreadheal = heal - consumed
					else
						ally:Heal(spreadheal, caster)
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
		caster:Heal(heal, caster)
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true) 
		ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)
	end
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
end


skeleton_king_wraithfire_blast_ebf = class({})

if IsServer() then
	function skeleton_king_wraithfire_blast_ebf:OnAbilityPhaseStart()
		self.warmUp = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_warmup.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.warmUp, 0, self:GetCaster(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
		return true
	end
	function skeleton_king_wraithfire_blast_ebf:OnAbilityPhaseInterrupted()
		ParticleManager:DestroyParticle(self.warmUp ,false)
		ParticleManager:ReleaseParticleIndex(self.warmUp)
	end
	function skeleton_king_wraithfire_blast_ebf:OnSpellStart()
		ParticleManager:DestroyParticle(self.warmUp ,false)
		ParticleManager:ReleaseParticleIndex(self.warmUp)
		local projectile = {
			Target = self:GetCursorTarget(),
			Source = self:GetCaster(),
			Ability = self,
			EffectName = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf",
			bDodgable = true,
			bProvidesVision = false,
			iMoveSpeed = self:GetTalentSpecialValueFor("blast_speed"),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
		}
		ProjectileManager:CreateTrackingProjectile(projectile)
		EmitSoundOn("Hero_SkeletonKing.Hellfire_Blast", self:GetCaster())
	end

	function skeleton_king_wraithfire_blast_ebf:OnProjectileHit(target, position)
		EmitSoundOn("Hero_SkeletonKing.Hellfire_BlastImpact", target)
		local caster = self:GetCaster()
		local radius = self:GetTalentSpecialValueFor("blast_dot_radius")
		ApplyDamage({victim = target, attacker = caster, damage = self:GetAbilityDamage(), damage_type = self:GetAbilityDamageType(), ability = self})
		local enemies = FindUnitsInRadius(caster:GetTeam(),
                              target:GetAbsOrigin(),
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
		local duration = self:GetSpecialValueFor("blast_dot_duration")
		target:AddNewModifier(caster, self, "modifier_stunned", {duration = self:GetSpecialValueFor("blast_stun_duration")})
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, self, "modifier_skeleton_king_wraithfire_blast_dot", {duration = duration})
		end
		local explosion = ParticleManager:CreateParticle("particles/frostivus_gameplay/frostivus_skeletonking_hellfireblast_explosion_ebf.vpcf", PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControl(explosion, 1, Vector(radius,0,0))
			ParticleManager:SetParticleControl(explosion, 3, target:GetAbsOrigin())
	end
end

LinkLuaModifier( "modifier_skeleton_king_wraithfire_blast_dot", "lua_abilities/heroes/wraith_king.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_skeleton_king_wraithfire_blast_dot = class({})

function modifier_skeleton_king_wraithfire_blast_dot:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("blast_dot_damage")
	self.slow = self:GetAbility():GetSpecialValueFor("blast_slow")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_skeleton_king_wraithfire_blast_dot:OnIntervalThink()
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
end

function modifier_skeleton_king_wraithfire_blast_dot:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf"
end

function modifier_skeleton_king_wraithfire_blast_dot:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_skeleton_king_wraithfire_blast_dot:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end