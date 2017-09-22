forest_become_one = class({})

function forest_become_one:OnAbilityPhaseStart()
	self.preFX = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_teleport.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.preFX, 0, self:GetCaster():GetAbsOrigin())
	self.postFX = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_teleport_end.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.postFX, 1, self:GetCursorPosition())
	EmitSoundOn("Hero_Furion.Teleport_Grow", self:GetCaster())
	return true
end

function forest_become_one:OnAbilityPhaseInterrupted()
	ParticleManager:DestroyParticle(self.preFX, false)
	ParticleManager:ReleaseParticleIndex(self.preFX)
	ParticleManager:DestroyParticle(self.postFX, false)
	ParticleManager:ReleaseParticleIndex(self.postFX)
	StopSoundOn("Hero_Furion.Teleport_Grow", self:GetCaster())		
end

function forest_become_one:OnSpellStart()
	local caster = self:GetCaster()
	local tree = self:GetCursorTarget()
	
	self:OnAbilityPhaseInterrupted()
	
	if caster:HasTalent("forest_become_one_talent_1") then
		local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("talent_radius"))
		for _, ally in ipairs(allies) do
			if ally ~= caster then
				ally:HealEvent( heal + maxHPHeal, self, caster)
			end
		end
	end
	
	EmitSoundOn("Hero_Furion.Teleport_Disappear", caster)
	local newPos = tree:GetAbsOrigin()
	GridNav:DestroyTreesAroundPoint(newPos, caster:GetHullRadius() + 25, true)
	FindClearSpaceForUnit(caster, newPos, true)
	EmitSoundOn("Hero_Furion.Teleport_Appear", caster)
	
	local heal = self:GetSpecialValueFor("heal")
	local maxHPHeal = caster:GetMaxHealth() * self:GetSpecialValueFor("max_hp_heal") / 100
	caster:HealEvent( heal + maxHPHeal, self, caster)
	
	ParticleManager:FireParticle("particles/units/heroes/hero_furion/furion_teleport_flash.vpcf", PATTACH_POINT_FOLLOW, caster)

	if caster:HasTalent("forest_become_one_talent_1") then
		local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("talent_radius"))
		for _, ally in ipairs(allies) do
			if ally ~= caster then
				ally:HealEvent( heal + maxHPHeal, self, caster)
			end
		end
	end
end