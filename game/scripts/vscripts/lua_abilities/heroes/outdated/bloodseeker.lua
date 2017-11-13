function Blood_Seeker_Blood_Smell(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
	local modifier = keys.damageapplied
    local missing_health = target:GetMaxHealth() - target:GetHealth()
    local damage = math.floor(ability:GetTalentSpecialValueFor("percent") * missing_health * 0.01) + 1
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = 1})
	caster:SetModifierStackCount( modifier, ability, damage )
    if caster.show_popup ~= true then
                    caster.show_popup = true
                    caster:ShowPopup( {
                    PreSymbol = 1,
                    PostSymbol = 4,
                    Color = Vector( 255, 50, 10 ),
                    Duration = 1.5,
                    Number = damage,
                    pfx = "damage",
                    Player = true
                } )
                Timers:CreateTimer(2.0,function()
                    caster.show_popup = false
                end)
    end
end

function DistanceCheck(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local movement_damage_pct = ability:GetTalentSpecialValueFor( "movement_damage_pct")/100
	local damage_cap_amount = ability:GetTalentSpecialValueFor( "damage_cap_amount")
	local position = target:GetAbsOrigin()
	local damage = 0
	if target.damagetaken == nil then target.damagetaken = 0 end
	if target.origin == nil then target.origin = position end
	if target.origin ~= nil then
		local distance = math.sqrt((target.origin.x - position.x)^2 + (target.origin.y - position.y)^2)
		if distance <= 1200 and distance > 0 then
			damage = distance * movement_damage_pct
		end
	end
	target.origin = position
	if damage ~= 0 then
		target.damagetaken = target.damagetaken + damage
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
	end
end

function Damage(keys)
	local caster = keys.caster
	local target = keys.attacker
	local ability = keys.ability
	local movement_damage_pct = ability:GetTalentSpecialValueFor( "movement_damage_pct")/100
	local damage_cap_amount = ability:GetTalentSpecialValueFor( "damage_cap_amount")
	
	damage = target:GetAttacksPerSecond() * target:GetBaseAttackTime() * 100 * movement_damage_pct * 1.7 --1.7 is the default BAT modifier to find adjusted BAT

	if target.damagetaken == nil then target.damagetaken = 0 end
	if damage ~= nil and target.damagetaken < damage_cap_amount then
		target.damagetaken = target.damagetaken + damage
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
	end
end

function InitialDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local initial_damage = ability:GetTalentSpecialValueFor( "damage_initial")
	local damage_cap_amount = ability:GetTalentSpecialValueFor( "damage_cap_amount")
	local burst_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_explode.vpcf", PATTACH_ABSORIGIN , target)
            ParticleManager:SetParticleControl(burst_effect, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(burst_effect, 1, Vector(150,150,600))
			ParticleManager:SetParticleControl(burst_effect, 3, target:GetAbsOrigin())
	target.origin = target:GetAbsOrigin()
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_aghs_explosion", {})
	end
	if initial_damage ~= nil then
		target.damagetaken = initial_damage
		ApplyDamage({victim = target, attacker = caster, damage = initial_damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
	end
end

function ClearDamage(keys)
	local target = keys.target
	target.damagetaken = 0
end

function ApplyAghs(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local duration = ability:GetTalentSpecialValueFor( "duration")
	local radius = ability:GetTalentSpecialValueFor( "radius_scepter")
	local burst_effect = ParticleManager:CreateParticle("particles/bloodseeker_haemophillia_burst.vpcf", PATTACH_ABSORIGIN , target)
            ParticleManager:SetParticleControl(burst_effect, 0, target:GetAbsOrigin())
	local aoe_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_explode.vpcf", PATTACH_ABSORIGIN , target)
            ParticleManager:SetParticleControl(aoe_effect, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(aoe_effect, 1, Vector(radius,radius,radius))
			ParticleManager:SetParticleControl(aoe_effect, 3, target:GetAbsOrigin())
	local nearbyUnits = FindUnitsInRadius(caster:GetTeam(),
                                  target:GetAbsOrigin(),
                                  nil,
                                  radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)

    for _,unit in pairs(nearbyUnits) do
        if unit ~= caster then
            if unit:GetUnitName()~="npc_dota_courier" and unit:GetUnitName()~="npc_dota_flying_courier" then
				caster:SetCursorCastTarget(unit)
				ability:OnSpellStart()
            end
        end
    end
end