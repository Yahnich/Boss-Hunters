tinker_march = class({})

function tinker_march:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Tinker.March_of_the_Machines.Cast", self:GetCaster())
    return true
end

function tinker_march:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Tinker.March_of_the_Machines.Cast", self:GetCaster())
end

function tinker_march:OnSpellStart()
	local caster = self:GetCaster()
	
	local point = self:GetCursorPosition()
	local startPos = caster:GetAbsOrigin()
	local dir = CalculateDirection(point, startPos)	

	local max_robots = self:GetTalentSpecialValueFor("max_robots")
	local current_robots = 0

	EmitSoundOnLocationWithCaster(startPos, "Hero_Tinker.March_of_the_Machines", caster)
	Timers:CreateTimer(function()
		local randoVect = ActualRandomVector(self:GetTalentSpecialValueFor("spawn_radius"),-self:GetTalentSpecialValueFor("spawn_radius"))
        pointRando = startPos + randoVect
		if current_robots < max_robots then
			self:FireLinearProjectile("particles/units/heroes/hero_tinker/tinker_machine.vpcf", dir*self:GetTalentSpecialValueFor("speed"), self:GetTrueCastRange(), self:GetTalentSpecialValueFor("collision_radius"), {origin=pointRando}, false, true, self:GetTalentSpecialValueFor("collision_radius"))
			current_robots = current_robots + 1
			return self:GetTalentSpecialValueFor("spawn_rate")
		else
			return nil
		end
	end)
end

function tinker_march:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
	local caster = self:GetCaster()

	if hTarget ~= nil then
		local enemies = caster:FindEnemyUnitsInRadius(vLocation, self:GetTalentSpecialValueFor("splash_radius"))
		for _,enemy in pairs(enemies) do
			if caster:HasTalent("special_bonus_unique_tinker_march_1") then
				enemy:Paralyze(self, caster)
			end
			self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
		end
		if not caster:HasTalent("special_bonus_unique_tinker_march_2") then
			ProjectileManager:DestroyLinearProjectile(iProjectileHandle)
		end
	end
end

function tinker_march:OnProjectileThink(vLocation)
	GridNav:DestroyTreesAroundPoint(vLocation, self:GetSpecialValueFor("collision_radius"), false)
end