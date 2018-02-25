chen_test_of_faith_ebf = class({})
function chen_test_of_faith_ebf:IsStealable()
	return true
end

function chen_test_of_faith_ebf:IsHiddenWhenStolen()
	return false
end

function chen_test_of_faith_ebf:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_chen_test_of_faith_ebf_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_chen_test_of_faith_ebf_2") end
    return cooldown
end

function chen_test_of_faith_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local min = self:GetTalentSpecialValueFor("damage_min")
	local max = self:GetTalentSpecialValueFor("damage_max")

	EmitSoundOn("Hero_Chen.TestOfFaith.Cast", caster)
	EmitSoundOn("Hero_Chen.TestOfFaith.Target", target)

	if caster:HasTalent("special_bonus_unique_chen_test_of_faith_ebf_1") then
		local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_chen_test_of_faith_ebf_1"))
		for _,enemy in pairs(enemies) do
			ParticleManager:FireParticle("particles/chen_corrupted_test.vpcf", PATTACH_POINT, enemy, {})
			self:DealDamage(caster, enemy, math.random(min, max), {}, OVERHEAD_ALERT_DAMAGE)
			enemy:Daze(self, caster, self:GetTalentSpecialValueFor("duration"))
		end
	else
		ParticleManager:FireParticle("particles/chen_corrupted_test.vpcf", PATTACH_POINT, target, {})
		self:DealDamage(caster, target, math.random(min, max), {}, OVERHEAD_ALERT_DAMAGE)
		target:Daze(self, caster, self:GetTalentSpecialValueFor("duration"))
	end
end