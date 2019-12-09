boss_durva_purgatory = class({})

function boss_durva_purgatory:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	return true
end

function boss_durva_purgatory:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:AddNewModifier(caster, self, "modifier_boss_durva_purgatory", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("Hero_Bane.Nightmare", target)
end


modifier_boss_durva_purgatory = class({})
LinkLuaModifier("modifier_boss_durva_purgatory", "bosses/boss_durva/boss_durva_purgatory", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_durva_purgatory:OnCreated()
	if IsServer() then 
		EmitSoundOn("Hero_Bane.Nightmare.Loop", self:GetParent())
	end
end

function modifier_boss_durva_purgatory:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_Bane.Nightmare.Loop", self:GetParent())
		EmitSoundOn("Hero_Bane.Nightmare.End", self:GetParent())
	end
end

function modifier_boss_durva_purgatory:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE}
end

function modifier_boss_durva_purgatory:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_boss_durva_purgatory:GetOverrideAnimationRate()
	return 0.2
end

function modifier_boss_durva_purgatory:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_nightmare.vpcf"
end

function modifier_boss_durva_purgatory:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_boss_durva_purgatory:GetStatusEffectName()
	return "particles/status_fx/status_effect_nightmare.vpcf"
end

function modifier_boss_durva_purgatory:StatusEffectPriority()
	return 10
end

function modifier_boss_durva_purgatory:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NIGHTMARED] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true}
end
