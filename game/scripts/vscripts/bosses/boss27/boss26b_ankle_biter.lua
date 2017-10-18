boss26b_ankle_biter = class({})

function boss26b_ankle_biter:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	ParticleManager:FireTargetWarningParticle(target)
	EmitSoundOn("Hero_Ursa.Overpower", caster)
	return true
end

function boss26b_ankle_biter:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local ability = self
	
	caster:AddNewModifier(caster, self, "modifier_phased", {duration = 0.1})
	caster:SetAbsOrigin(target:GetAbsOrigin())
	self.channel = 0
	Timers:CreateTimer(FrameTime(), function()
		if CalculateDistance(caster,target) < caster:GetHullRadius() + target:GetHullRadius() + ability:GetSpecialValueFor("break_distance") * FrameTime() and not (caster:IsStunned() or caster:IsSilenced() or caster:IsHexed()) and ability.channel < 5 then
			ability.channel = (ability.channel or 0) + FrameTime()
			caster:AddNewModifier(caster, ability, "modifier_phased", {duration = FrameTime() + 0.1})
			caster:SetAbsOrigin(target:GetAbsOrigin())
			return FrameTime()
		else
			caster:Stop()
			caster:Interrupt()
			caster:AddNewModifier(caster, ability, "modifier_stunned_generic", {duration = ability:GetSpecialValueFor("duration"), delay = false})
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		end
	end)
end