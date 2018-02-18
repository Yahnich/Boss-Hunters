function rearm_start( keys )
    local caster = keys.caster
    local ability = keys.ability
    local abilityLevel = ability:GetLevel()-1
    if abilityLevel <= 3 then 
        ability:ApplyDataDrivenModifier( caster, caster, "modifier_rearm_level_1_datadriven", {} )
    elseif abilityLevel <= 5 then 
        ability:ApplyDataDrivenModifier( caster, caster, "modifier_rearm_level_2_datadriven", {} )
    else
        ability:ApplyDataDrivenModifier( caster, caster, "modifier_rearm_level_3_datadriven", {} )
    end
end

function rearm_refresh_cooldown( keys )
    local caster = keys.caster
    local ability = keys.ability
    -- Reset cooldown for abilities
    for i = 0, caster:GetAbilityCount() - 1 do
        local ability = caster:GetAbilityByIndex( i )
        if ability and ability ~= keys.ability then
            ability:Refresh()
        end
    end

    local no_refresh_item = {["item_ressurection_stone"] = true,
							 ["item_refresher"] = true,
							 ["item_bahamut_chest"]= true,
							 ["item_asura_plate"]= true,
							 ["item_octarine_core4"] = true,
							 ["item_octarine_core5"] = true,
							 ["item_asura_core"] = true,
							 ["item_lifesteal2"] = true,
							 ["item_lifesteal3"] = true,
							 ["item_lifesteal4"] = true,}
	local half_refresh_item = {["item_chronos_shard"] = true, 
							   ["item_blade_mail"] = true,
							   ["item_blade_mail2"] = true,
							   ["item_blade_mail3"] = true,
							   ["item_blade_mail4"] = true,
							   ["item_pixels_guard"] = true,
							   ["item_sheepstick"] = true,}
	
    for i = 0, 5 do
        local item = caster:GetItemInSlot( i )
		if item then
			local cd = item:GetCooldownTimeRemaining()
			if not no_refresh_item[ item:GetAbilityName() ] then
				item:Refresh()
			end
			if cd > 1 and half_refresh_item[ item:GetAbilityName() ] then
				item:StartCooldown(cd/2)
			end
		end
    end
end

function heat_seeking_missile_seek_targets( keys )
    -- Variables
    local caster = keys.caster
    local ability = keys.ability
    local particleName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf"
    local modifierDudName = "modifier_heat_seeking_missile_dud"
    local projectileSpeed = 900
    local radius = ability:GetTalentSpecialValueFor( "radius")
    local max_targets = ability:GetTalentSpecialValueFor( "targets")
    local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
    local targetType = DOTA_UNIT_TARGET_ALL
    local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
    local projectileDodgable = false
    local projectileProvidesVision = false
     if HasCustomScepter(caster) == true or caster:HasScepter() then
		radius = ability:GetTalentSpecialValueFor( "radius_scepter")
		max_targets = ability:GetTalentSpecialValueFor( "targets_scepter")
	end
    -- pick up x nearest target heroes and create tracking projectile targeting the number of targets
    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, targetTeam, targetType, targetFlag, FIND_CLOSEST, false)  
    -- Seek out target
    local count = 0
    for k, v in pairs( units ) do
        if count < max_targets then
            local projTable = {
                Target = v,
                Source = caster,
                Ability = ability,
                EffectName = particleName,
                bDodgeable = projectileDodgable,
                bProvidesVision = projectileProvidesVision,
                iMoveSpeed = projectileSpeed, 
                vSpawnOrigin = caster:GetAbsOrigin()
            }
            ProjectileManager:CreateTrackingProjectile( projTable )
            count = count + 1
        else
            break
        end
    end
    
    -- If no unit is found, fire dud
    if count == 0 then
        ability:ApplyDataDrivenModifier( caster, caster, modifierDudName, {} )
    end
end

function heat_seeking_missile_seek_damage( keys )
    -- Variables
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local damage = ability:GetAbilityDamage() 
	if HasCustomScepter(caster) == true or caster:HasScepter() then
        damage = ability:GetTalentSpecialValueFor("damage_scepter")
    end
	
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
		ability = ability
    }
    ApplyDamage( damageTable )
    if caster:HasTalent("special_bonus_unique_tinker_3") then
		target:AddNewModifier(caster, ability, "modifier_stunned_generic", {duration = caster:FindTalentValue("special_bonus_unique_tinker_3")})
	end
    -- pick up x nearest target heroes and create tracking projectile targeting the number of targets
end


tinker_laser_ebf = class({})

function tinker_laser_ebf:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Tinker.LaserAnim", self:GetCaster())
	return true
end

function tinker_laser_ebf:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Tinker.LaserAnim", self:GetCaster())
end

function tinker_laser_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_Tinker.Laser", caster)
	self:FireLaser(target)
	
	if caster:HasScepter() then
		local hitTargets = {}
		local scepterRadius = self:GetTalentSpecialValueFor("cast_range_scepter")
		local FindNextUnit = function(lastTarget, targetList)
			for _, unit in ipairs( self:GetCaster():FindEnemyUnitsInRadius(lastTarget:GetAbsOrigin(), scepterRadius, {order = FIND_CLOSEST}) ) do
				if not targetList[unit:entindex()] then
					return unit
				end
			end
		end
		while FindNextUnit(target, hitTargets) do
			local newTarget = FindNextUnit(target, hitTargets)
			hitTargets[target:entindex()] = true
			self:FireLaser(newTarget, target)
			target = newTarget
		end
	end
end

function tinker_laser_ebf:FireLaser(target, oldTarget)
	local caster = self:GetCaster()
	
	local laserDamage = self:GetTalentSpecialValueFor("laser_damage")
	local blindDuration = self:GetTalentSpecialValueFor("duration")
	
	self:DealDamage(caster, target, laserDamage)
	target:AddNewModifier(caster, self, "modifier_tinker_laser_ebf_blind", {duration = blindDuration})
	EmitSoundOn("Hero_Tinker.LaserImpact", target)
	
	local owner = oldTarget or caster
	local FX = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_POINT_FOLLOW, owner)

	ParticleManager:SetParticleControlEnt(FX, 9, owner, PATTACH_POINT_FOLLOW, "attach_attack2", owner:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(FX, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	
	ParticleManager:ReleaseParticleIndex(FX)
end

modifier_tinker_laser_ebf_blind = class({})
LinkLuaModifier("modifier_tinker_laser_ebf_blind", "lua_abilities/heroes/tinker", 0)

function modifier_tinker_laser_ebf_blind:OnCreated()
	self.miss = self:GetTalentSpecialValueFor("miss_rate")
end

function modifier_tinker_laser_ebf_blind:OnRefresh()
	self.miss = self:GetTalentSpecialValueFor("miss_rate")
end

function modifier_tinker_laser_ebf_blind:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_tinker_laser_ebf_blind:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_tinker_laser_ebf_blind:GetEffectName()
	return "particles/units/heroes/hero_tinker/tinker_laser_debuff.vpcf"
end