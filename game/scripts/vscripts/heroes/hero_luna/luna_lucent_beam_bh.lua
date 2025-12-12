luna_lucent_beam_bh = class({})

function luna_lucent_beam_bh:GetCooldown(iLvl)
	return self.BaseClass.GetCooldown(self, iLvl) + self:GetCaster():FindTalentValue("special_bonus_unique_luna_lucent_beam_2", "cd")
end

function luna_lucent_beam_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_luna_lucent_beam_1") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT
	else	
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function luna_lucent_beam_bh:OnAbilityPhaseStart()
	self.warmUpFX = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_lucent_beam_precast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
	return true
end

function luna_lucent_beam_bh:OnAbilityPhaseInterrupted()
	ParticleManager:ClearParticle( self.warmUpFX )
end

function luna_lucent_beam_bh:OnSpellStart( target )
	local caster = self:GetCaster()
	local target = target or self:GetCursorTarget()
	local position = self:GetCursorPosition()
	
	if not target and caster:HasTalent("special_bonus_unique_luna_lucent_beam_1") then
		local enemies = caster:FindEnemyUnitsInRadius( position, caster:FindTalentValue("special_bonus_unique_luna_lucent_beam_1", "search_radius"), {order = FIND_CLOSEST} )
		if enemies[1] then
			target = enemies[1]
		end
	end
	
	self:LucentBeam(target or position, true)
	
	if caster:HasScepter() then
		local eclipse = caster:FindAbilityByName("luna_eclipse_bh")
		if eclipse and eclipse:GetLevel() > 0 then
			eclipse:CreateEclipse( target or position, self:GetSpecialValueFor("scepter_modifier") / 100 )
		end
	end
	
	caster:EmitSound("Hero_Luna.LucentBeam.Cast")
	ParticleManager:FireParticle("particles/units/heroes/hero_luna/luna_lucent_beam_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	
	if caster:HasTalent("special_bonus_unique_luna_lunar_blessing_2") then
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
			ally:AddNewModifier( caster, caster:FindAbilityByName("luna_lunar_blessing_bh"), "modifier_luna_lunar_blessing_bh_talent", { duration = caster:FindTalentValue("special_bonus_unique_luna_lunar_blessing_2", "duration") } )
		end
	end
end

function luna_lucent_beam_bh:LucentBeam(target, bFull)
	local caster = self:GetCaster()
	local hasTarget = target.GetAbsOrigin ~= nil
	local position
	
	if not hasTarget then
		position = target
	else
		position = target:GetAbsOrigin()
	end
	
	local sDur = TernaryOperator( self:GetSpecialValueFor("stun_duration"), GameRules:IsDaytime(), self:GetSpecialValueFor("stun_night") )
	local damage = TernaryOperator( self:GetSpecialValueFor("beam_damage"), GameRules:IsDaytime(), self:GetSpecialValueFor("night_beam_damage") )
	
	if hasTarget then
		if not target:TriggerSpellAbsorb( self ) then
			self:DealDamage( caster, target, damage )
			if bFull then
				self:Stun( target, sDur )
			end
		end
	end
	
	if bFull and caster:HasTalent("special_bonus_unique_luna_lucent_beam_1") then
		self.moon_glaive = self.moon_glaive or caster:FindAbilityByName("luna_moon_glaive_bh")
		if self.moon_glaive and self.moon_glaive:GetLevel() > 0 then
			local enemies = caster:FindEnemyUnitsInRadius( position, self.moon_glaive:GetSpecialValueFor("range"), {order = FIND_CLOSEST} )
			if #enemies > 0 then
				local rng = RandomInt(1, #enemies)
				enemy = enemies[rng]
				if enemy then
					if not hasTarget then
						target = caster:CreateDummy(position, 0.3)
					end
					self.moon_glaive:LaunchMoonGlaive( enemy, 0, nil, target)
				end
			end
		end
	end
		
	if hasTarget then
		ParticleManager:FireParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_ABSORIGIN, target, { [1] = position, 
																														[2] = {attach = PATTACH_POINT_FOLLOW, point = "attach_hitloc"}, 
																														[5] = {attach = PATTACH_POINT_FOLLOW, point = "attach_hitloc"}, 
																														[6] = {attach = PATTACH_POINT_FOLLOW, point = "attach_hitloc"}})
	else
		ParticleManager:FireParticle("particles/units/heroes/hero_luna/luna_lucent_beam_position.vpcf", PATTACH_WORLDORIGIN, nil, {  [1] = position, 
																														[2] = position, 
																														[5] = position, 
																														[6] = position})
	end
	if bFull then EmitSoundOnLocationWithCaster(position, "Hero_Luna.LucentBeam.Target", caster) end
end