furion_natures_wrath = class({})

function furion_natures_wrath:IsStealable()
	return true
end

function furion_natures_wrath:IsHiddenWhenStolen()
	return false
end

function furion_natures_wrath:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()

	local previousEnemy = caster

	local damage = self:GetTalentSpecialValueFor("damage")
	local reviveDuration = self:GetTalentSpecialValueFor("revive_duration")

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_wrath_of_nature_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)

	EmitSoundOn("Hero_Furion.WrathOfNature_Cast.Self", caster)
	
	local hitTable = {}
	
	local entangle = caster:FindAbilityByName("furion_entangle")
	local talent2Chance = caster:FindTalentValue("special_bonus_unique_furion_natures_wrath_2")
	local talent2Duration = caster:FindTalentValue("special_bonus_unique_furion_natures_wrath_2", "duration")

	Timers:CreateTimer(0,function()
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(previousEnemy:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {order = FIND_CLOSEST})
		for _,enemy in pairs(enemies) do
			if not hitTable[enemy:entindex()] then -- only hit every target once
				--Spare ourselves sound complaints
				--EmitSoundOn("Hero_Furion.WrathOfNature_Damage.Creep", enemy)
				hitTable[enemy:entindex()] = true
				if not enemy:TriggerSpellAbsorb(self) then
					if caster:HasTalent("special_bonus_unique_furion_natures_wrath_2") and RollPercentage( talent2Chance ) then
						enemy:AddNewModifier(caster, entangle, "modifier_entangle_enemy", {duration = talent2Duration})
					end
					
					enemy:AddNewModifier(caster, self, "modifier_furion_natures_wrath_revive", {duration = reviveDuration})

					local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_wrath_of_nature.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(particle, 0, previousEnemy, PATTACH_POINT_FOLLOW, "attach_hitloc", previousEnemy:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(particle, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(particle, 2, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(particle, 3, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(particle, 4, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(particle)
					
					
					self:DealDamage(caster, enemy, damage, {}, 0)
					damage = damage + damage * self:GetTalentSpecialValueFor("damage_add") / 100

					previousEnemy = enemy

					return self:GetTalentSpecialValueFor("jump_delay")
				end
			end -- no valid targets found
		end
		StopSoundOn("Hero_Furion.WrathOfNature_Cast.Self", caster)
		return nil
	end)
end

modifier_furion_natures_wrath_revive = class({})
LinkLuaModifier( "modifier_furion_natures_wrath_revive", "heroes/hero_furion/furion_natures_wrath",LUA_MODIFIER_MOTION_NONE )

function modifier_furion_natures_wrath_revive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_furion_natures_wrath_revive:OnDeath(params)
	if params.unit == self:GetParent() then
		local treants = self:GetCaster():FindAbilityByName("furion_tree_ant")
		if treants then treants:SpawnTreant( self:GetParent():GetAbsOrigin(), params.unit:IsMinion() ) end
	end
end