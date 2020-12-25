luna_lucent_beam_bh = class({})

function luna_lucent_beam_bh:GetCooldown(iLvl)
	local cd = self.BaseClass.GetCooldown(self, iLvl)
	cd = cd + self:GetCaster():FindTalentValue("special_bonus_unique_luna_lucent_beam_2", "cd")
	cd = cd + self:GetCaster():FindTalentValue("special_bonus_unique_luna_lucent_beam_1", "cd")
	return cd
end

function luna_lucent_beam_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("beam_radius")
end

function luna_lucent_beam_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_luna_lucent_beam_1") then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	else	
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
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
	
	
	local radius = self:GetTalentSpecialValueFor("beam_radius")
	local stun = TernaryOperator( self:GetTalentSpecialValueFor("stun_duration"), GameRules:IsDaytime(), self:GetTalentSpecialValueFor("stun_night") )
	if caster:HasTalent("special_bonus_unique_luna_lucent_beam_1") then
		local target = self:GetCursorPosition()
		
		local interval = caster:FindTalentValue("special_bonus_unique_luna_lucent_beam_1")
		
		local beams = math.ceil( (self:GetTrueCastRange() - 150) / radius )
		local direction = CalculateDirection(target, caster)
		local initPos = caster:GetAbsOrigin() + direction * 150
		
		Timers:CreateTimer(function()
			self:LucentBeamPosition(initPos, radius, stun)
			initPos = initPos + direction * radius * 1.25
			beams = beams - 1
			if beams > 0 then
				return interval
			end
		end)
	else	
		local target = self:GetCursorTarget()
		self:LucentBeam(target, radius, stun)
	end
	caster:EmitSound("Hero_Luna.LucentBeam.Cast")
	ParticleManager:FireParticle("particles/units/heroes/hero_luna/luna_lucent_beam_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
end

function luna_lucent_beam_bh:LucentBeam(target, radius, stun, talent)
	local caster = self:GetCaster()
	local position = target:GetAbsOrigin()
	local sDur = stun or 0
	local damage = TernaryOperator( self:GetTalentSpecialValueFor("night_beam_damage"), not GameRules:IsDaytime(), self:GetTalentSpecialValueFor("beam_damage") )
	local enemies = caster:FindEnemyUnitsInRadius(position, radius)
	for _, enemy in ipairs( enemies ) do
		if not enemy:TriggerSpellAbsorb( self ) then
			self:DealDamage( caster, enemy, damage )
			if sDur > 0 then
				self:Stun( enemy, sDur )
			end
		end
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_ABSORIGIN, target, { [1] = position, 
																														[2] = {attach = PATTACH_POINT_FOLLOW, point = "attach_hitloc"}, 
																														[5] = {attach = PATTACH_POINT_FOLLOW, point = "attach_hitloc"}, 
																														[6] = {attach = PATTACH_POINT_FOLLOW, point = "attach_hitloc"}})
	if stun then target:EmitSound("Hero_Luna.LucentBeam.Target") end
end

function luna_lucent_beam_bh:LucentBeamPosition(position, radius, stun)
	local caster = self:GetCaster()
	
	local enemies = caster:FindEnemyUnitsInRadius(position, radius)
	
	local damage = TernaryOperator( self:GetTalentSpecialValueFor("night_beam_damage"), not GameRules:IsDaytime(), self:GetTalentSpecialValueFor("beam_damage") )
	local sDur = stun or 0
	for _, enemy in ipairs( enemies ) do
		if not enemy:TriggerSpellAbsorb( self ) then
			self:DealDamage( caster, enemy, damage )
			if sDur > 0 then
				self:Stun( enemy, sDur )
			end
		end
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_luna/luna_lucent_beam_position.vpcf", PATTACH_WORLDORIGIN, nil, {  [1] = position, 
																														[2] = position, 
																														[5] = position, 
																														[6] = position})
	if stun then EmitSoundOnLocationWithCaster(position, "Hero_Luna.LucentBeam.Target", caster) end
end