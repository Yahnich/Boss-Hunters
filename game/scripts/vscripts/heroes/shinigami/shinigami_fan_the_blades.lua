shinigami_fan_the_blades = class({})

function shinigami_fan_the_blades:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function shinigami_fan_the_blades:GetAOERadius()
	return 400
end

function shinigami_fan_the_blades:OnSpellStart()
	local caster = self:GetCaster()
	
	local startPos = caster:GetAbsOrigin()
	local endPos = self:GetCursorPosition()
	local enemies = caster:FindEnemyUnitsInRadius(endPos, 400, {flag = DOTA_UNIT_TARGET_FLAG_NO_INVIS})
	local counter = self:GetSpecialValueFor("dagger_count")
	for _, enemy in pairs(enemies) do
		if counter > 1 then
			local info = {
				Target = enemy,
				Source = caster,
				Ability = self,
				EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
				bDodgeable = true,
				bProvidesVision = true,
				iMoveSpeed = self:GetSpecialValueFor("dagger_speed"),
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
			}
			ProjectileManager:CreateTrackingProjectile( info )
			counter = counter - 1
		end
	end
	EmitSoundOn("Hero_PhantomAssassin.Dagger.Cast"	, caster)
end

function shinigami_fan_the_blades:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	print("wut")
	-- attack proc handling
	local dmgPct = self:GetTalentSpecialValueFor("damage_bonus") / 100
	local baseDamage = self:GetTalentSpecialValueFor("base_damage")
	local bonusDamage = caster:GetAverageTrueAttackDamage(caster) * dmgPct + baseDamage
	
	caster:AddNewModifier(caster, self, "modifier_shinigami_fan_the_blades_bonusdamage", {}):SetStackCount(baseDamage)
	caster:PerformAbilityAttack(target, true, self)
	caster:RemoveModifierByName("modifier_shinigami_fan_the_blades_bonusdamage")
	if caster:HasTalent("shinigami_fan_the_blades_talent_1") then
		target:AddNewModifier(caster, self, "modifier_stunned_generic", {duration = 0.4})
	end

	-- apply slow
	target:AddNewModifier(caster, self, "modifier_shinigami_fan_the_blades_slow", {duration = self:GetTalentSpecialValueFor("slow_duration")})
	
	EmitSoundOn("Hero_PhantomAssassin.Dagger.Target", target)
end

modifier_shinigami_fan_the_blades_slow = class({})
LinkLuaModifier("modifier_shinigami_fan_the_blades_slow", "heroes/shinigami/shinigami_fan_the_blades.lua", 0)

function modifier_shinigami_fan_the_blades_slow:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow_amount")
end

function modifier_shinigami_fan_the_blades_slow:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_shinigami_fan_the_blades_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

modifier_shinigami_fan_the_blades_bonusdamage = class({})
LinkLuaModifier("modifier_shinigami_fan_the_blades_bonusdamage", "heroes/shinigami/shinigami_fan_the_blades.lua", 0)

function modifier_shinigami_fan_the_blades_bonusdamage:IsHidden()
	return true
end

function modifier_shinigami_fan_the_blades_bonusdamage:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			}
	return funcs
end

function modifier_shinigami_fan_the_blades_bonusdamage:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end