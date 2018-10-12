boss26_ravage = class({})

function boss26_ravage:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local newPos = caster:GetAbsOrigin() + CalculateDirection(self:GetCursorPosition(), caster) * self:GetSpecialValueFor("jump_distance")
	ParticleManager:FireLinearWarningParticle(caster:GetAbsOrigin(), newPos)
	EmitSoundOn("Hero_Ursa.Enrage", caster)
	return true
end

function boss26_ravage:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local vDir = CalculateDirection(self:GetCursorPosition(), caster) * Vector(1,1,0)
	
	local duration = self:GetSpecialValueFor("stun_duration")
	local damage = self:GetSpecialValueFor("impact_damage")
	
	local distance = self:GetSpecialValueFor("jump_distance")
	local position = caster:GetAbsOrigin() + vDir * distance
	local speed = (distance / 0.2) * FrameTime()
	caster:AddNewModifier(caster, self, "modifier_stunned_generic", {duration = 0.19, delay = false})
	
	self.blurFX = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf", PATTACH_POINT_FOLLOW, caster)
	
	local distTravel = 0
	Timers:CreateTimer(function()
		local newPos = GetGroundPosition(caster:GetAbsOrigin(), caster) + vDir * speed
		local enemies = caster:FindEnemyUnitsInLine(caster:GetAbsOrigin(), newPos, 100)
		for _, enemy in ipairs(enemies) do
			if enemy:TriggerSpellAbsorb(self) then return end
			ability:DealDamage(caster, enemy, damage)
			enemy:AddNewModifier(caster, ability, "modifier_stunned_generic", {duration = duration, delay = false})
			caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
			EmitSoundOn("Hero_Ursa.Earthshock", caster)
			ParticleManager:ClearParticle(ability.blurFX)
			return nil
		end
		caster:SetAbsOrigin( newPos)
		distTravel = distTravel + speed
		if distTravel < distance then
			return FrameTime()
		else
			ParticleManager:ClearParticle(self.blurFX)
			ResolveNPCPositions(caster:GetAbsOrigin(), caster:GetHullRadius() * 3)
		end
	end)
end