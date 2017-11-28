function SableDjinnHandler(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsMoving() and not caster:PassivesDisabled() and not ability:GetToggleState() then
		if not caster.sandStorm then
			caster.sandStorm = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_sandstorm.vpcf",PATTACH_POINT_FOLLOW,caster)
		end
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_sable_djinn_sandstorm", {})
	else
		caster:RemoveModifierByName("modifier_sable_djinn_sandstorm")
		if caster.sandStorm then
			ParticleManager:DestroyParticle(caster.sandStorm, false)
			ParticleManager:ReleaseParticleIndex(caster.sandStorm)
			caster.sandStorm = nil
			caster.growthReached = 0
			caster.sandStormRadius = nil
			caster.sandStormDamage = nil
		end
	end
end

function SableDjinnDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local thinkinterval = ability:GetTalentSpecialValueFor("sand_storm_think")
	local maxtime = ability:GetTalentSpecialValueFor("sand_storm_grow_time")
	caster.growthReached = caster.growthReached or 0
	if caster.growthReached < maxtime then
		if not caster.sandStormRadius then caster.sandStormRadius = ability:GetTalentSpecialValueFor("sand_storm_base_radius") 
		else caster.sandStormRadius = caster.sandStormRadius + ability:GetTalentSpecialValueFor("sand_storm_radius_grow")*thinkinterval end
		
		if not caster.sandStormDamage then caster.sandStormDamage = ability:GetTalentSpecialValueFor("sand_storm_base_damage") 
		else caster.sandStormDamage = caster.sandStormDamage + ability:GetTalentSpecialValueFor("sand_storm_damage_grow")*thinkinterval end
		caster.growthReached = caster.growthReached + thinkinterval
	end
	
	ParticleManager:SetParticleControl(caster.sandStorm, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(caster.sandStorm, 1, Vector(caster.sandStormRadius,caster.sandStormRadius,caster.sandStormRadius))
	
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, caster.sandStormRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER , false)
	
	for _,enemy in pairs( enemies ) do
        ApplyDamage({victim = enemy, attacker = keys.caster, damage = caster.sandStormDamage*thinkinterval, damage_type = ability:GetAbilityDamageType(), ability = ability})
		if caster:HasTalent("special_bonus_unique_sand_king_4") then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_sable_djinn_sandstorm_talent", {duration = 0.5})
		end
    end
end

sandking_burrowstrike_ebf = class({})

if IsServer() then
	function sandking_burrowstrike_ebf:OnSpellStart()
		self.vLocation = self:GetCursorPosition()
		self.vStartLoc = self:GetCaster():GetAbsOrigin()
		self.vDirection = (self.vStartLoc - self.vLocation):Normalized()
		self.width = self:GetTalentSpecialValueFor("burrow_width")
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_burrowstrike.vpcf", PATTACH_POINT, self:GetCaster())
			ParticleManager:SetParticleControl(particle, 0, self.vStartLoc)
			ParticleManager:SetParticleControl(particle, 1, self.vLocation)
		local targets = FindUnitsInLine(self:GetCaster():GetTeamNumber(), self.vStartLoc, self.vLocation, nil, self.width, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE)
		for _,target in pairs(targets) do
			ApplyDamage({victim = target, attacker = self:GetCaster(), damage = self:GetAbilityDamage(), damage_type = self:GetAbilityDamageType(), ability = self})
			target:AddNewModifier(self:GetCaster(), self, "modifier_sandking_burrowstrike_ebf_stun", {duration = self:GetTalentSpecialValueFor("burrow_duration")})
			if self:GetCaster():HasScepter() then
				local caustic = self:GetCaster():FindAbilityByName("sandking_caustic_finale")
				local cDuration = caustic:GetTalentSpecialValueFor("caustic_finale_duration")
				target:AddNewModifier(self:GetCaster(), caustic, "modifier_sand_king_caustic_finale_orb", {duration = cDuration})
			end
		end
		self:GetCaster():EmitSound("Ability.SandKing_BurrowStrike")
		FindClearSpaceForUnit(self:GetCaster(), self.vLocation, true)
	end
end

function sandking_burrowstrike_ebf:GetCastRange( vLocation, hTarget )
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor( "cast_range_scepter" )
	end

	return self:GetTalentSpecialValueFor( "tooltip_range" )
end

LinkLuaModifier( "modifier_sandking_burrowstrike_ebf_stun", "lua_abilities/heroes/sandking.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_sandking_burrowstrike_ebf_stun = class({})

function modifier_sandking_burrowstrike_ebf_stun:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_sandking_burrowstrike_ebf_stun:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_sandking_burrowstrike_ebf_stun:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end