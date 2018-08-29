pugna_nether_blast_bh = class({})

function pugna_nether_blast_bh:IsHiddenWhenStolen()
	return false
end

function pugna_nether_blast_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local delay = self:GetTalentSpecialValueFor("delay")
	local radius = self:GetTalentSpecialValueFor("radius")
	local damage = self:GetTalentSpecialValueFor("blast_damage")
	
	local hasTalent = caster:HasTalent("special_bonus_unique_pugna_nether_blast_2")
	local stunDur = caster:FindTalentValue("special_bonus_unique_pugna_nether_blast_2", "stun")
	
	Timers:CreateTimer(delay, function()
		ParticleMananger:FireParticle("", PATTACH_WORLDORIGIN, nil, {[0] = position})
		
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) do
			self:DealDamage( caster, enemy, damage )
			if hasTalent then
				self:Stun( enemy, stunDur )
			end
		end
	end)
end