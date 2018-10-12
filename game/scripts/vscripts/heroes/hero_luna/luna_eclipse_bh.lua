luna_eclipse_bh = class({})

function luna_eclipse_bh:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function luna_eclipse_bh:GetAOERadius()	
	return self:GetTalentSpecialValueFor("radius")
end

function luna_eclipse_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_luna_eclipse_2") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function luna_eclipse_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("duration_tooltip") + 0.1
	if self:GetCaster():HasTalent("special_bonus_unique_luna_eclipse_2") then
		if self:GetCursorTarget() then
			self:GetCursorTarget():AddNewModifier(caster, self, "modifier_luna_eclipse_bh", {duration = duration})
		else
			CreateModifierThinker(caster, self, "modifier_luna_eclipse_bh", {Duration = duration}, self:GetCursorPosition(), caster:GetTeam(), false)
		end
	else
		caster:AddNewModifier(caster, self, "modifier_luna_eclipse_bh", {duration = duration})
	end
	caster:EmitSound("Hero_Luna.Eclipse.Cast")
end

modifier_luna_eclipse_bh = class({})
LinkLuaModifier( "modifier_luna_eclipse_bh", "heroes/hero_luna/luna_eclipse_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_luna_eclipse_bh:OnCreated()
	local caster = self:GetCaster()
	self.beams = TernaryOperator( self:GetTalentSpecialValueFor("beams_scepter"), caster:HasScepter(), self:GetTalentSpecialValueFor("beams") )
	self.interval = TernaryOperator( self:GetTalentSpecialValueFor("beam_interval_scepter"), caster:HasScepter(), self:GetTalentSpecialValueFor("beam_interval") )
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.hits = TernaryOperator( self:GetTalentSpecialValueFor("hit_count_scepter"), caster:HasScepter(), self:GetTalentSpecialValueFor("hit_count") )
	self.talent = caster:HasTalent("special_bonus_unique_luna_eclipse_1")
	self.hitEnemies = {}
	
	if IsServer() then
		ParticleManager:FireParticle("particles/units/heroes/hero_luna/luna_eclipse.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), {[1] = Vector(self.radius, 12, 12)} )
		self.lucent = caster:FindAbilityByName("luna_lucent_beam_bh")
		self.nightsilver = caster:FindAbilityByName("luna_nightsilver_resolve")
		GameRules:BeginTemporaryNight( self:GetRemainingTime() ) 
		self:StartIntervalThink(self.interval)
	end
end

function modifier_luna_eclipse_bh:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local position = parent:GetAbsOrigin()
	local randomPosition = position + ActualRandomVector(self.radius)
	if self.lucent then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, self.radius) ) do
			self.hitEnemies[enemy:entindex()] = self.hitEnemies[enemy:entindex()] or 0
			if self.hitEnemies[enemy:entindex()] < self.hits then
				self.lucent:LucentBeam(enemy, self.talent)
				if self.talent and self.nightsilver then
					enemy:AddNewModifier( caster, self.nightsilver, "modifier_luna_nightsilver_resolve_weaken", {duration = self.nightsilver:GetSpecialValueFor("weaken_duration")})
				end
				enemy:EmitSound("Hero_Luna.Eclipse.Target")
				self.hitEnemies[enemy:entindex()] = self.hitEnemies[enemy:entindex()] + 1
				return true
			end
		end
		self.lucent:LucentBeamPosition( randomPosition, 0, self.talent )
	end
	EmitSoundOnLocationWithCaster( randomPosition, "Hero_Luna.Eclipse.NoTarget", caster )
	return false
end

function modifier_luna_eclipse_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end