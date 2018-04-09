centaur_great_edge = class({})

function centaur_great_edge:IsStealable()
	return true
end

function centaur_great_edge:IsHiddenWhenStolen()
	return false
end

function centaur_great_edge:GetCooldown(iLevel)
	if self:GetCaster():HasTalent("special_bonus_unique_centaur_great_edge_1") then
		return 0
	end
	return self.BaseClass.GetCooldown(self, iLevel)
end

function centaur_great_edge:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local edgeDamage = self:GetTalentSpecialValueFor( "edge_damage" )
	local bonusDamage = caster:GetStrength() * self:GetTalentSpecialValueFor( "edge_str_damage" ) / 100
	local radius = self:GetTalentSpecialValueFor("radius")
	
	EmitSoundOn( "Hero_Centaur.DoubleEdge", caster )
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()) -- Origin
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin()) -- Destination
	ParticleManager:SetParticleControl(particle, 5, target:GetAbsOrigin()) -- Hit Glow
	
	self:DealDamage( caster, caster, edgeDamage + bonusDamage, {damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
	local units = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius)
	for _, enemy in ipairs(units) do
		self:DealDamage( caster, enemy, edgeDamage + bonusDamage )
		if caster:HasTalent("special_bonus_unique_centaur_great_edge_2") then self:Stun(enemy, caster:FindTalentValue("special_bonus_unique_centaur_great_edge_2"), false) end
	end
end