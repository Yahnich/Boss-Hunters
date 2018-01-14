function rocketLaunch( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local speed = ability:GetLevelSpecialValueFor("speed", ability:GetLevel() -1)
	local range = ability:GetLevelSpecialValueFor("range", ability:GetLevel() -1)

	if caster:HasModifier("modifier_rocket_launch_stack") then
		--A Liner Projectile must have a table with projectile info
		local info = 
		{
			Ability = ability,
        	EffectName = "particles/units/heroes/hero_ac/ac_homing_missile/ac_homing_missile_base.vpcf",
        	vSpawnOrigin = caster:GetAbsOrigin(),
        	fDistance = range,
        	fStartRadius = 64,
        	fEndRadius = 64,
        	Source = caster,
        	bHasFrontalCone = false,
        	bReplaceExisting = true,
        	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        	iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = true,
			vVelocity = caster:GetForwardVector() * speed,
			bProvidesVision = false,
			iVisionRadius = 1000,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		local projectile = ProjectileManager:CreateLinearProjectile(info)
		if caster:GetModifierStackCount("modifier_rocket_launch_stack",caster) > 1 then
			caster:SetModifierStackCount("modifier_rocket_launch_stack",caster,caster:GetModifierStackCount("modifier_rocket_launch_stack",caster)-1) --subtract one stack per launch
		else
			caster:SetModifierStackCount("modifier_rocket_launch_stack",caster,caster:GetModifierStackCount("modifier_rocket_launch_stack",caster)-2)
			caster:RemoveModifierByName("modifier_rocket_launch_stack")
			ability:SetActivated(false)
		end
	end--if end
end

--stacks rocket stacks so we can fire
function rocketReset( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local rocket_stock = ability:GetLevelSpecialValueFor("rocket_stock", ability:GetLevel() -1)

	--getting a weird bug that gives 8 stacks instead of 7 sometimes? haven't nailed it down 8/2/2017
	--fix with less than, not less than or equal, which makes no sense to me
	if caster:HasModifier("modifier_rocket_launch_stack") then
		if caster:GetModifierStackCount("modifier_rocket_launch_stack",caster) < rocket_stock then
			caster:SetModifierStackCount("modifier_rocket_launch_stack",caster,caster:GetModifierStackCount("modifier_rocket_launch_stack",caster)+1)
		end
	elseif not caster:HasModifier("modifier_rocket_launch_stack") then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_rocket_launch_stack",{})
		caster:SetModifierStackCount("modifier_rocket_launch_stack",caster,1)
		ability:SetActivated(true)
	end
end

function rocketDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local base_damage = ability:GetLevelSpecialValueFor("base_damage", ability:GetLevel() -1)
	local bonus_ad_damage = ability:GetLevelSpecialValueFor("bonus_ad_damage", ability:GetLevel() -1)/100
	--print("Bonus_ad_damage: " .. bonus_ad_damage)
	local bonus_int_damage = ability:GetLevelSpecialValueFor("bonus_int_damage", ability:GetLevel() -1)/100
	--print("bonus_int_damage: " .. bonus_int_damage)

	local adDamage = caster:GetAttackDamage() - caster:GetAttackDamage() * bonus_ad_damage
	--print("adDamage: " .. adDamage)
	local magicDamage = caster:GetIntellect() - caster:GetIntellect() * bonus_int_damage
	--print("magicDamage: " .. magicDamage)

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = base_damage + adDamage + magicDamage,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = ability:GetAbilityTargetFlags(), --Optional.
		ability = ability, --Optional.
	}
 
	ApplyDamage(damageTable)
end

function rocketUpgrade( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local rocket_stock = ability:GetLevelSpecialValueFor("rocket_stock", ability:GetLevel() -1)

	if ability:GetLevel() < 2 then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_rocket_launch_stack",{})
		caster:SetModifierStackCount("modifier_rocket_launch_stack",caster,rocket_stock)
	end
end