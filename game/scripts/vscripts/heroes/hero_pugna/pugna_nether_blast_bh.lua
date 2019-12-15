pugna_nether_blast_bh = class({})

function pugna_nether_blast_bh:IsHiddenWhenStolen()
	return false
end

function pugna_nether_blast_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function pugna_nether_blast_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local delay = self:GetTalentSpecialValueFor("delay")
	local radius = self:GetTalentSpecialValueFor("radius")
	local damage = self:GetTalentSpecialValueFor("blast_damage")
	
	local hasTalent = caster:HasTalent("special_bonus_unique_pugna_nether_blast_2")
	local stunDur = caster:FindTalentValue("special_bonus_unique_pugna_nether_blast_2", "stun")
	
	EmitSoundOnLocationWithCaster(position, "Hero_Pugna.NetherBlastPreCast", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_pugna/pugna_netherblast_pre.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
	Timers:CreateTimer(delay, function()
		ParticleManager:FireParticle("particles/units/heroes/hero_pugna/pugna_netherblast.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
		EmitSoundOnLocationWithCaster(position, "Hero_Pugna.NetherBlast", caster)
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			if not enemy:TriggerSpellAbsorb( self ) then
				self:DealDamage( caster, enemy, damage )
				if hasTalent then
					self:Stun( enemy, stunDur )
				end
			end
		end
	end)
end