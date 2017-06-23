function FanTheBladeStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local startPos = caster:GetAbsOrigin()
	local endPos = startPos + caster:GetForwardVector() * ability:GetCastRange()
	local enemies = FindUnitsInLine(caster:GetTeamNumber(), startPos, endPos, nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NO_INVIS)
	local counter = 7
	for _, enemy in pairs(enemies) do
		if counter > 1 then
			local info = {
					Target = enemy,
					Source = caster,
					Ability = ability,
					EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
					bDodgeable = true,
					bProvidesVision = true,
					iMoveSpeed = keys.speed,
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
					}
			ProjectileManager:CreateTrackingProjectile( info )
			counter = counter - 1
		end
	end
	EmitSoundOn(keys.sound, caster)
end

function FanTheBladeHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	-- attack proc handling
	local dmgPct = ability:GetTalentSpecialValueFor("damage_percentage") / 100
	local bonusDamage = caster:GetAverageTrueAttackDamage(caster) * dmgPct
	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_stifling_dagger_bonusdamage_datadriven", {duration = ability:GetTalentSpecialValueFor("slow_duration")})
	caster:SetModifierStackCount("modifier_stifling_dagger_bonusdamage_datadriven", caster, bonusDamage)
	caster:PerformAttack(target, true, true, true, true, false, false, true)
	caster:RemoveModifierByName("modifier_stifling_dagger_bonusdamage_datadriven")

	
	-- magic bonus damage
	local magicDamage = ability:GetTalentSpecialValueFor("magic_damage")
	ApplyDamage({victim = target, attacker = caster, damage = magicDamage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
	-- apply slow
	ability:ApplyDataDrivenModifier(caster, target, "modifier_stifling_dagger_slow_datadriven", {duration = ability:GetTalentSpecialValueFor("slow_duration")})
	
	EmitSoundOn(keys.sound, target)
end

function AssassinDanceInit( keys )
	-- Cannot cast multiple stacks
	if keys.caster.sleight_of_fist_active ~= nil and keys.caster.sleight_of_fist_action == true then
		keys.ability:RefundManaCost()
		return nil
	end

	-- Inheritted variables
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ability = keys.ability
	local radius = 150
	local attack_interval = ability:GetTalentSpecialValueFor( "attack_interval" )
	local modifierTargetName = "modifier_sleight_of_fist_target_datadriven"
	local modifierHeroName = "modifier_sleight_of_fist_target_hero_datadriven"
	local modifierCreepName = "modifier_sleight_if_fist_target_creep_datadriven"
	local casterModifierName = "modifier_sleight_of_fist_caster_datadriven"
	local dummyModifierName = "modifier_sleight_of_fist_dummy_datadriven"

	local endSound = "Hero_PhantomAssassin.Strike.Start"
	local displaceSound = "Hero_PhantomAssassin.Strike.End"
	
	local slashSound1 = "Hero_PhantomAssassin.Attack"
	local slashSound2 = "Hero_PhantomAssassin.Attack.Rip"
	
	-- Targeting variables
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS
	local unitOrder = FIND_ANY_ORDER
	
	-- Necessary varaibles
	local counter = 0
	caster.sleight_of_fist_active = true
	
	local blinkIn = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_end.vpcf", PATTACH_ABSORIGIN, caster)
						ParticleManager:SetParticleControl(blinkIn, 0, caster:GetAbsOrigin())
	Timers:CreateTimer(0.1, function()
		ParticleManager:DestroyParticle( blinkIn, false )
		ParticleManager:ReleaseParticleIndex(blinkIn)
		return nil
		end
	)
	
	-- Start function
	local startPos = caster:GetAbsOrigin()
	local endPos = ability:GetCursorPosition()
	local enemies = FindUnitsInLine(caster:GetTeamNumber(), startPos, endPos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NO_INVIS)
	
	for _, target in pairs( enemies ) do
		Timers:CreateTimer(attack_interval*counter, function()
				FindClearSpaceForUnit( caster, target:GetAbsOrigin(), false )
				
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_sleight_of_fist_target_hero_datadriven", {})
				caster:PerformAttack(target, true, true, true, true, false, false, true)
				if caster:HasTalent("special_bonus_unique_phantom_assassin") then -- Talent Double Hit
					caster:PerformAttack(target, true, true, true, true, false, false, true)
				end
				caster:RemoveModifierByName("modifier_sleight_of_fist_target_hero_datadriven")
				
				Timers:CreateTimer(0.3, function()  
					EmitSoundOn(displaceSound, target)
				end)
				EmitSoundOn(slashSound1, target)
				EmitSoundOn(slashSound2, target)
			end
		)
		counter = counter + 1
	end
	
	-- Return caster to origin position
	Timers:CreateTimer(attack_interval*(counter+1), function()
			EmitSoundOn(endSound, target)
			FindClearSpaceForUnit( caster, endPos, false )
			caster:RemoveModifierByName( casterModifierName )
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_assassins_dance_attackspeed", {duration = ability:GetDuration()})
			caster.sleight_of_fist_active = false
			local blinkIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_end.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(blinkIndex, 0, caster:GetAbsOrigin())
			Timers:CreateTimer(0.1, function()
				ParticleManager:DestroyParticle( blinkIndex, false )
				ParticleManager:ReleaseParticleIndex(blinkIndex)
				return nil
				end
			)
			return nil
		end
	)
end

phantom_assassin_blur_ebf = class({})

function phantom_assassin_blur_ebf:GetIntrinsicModifierName()
	return "modifier_phantom_assassin_blur_ebf"
end

LinkLuaModifier( "modifier_phantom_assassin_blur_ebf", "lua_abilities/heroes/phantom_assassin.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_phantom_assassin_blur_ebf = class({})

function modifier_phantom_assassin_blur_ebf:OnCreated()
	self.evasion = self:GetAbility():GetSpecialValueFor("bonus_evasion_tooltip")
	self.evasion_stack = self:GetAbility():GetSpecialValueFor("evasion_stacks")
	self.trueEvasion = self:GetAbility():GetSpecialValueFor("true_evasion")
end

function modifier_phantom_assassin_blur_ebf:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_START,
				MODIFIER_EVENT_ON_ATTACK_LANDED,
				MODIFIER_EVENT_ON_ATTACK_FAIL,
				MODIFIER_PROPERTY_EVASION_CONSTANT,
			}
	return funcs
end

function modifier_phantom_assassin_blur_ebf:OnAttackStart(params)
	if IsServer() then
		if params.target == self:GetParent() then
			if RollPercentage(self.trueEvasion) then
				params.attacker:AddNewModifier(params.target, self:GetAbility(), "modifier_phantom_assassin_blur_true_evasion", {})
			end
		else
			params.attacker:RemoveModifierByName("modifier_phantom_assassin_blur_true_evasion")
		end
	end
end

function modifier_phantom_assassin_blur_ebf:OnAttackLanded(params)
	if IsServer() then
		if params.target == self:GetParent() then
			params.attacker:RemoveModifierByName("modifier_phantom_assassin_blur_true_evasion")
			self:IncrementStackCount()
		end
	end
end

function modifier_phantom_assassin_blur_ebf:OnAttackFail(params)
	if IsServer() then
		if params.target == self:GetParent() then
			params.attacker:RemoveModifierByName("modifier_phantom_assassin_blur_true_evasion")
			self:SetStackCount(0)
		end
	end
end

function modifier_phantom_assassin_blur_ebf:GetModifierEvasion_Constant(params)
	return self.evasion + self:GetStackCount() * self.evasion_stack
end

LinkLuaModifier( "modifier_phantom_assassin_blur_true_evasion", "lua_abilities/heroes/phantom_assassin.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_phantom_assassin_blur_true_evasion = class({})

function modifier_phantom_assassin_blur_true_evasion:IsHidden()
	return true
end

function modifier_phantom_assassin_blur_true_evasion:CheckState()
    local state = {
		[MODIFIER_STATE_CANNOT_MISS] = false,
	}
	return state
end