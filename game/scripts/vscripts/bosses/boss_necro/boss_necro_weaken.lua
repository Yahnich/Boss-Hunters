boss_necro_weaken = class({})

function boss_necro_weaken:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	return true
end

function boss_necro_weaken:OnSpellStart()
	self:GetCursorTarget():AddNewModifier( self:GetCaster(), self, "modifier_boss_necro_weaken", {duration = self:GetSpecialValueFor("duration")} )
end

modifier_boss_necro_weaken = class({})
LinkLuaModifier("modifier_boss_necro_weaken", "bosses/boss_necro/boss_necro_weaken", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_necro_weaken:OnCreated()
	self.reduction = self:GetSpecialValueFor("damage_reduction")
	if IsServer() then
		EmitSoundOn("Hero_Necrolyte.DeathPulse", self:GetParent())
		self:GetCaster():Taunt( self:GetAbility(), self:GetParent(), self:GetRemainingTime() )
	end
end

function modifier_boss_necro_weaken:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_boss_necro_weaken:GetModifierTotalDamageOutgoing_Percentage()
	return self.reduction
end

function modifier_boss_necro_weaken:GetStatusEffectName()
	return "particles/status_fx/status_effect_necrolyte_spirit.vpcf"
end

function modifier_boss_necro_weaken:StatusEffectPriority()
	return 20
end