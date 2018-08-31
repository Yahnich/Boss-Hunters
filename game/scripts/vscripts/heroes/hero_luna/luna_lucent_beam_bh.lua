luna_lucent_beam_bh = class({})

function luna_lucent_beam_bh:GetCooldown(iLvl)
	return ( self.BaseClass.GetCooldown(self, iLvl) + self:GetCaster():FindTalentValue("special_bonus_unique_luna_lucent_beam_2") )
end

function luna_lucent_beam_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_luna_lucent_beam_1") then
		return DOTA_ABILITY_BEHAVIOR_POINT
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

function luna_lucent_beam_bh:OnSpellStart()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_luna_lucent_beam_1") then
		local target = self:GetCursorPosition()
		
		local radius = caster:FindTalentValue("special_bonus_unique_luna_lucent_beam_1", "radius")
		local interval = caster:FindTalentValue("special_bonus_unique_luna_lucent_beam_1")
		
		local beams = math.ceil( (self:GetTrueCastRange() - 150) / radius )
		local direction = CalculateDirection(target, caster)
		local initPos = caster:GetAbsOrigin() + direction * 150
		
		local gifts = caster:FindAbilityByName("luna_lunar_blessing_bh")
		if gifts and gifts:GetLevel() > 0 then
			local waves = 1 + gifts:GetTalentSpecialValueFor("bonus_lucent_targets")
			local angle = 15
			for i = 1, waves do
				local divider = 0
				if (waves % 2) == 0 then
					divider = angle / 2
				end
				local newAngle = math.abs( math.ceil( ( i - ( (waves % 2) ) ) / 2 ) * (angle) - divider ) * (-1)^i ;
				local newInit = RotatePosition(caster:GetAbsOrigin(), QAngle(0, newAngle, 0), initPos)
				local newDir = CalculateDirection(newInit, caster)
				local newBeams = beams
				Timers:CreateTimer(function()
					self:LucentBeamPosition(newInit, radius)
					newInit = newInit + newDir * radius
					newBeams = newBeams - 1
					if newBeams > 0 then
						return interval
					end
				end)
			end
		else
			Timers:CreateTimer(function()
				self:LucentBeamPosition(initPos, radius)
				initPos = initPos + direction * radius
				beams = beams - 1
				if beams > 0 then
					return interval
				end
			end)
		end
	else	
		local target = self:GetCursorTarget()
		self:LucentBeam(target)
		
		local gifts = caster:FindAbilityByName("luna_lunar_blessing_bh")
		if gifts and gifts:GetLevel() > 0 then
			local beams = gifts:GetTalentSpecialValueFor("bonus_lucent_targets")
			local searchRadius = gifts:GetTalentSpecialValueFor("bonus_beam_radius")
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), searchRadius ) ) do
				if beams > 0 and enemy ~= target then
					self:LucentBeam(enemy)
					beams = beams - 1
				else
					break
				end
			end
		end
	end
	caster:EmitSound("Hero_Luna.LucentBeam.Cast")
	ParticleManager:FireParticle("particles/units/heroes/hero_luna/luna_lucent_beam_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
end

function luna_lucent_beam_bh:LucentBeam(target, stun)
	local caster = self:GetCaster()
	local position = target:GetAbsOrigin()
	local bStun = stun
	if bStun == nil then bStun = true end
	
	local damage = TernaryOperator( self:GetTalentSpecialValueFor("night_beam_damage"), not GameRules:IsDaytime(), self:GetTalentSpecialValueFor("beam_damage") )
	self:DealDamage( caster, target, damage )
	
	if bStun then
		local sDur = self:GetTalentSpecialValueFor("stun_duration")
		self:Stun( target, sDur )
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_ABSORIGIN, target, { [1] = position, 
																														[2] = {attach = PATTACH_POINT_FOLLOW, point = "attach_hitloc"}, 
																														[5] = {attach = PATTACH_POINT_FOLLOW, point = "attach_hitloc"}, 
																														[6] = {attach = PATTACH_POINT_FOLLOW, point = "attach_hitloc"}})
	if stun then target:EmitSound("Hero_Luna.LucentBeam.Target") end
end

function luna_lucent_beam_bh:LucentBeamPosition(position, radius, stun)
	local caster = self:GetCaster()
	local bStun = stun or true
	if bStun == nil then bStun = true end
	
	local enemies = caster:FindEnemyUnitsInRadius(position, radius)
	
	local damage = TernaryOperator( self:GetTalentSpecialValueFor("night_beam_damage"), not GameRules:IsDaytime(), self:GetTalentSpecialValueFor("beam_damage") )
	local sDur = self:GetTalentSpecialValueFor("stun_duration")
	for _, enemy in ipairs( enemies ) do
		self:DealDamage( caster, enemy, damage )
		if bStun then
			self:Stun( enemy, sDur )
		end
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_luna/luna_lucent_beam_position.vpcf", PATTACH_WORLDORIGIN, nil, {  [1] = position, 
																														[2] = position, 
																														[5] = position, 
																														[6] = position})
	if stun then EmitSoundOnLocationWithCaster(position, "Hero_Luna.LucentBeam.Target", caster) end
end