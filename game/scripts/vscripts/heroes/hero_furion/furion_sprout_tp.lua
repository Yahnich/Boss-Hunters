furion_sprout_tp = class({})

function furion_sprout_tp:IsStealable()
	return true
end

function furion_sprout_tp:IsHiddenWhenStolen()
	return false
end

function furion_sprout_tp:GetCooldown(iLevel)
	local cooldown = self.BaseClass.GetCooldown(self, iLevel)
	if self:GetCaster():HasTalent("special_bonus_unique_furion_sprout_tp_1") then return 0 end
	return cooldown
end

function furion_sprout_tp:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("Hero_Furion.Teleport_Grow", caster)

	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_teleport.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(self.nfx, 0, caster:GetAbsOrigin())

	self.nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_teleport_end.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(self.nfx2, 1, point)
	
	return true
end

function furion_sprout_tp:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Furion.Teleport_Grow", caster)

	ParticleManager:DestroyParticle(self.nfx, false)
	ParticleManager:DestroyParticle(self.nfx2, false)
end

function furion_sprout_tp:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	FindClearSpaceForUnit(caster, point, true)

	GridNav:DestroyTreesAroundPoint(point, 150, true)

	ParticleManager:DestroyParticle(self.nfx, false)
	ParticleManager:DestroyParticle(self.nfx2, false)

	StopSoundOn("Hero_Furion.Teleport_Grow", caster)
	EmitSoundOn("Hero_Furion.Teleport_Disappear", caster)
	EmitSoundOn("Hero_Furion.Teleport_Appear", caster)

	Timers:CreateTimer(1, function()
		StopSoundOn("Hero_Furion.Teleport_Disappear", caster)
		StopSoundOn("Hero_Furion.Teleport_Appear", caster)
	end)
	if caster:HasTalent("special_bonus_unique_furion_sprout_tp_2") then
		local enemies = caster:FindEnemyUnitsInRadius(point, 500, {})
		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, caster:FindAbilityByName("furion_entangle"), "modifier_entangle_enemy", {Duration = caster:FindAbilityByName("furion_entangle"):GetTalentSpecialValueFor("duration")})
		end
	end
end