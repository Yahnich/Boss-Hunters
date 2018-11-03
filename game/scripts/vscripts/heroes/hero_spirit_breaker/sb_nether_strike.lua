sb_nether_strike = class({})
LinkLuaModifier( "modifier_sb_nether_strike", "heroes/hero_spirit_breaker/sb_nether_strike.lua" ,LUA_MODIFIER_MOTION_NONE )

function sb_nether_strike:IsStealable()
    return true
end

function sb_nether_strike:IsHiddenWhenStolen()
    return false
end

function sb_nether_strike:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasScepter() then cooldown = self:GetTalentSpecialValueFor("cooldown_scepter") end
    return cooldown
end

function sb_nether_strike:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor("range_scepter")
	end
	return self:GetTalentSpecialValueFor("range")
end

function sb_nether_strike:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Spirit_Breaker.NetherStrike.Begin", self:GetCaster())
	return true
end

function sb_nether_strike:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local startPos = caster:GetAbsOrigin()
	local tpPoint = target:GetAbsOrigin() - target:GetForwardVector() * 54

	EmitSoundOn("Hero_Spirit_Breaker.NetherStrike.End", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_nether_strike_begin.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, startPos)
				ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 2, tpPoint)
				ParticleManager:ReleaseParticleIndex(nfx)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_nether_strike_end.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, tpPoint)
				ParticleManager:ReleaseParticleIndex(nfx)

	FindClearSpaceForUnit(caster, tpPoint, true)
	caster:FaceTowards(target:GetAbsOrigin())

	if caster:HasTalent("special_bonus_unique_sb_nether_strike_2") then
		caster:PerformAttack(target, true, true, true, true, true, false, true)
	end

	if target and target:IsAlive() then
		if caster:HasTalent("special_bonus_unique_sb_nether_strike_1") then
			local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("bash_radius_scepter"))
			for _,enemy in pairs(enemies) do
				self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
			end
		else
			self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
		end
	end

	if target and target:IsAlive() then
		local ability = caster:FindAbilityByName("sb_bash")
		if ability and ability:IsTrained() then
			if caster:HasScepter() then
				local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("bash_radius_scepter"))
				for _,enemy in pairs(enemies) do
					ability:Bash(enemy, ability:GetTalentSpecialValueFor("knockback_distance")*2)
				end
			else
				ability:Bash(target, ability:GetTalentSpecialValueFor("knockback_distance")*2)
			end
		end
	end
end