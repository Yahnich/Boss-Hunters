chen_sup_silence = class({})
function chen_sup_silence:IsStealable()
	return true
end

function chen_sup_silence:IsHiddenWhenStolen()
	return false
end

function chen_sup_silence:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function chen_sup_silence:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local radius = self:GetTalentSpecialValueFor("radius")

	EmitSoundOn("Brewmaster_Storm.DispelMagic", caster)

	ParticleManager:FireParticle("particles/units/heroes/hero_silencer/silencer_curse_aoe.vpcf", PATTACH_POINT, caster, {[0]=point,[1]=Vector(radius,radius,radius)})

	local enemies = caster:FindEnemyUnitsInRadius(point, radius)
	for _,enemy in pairs(enemies) do
		enemy:Silence(self, caster, self:GetSpecialValueFor("duration"))
	end
end