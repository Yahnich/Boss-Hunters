luna_eclipse_bh = class({})

function luna_eclipse_bh:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function luna_eclipse_bh:GetAOERadius()	
	return self:GetTalentSpecialValueFor("radius")
end

function luna_eclipse_bh:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_luna_eclipse_2")
end

function luna_eclipse_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_luna_eclipse_2") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function luna_eclipse_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = caster
	if caster:HasTalent("special_bonus_unique_luna_eclipse_2") then
		target = self:GetCursorTarget() or self:GetCursorPosition()
	end
	self:CreateEclipse( target )
	caster:EmitSound("Hero_Luna.Eclipse.Cast")
end

function luna_eclipse_bh:CreateEclipse( target, flMinor )
	local caster = self:GetCaster()
	
	local beams = self:GetTalentSpecialValueFor("beams")
	local maxBeams = self:GetTalentSpecialValueFor("hit_count")
	local radius = self:GetTalentSpecialValueFor("radius")
	local nightDuration = self:GetTalentSpecialValueFor("night_duration")
	if flMinor then
		beams = math.ceil( beams * flMinor )
		beams = beams - 1
		maxBeams = math.ceil( maxBeams * flMinor )
		nightDuration = nightDuration * flMinor
	end
	local duration = beams * self:GetTalentSpecialValueFor("beam_interval") + 0.1
	
	GameRules:BeginTemporaryNight( nightDuration )
	print( nightDuration )
	
	local modifierData = {duration = duration, beams = beams, maxBeams = maxBeams, radius = radius, ignoreStatusAmp = true}
	if target.GetAbsOrigin then
		target:AddNewModifier(caster, self, "modifier_luna_eclipse_bh", modifierData)
	else
		CreateModifierThinker(caster, self, "modifier_luna_eclipse_bh", modifierData, target, caster:GetTeam(), false)
	end
	caster:EmitSound("Hero_Luna.Eclipse.Cast")
end

modifier_luna_eclipse_bh = class({})
LinkLuaModifier( "modifier_luna_eclipse_bh", "heroes/hero_luna/luna_eclipse_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_luna_eclipse_bh:OnCreated(kv)
	local caster = self:GetCaster()
	self.beams = kv.beams or self:GetTalentSpecialValueFor("beams")
	self.hits = kv.hits or self:GetTalentSpecialValueFor("hit_count")
	self.interval = self:GetTalentSpecialValueFor("beam_interval")
	self.radius = kv.radius or self:GetTalentSpecialValueFor("radius")
	self.talent = caster:HasTalent("special_bonus_unique_luna_eclipse_1")
	self.hitEnemies = {}
	
	self.talent1 = caster:HasTalent("special_bonus_unique_luna_eclipse_1")
	self.talent2 = caster:HasTalent("special_bonus_unique_luna_eclipse_2")
	
	if IsServer() then
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_eclipse.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( particle, 1, Vector(self.radius, kv.duration, kv.duration) )
		self:AddEffect( particle )
		self.lucent = caster:FindAbilityByName("luna_lucent_beam_bh")
		if self.lucent then 
			self.beam_radius = self.lucent:GetTalentSpecialValueFor("beam_radius")
			if self.talent then
				self.stun_dur = self.lucent:GetTalentSpecialValueFor("stun_night")
			end
		end
		self:StartIntervalThink(self.interval)
	end
end

function modifier_luna_eclipse_bh:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local position = parent:GetAbsOrigin()
	local randomPosition = position + ActualRandomVector(self.radius)
	local beamTarget
	if self.lucent then
		local enemies = caster:FindEnemyUnitsInRadius( position, self.radius)
		for _, enemy in ipairs( enemies ) do
			self.hitEnemies[enemy:entindex()] = self.hitEnemies[enemy:entindex()] or 0
			if enemy:IsMinion() and self.talent1 then
				self.lucent:LucentBeam(enemy, caster:HasScepter() )
				if not caster:HasScepter() then enemy:EmitSound("Hero_Luna.Eclipse.Target") end
			elseif not beamTarget and self.hitEnemies[enemy:entindex()] < self.hits then
				beamTarget = enemy
			end
		end
		if beamTarget then
			self.lucent:LucentBeam( beamTarget, caster:HasScepter() )
			if not caster:HasScepter() then beamTarget:EmitSound("Hero_Luna.Eclipse.Target") end
			self.hitEnemies[beamTarget:entindex()] = self.hitEnemies[beamTarget:entindex()] + 1
		else
			self.lucent:LucentBeam( randomPosition, caster:HasScepter() )
			if not caster:HasScepter() then EmitSoundOnLocationWithCaster( randomPosition, "Hero_Luna.Eclipse.NoTarget", caster ) end
		end
	end
	
	return false
end


function modifier_luna_eclipse_bh:IsAura()
	return self.talent2
end

function modifier_luna_eclipse_bh:GetModifierAura()
	return "modifier_luna_eclipse_bh_talent"
end

function modifier_luna_eclipse_bh:GetAuraRadius()
	return self.radius
end

function modifier_luna_eclipse_bh:GetAuraDuration()
	return 0.5
end

function modifier_luna_eclipse_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_luna_eclipse_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_luna_eclipse_bh:GetAuraEntityReject( entity )    
	if self:GetCaster():IsSameTeam( entity ) then
		return true
	end
end



function modifier_luna_eclipse_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_luna_eclipse_bh:IsPurgable()
	return false
end

modifier_luna_eclipse_bh_talent = class({})
LinkLuaModifier( "modifier_luna_eclipse_bh_talent", "heroes/hero_luna/luna_eclipse_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_luna_eclipse_bh_talent:OnCreated()
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_luna_eclipse_2", "slow")
end

function modifier_luna_eclipse_bh_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_luna_eclipse_bh_talent:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_luna_eclipse_bh_talent:GetEffectName()
	return "particles/units/heroes/hero_luna/luna_eclipse_slow.vpcf"
end