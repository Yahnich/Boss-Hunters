boss14_quake = class({})

function boss14_quake:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle(self:GetCursorPosition(), self:GetSpecialValueFor("radius"))
	return true
end

function boss14_quake:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("radius")
	ParticleManager:FireParticle("particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position})
	EmitSoundOn("Hero_Axe.BerserkersCall.Item.Shoutmask", caster)
	local enemies = caster:FindEnemyUnitsInRadius(position, radius)
	for _, enemy in ipairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_stunned_generic", {duration = self:GetSpecialValueFor("duration")})
	end
end