silencer_global_silence_bh = class({})

function silencer_global_silence_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = TernaryOperator( self:GetTalentSpecialValueFor("scepter_duration"), caster:HasScepter(), self:GetTalentSpecialValueFor("duration")	)
	local talent1 = caster:HasTalent("special_bonus_unique_silencer_global_silence_1")
	local curse = caster:FindAbilityByName("silencer_arcane_curse_bh")
	
	self:StartDelayedCooldown(duration)
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		if not enemy:TriggerSpellAbsorb( self ) then
			enemy:Silence(self, caster, duration, false)
			if talent2 then
				enemy:Disarm(self, caster, duration, false)
				enemy:Break(self, caster, duration, false)
			end
			if talent1 and curse then
				curse:ApplyArcaneCurse( enemy, duration )
			end
			ParticleManager:FireParticle("particles/units/heroes/hero_silencer/silencer_global_silence_hero.vpcf", PATTACH_POINT_FOLLOW, enemy)
		end
	end
	
	caster:EmitSound("Hero_Silencer.GlobalSilence.Cast")
	ParticleManager:FireParticle("particles/units/heroes/hero_silencer/silencer_global_silence.vpcf", PATTACH_POINT_FOLLOW, caster)
end