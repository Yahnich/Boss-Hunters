morph_agi_strike = class({})
LinkLuaModifier( "modifier_morph_agi_strike", "heroes/hero_morphling/morph_agi_strike.lua" ,LUA_MODIFIER_MOTION_NONE )

function morph_agi_strike:IsStealable()
    return true
end

function morph_agi_strike:IsHiddenWhenStolen()
    return false
end

function morph_agi_strike:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	self.point = caster:GetAbsOrigin()

	local speed = 1150

	local extraData = {name = "proj"}

	EmitSoundOn("Hero_Morphling.AdaptiveStrikeAgi.Cast", caster)

	self:FireTrackingProjectile("particles/units/heroes/hero_morphling/morphling_adaptive_strike_agi_proj.vpcf", target, speed, {extraData=extraData}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, false, 0)

	--Talent 1
	if caster:HasTalent("special_bonus_unique_morph_agi_strike_1") then
		local maxEms = caster:FindTalentValue("special_bonus_unique_morph_agi_strike_1")
		local curEms = 0
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange())
		for _,enemy in pairs(enemies) do
			if curEms < maxEms and enemy ~= target then
				self:FireTrackingProjectile("particles/units/heroes/hero_morphling/morphling_adaptive_strike_agi_proj.vpcf", enemy, speed, {extraData=extraData}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, false, 0)

				curEms = curEms + 1
			end
		end
	end
end

function morph_agi_strike:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	local caster = self:GetCaster()

	if table.name == "proj" then
		if hTarget then
			EmitSoundOn("Hero_Morphling.AdaptiveStrike", caster)
			EmitSoundOn("Hero_Morphling.AdaptiveStrikeAgi.Target", hTarget)

			self:FireTrackingProjectile("particles/units/heroes/hero_morphling/morphling_adaptive_strike.vpcf", hTarget, 1150, {origin = self.point}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, false, 0)

			local damage = self:GetTalentSpecialValueFor("damage")
			damage = damage + caster:GetAgility() * self:GetTalentSpecialValueFor("agi_max")

			self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
	end
end
