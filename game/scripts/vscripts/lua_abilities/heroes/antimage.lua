require( "libraries/Timers" )
LinkLuaModifier( "modifier_mage_rage_leech", "lua_abilities/heroes/modifiers/modifier_mage_rage_leech.lua" ,LUA_MODIFIER_MOTION_NONE )

function ApplyLuaModifier(keys)
	if not keys.target:HasModifier(keys.modifier) then
		keys.target:AddNewModifier(keys.caster, keys.ability, keys.modifier, nil)
	end
end

function MageRageUnload(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = caster.rage*(keys.unload/100)
	if damage > 1 and not target:IsMagicImmune() then
		ability:ApplyDataDrivenModifier( caster, target, "mage_rage_active", {duration = 0.08})
		ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability })
		caster.rage = caster.rage - damage
	end
end

function MageRageVisual(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster.rage == nil then
		caster.rage = 0
	end
	if caster.bank == nil then
		caster.bank = 0
	end
	local limit = keys.limit
	if caster:HasScepter() then
		limit = keys.limit_scepter
	end
	if caster.rage > limit then
		caster.rage = limit
	end
	if caster.bank > limit then
		caster.bank = limit
	end

	if not caster.ragedelay then caster.ragedelay = GameRules:GetGameTime() end
	if caster:HasScepter() and (caster:IsAttacking() or caster.ragedelay >= GameRules:GetGameTime() - 2) then
		local generation = ability:GetTalentSpecialValueFor("rage_gen_scepter")
		caster.rage = caster.rage + generation * 0.1 / 2 --0.1 tick interval; split over bank and active
		caster.bank = caster.bank + generation * 0.1 / 2
		if caster:IsAttacking() then caster.ragedelay = GameRules:GetGameTime() end
	end
	if not caster:HasModifier(keys.modifier_rage) and caster.rage > 10 then
		ability:ApplyDataDrivenModifier(caster, target, keys.modifier_rage, {})
	end
	if not caster:HasModifier(keys.modifier_bank)  and caster.bank > 10  then
		ability:ApplyDataDrivenModifier(caster, target, keys.modifier_bank, {})
	end
	caster:SetModifierStackCount( keys.modifier_rage, ability, math.floor(caster.rage + 0.5) )
	caster:SetModifierStackCount( keys.modifier_bank, ability, math.floor(caster.bank + 0.5) )
	if caster.bank < 1 then
		caster:RemoveModifierByName(keys.modifier_bank)
	end
	if caster.rage < 1 then
		caster:RemoveModifierByName(keys.modifier_rage)
	end
end

function RageVoid(keys)
	local caster = keys.caster
	local target = keys.target
	local targetLocation = target:GetAbsOrigin()
	local ability = keys.ability
	local multiplier = keys.multiplier
	local radius = ability:GetTalentSpecialValueFor("mana_void_aoe_radius")
	
	-- if caster:HasScepter() then
		-- multiplier = keys.multiplier_scepter
	-- end
	if ability:IsStolen() then
		local antimage = caster.target
		caster.rage = antimage.rage
		caster.bank = antimage.bank
	end
	if caster.bank and caster.rage then
		if (caster.bank+caster.rage) > 1 then
			local damage = (caster.bank + caster.rage)*multiplier
			local unitsToDamage = FindUnitsInRadius(caster:GetTeam(), targetLocation, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
			for _,v in ipairs(unitsToDamage) do
				ApplyDamage({ victim = v, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability })
			end
			caster.bank = 0
			caster.rage = 0
		end
	end
end

function RageBlockPurge(keys)
	local caster = keys.caster
	if keys.ability:GetCooldownTimeRemaining() == 0 then
		caster:Purge(false,true,false,true,true)
		local burst_effect = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/am_basher.vpcf", PATTACH_ABSORIGIN , caster)
            ParticleManager:SetParticleControl(burst_effect, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(burst_effect, 1, caster:GetAbsOrigin() + Vector(math.random(-200,200),math.random(-200,200),math.random(400)))
			ParticleManager:SetParticleControl(burst_effect, 2, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(burst_effect, 3, caster:GetAbsOrigin())
	end
end

function RageBlockDoubleAttack(keys)
		if keys.ability.stagger then 
			keys.ability.stagger = false
			return
		end
		local delay = keys.caster:GetSecondsPerAttack() / 2
		Timers:CreateTimer(delay,function()
			if keys.target:IsAlive() then
				if keys.caster:IsAlive() then
					keys.ability.stagger = true
					keys.caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, (2*keys.caster:GetAttacksPerSecond()))
					keys.caster:PerformAttack(keys.target, false,true,true,false,false)
					local burst_effect = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_manavoid_flare_ti_5.vpcf", PATTACH_ABSORIGIN , keys.caster)
					ParticleManager:SetParticleControl(burst_effect, 0, keys.caster:GetAbsOrigin())
				end
			end
		end)
end