function HeadShot(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage()/get_aether_multiplier(caster), damage_type = ability:GetAbilityDamageType(), ability = ability})
	if not ability.prng then ability.prng = 0 end

	-- ASSASSINATE PROC CHANCE
	local chance = ability:GetTalentSpecialValueFor("assassinate_chance_scepter")
	if chance+ability.prng > math.random(100) then
		local assassinate = caster:FindAbilityByName("sniper_assassinate_ebf")
		ability.prng = 0
		if assassinate:GetLevel() > 0 and assassinate:IsCooldownReady() then
			local cooldown = assassinate:GetCooldown(-1) * ability:GetTalentSpecialValueFor("assassinate_passive_cooldown") * get_octarine_multiplier(caster) / 100
			caster:SetCursorCastTarget(target)
			assassinate:OnSpellStart()
			assassinate:StartCooldown(cooldown)
		end
	else
		ability.prng = ability.prng + 1
	end

end

function RegisterAssassinate( keys )
	keys.caster.assassinate_target = keys.target
end

--[[
	Author: kritth
	Date: 6.1.2015.
	Remove debuff from target
]]
function RemoveAssassinate( keys )
	if keys.caster.assassinate_target then
		keys.caster.assassinate_target:RemoveModifierByName( "modifier_assassinate_target_datadriven" )
		keys.caster.assassinate_target = nil
	end
end

function FireAssassinate(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	if not caster:HasScepter() then
		local info = {
			Target = target,
			Source = caster,
			Ability = ability,
			EffectName = keys.particle,
			bDodgeable = true,
			bProvidesVision = true,
			iMoveSpeed = keys.speed,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
			}
		ProjectileManager:CreateTrackingProjectile( info )
	else
		local enemies = FindUnitsInRadius(caster:GetTeam(), ability:GetCursorPosition(), nil, ability:GetTalentSpecialValueFor("scepter_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			local info = {
				Target = enemy,
				Source = caster,
				Ability = ability,
				EffectName = keys.particle,
				bDodgeable = true,
				bProvidesVision = true,
				iMoveSpeed = keys.speed,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
			}
			print(#enemies)
			ProjectileManager:CreateTrackingProjectile( info )
		end
	end
end

function AssassinateDamage(keys)
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = keys.ability:GetAbilityDamage(), damage_type = keys.ability:GetAbilityDamageType(), ability = keys.ability})
	keys.target:AddNewModifier(keys.caster, keys.ability, "modifier_stunned", {duration = keys.ability:GetTalentSpecialValueFor("ministun_duration")})
end