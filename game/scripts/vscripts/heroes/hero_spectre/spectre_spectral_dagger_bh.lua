spectre_spectral_dagger_bh = class({})

function spectre_spectral_dagger_bh:GetIntrinsicModifierName()
	if self:GetCaster():HasTalent("special_bonus_unique_spectre_spectral_dagger_1") then
		return "modifier_spectre_spectral_dagger_bh_path"
	end
end

function spectre_spectral_dagger_bh:OnTalentLearned(talent)
	if talent == "special_bonus_unique_spectre_spectral_dagger_1" then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_spectre_spectral_dagger_bh_path", {} )
	end
end

function spectre_spectral_dagger_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local position = self:GetCursorPosition()
	
	local direction = CalculateDirection( target or position, caster )
	local damage = self:GetTalentSpecialValueFor("damage")
	local radius = self:GetTalentSpecialValueFor("dagger_radius")
	local speed = self:GetTalentSpecialValueFor("speed")
	local distance = self:GetTalentSpecialValueFor("distance")
	
	local ProjectileHit = function(self, target, position)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.hitUnits = self.hitUnits or {}
		if not self.hitUnits[target:entindex()] then
			self.hitUnits[target:entindex()] = true
			if target:TriggerSpellAbsorb(self) then return false end
			EmitSoundOn("Hero_Spectre.DaggerImpact", target)
			ability:DealDamage( caster, target, self.damage )
			if target == self.target then
				target:AddNewModifier(caster, ability, "modifier_spectre_spectral_dagger_bh_path", {duration = self.modDur})
			end
		end
		return true
	end
	
	local ProjectileThink = function(self)
		local caster = self:GetCaster()
		local position = self:GetPosition()
		local velocity = self:GetVelocity()
		if self.target then
			velocity = CalculateDirection( target, position ) * self:GetSpeed()
		end
		if velocity.z > 0 then velocity.z = 0 end
		self:SetPosition( position + (velocity*FrameTime()) )
		CreateModifierThinker(caster, self:GetAbility(), "modifier_spectre_spectral_dagger_bh_thinker", {duration = self.modDur}, position, caster:GetTeamNumber(), false)
	end
	caster:EmitSound("Hero_Spectre.DaggerCast")
	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/units/heroes/hero_spectre/spectre_spectral_dagger_tracking.vpcf",
																			position = caster:GetAbsOrigin(),
																			caster = caster,
																			ability = self,
																			speed = speed,
																			radius = radius,
																			velocity = speed * direction,
																			distance = distance,
																			target = target,
																			damage = damage,
																			modDur = self:GetTalentSpecialValueFor("dagger_path_duration")})
end

modifier_spectre_spectral_dagger_bh_path = class({})
LinkLuaModifier("modifier_spectre_spectral_dagger_bh_path", "heroes/hero_spectre/spectre_spectral_dagger_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_spectral_dagger_bh_path:OnCreated()
	self.pathDuration = self:GetTalentSpecialValueFor("dagger_path_duration")
	if IsServer() then
		self:StartIntervalThink(0.15)
		local pathFX = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_shadow_path.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(pathFX, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl( pathFX, 5, Vector(self.pathDuration, 0, 0) )
		self:AddEffect(pathFX)
	end
end


function modifier_spectre_spectral_dagger_bh_path:OnIntervalThink()
	local caster = self:GetCaster()
	CreateModifierThinker(caster, self:GetAbility(), "modifier_spectre_spectral_dagger_bh_thinker", {duration = self.pathDuration}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
end

function modifier_spectre_spectral_dagger_bh_path:IsHidden()    
	return true
end

modifier_spectre_spectral_dagger_bh_thinker = class({})
LinkLuaModifier("modifier_spectre_spectral_dagger_bh_thinker", "heroes/hero_spectre/spectre_spectral_dagger_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_spectral_dagger_bh_thinker:OnCreated()
	self.stick = self:GetTalentSpecialValueFor("dagger_grace_period")
	self.radius = self:GetTalentSpecialValueFor("path_radius")
	if IsServer() then
		AddFOWViewer( self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("vision_radius"), self:GetRemainingTime(), true )
	end
end

function modifier_spectre_spectral_dagger_bh_thinker:IsAura()
	return true
end

function modifier_spectre_spectral_dagger_bh_thinker:GetModifierAura()
	return "modifier_spectre_spectral_dagger_bh"
end

function modifier_spectre_spectral_dagger_bh_thinker:GetAuraRadius()
	return self.radius
end

function modifier_spectre_spectral_dagger_bh_thinker:GetAuraDuration()
	return self.stick
end

function modifier_spectre_spectral_dagger_bh_thinker:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_spectre_spectral_dagger_bh_thinker:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_spectre_spectral_dagger_bh_thinker:IsHidden()    
	return true
end

modifier_spectre_spectral_dagger_bh = class({})
LinkLuaModifier("modifier_spectre_spectral_dagger_bh", "heroes/hero_spectre/spectre_spectral_dagger_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_spectral_dagger_bh:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("bonus_movespeed")
	if not self:GetParent():IsSameTeam( self:GetCaster() ) then
		self.slow = self.slow * (-1)
	end
end

function modifier_spectre_spectral_dagger_bh:CheckState()
	return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = (self:GetParent() == self:GetCaster()) }
end

function modifier_spectre_spectral_dagger_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_spectre_spectral_dagger_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end