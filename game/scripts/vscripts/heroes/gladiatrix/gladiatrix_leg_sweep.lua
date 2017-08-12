gladiatrix_leg_sweep = class({})

function gladiatrix_leg_sweep:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	self:GetCaster().legSweepAbilityPhaseInterrupted = false
	self:GetCaster().originalForwardVector = self:GetCaster():GetForwardVector()
	local angleSet = -45
	local angVel = ( 90 / 0.3 ) * FrameTime()
	caster:SetForwardVector( RotateVector2D(caster:GetForwardVector(), ToRadians(angleSet)) )
	Timers:CreateTimer(function()
		if angleSet < 45 and not self:GetCaster().legSweepAbilityPhaseInterrupted then	
			caster:SetForwardVector( RotateVector2D(caster:GetForwardVector(), ToRadians(angVel)))
			angleSet = angleSet + angVel
			return FrameTime()
		else
			caster:SetForwardVector( self:GetCaster().originalForwardVector )
		end
	end)
	return true
end

function gladiatrix_leg_sweep:OnAbilityPhaseInterrupted()
	self:GetCaster().legSweepAbilityPhaseInterrupted = true
end

function gladiatrix_leg_sweep:OnSpellStart()
	local caster = self:GetCaster()
	local spin = ParticleManager:CreateParticle("particles/econ/items/axe/axe_weapon_practos/axe_attack_blur_counterhelix_practos.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(spin)
	EmitSoundOn("Hero_Axe.CounterHelix", caster)
	if caster:HasTalent("gladiatrix_leg_sweep_talent_1") then
		local targets = caster:FindEnemyUnitsInRadius(targetPoint, caster:FindTalentValueFor("gladiatrix_leg_sweep_talent_1"), {})
		for _, target in pairs(target) do
			target:AddNewModifier(caster, self, "modifier_stunned_generic", {duration = self:GetTalentSpecialValueFor("stun_duration")})
			target:AddNewModifier(caster, self, "modifier_dazed_generic", {duration = self:GetTalentSpecialValueFor("stun_duration") + self:GetTalentSpecialValueFor("daze_duration")})
		end
	else
		local target = self:GetCursorTarget()
		target:AddNewModifier(caster, self, "modifier_stunned_generic", {duration = self:GetTalentSpecialValueFor("stun_duration")})
		target:AddNewModifier(caster, self, "modifier_dazed_generic", {duration = self:GetTalentSpecialValueFor("stun_duration") + self:GetTalentSpecialValueFor("daze_duration")})
	end
end