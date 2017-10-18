boss27_kill_them = class({})

function boss27_kill_them:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	ParticleManager:FireTargetWarningParticle(self:GetCursorTarget() )
	return true
end

function boss27_kill_them:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("duration")
	self:GetCursorTarget():AddNewModifier(caster, self, "modifier_boss27_kill_them_debuff", {duration = duration})
	
	caster:FindAbilityByName("boss27_destroy"):UseResources(false, false, true)
	caster:FindAbilityByName("boss27_protect_me"):UseResources(false, false, true)
end


modifier_boss27_kill_them_debuff = class({})
LinkLuaModifier("modifier_boss27_kill_them_debuff", "bosses/boss27/boss27_kill_them.lua", 0)

function modifier_boss27_kill_them_debuff:OnCreated()
	self.amp = self:GetSpecialValueFor("damage_amp")
	if IsServer() then
		local shieldFX = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(shieldFX, 0, self:GetParent():GetAbsOrigin())
		self:AddOverHeadEffect(shieldFX)
	end
end

function modifier_boss27_kill_them_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss27_kill_them_debuff:GetModifierIncomingDamage_Percentage()
	return self.amp
end

function modifier_boss27_kill_them_debuff:GetEffectName()
	return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail.vpcf"
end