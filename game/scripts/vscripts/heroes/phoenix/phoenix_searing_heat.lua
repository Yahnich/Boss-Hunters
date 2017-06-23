phoenix_searing_heat = class({})

function phoenix_searing_heat:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_phoenix_kindled_soul_active") then
		return "custom/phoenix_searing_heat_kindled"
	else
		return "custom/phoenix_searing_heat"
	end
end

function phoenix_searing_heat:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Ability.LagunaBlade", caster)
	Timers:CreateTimer(0.25, function()
		if caster:HasModifier("modifier_phoenix_kindled_soul_active") then
			self:EndCooldown()
			self:UseResources(true, false, false)
		end
		self:CreateSearingHeat(target, caster)
		if caster:HasTalent("phoenix_searing_heat_talent_1") then
			local newTarget
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), target:GetAbsOrigin(), nil, caster:FindTalentValue("phoenix_searing_heat_talent_1"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
			for _, enemy in pairs(enemies) do
				newTarget = enemy
				break
			end
			if newTarget then
				Timers:CreateTimer(0.25, function()
					self:CreateSearingHeat(newTarget, target)
				end)
			end
		end
	end)
end

function phoenix_searing_heat:CreateSearingHeat(target, origin)
	searingFX = ParticleManager:CreateParticle("particles/heroes/phoenix/phoenix_searing_heat.vpcf", PATTACH_POINT_FOLLOW, origin)
	ParticleManager:SetParticleControlEnt(searingFX, 0, origin, PATTACH_POINT_FOLLOW, "attach_attack1", origin:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(searingFX, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	EmitSoundOn("Ability.LagunaBladeImpact", target)
	self:GetCaster().selfImmolationDamageBonus = self:GetCaster().selfImmolationDamageBonus or 0
	ApplyDamage({victim = target, attacker = self:GetCaster(), damage = self:GetTalentSpecialValueFor("damage") + self:GetCaster().selfImmolationDamageBonus, damage_type = self:GetAbilityDamageType(), ability = self})
end