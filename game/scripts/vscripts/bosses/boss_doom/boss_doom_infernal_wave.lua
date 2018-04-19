boss_doom_infernal_wave = class({})

function boss_doom_infernal_wave:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local ogPos = caster:GetAbsOrigin() + caster:GetForwardVector() * self:GetSpecialValueFor("radius")
	local rightPos = ogPos + caster:GetRightVector() * self:GetSpecialValueFor("raze_spacing") * (self:GetSpecialValueFor("razes_per_line") - 1) / 2
	local leftPos = ogPos - caster:GetRightVector() * self:GetSpecialValueFor("raze_spacing") * (self:GetSpecialValueFor("razes_per_line") - 1) / 2
	ParticleManager:FireLinearWarningParticle( leftPos, rightPos, self:GetSpecialValueFor("radius") * 2 )
	return true
end

function boss_doom_infernal_wave:OnSpellStart()
	local caster = self:GetCaster()

	local waves = self:GetSpecialValueFor("waves")
	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("radius")
	local rSpacing = self:GetSpecialValueFor("raze_spacing")
	local rPerLine = self:GetSpecialValueFor("razes_per_line")
	local wSpacing = self:GetSpecialValueFor("wave_spacing")
	local wDelay = self:GetCastPoint()
	
	local direction = caster:GetForwardVector()
	local normal = GetPerpendicularVector(direction)
	local ogPos = caster:GetAbsOrigin() + direction * radius
	local startPos = ogPos + normal * rSpacing * ( rPerLine - 1) / 2
	local endPos = ogPos - normal * rSpacing * ( rPerLine - 1 ) / 2

	
	local ability = self
	Timers:CreateTimer(0, function()
		waves = waves - 1
		
		
		ability:CreateRazeLine(ogPos, normal)
		ogPos = ogPos + direction * wSpacing
		startPos = startPos + direction * wSpacing
		endPos = endPos + direction * wSpacing
		ParticleManager:FireLinearWarningParticle(startPos, endPos, radius * 2)
		
		if waves > 0 then
			return wDelay
		end
	end)
end

function boss_doom_infernal_wave:CreateRazeLine(ogPos, normal)
	local caster = self:GetCaster()

	local rSpacing = self:GetSpecialValueFor("raze_spacing")
	local razes = self:GetSpecialValueFor("razes_per_line")
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	
	EmitSoundOnLocationWithCaster(ogPos, "Hero_Nevermore.Shadowraze.Arcana", caster)
	for i = 0, razes - 1 do
		local position = ogPos + normal * math.floor(i/2) * (-1)^(i) * rSpacing
		ParticleManager:FireParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position})

		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(position, radius) ) do
			self:DealDamage( caster, enemy, damage )
		end
	end
end