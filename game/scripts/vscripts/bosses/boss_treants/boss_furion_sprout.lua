boss_furion_sprout = class({})

function boss_furion_sprout:IsStealable()
	return true
end

function boss_furion_sprout:IsHiddenWhenStolen()
	return false
end

function boss_furion_sprout:GetAOERadius()
	return self:GetTalentSpecialValueFor("tree_radius")
end

function boss_furion_sprout:OnAbilityPhaseStart()
	local point = self:GetCursorPosition()
	if self:GetCursorTarget() then
		local point = self:GetCursorTarget():GetAbsOrigin()
	end
	ParticleManager:FireWarningParticle( point, self:GetTalentSpecialValueFor("tree_radius") )
	return true
end

function boss_furion_sprout:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	if self:GetCursorTarget() then
		local point = self:GetCursorTarget():GetAbsOrigin()
	end
	local duration = self:GetTalentSpecialValueFor("duration")
	local vision_range = self:GetTalentSpecialValueFor("vision_range")
	local trees = self:GetTalentSpecialValueFor("tree_count")
	local radius = self:GetTalentSpecialValueFor("tree_radius")
	local angle = math.pi/(trees/2)
	
	-- Creates 16 temporary trees at each 45 degree interval around the clicked point
	for i=1,trees do
		local position = Vector(point.x+radius*math.sin(angle), point.y+radius*math.cos(angle), point.z)
		CreateTempTree(position, duration)
		angle = angle + math.pi/(trees/2)
	end
	-- Gives vision to the caster's team in a radius around the clicked point for the duration
	AddFOWViewer(caster:GetTeam(), point, vision_range, duration, false)
	ParticleManager:FireParticle("particles/units/heroes/hero_furion/furion_sprout.vpcf", PATTACH_ABSORIGIN, dummy)
	EmitSoundOn("Hero_Furion.Sprout", dummy)
end