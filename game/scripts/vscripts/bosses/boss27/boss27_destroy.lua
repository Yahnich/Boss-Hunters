boss27_destroy = class({})

function boss27_destroy:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Ursa.Overpower", caster)
	for id, bear in pairs( caster.bigBearsTable ) do
		if not bear:IsNull() and bear:IsAlive() then
			ParticleManager:FireTargetWarningParticle(bear)
		end
	end
	for id, bear in pairs( caster.smallBearsTable ) do
		if not bear:IsNull() and bear:IsAlive() then
			ParticleManager:FireTargetWarningParticle(bear)
		end
	end
	return true
end

function boss27_destroy:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("duration")
	for id, bear in pairs( caster.bigBearsTable ) do
		if not bear:IsNull() and bear:IsAlive() then
			bear:AddNewModifier(caster, self, "modifier_boss27_destroy_buff", {duration = duration})
		end
	end
	for id, bear in pairs( caster.smallBearsTable ) do
		if not bear:IsNull() and bear:IsAlive() then
			bear:AddNewModifier(caster, self, "modifier_boss27_destroy_buff", {duration = duration})
		end
	end
	caster:FindAbilityByName("boss27_kill_them"):UseResources(false, false, true)
	caster:FindAbilityByName("boss27_protect_me"):UseResources(false, false, true)
end

modifier_boss27_destroy_buff = class({})
LinkLuaModifier("modifier_boss27_destroy_buff", "bosses/boss27/boss27_destroy.lua", 0)

function modifier_boss27_destroy_buff:OnCreated()
	self.cdr = self:GetSpecialValueFor("bonus_cdr")
	self.ms = self:GetSpecialValueFor("bonus_ms")
end

function modifier_boss27_destroy_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss27_destroy_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_boss27_destroy_buff:GetModifierPercentageCooldownStacking()
	return self.cdr
end

function modifier_boss27_destroy_buff:GetEffectName()
	return "particles/items2_fx/mask_of_madness.vpcf"
end