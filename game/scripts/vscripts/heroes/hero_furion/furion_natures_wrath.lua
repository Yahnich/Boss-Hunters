furion_natures_wrath = class({})
LinkLuaModifier( "modifier_sprout_tp", "heroes/hero_furion/furion_sprout_tp.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_entangle_enemy", "heroes/hero_furion/furion_entangle.lua",LUA_MODIFIER_MOTION_NONE )

function furion_natures_wrath:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()

	local maxBounces = self:GetTalentSpecialValueFor("max_bounces")
	local currentBounces = 0
	local previousEnemy = caster

	local damage = self:GetTalentSpecialValueFor("damage")

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_wrath_of_nature_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)

	EmitSoundOn("Hero_Furion.WrathOfNature_Cast.Self", caster)

	Timers:CreateTimer(0,function()
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(point, FIND_UNITS_EVERYWHERE, {})
		for _,enemy in pairs(enemies) do
			if currentBounces < maxBounces then
				--Spare ourselves sound complaints
				--EmitSoundOn("Hero_Furion.WrathOfNature_Damage.Creep", enemy)

				if caster:HasTalent("special_bonus_unique_furion_natures_wrath_1") and enemy:HasModifier("modifier_entangle_enemy") then
					self:Stun(enemy, 0.25, false)
				end

				if caster:HasTalent("special_bonus_unique_furion_natures_wrath_2") and RollPercentage(5) then
					enemy:AddNewModifier(caster, caster:FindAbilityByName("furion_entangle"), "modifier_entangle_enemy", {Duration = 1})
				end

				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_wrath_of_nature.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(particle, 0, previousEnemy, PATTACH_POINT_FOLLOW, "attach_hitloc", previousEnemy:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(particle, 2, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(particle, 3, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(particle, 4, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(particle)

				self:DealDamage(caster, enemy, damage, {}, 0)
				damage = damage + self:GetTalentSpecialValueFor("damage_add")

				previousEnemy = enemy
				currentBounces = currentBounces + 1

				return self:GetTalentSpecialValueFor("jump_delay")
			else
				StopSoundOn("Hero_Furion.WrathOfNature_Cast.Self", caster)
				return nil
			end
		end
	end)

	self:StartDelayedCooldown(maxBounces*self:GetTalentSpecialValueFor("jump_delay"))
end
