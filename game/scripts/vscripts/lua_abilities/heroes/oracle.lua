function AghsCheck(keys)
	if keys.caster:HasScepter() then
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.target,"purifying_flames_scepter",nil)
	end
end

function FlameDamage(keys)
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = keys.damage, damage_type = keys.ability:GetAbilityDamageType(), ability = keys.ability })
end

function FlameHealCreate(keys)
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	local heal = ability:GetTalentSpecialValueFor("heal_per_second")
	if ability.stack == nil then ability.stack = 0 end
	ability.stack = ability.stack + 1
	target:RemoveModifierByName("purifying_flames_heal_counter")
	ability:ApplyDataDrivenModifier(caster,target,"purifying_flames_heal_counter",nil)
	target:SetModifierStackCount( "purifying_flames_heal_counter", ability, ability.stack)
	target:Heal(heal,keys.caster)
end

function FlameHeal(keys)
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	local heal = ability:GetTalentSpecialValueFor("heal_per_second")
	if ability.stack == nil then ability.stack = 0 end
	target:Heal(heal,keys.caster)
end

function FlameHealDestroy(keys)
	local ability = keys.ability
	if ability.stack == nil then ability.stack = 1 end
	ability.stack = ability.stack - 1
	keys.target:SetModifierStackCount( "purifying_flames_heal_counter", ability, ability.stack)
	if ability.stack == 0 then keys.target:RemoveModifierByName("purifying_flames_heal_counter") end
end

function ShareUpgrade(keys)
	local caster = keys.caster
	local this_ability = keys.ability	
		local this_abilityName = this_ability:GetAbilityName()
		local this_abilityLevel = this_ability:GetLevel()	
			-- The ability to level up
		local ability_name = keys.twin
		if caster:FindAbilityByName(ability_name) then
			local ability_handle = caster:FindAbilityByName(ability_name)	
			local ability_level = ability_handle:GetLevel()
			-- Check to not enter a level up loop
			if ability_level ~= this_abilityLevel then
				ability_handle:SetLevel(this_abilityLevel)
			end
		end
end

function AghsCounterUp(keys)
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	if ability.stack == nil then ability.stack = 0 end
	ability.stack = ability.stack + 1
	target:RemoveModifierByName("purifying_flames_scepter_counter")
	ability:ApplyDataDrivenModifier(caster,target,"purifying_flames_scepter_counter",nil)
	target:SetModifierStackCount( "purifying_flames_scepter_counter", ability, ability.stack)
end

function AghsCounterDown(keys)
	local ability = keys.ability
	if ability.stack == nil then ability.stack = 1 end
	ability.stack = ability.stack - 1
	keys.target:SetModifierStackCount( "purifying_flames_scepter_counter", ability, ability.stack)
	if ability.stack == 0 then keys.target:RemoveModifierByName("purifying_flames_scepter_counter") end
end

function FateDelay(keys)
	local ability = keys.ability
	local caster = keys.caster
	
	local maxBlock = ability:GetTalentSpecialValueFor("max_hp_block") / 100
	local duration = ability:GetTalentSpecialValueFor("duration")
	
	local target = ability:GetCursorPosition()
	
	local allies = FindUnitsInRadius(caster:GetTeam(),
                                  target,
                                  nil,
                                  ability:GetCastRange(),
                                  DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                  DOTA_UNIT_TARGET_HERO,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
	local castermaxHp = caster:GetMaxHealth()
	local casterblock = castermaxHp * maxBlock
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_oracle_fate_extension_visual", {duration = duration})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_oracle_fate_extension_block", {duration = duration})
	caster:SetModifierStackCount("modifier_oracle_fate_extension_block", caster, casterblock)
	for _,ally in pairs(allies) do
		local maxHp = ally:GetMaxHealth()
		local block = maxHp * maxBlock
		ability:ApplyDataDrivenModifier(caster, ally, "modifier_oracle_fate_extension_visual", {duration = duration})
		ability:ApplyDataDrivenModifier(caster, ally, "modifier_oracle_fate_extension_block", {duration = duration})
		ally:SetModifierStackCount("modifier_oracle_fate_extension_block", caster, block)
		EmitSoundOn("Hero_Oracle.FatesEdict", ally)
		ally.Particle = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_death.vpcf", PATTACH_ABSORIGIN, ally)
						ParticleManager:SetParticleControl(ally.Particle, 0, ally:GetAbsOrigin())
						ParticleManager:SetParticleControl(ally.Particle, 1, ally:GetAbsOrigin())
						ParticleManager:SetParticleControl(ally.Particle, 3, ally:GetAbsOrigin())
		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle( ally.Particle, false )
			return nil
			end
		)
	end
end