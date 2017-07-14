justicar_shining_light = class({})

function justicar_shining_light:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local cast = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(cast)
	
	
	if caster:HasTalent("justicar_shining_light_talent_1") then
		local radius = caster:FindTalentValue("justicar_shining_light_talent_1")
		local targets = caster:FindEnemyUnitsInRadius(target:FindAbsOrigin(), radius, {team = DOTA_UNIT_TARGET_TEAM_BOTH})
		for _, target in pairs(targets) do
			
		end
	else
	end
end

function justicar_shining_light:AllyEnemyActions(target, damageheal)
	local target = ParticleManager:CreateParticle("", PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControl(target, 1, Vector(target:GetHullRadius(), target:GetHullRadius() * 2, target:GetHullRadius() * 2 ))
	ParticleManager:ReleaseParticleIndex(target)
	if target:GetTeam() == self:GetCaster():GetTeam() then
		target:HealEvent(damageheal, self, self:GetCaster())
	else
		
	end
end