mk_boundless = class({})
LinkLuaModifier("modifier_mk_boundless_crit", "heroes/hero_monkey_king/mk_boundless", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mk_boundless_slow", "heroes/hero_monkey_king/mk_boundless", LUA_MODIFIER_MOTION_NONE)

function mk_boundless:IsStealable()
	return true
end

function mk_boundless:IsHiddenWhenStolen()
	return false
end

function mk_boundless:OnAbilityPhaseStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_MonkeyKing.Strike.Cast", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_weapon_bot", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_weapon_top", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)

	return true
end

function mk_boundless:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local casterPos = caster:GetAbsOrigin()

	local duration = self:GetTalentSpecialValueFor("duration")
	local width = self:GetTalentSpecialValueFor("width")
	local range = self:GetTalentSpecialValueFor("range") - 75 --blame Valve

	local direction = CalculateDirection(point, casterPos)

	local startPos = caster:GetAbsOrigin() + direction * 75 --blame Valve
	local endPos = startPos + direction * range

	EmitSoundOnLocationWithCaster(startPos, "Hero_MonkeyKing.Strike.Impact", caster)
	EmitSoundOnLocationWithCaster(endPos, "Hero_MonkeyKing.Strike.Impact.EndPos", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlForward(nfx, 0, direction)
				ParticleManager:SetParticleControl(nfx, 1, endPos)
				ParticleManager:ReleaseParticleIndex(nfx)

	caster:AddNewModifier(caster, self, "modifier_mk_boundless_crit", {Duration = 0.25})
	local enemies = caster:FindEnemyUnitsInLine(startPos, endPos, width, {})
	for _,enemy in pairs(enemies) do
		self:Stun(enemy, duration, false)
		caster:PerformAbilityAttack(enemy, true, self, 0, false, true)
		if caster:HasTalent("special_bonus_unique_mk_boundless_1") then
			Timers:CreateTimer(duration, function()
				enemy:Break(self, caster, caster:FindTalentValue("special_bonus_unique_mk_boundless_1", "duration"), false)
				enemy:AddNewModifier(caster, self, "modifier_mk_boundless_slow", {Duration = caster:FindTalentValue("special_bonus_unique_mk_boundless_1", "duration")})
			end)
		end
	end
	caster:RemoveModifierByName("modifier_mk_boundless_crit")

	if caster:HasModifier("modifier_mk_mastery_hits") then
		local mod = caster:FindModifierByName("modifier_mk_mastery_hits")
		if mod:GetStackCount() > 1 then
			mod:DecrementStackCount()
		else
			caster:RemoveModifierByName("modifier_mk_mastery_hits")
		end
	end
end

modifier_mk_boundless_crit = class({})
function modifier_mk_boundless_crit:OnCreated(table)
	self.crit = self:GetTalentSpecialValueFor("crit_mult")
end

function modifier_mk_boundless_crit:OnRefresh(table)
	self.crit = self:GetTalentSpecialValueFor("crit_mult")
end

function modifier_mk_boundless_crit:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_mk_boundless_crit:GetModifierPreAttack_CriticalStrike(params)
	return self.crit
end

function modifier_mk_boundless_crit:IsHidden()
	return true
end

modifier_mk_boundless_slow = class({})
function modifier_mk_boundless_slow:OnCreated(table)
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_mk_boundless_1", "slow")
end

function modifier_mk_boundless_slow:OnRefresh(table)
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_mk_boundless_1", "slow")
end

function modifier_mk_boundless_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_mk_boundless_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_mk_boundless_slow:IsDebuff()
	return true
end

function modifier_mk_boundless_slow:GetEffectName()
	return "particles/units/heroes/hero_monkey_king/monkey_king_spring_slow.vpcf"
end