boss16_conflagration = class({})

function boss16_conflagration:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local direction = CalculateDirection(position, caster)
	
	if caster:GetHealthPercent() < 66 then
		local startPos = caster:GetAbsOrigin() + direction * 128
		local endPos = startPos + direction * self:GetSpecialValueFor("length") 
		ParticleManager:FireLinearWarningParticle(startPos, endPos, self:GetSpecialValueFor("radius"))
	else
		ParticleManager:FireWarningParticle(self:GetCursorPosition(), self:GetSpecialValueFor("radius"))
	end
	return true
end

function boss16_conflagration:OnSpellStart()
	EmitSoundOn("Hero_Jakiro.Macropyre.Cast", self:GetCaster())
	local position = self:GetCursorPosition()
	local caster = self:GetCaster()
	local direction = CalculateDirection(position, caster)
	if self:GetCaster():GetHealthPercent() < 33 and self:GetLevel() > 2 then
		local spread = self:GetSpecialValueFor("cone_spread")
		local pathCount = (spread/30) * 2
		for i = 0, pathCount do
			local newDir = RotateVector2D(direction, ToRadians(15*(i/2)*(-1^i)) )
			self:CreateFirePath(newDir)
		end
	else
		self:CreateFirePath(direction)
	end
end

function boss16_conflagration:CreateFirePath(direction)
	local caster = self:GetCaster()
	local ability = self
	
	local initialPosition = self:GetCursorPosition()
	local endPos = initialPosition
	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage_over_time")
	if caster:GetHealthPercent() < 66 and self:GetLevel() > 2 then
		initialPosition = caster:GetAbsOrigin() + direction * 128
		endPos = endPos + direction * self:GetSpecialValueFor("length") 
	end
	
	local fireFX = ParticleManager:CreateParticle("particles/units/bosses/boss_dragon/boss_dragon_conflagration.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(fireFX, 0, initialPosition)
	ParticleManager:SetParticleControl(fireFX, 1, endPos)
	ParticleManager:SetParticleControl(fireFX, 2, Vector(duration, 0, 0))
	
	local timer = 0
	Timers:CreateTimer(1, function()
		if not caster or caster:IsNull() then return nil end
		local enemies = caster:FindEnemyUnitsInLine(initialPosition, endPos, radius)
		for _, enemy in ipairs(enemies) do
			print( enemy.lastDamageInstance, GameRules:GetGameTime() )
			if not enemy.lastDamageInstance or ( enemy.lastDamageInstance < GameRules:GetGameTime() ) then
				ability:DealDamage(caster, enemy, damage)
				enemy.lastDamageInstance = GameRules:GetGameTime() + FrameTime()
			end
		end
		timer = timer + 1
		if timer < duration then
			return 1
		end
	end)
end