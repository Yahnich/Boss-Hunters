lina_self_immolate_kindled = class({})
lina_self_immolate = class({})

LinkLuaModifier( "modifier_lina_self_immolate_kindled", "lua_abilities/heroes/lina.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lina_self_immolate", "lua_abilities/heroes/lina.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function lina_self_immolate_kindled:OnSpellStart()
	self.duration = self:GetSpecialValueFor( "buff_duration" )
	-- kindle handling
	self.fierysoulextend = self:GetSpecialValueFor("kindle_extension")
	local kindle = self:GetCaster():FindModifierByName("modifier_fiery_soul_kindled")
	kindle:SetDuration(kindle:GetRemainingTime() + self.fierysoulextend, true)
	-- hp cost
	local hpReduction = self:GetCaster():GetHealth() - self:GetCaster():GetMaxHealth() * self:GetSpecialValueFor("hp_cost") / 100
	if hpReduction < 10 then hpReduction = 1 end
	self:GetCaster():SetHealth( hpReduction )
	self:GetCaster():AddNewModifier( self:GetCaster(), self,  "modifier_lina_self_immolate", { duration = self.duration} )
end

function lina_self_immolate:OnSpellStart()
	self.duration = self:GetSpecialValueFor( "buff_duration" )
	self.fierysoulstacks = self:GetSpecialValueFor("fiery_soul_stacks")
	local kindle = self:GetCaster():FindModifierByName("modifier_fiery_soul_buff_datadriven")
	kindle:SetStackCount( kindle:GetStackCount() + self.fierysoulstacks )
	if kindle:GetStackCount() >= 100 then kindle:SetStackCount(99) end
	local hpReduction = self:GetCaster():GetHealth() - self:GetCaster():GetMaxHealth() * self:GetSpecialValueFor("hp_cost") / 100
	if hpReduction < 10 then hpReduction = 1 end
	self:GetCaster():SetHealth( hpReduction )
    self:GetCaster():AddNewModifier( self:GetCaster(), self,  "modifier_lina_self_immolate", { duration = self.duration} )
end


modifier_lina_self_immolate = class({})

function modifier_lina_self_immolate:OnCreated()
	self.damagebonus = self:GetAbility():GetSpecialValueFor("magical_damage_on_hit")
end

function modifier_lina_self_immolate:DeclareFunctions()
	return 
	{ 
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
	}
end

function modifier_lina_self_immolate:GetModifierProcAttack_BonusDamage_Magical(params)
	return self.damagebonus
end


modifier_lina_self_immolate_kindled = class({})

function modifier_lina_self_immolate_kindled:OnCreated()
	self.damagebonus = self:GetAbility():GetSpecialValueFor("magical_damage_on_hit")
end

function modifier_lina_self_immolate_kindled:DeclareFunctions()
	return 
	{ 
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
	}
end

function modifier_lina_self_immolate_kindled:GetModifierProcAttack_BonusDamage_Magical(params)
	return self.damagebonus
end

function FierySoul( keys )
	local caster = keys.caster
	if caster:HasModifier("modifier_fiery_soul_kindled") then return end
	local ability = keys.ability
	local maxStack = ability:GetLevelSpecialValueFor("trigger_stacks", (ability:GetLevel() - 1))
	local currentStack = 0
	local modifierStackName = "modifier_fiery_soul_buff_datadriven"
	ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {duration = ability:GetDuration()}) -- refresh modifierStackName
	local stacks = caster:GetModifierStackCount(modifierStackName, caster) + 1
	if stacks >= maxStack then -- SWAP TO STRONK
		caster:RemoveModifierByName(modifierStackName)
		local kindle = caster:FindAbilityByName(keys.blazingsoul)
		kindle:SetLevel(ability:GetLevel())
		caster:SwapAbilities(ability:GetName(), keys.blazingsoul, false, true)
		local slave_k = caster:FindAbilityByName("lina_dragon_slave_kindled")
		local slave = caster:FindAbilityByName("lina_dragon_slave")
		slave_k:SetLevel(slave:GetLevel())
		caster:SwapAbilities("lina_dragon_slave", "lina_dragon_slave_kindled", false, true)
		local strike_k = caster:FindAbilityByName("lina_light_strike_array_kindled")
		local strike = caster:FindAbilityByName("lina_light_strike_array")
		strike_k:SetLevel(strike:GetLevel())
		caster:SwapAbilities("lina_light_strike_array", "lina_light_strike_array_kindled", false, true)
		local immo_k = caster:FindAbilityByName("lina_self_immolate_kindled")
		local immo = caster:FindAbilityByName("lina_self_immolate")
		immo_k:SetLevel(immo:GetLevel())
		caster:SwapAbilities("lina_self_immolate", "lina_self_immolate_kindled", false, true)
		local blade_k = caster:FindAbilityByName("lina_laguna_blade_kindled")
		local blade = caster:FindAbilityByName("lina_laguna_blade")
		blade_k:SetLevel(blade:GetLevel())
		caster:SwapAbilities("lina_laguna_blade", "lina_laguna_blade_kindled", false, true)
		kindle:ApplyDataDrivenModifier(caster, caster, "modifier_fiery_soul_kindled", {duration = kindle:GetSpecialValueFor("kindle_duration")})
	else
		caster:SetModifierStackCount(modifierStackName, caster, stacks)
	end	
end

function HandleSoulSwap(keys)
	local caster = keys.caster
	local ability = keys.ability
	local kindle = caster:FindAbilityByName(keys.blazingsoul)
	kindle:SetLevel(ability:GetLevel())
	caster:SwapAbilities(ability:GetName(), keys.blazingsoul, false, true)
	local slave_k = caster:FindAbilityByName("lina_dragon_slave_kindled")
	local slave = caster:FindAbilityByName("lina_dragon_slave")
	slave:SetLevel(slave_k:GetLevel())
	caster:SwapAbilities("lina_dragon_slave", "lina_dragon_slave_kindled", true, false)
	local strike_k = caster:FindAbilityByName("lina_light_strike_array_kindled")
	local strike = caster:FindAbilityByName("lina_light_strike_array")
	strike:SetLevel(strike_k:GetLevel())
	caster:SwapAbilities("lina_light_strike_array", "lina_light_strike_array_kindled", true, false)
	local immo_k = caster:FindAbilityByName("lina_self_immolate_kindled")
	local immo = caster:FindAbilityByName("lina_self_immolate")
	immo:SetLevel(immo_k:GetLevel())
	caster:SwapAbilities("lina_self_immolate", "lina_self_immolate_kindled", true, false)
	local blade_k = caster:FindAbilityByName("lina_laguna_blade_kindled")
	local blade = caster:FindAbilityByName("lina_laguna_blade")
	blade:SetLevel(blade_k:GetLevel())
	caster:SwapAbilities("lina_laguna_blade", "lina_laguna_blade_kindled", true, false)
	return
end

function KindledDragonSlave(keys)
	local ability = keys.ability
	local caster = keys.caster
	local counter = ability:GetSpecialValueFor("total_dragon_slaves")
	local maxcounter = counter
	local delay = 0.1
	Timers:CreateTimer(delay,function()
 		if counter > 0 and counter < maxcounter then
				local projectileTable = {
					Ability = ability,
					EffectName = "particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_headflame.vpcf",
					vSpawnOrigin = caster:GetAbsOrigin(),
					fDistance = ability:GetSpecialValueFor("dragon_slave_distance"),
					fStartRadius = ability:GetSpecialValueFor("dragon_slave_width_initial"),
					fEndRadius = ability:GetSpecialValueFor("dragon_slave_width_end"),
					Source = caster,
					bHasFrontalCone = true,
					bReplaceExisting = false,
					bProvidesVision = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType = DOTA_UNIT_TARGET_ALL,
					bDeleteOnHit = false,
					vVelocity = RotateVector2D(caster:GetForwardVector(), (maxcounter-counter)*0.261799) * ability:GetSpecialValueFor("dragon_slave_speed")
					}
				local dragonslave1 = ProjectileManager:CreateLinearProjectile( projectileTable )
				local projectileTable = {
					Ability = ability,
					EffectName = "particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_headflame.vpcf",
					vSpawnOrigin = caster:GetAbsOrigin(),
					fDistance = ability:GetSpecialValueFor("dragon_slave_distance"),
					fStartRadius = ability:GetSpecialValueFor("dragon_slave_width_initial"),
					fEndRadius = ability:GetSpecialValueFor("dragon_slave_width_end"),
					Source = caster,
					bHasFrontalCone = true,
					bReplaceExisting = false,
						bProvidesVision = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType = DOTA_UNIT_TARGET_ALL,
					bDeleteOnHit = false,
					vVelocity = RotateVector2D(caster:GetForwardVector(), -(maxcounter-counter)*0.261799) * ability:GetSpecialValueFor("dragon_slave_speed")
				}
				local dragonslave2 = ProjectileManager:CreateLinearProjectile( projectileTable )
			counter = counter - 2
			return delay
		elseif counter == maxcounter then
			local projectileTable = {
					Ability = ability,
					EffectName = "particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_headflame.vpcf",
					vSpawnOrigin = caster:GetAbsOrigin(),
					fDistance = ability:GetSpecialValueFor("dragon_slave_distance"),
					fStartRadius = ability:GetSpecialValueFor("dragon_slave_width_initial"),
					fEndRadius = ability:GetSpecialValueFor("dragon_slave_width_end"),
					Source = caster,
					bHasFrontalCone = true,
					bReplaceExisting = false,
					bProvidesVision = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType = DOTA_UNIT_TARGET_ALL,
					bDeleteOnHit = false,
					vVelocity = caster:GetForwardVector() * ability:GetSpecialValueFor("dragon_slave_speed")
					}
				local dragonslave1 = ProjectileManager:CreateLinearProjectile( projectileTable )
			counter = counter - 2
			return delay
		else
			return nil
		end
 	end)
end

function KindledDragonSlaveHit(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	if not target.dragonSlaveHit then 
		target.dragonSlaveHit = true
		ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
	else Timers:CreateTimer(0.15,function() target.dragonSlaveHit = false end) end
end

function KindledLightStrike(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local stunMod = keys.stunModifier
	local stunDuration = keys.stunDuration
	ability:ApplyDataDrivenModifier(caster, target, stunMod, {duration = stunDuration})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_light_strike_array_mrdebuff", {duration = stunDuration})
	
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function KindledLaguna(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local damage = ability:GetSpecialValueFor("damage")
	local damage_type = ability:GetAbilityDamageType()
	if caster:HasScepter() then damage_type = ability:AbilityScepterDamageType() end
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = damage_type, ability = ability})
end