leshrac_split_earth_bh = class({})

function leshrac_split_earth_bh:IsStealable()
	return true
end

function leshrac_split_earth_bh:IsHiddenWhenStolen()
	return false
end

function leshrac_split_earth_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local damage = self:GetTalentSpecialValueFor("damage")
	local stunDur = self:GetTalentSpecialValueFor("duration")
	local delay = self:GetTalentSpecialValueFor("delay")
	
	local talent1 = caster:HasTalent("special_bonus_unique_leshrac_split_earth_1")
	local talent1Delay = caster:FindTalentValue("special_bonus_unique_leshrac_split_earth_1")
	
	local talent2 = caster:HasTalent("special_bonus_unique_leshrac_split_earth_2")
	local lightning = caster:FindAbilityByName("leshrac_lightning_storm_bh")
	
	Timers:CreateTimer( delay, function()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			self:DealDamage( caster, enemy, damage )
			self:Stun( enemy, stunDur )
			if talent2 and lightning then
				lightning:Zap( enemy )
			end
		end
	
		ParticleManager:FireParticle("particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
		EmitSoundOnLocationWithCaster( position, "Hero_Leshrac.Split_Earth", caster )
		
		if talent1 then
			talent1 = false
			return talent1Delay
		end
	end)
end