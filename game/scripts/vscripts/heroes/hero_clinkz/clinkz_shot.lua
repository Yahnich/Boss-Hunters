clinkz_shot = class({})
LinkLuaModifier("modifier_clinkz_shot_caster", "heroes/hero_clinkz/clinkz_shot", LUA_MODIFIER_MOTION_NONE)

function clinkz_shot:IsStealable()
	return false
end

function clinkz_shot:IsHiddenWhenStolen()
	return false
end

function clinkz_shot:GetCastRange(vLocation, hTarget)
	return self:GetCaster():GetAttackRange() + 50
end

function clinkz_shot:GetIntrinsicModifierName()
	return "modifier_clinkz_shot_caster"
end

modifier_clinkz_shot_caster = class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
})

function modifier_clinkz_shot_caster:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_clinkz_shot_caster:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		
		if ability:IsCooldownReady() and caster:IsAttacking() and not caster:HasModifier("modifier_clinkz_walk") then
			local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange()+ 50, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
			for _,enemy in pairs(enemies) do
				StartAnimation(caster, {duration=caster:GetSecondsPerAttack(), activity=ACT_DOTA_ATTACK, rate=1/caster:GetSecondsPerAttack()})
				ability:SetCooldown()
				caster.forceSearingArrows = true
				caster:PerformAttack(enemy, true, true, true, true, true, false, false)
				break
			end
		end
	end
end
