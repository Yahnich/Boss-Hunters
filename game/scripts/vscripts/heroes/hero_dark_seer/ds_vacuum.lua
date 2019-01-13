ds_vacuum = class({})

function ds_vacuum:IsStealable()
    return true
end

function ds_vacuum:IsHiddenWhenStolen()
    return false
end

function ds_vacuum:GetAOERadius()
	if self:GetCaster():HasTalent("special_bonus_unique_ds_vacuum_1") then
		return 100
	end
    return self:GetTalentSpecialValueFor("radius")
end

function ds_vacuum:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local radius = self:GetTalentSpecialValueFor("radius")

	self.hitUnits = {}

	if caster:HasTalent("special_bonus_unique_ds_vacuum_1") then
		radius = 100
		local distance = self:GetTrueCastRange()
		local direction = caster:GetForwardVector()
		point = caster:GetAbsOrigin() + direction * radius

		Timers:CreateTimer(0, function()
			if distance > 0 then
				EmitSoundOnLocationWithCaster(point, "Hero_Dark_Seer.Vacuum", caster)
				self:Vacuum(point, radius)
				point = point + direction * radius
				distance = distance - radius
				return 0.1
			else
				return nil
			end
		end)
	else
		EmitSoundOnLocationWithCaster(point, "Hero_Dark_Seer.Vacuum", caster)
		self:Vacuum(point, radius)
	end
end

function ds_vacuum:Vacuum(vlocation, iRadius)
	local caster = self:GetCaster()
	local damage = self:GetTalentSpecialValueFor("damage")
	local duration = self:GetTalentSpecialValueFor("duration")

	local radius = iRadius

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, vlocation)
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
				ParticleManager:SetParticleControl(nfx, 2, vlocation)
				ParticleManager:ReleaseParticleIndex(nfx)

	local enemies = caster:FindEnemyUnitsInRadius(vlocation, radius)
	local talent2 = caster:HasTalent("special_bonus_unique_ds_vacuum_2")
	for _,enemy in pairs(enemies) do
		if not self.hitUnits[enemy:entindex()] then
			local knockback = enemy:ApplyKnockBack(vlocation, duration, duration, -CalculateDistance(enemy, vlocation), 0, caster, self)
			Timers:CreateTimer(duration, function()
				self:DealDamage(caster, enemy, damage)
				if talent2 and enemy:IsAlive() then enemy:Paralyze(self, caster, 1) end
			end)

			self.hitUnits[enemy:entindex()] = true
        end
	end

	GridNav:DestroyTreesAroundPoint(vlocation, radius, false)
end