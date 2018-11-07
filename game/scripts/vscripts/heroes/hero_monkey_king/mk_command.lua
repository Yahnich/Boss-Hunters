mk_command = class({})

function mk_command:OnAbilityPhaseStart()
	EmitSoundOn("Hero_MonkeyKing.FurArmy.Channel", self:GetCaster())
    return true
end

function mk_command:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_MonkeyKing.FurArmy.Channel", self:GetCaster())
end

function mk_command:OnSpellStart()
	local caster = self:GetCaster()

	local point = self:GetCursorPosition()
	local startPos = caster:GetAbsOrigin()
	local dir = CalculateDirection(point, startPos)	

	local max_monkeys = self:GetTalentSpecialValueFor("number_of_monkeys")
	local current = 0

	EmitSoundOn("Hero_MonkeyKing.FurArmy", caster)

	Timers:CreateTimer(function()
		local radius = caster:GetAttackRange() * 2
		local randoVect = ActualRandomVector(radius,-radius)
        pointRando = startPos + randoVect
		if current < max_monkeys then
			self:FireLinearProjectile("particles/units/heroes/hero_monkey_king/mk_command_projectile.vpcf", dir*caster:GetIdealSpeedNoSlows(), 1000, caster:GetModelRadius(), {origin=pointRando}, false, true, 200)
			current = current + 1
			return 0.25
		else
			return nil
		end
	end)
end

function mk_command:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	local bonusDamage = self:GetTalentSpecialValueFor("bonus_damage")
	local bCantMiss = false

	EmitSoundOnLocationWithCaster(vLocation, "Hero_MonkeyKing.FurArmy.End", caster)

	if hTarget then
		if caster:HasModifier("modifier_mk_mastery_hits") then
			local mod = caster:FindModifierByName("modifier_mk_mastery_hits")
			if mod:GetStackCount() > 1 then
				mod:DecrementStackCount()
			else
				caster:RemoveModifierByName("modifier_mk_mastery_hits")
			end
		end
		
		--Truestrike
		if caster:HasTalent("special_bonus_unique_mk_mastery_1") then
			bCantMiss = true
		end

		--Talent 2
		if caster:HasTalent("special_bonus_unique_mk_command_2") then
			local damage = caster:GetAttackDamage() * bonusDamage/100
			self:DealDamage(caster, hTarget, damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_DAMAGE)
			bonusDamage = 0
		end

		caster:PerformAbilityAttack(hTarget, true, self, bonusDamage, true, bCantMiss)

		--Talent 1
		if caster:HasTalent("special_bonus_unique_mk_command_1") then
			return true
		else
			return false
		end
	end
end

function mk_command:OnProjectileThink(vLocation)
	GridNav:DestroyTreesAroundPoint(vLocation, self:GetCaster():GetModelRadius(), false)
end