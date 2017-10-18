boss26_smash = class({})

function boss26_smash:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	return true
end

function boss26_smash:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")
	
	ParticleManager:FireParticle("particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", PATTACH_ABSORIGIN, caster)
	EmitSoundOn("Hero_Ursa.Earthshock", caster)
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius) ) do
		self:DealDamage(caster, enemy, damage)
		enemy:AddNewModifier(caster, self, "modifier_boss26_smash_slow", {duration = duration})
	end
end

modifier_boss26_smash_slow = class({})
LinkLuaModifier("modifier_boss26_smash_slow", "bosses/boss27/boss26_smash.lua", 0)

function modifier_boss26_smash_slow:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
end

function modifier_boss26_smash_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss26_smash_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end
