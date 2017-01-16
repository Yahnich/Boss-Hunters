function LevelUpAbility( keys )
	local caster = keys.caster
	local this_ability = keys.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name1 = keys.ability_name1
	local ability_handle1 = caster:FindAbilityByName(ability_name1)	
	local ability_level1 = ability_handle1:GetLevel()
	
	local ability_name2 = keys.ability_name2
	local ability_handle2 = caster:FindAbilityByName(ability_name2)	
	local ability_level2 = ability_handle2:GetLevel()

	-- Check to not enter a level up loop
	if ability_level1 ~= this_abilityLevel then
		ability_handle1:SetLevel(this_abilityLevel)
	end
	if ability_level2 ~= this_abilityLevel then
		ability_handle2:SetLevel(this_abilityLevel)
	end
end

function SummonDemon( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target_point = keys.target_points[1]
	local demons = Entities:FindAllByClassname("npc_dota_warlock_golem")
	for _,demon in pairs(demons) do -- clear old demon
		demon:ForceKill(false)
	end
	local demon = CreateUnitByName(keys.unitName, keys.target_points[1], false, caster, caster, caster:GetTeam())
	ResolveNPCPositions(demon:GetAbsOrigin(), demon:GetHullRadius())
	demon.summonAbility = ability
	demon:SetForwardVector(caster:GetForwardVector())
	demon:SetOwner(caster)
	demon:AddNewModifier(demon, nil, "modifier_kill", {duration = keys.Duration})
	for i=0, 6 do
		local demonAb = demon:GetAbilityByIndex(i)
		if demonAb then
			demonAb:SetLevel(ability:GetLevel())
		end
	end
	local hpshare = caster:GetMaxHealth() * ability:GetTalentSpecialValueFor("hp_share") / 100
	local armorshare = caster:GetPhysicalArmorValue() * ability:GetTalentSpecialValueFor("armor_share") / 100
	local damageshare = caster:GetAverageBaseDamage() * ability:GetTalentSpecialValueFor("atk_share") / 100
	
	demon:SetMaxHealth(demon:GetMaxHealth() + hpshare)
	demon:SetBaseMaxHealth(demon:GetBaseMaxHealth() + hpshare)
	demon:SetHealth(demon:GetMaxHealth())
	demon:SetPhysicalArmorBaseValue(demon:GetPhysicalArmorValue() + armorshare)
	demon:SetBaseDamageMax(demon:GetBaseDamageMax() + damageshare)
	demon:SetBaseDamageMin(demon:GetBaseDamageMin() + damageshare)
	demon:StartGesture(ACT_DOTA_CAST_ABILITY_3)
end

LinkLuaModifier("modifier_warlock_deepfire_ember_dot_moloch", "lua_abilities/heroes/warlock", LUA_MODIFIER_MOTION_NONE)

warlock_deepfire_ember = class({})


function warlock_deepfire_ember:OnSpellStart()
	if IsServer() then
		local damage = self:GetAbilityDamage()
		local hTarget = self:GetCursorTarget()
		local bounces = 0
		if self:GetCaster():HasModifier("modifier_transfer_power_naamah") then
			bounces = self:GetCaster():FindAbilityByName("warlock_transfer_power"):GetTalentSpecialValueFor("deepfire_naamah_bounce")
		end
		local projectile = {
			Target = hTarget,
			Source = self:GetCaster(),
			Ability = self,
			EffectName = "particles/warlock_deepfire_ember.vpcf",
			bDodgable = true,
			bProvidesVision = false,
			iMoveSpeed = 1500,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			ExtraData = {bounces_left = bounces, damage = damage, [tostring(hTarget:GetEntityIndex())] = 1}
		}
		ProjectileManager:CreateTrackingProjectile(projectile)
	end
end

function warlock_deepfire_ember:DeepFireProjectile(originalTarget, extraData)
    local caster = self:GetCaster()
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), originalTarget:GetAbsOrigin(), nil, 900,
                    self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
                    0, FIND_CLOSEST, false)
    local target = originalTarget
    for _,enemy in pairs(enemies) do
        if extraData[tostring(enemy:GetEntityIndex())] ~= 1 and not enemy:IsMagicImmune() then
            target = enemy
            break
        end
    end
	EmitSoundOn("Hero_Jakiro.Attack" ,originalTarget)
    if target then
        local projectile = {
            Target = target,
            Source = originalTarget,
            Ability = self,
            EffectName = "particles/warlock_deepfire_ember.vpcf",
            bDodgable = true,
            bProvidesVision = false,
            iMoveSpeed = 1500,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
            ExtraData = extraData
        }
        ProjectileManager:CreateTrackingProjectile(projectile)
    end
end

function warlock_deepfire_ember:OnProjectileHit_ExtraData(target, vLocation, extraData)
	 -- Do damage and reduce bounces
    ApplyDamage({victim = target, attacker = self:GetCaster(), damage = extraData.damage, ability = self, damage_type = self:GetAbilityDamageType()})
	EmitSoundOn("Hero_Jakiro.LiquidFire" ,target)
	if RollPercentage(self:GetTalentSpecialValueFor("empower_chance")) then -- empower handling
		local units = FindUnitsInRadius(self:GetCaster():GetTeam(), target:GetAbsOrigin(), nil, self:GetTalentSpecialValueFor("empower_splash"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), 0, FIND_ANY_ORDER, false)
		for _, enemy in pairs(units) do
			ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = extraData.damage, ability = self, damage_type = self:GetAbilityDamageType()})
		end
		self:GetCaster():Heal(extraData.damage*self:GetTalentSpecialValueFor("empower_heal")*100, self:GetCaster())
		SendOverheadEventMessage( self:GetCaster(), OVERHEAD_ALERT_HEAL , self:GetCaster(), dmgheal, self:GetCaster() )
		local demons = Entities:FindAllByClassname("npc_dota_warlock_golem")
		for _,demon in pairs(demons) do -- heal demon
			demon:Heal(extraData.damage*self:GetTalentSpecialValueFor("empower_heal")*100, self:GetCaster())
			SendOverheadEventMessage( demon, OVERHEAD_ALERT_HEAL , demon, dmgheal, self:GetCaster() )
		end
	end
    -- If there are bounces remaining, reduce damage and find a new target
	if self:GetCaster():HasModifier("modifier_transfer_power_moloch") then
		if IsServer() then
			local power = self:GetCaster():FindAbilityByName("warlock_transfer_power")
			local duration = power:GetTalentSpecialValueFor("deepfire_moloch_duration")
			target:AddNewModifier(self:GetCaster(), self, "modifier_warlock_deepfire_ember_dot_moloch", {duration = duration})
		end
	end
    if extraData.bounces_left > 0 then
		extraData.bounces_left = extraData.bounces_left - 1
        extraData[tostring(target:GetEntityIndex())] = 1
        self:DeepFireProjectile(target, extraData)
    end
end

modifier_warlock_deepfire_ember_dot_moloch = class({})
if IsServer() then
	function modifier_warlock_deepfire_ember_dot_moloch:OnCreated()
		print("seperator", self.duration, self.damage, self:GetCaster())
		if not self.damage then
			local power = self:GetCaster():FindAbilityByName("warlock_transfer_power")
			self.damage = power:GetTalentSpecialValueFor("deepfire_moloch_dot") * self:GetAbility():GetAbilityDamage() / (100*3)
		end
		ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage*0.5, ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType()})
		self:StartIntervalThink(0.5)
	end
	
	function modifier_warlock_deepfire_ember_dot_moloch:OnIntervalThink()
		ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage*0.5, ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType()})
	end
end

function modifier_warlock_deepfire_ember_dot_moloch:GetStatusEffectName()
	return "particles/status_fx/status_effect_burn.vpcf"
end


function TransferPower(keys)
	local caster = keys.caster
	local ability = keys.ability
	local demons = Entities:FindAllByClassname("npc_dota_warlock_golem")
	
	local moloch = caster:FindAbilityByName("warlock_summon_moloch")
	local naamah = caster:FindAbilityByName("warlock_summon_naamah")
	
	if #demons == 0 then
		ability:RefundManaCost()
		ability:EndCooldown()
		return 0
	end
	for _,demon in pairs(demons) do -- clear old demon
		if demon:IsAlive() then
			if demon:GetUnitName() == "npc_dota_warlock_moloch" then
				caster:RemoveModifierByName("modifier_transfer_power_naamah")
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_transfer_power_moloch", {duration = ability:GetDuration()})
				if not naamah:IsActivated() then naamah:SetActivated(true) end
				if moloch:IsActivated() then moloch:SetActivated(false) end
			elseif demon:GetUnitName() == "npc_dota_warlock_naamah" then
				caster:RemoveModifierByName("modifier_transfer_power_moloch")
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_transfer_power_naamah", {duration = ability:GetDuration()})
				if naamah:IsActivated() then naamah:SetActivated(false) end
				if not moloch:IsActivated() then moloch:SetActivated(true) end
			end
			local transfer = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(transfer, 0, demon, PATTACH_POINT_FOLLOW, "attach_hitloc", demon:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(transfer, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			EmitSoundOn(keys.sound1, caster)
			EmitSoundOn(keys.sound2, demon)
			demon:ForceKill(false)
		end
	end
end

function ShadowWord(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local power = caster:FindAbilityByName("warlock_transfer_power")
	if target:IsIllusion() then return end
	local dmgheal = ability:GetTalentSpecialValueFor("damageheal")
	if target:GetTeam() ~= caster:GetTeam() then
		EmitSoundOn("Hero_Warlock.ShadowWordCastBad", target)
		if caster:HasModifier("modifier_transfer_power_naamah") then
			local ms = power:GetTalentSpecialValueFor("shadowword_naamah_movespeed")
			if not target:HasModifier("modifier_shadow_word_naamah_slow") then
				ability:ApplyDataDrivenModifier(caster, target, "modifier_shadow_word_naamah_slow", {duration = ability:GetDuration()})
				target:SetModifierStackCount("modifier_shadow_word_naamah_slow", caster, ms)
			elseif target:GetModifierStackCount("modifier_shadow_word_naamah_slow", caster) ~= ms then
				target:SetModifierStackCount("modifier_shadow_word_naamah_slow", caster, ms)
			end
		end
		if caster:HasModifier("modifier_transfer_power_moloch") then
			dmgheal = dmgheal + dmgheal * power:GetTalentSpecialValueFor("shadowword_moloch_bonus_dmg") / 100
		end
		ApplyDamage({victim = target, attacker = caster, damage = dmgheal, ability = ability, damage_type = ability:GetAbilityDamageType()})
		SendOverheadEventMessage( target, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE , target, dmgheal, caster )
	else
		EmitSoundOn("Hero_Warlock.ShadowWordCastGood", target)
		if caster:HasModifier("modifier_transfer_power_naamah") then
			local ms = power:GetTalentSpecialValueFor("shadowword_naamah_movespeed")
			if not target:HasModifier("modifier_shadow_word_naamah_haste") then
				ability:ApplyDataDrivenModifier(caster, target, "modifier_shadow_word_naamah_haste", {duration = ability:GetDuration()})
				target:SetModifierStackCount("modifier_shadow_word_naamah_haste", caster, ms)
			elseif target:GetModifierStackCount("modifier_shadow_word_naamah_haste", caster) ~= ms then
				target:SetModifierStackCount("modifier_shadow_word_naamah_haste", caster, ms)
			end
		end
		if caster:HasModifier("modifier_transfer_power_moloch") then
			dmgheal = dmgheal + dmgheal * power:GetTalentSpecialValueFor("shadowword_moloch_bonus_dmg") / 100
		end
		target:Heal(dmgheal, caster)
		SendOverheadEventMessage( target, OVERHEAD_ALERT_HEAL , target, dmgheal, caster )
	end
end

function BaphometPulse(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability.shockwaves = 0
	ability.shockwavesTriggered = 0
	ability.shockwaveReduction = 0
	if caster:HasModifier("modifier_transfer_power_moloch") then
		ability.shockwaves = caster:FindAbilityByName("warlock_transfer_power"):GetTalentSpecialValueFor("baphomet_moloch_aftershocks") - 1
		ability.shockwaveReduction = caster:FindAbilityByName("warlock_transfer_power"):GetTalentSpecialValueFor("baphomet_moloch_aftershocks_reduction") / 100
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_baphomet_pulse_attacker", {duration = 0.03 + ability.shockwaves*0.5})
	local demons = Entities:FindAllByClassname("npc_dota_warlock_golem")
	for _,demon in pairs(demons) do -- clear old demon
		ability:ApplyDataDrivenModifier(caster, demon, "modifier_baphomet_pulse_attacker", {duration = 0.03 + ability.shockwaves*0.5})
	end
end

function BaphometPulseHeal(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	local radius = ability:GetTalentSpecialValueFor("radius")
	local units = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, FIND_ANY_ORDER, false)
	for _, unit in pairs(units) do
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_baphomet_pulse_hit", {duration = 0.1})
	end
	
	local heal = #units * ability:GetTalentSpecialValueFor("healdamage") * (1 + ability.shockwaveReduction)^ability.shockwavesTriggered
	if ability.shockwavesTriggered == 0 then
		heal = heal + target:GetMaxHealth()*ability:GetTalentSpecialValueFor("base_heal") / 100
	end
	
	target:Heal(math.floor(heal), caster)
	
	local pulse = ParticleManager:CreateParticle("particles/warlock_baphomet_pulse.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(pulse, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(pulse, 1, Vector(radius,radius,radius))
		ParticleManager:SetParticleControl(pulse, 2, target:GetAbsOrigin())
	
	ability.shockwavesTriggered = ability.shockwavesTriggered + 1
end

function BaphometPulseDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	if caster:HasModifier("modifier_transfer_power_naamah") then
		local power = caster:FindAbilityByName("warlock_transfer_power")
		ability:ApplyDataDrivenModifier(caster, target, "modifier_baphomet_pulse_slow", {duration = power:GetTalentSpecialValueFor("baphomet_naamah_attackslow_duration")})
		target:SetModifierStackCount("modifier_baphomet_pulse_slow", caster, math.abs(power:GetTalentSpecialValueFor("baphomet_naamah_attackslow")))
	end
	
	local damage = ability:GetTalentSpecialValueFor("healdamage") * (1 + ability.shockwaveReduction)^ability.shockwavesTriggered
	ApplyDamage({victim = target, attacker = caster, damage = damage, ability = ability, damage_type = ability:GetAbilityDamageType()})
	
	ability.shockwavesTriggered = ability.shockwavesTriggered + 1
end