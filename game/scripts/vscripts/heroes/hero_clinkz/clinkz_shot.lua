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
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_clinkz_shot_caster:OnRefresh()
	self.targets = self:GetTalentSpecialValueFor("targets")
end

function modifier_clinkz_shot_caster:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		
		if ability:IsCooldownReady() and caster:IsAttacking() and not caster:HasModifier("modifier_clinkz_walk") then
			local targets = self.targets
			ability:SetCooldown()
			Timers:CreateTimer(0.25, function()
				local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange()+ 50, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
				for _,enemy in pairs(enemies) do
					caster.forceSearingArrows = true
					caster:PerformAttack(enemy, true, true, true, true, true, false, false)
					caster.forceSearingArrows = false
					targets = targets - 1
					StartAnimation(caster, {duration=caster:GetSecondsPerAttack(), activity=ACT_DOTA_ATTACK, rate=1/caster:GetSecondsPerAttack()})
					break
				end
				if targets > 0 then
					return 0.25
				end
			end)
		end
	end
end
