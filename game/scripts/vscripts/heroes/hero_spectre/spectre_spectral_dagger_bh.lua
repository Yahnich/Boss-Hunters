spectre_spectral_dagger_bh = class({})

function spectre_spectral_dagger_bh:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_spectre_spectral_dagger_2", "cd")
end

function spectre_spectral_dagger_bh:OnSpellStart()
	local target = self:GetCursorTarget()
	local position = self:GetCursorPosition()
	
	self:LaunchSpectralDagger( target or position )
end

function spectre_spectral_dagger_bh:LaunchSpectralDagger( target, origin )
	local caster = self:GetCaster()

	
	local direction = CalculateDirection( target , origin or caster )
	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("dagger_radius")
	local vision = self:GetSpecialValueFor("vision_radius")
	local speed = self:GetSpecialValueFor("speed")
	local distance = self:GetSpecialValueFor("distance")
	local duration = self:GetSpecialValueFor("dagger_path_duration")
	
	
	self.projectiles = self.projectiles or {}
	local pID
	if not target.GetAbsOrigin then
		pID = self:FireLinearProjectile("particles/units/heroes/hero_spectre/spectre_spectral_dagger.vpcf", direction * speed, distance, radius*2, {source = origin}, false, true, vision)
	else -- unit targeted
		pID = self:FireTrackingProjectile("particles/units/heroes/hero_spectre/spectre_spectral_dagger_tracking.vpcf", target, speed, {source = origin}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, vision)
	end
	self.projectiles[pID] = {duration = duration, damage = damage, tracking = target.GetAbsOrigin ~= nil, thinkTime = 1 / ( speed/(radius*2) ), currentThink = 0, units = {}, radius = radius }
end

function spectre_spectral_dagger_bh:OnProjectileHitHandle( target, position, projectile, bNotFinal )
	local caster = self:GetCaster()
	local projectileData = self.projectiles[projectile]
	if target then
		projectileData.units[target] = true
		if target:TriggerSpellAbsorb(self) then return false end
		EmitSoundOn("Hero_Spectre.DaggerImpact", target)
		self:DealDamage( caster, target, projectileData.damage )
		if projectileData.tracking and not bNotFinal then
			target:AddNewModifier(caster, self, "modifier_spectre_spectral_dagger_bh_path", {duration = projectileData.duration})
			table.remove( self.projectiles, projectile )
		end
	else
		table.remove( self.projectiles, projectile )
	end
end



function spectre_spectral_dagger_bh:OnProjectileThinkHandle( projectile )
	local caster = self:GetCaster()
	local projectileData = self.projectiles[projectile]
	if projectileData then
		if projectileData.currentThink <= 0 then
			local position = ProjectileManager:GetProjectileLocation( projectile )
			CreateModifierThinker(caster, self, "modifier_spectre_spectral_dagger_bh_thinker", {duration = self.projectiles[projectile].duration}, position, caster:GetTeamNumber(), false)
			projectileData.currentThink = projectileData.thinkTime
			if projectileData.tracking then
				for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, projectileData.radius ) ) do
					if not projectileData.units[enemy] then
						self:OnProjectileHitHandle( enemy, position, projectile, true )
					end
				end
			end
		else
			projectileData.currentThink = projectileData.currentThink - FrameTime()
		end
	end
end

modifier_spectre_spectral_dagger_bh_path = class({})
LinkLuaModifier("modifier_spectre_spectral_dagger_bh_path", "heroes/hero_spectre/spectre_spectral_dagger_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_spectral_dagger_bh_path:OnCreated()
	self.pathDuration = self:GetSpecialValueFor("dagger_path_duration")
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
	return false
end

modifier_spectre_spectral_dagger_bh_thinker = class({})
LinkLuaModifier("modifier_spectre_spectral_dagger_bh_thinker", "heroes/hero_spectre/spectre_spectral_dagger_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_spectral_dagger_bh_thinker:OnCreated()
	self.stick = self:GetSpecialValueFor("dagger_grace_period")
	self.radius = self:GetSpecialValueFor("path_radius")
	if IsServer() then
		AddFOWViewer( self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("vision_radius"), self:GetRemainingTime(), true )
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
	self.slow = self:GetSpecialValueFor("bonus_movespeed")
	if not self:GetParent():IsSameTeam( self:GetCaster() ) then
		self.slow = self.slow * (-1)
	end
	if self:GetParent() == self:GetCaster() then
		self.talent1Mr = self:GetCaster():FindTalentValue("special_bonus_unique_spectre_spectral_dagger_1", "magic_resist")
		self.talent1Ev = self:GetCaster():FindTalentValue("special_bonus_unique_spectre_spectral_dagger_1", "evasion")
	end
end

function modifier_spectre_spectral_dagger_bh:CheckState()
	return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = (self:GetParent() == self:GetCaster()) }
end

function modifier_spectre_spectral_dagger_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function modifier_spectre_spectral_dagger_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_spectre_spectral_dagger_bh:GetModifierMagicalResistanceBonus()
	return self.talent1Mr
end

function modifier_spectre_spectral_dagger_bh:GetModifierEvasion_Constant()
	return self.talent1Ev
end

function modifier_spectre_spectral_dagger_bh:GetEffectName()
	if self:GetParent() == self:GetCaster() then return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf" end
end