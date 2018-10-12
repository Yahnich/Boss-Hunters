boss26b_ankle_biter = class({})

function boss26b_ankle_biter:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	self.distance = CalculateDistance(caster, target) + 200
	self.direction = CalculateDirection(target, caster)
	ParticleManager:FireLinearWarningParticle( caster:GetAbsOrigin(), caster:GetAbsOrigin() + self.direction * self.distance )
	EmitSoundOn("Hero_Ursa.Overpower", caster)
	return true
end

function boss26b_ankle_biter:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local ability = self
	
	local speed = 600 * FrameTime()
	
	caster:AddNewModifier(caster, self, "modifier_phased", {duration = 0.1})
	Timers:CreateTimer(FrameTime(), function()
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetHullRadius() * 2 )
		if self.distance > 0 and not enemies[1] then
			caster:SetAbsOrigin(caster:GetAbsOrigin() + self.direction * speed)
			self.distance = self.distance - speed
			return FrameTime()
		elseif enemies[1] then
			if not enemies[1]:TriggerSpellAbsorb(self) then
				self:Grab(enemies[1])
			end
		end
	end)
	self.channel = 0
end

function boss26b_ankle_biter:Grab(target)
	local caster = self:GetCaster()
	local ability = self
	
	caster:AddNewModifier(caster, ability, "modifier_phased", {duration = 0.1})
	caster:SetAbsOrigin(target:GetAbsOrigin())
	self.initialDistance = CalculateDistance(caster, target)
	Timers:CreateTimer(FrameTime(), function()
		if (CalculateDistance(caster, target) - self.initialDistance) < ( caster:GetHullRadius() + target:GetHullRadius() + ability:GetSpecialValueFor("break_distance") ) * FrameTime() and not (caster:IsStunned() or caster:IsSilenced() or caster:IsHexed()) and ability.channel < 5 then
			ability.channel = (ability.channel or 0) + FrameTime()
			caster:AddNewModifier(caster, ability, "modifier_phased", {duration = FrameTime() + 0.1})
			caster:SetAbsOrigin(target:GetAbsOrigin())
			self.initialDistance = CalculateDistance(caster, target)
			return FrameTime()
		else 
			caster:Stop()
			caster:Interrupt()
			caster:AddNewModifier(caster, ability, "modifier_stunned_generic", {duration = ability:GetSpecialValueFor("duration"), delay = false})
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		end
	end)
end