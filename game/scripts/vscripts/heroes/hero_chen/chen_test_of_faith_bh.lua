chen_test_of_faith_bh = class({})
function chen_test_of_faith_bh:IsStealable()
	return true
end

function chen_test_of_faith_bh:IsHiddenWhenStolen()
	return false
end

-- function chen_test_of_faith_bh:GetCooldown(iLvl)
    -- local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    -- if self:GetCaster():HasTalent("special_bonus_unique_chen_test_of_faith_bh_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_chen_test_of_faith_bh_2") end
    -- return cooldown
-- end

function chen_test_of_faith_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local minVal = caster:GetLevel() * self:GetTalentSpecialValueFor("damage_min")
	local maxVal = caster:GetLevel() * self:GetTalentSpecialValueFor("damage_max")

	EmitSoundOn("Hero_Chen.DivineFavor.Cast", caster)
	EmitSoundOn("Hero_Chen.DivineFavor.Target", target)
	
	
	if caster:HasScepter() then
		for _, unit in ipairs( caster:FindAllUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() + 50 ) ) do
			local value = RandomInt( minVal, maxVal )
			if unit:IsSameTeam( caster ) then
				ParticleManager:FireParticle("particles/units/heroes/hero_chen/chen_test_of_faith.vpcf", PATTACH_POINT, unit, {})
				unit:HealEvent( value, self, caster )
			else
				ParticleManager:FireParticle("particles/chen_corrupted_test.vpcf", PATTACH_POINT, unit, {})
				self:DealDamage(caster, unit, value, {}, OVERHEAD_ALERT_DAMAGE)
			end
		end
	else
		local value = RandomInt( minVal, maxVal )
		if target:IsSameTeam( caster ) then
			ParticleManager:FireParticle("particles/units/heroes/hero_chen/chen_test_of_faith.vpcf", PATTACH_POINT, target, {})
			target:HealEvent( value, self, caster )
		else
			ParticleManager:FireParticle("particles/chen_corrupted_test.vpcf", PATTACH_POINT, target, {})
			self:DealDamage(caster, target, value, {}, OVERHEAD_ALERT_DAMAGE)
		end
	end
end