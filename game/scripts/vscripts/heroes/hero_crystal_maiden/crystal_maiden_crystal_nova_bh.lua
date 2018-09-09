crystal_maiden_crystal_nova_bh = class({})

function crystal_maiden_crystal_nova_bh:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("hero_Crystal.CrystalNovaCast")
	return true
end

function crystal_maiden_crystal_nova_bh:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("hero_Crystal.CrystalNovaCast")
end 

function crystal_maiden_crystal_nova_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local damage = self:GetTalentSpecialValueFor("nova_damage")
	local chill = self:GetTalentSpecialValueFor("chill")
	local cDur = self:GetTalentSpecialValueFor("duration")
	local vDur = self:GetTalentSpecialValueFor("vision_duration")
	local radius = self:GetTalentSpecialValueFor("radius")
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		self:DealDamage( caster, enemy, damage )
		enemy:AddChill(self, caster, cDur, chill)
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", PATTACH_WORLDORIGIN, nil, { [0] = position, [1] = Vector(radius,1,1) })
	EmitSoundOnLocationWithCaster(position, "Hero_Crystal.CrystalNova", caster)
	AddFOWViewer( caster:GetTeam(), position, radius, vDur, true )
end