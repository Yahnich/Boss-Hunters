boss33a_devitalize = class({})

function boss33a_devitalize:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local vDir = CalculateDirection(self:GetCursorPosition(), caster)
	ParticleManager:FireLinearWarningParticle(caster:GetAbsOrigin(), caster:GetAbsOrigin() + vDir * self:GetTrueCastRange() )
	return true
end

function boss33a_devitalize:OnSpellStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection(self:GetCursorPosition(), caster)
	
	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")
	local distance = self:GetTrueCastRange()
	local duration = self:GetSpecialValueFor("duration")
	
	local ProjectileThink = function(self)
		local position = self:GetPosition()
		local velocity = self:GetVelocity()
		local speed = self:GetSpeed()
		local caster = self:GetCaster()
		if velocity.z > 0 then velocity.z = 0 end
		local homeEnemies = caster:FindEnemyUnitsInRadius(position, self:GetRadius() * 5, {order = FIND_CLOSEST})
		for _, enemy in ipairs(homeEnemies) do
			velocity = velocity + CalculateDirection(enemy, position) * speed * 0.05
			if velocity:Length2D() ~= speed then velocity = velocity:Normalized() * speed end
			break
		end
		self:SetVelocity(velocity)
		self:SetPosition( position + (velocity*FrameTime()) )
	end
	if caster:GetHealthPercent() < 50 then
		ProjectileThink = function(self)
			local position = self:GetPosition()
			local velocity = self:GetVelocity()
			local caster = self:GetCaster()
			local speed = self:GetSpeed()
			if velocity.z > 0 then velocity.z = 0 end
			local homeEnemies = caster:FindEnemyUnitsInRadius(position, self:GetRadius() * 5, {order = FIND_CLOSEST})
			for _, enemy in ipairs(homeEnemies) do
				velocity = velocity + CalculateDirection(enemy, position) * speed * 0.05
				if velocity:Length2D() ~= speed then velocity = velocity:Normalized() * speed end
				break
			end
			self:SetVelocity(velocity)
			self:SetPosition( position + (velocity*FrameTime()) )
			if RollPercentage(1) then
				local newdir1 = RotateVector2D(self:GetVelocity(), ToRadians(10))
				local newdir2 = RotateVector2D(self:GetVelocity(), ToRadians(-10))
				self:SetVelocity(newdir1 * speed)
				ProjectileHandler:CreateProjectile(self.thinkBehavior, self.hitBehavior, {  FX = "particles/bosses/boss33/boss3a_devitalize.vpcf",
																					  position = self:GetPosition(),
																					  caster = self:GetCaster(),
																					  ability = self:GetAbility(),
																					  speed = speed,
																					  radius = self:GetRadius(),
																					  velocity = speed * newdir2,
																					  distance = self.distance,
																					  hitUnits = {},
																					  modDuration = self.duration,
																					  distanceTravelled = self.distanceTravelled})
			end
		end
	end
	
	
	
	
	local ProjectileHit = function(self, target, position)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not self.hitUnits[target:entindex()] then
			if target:TriggerSpellAbsorb(self) then return false end
			EmitSoundOn("Hero_ShadowDemon.ShadowPoison.Impact", caster)
			ParticleManager:FireParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_shadow_poison_release.vpcf", PATTACH_POINT_FOLLOW, target)
			target:AddNewModifier(caster, ability, "modifier_boss33a_devitalize_debuff", {duration = self.modDuration or ability:GetSpecialValueFor("duration")})
			self.hitUnits[target:entindex()] = true
		end
		return true
	end
	
	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/bosses/boss33/boss3a_devitalize.vpcf",
																		  position = caster:GetAbsOrigin(),
																		  caster = caster,
																		  ability = self,
																		  speed = speed,
																		  radius = radius,
																		  velocity = speed * direction,
																		  distance = distance,
																		  hitUnits = {},
																		  modDuration = duration})
end

modifier_boss33a_devitalize_debuff = class({})
LinkLuaModifier("modifier_boss33a_devitalize_debuff", "bosses/boss33/boss33a_devitalize.lua", 0)

function modifier_boss33a_devitalize_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_DISABLE_HEALING}
end

function modifier_boss33a_devitalize_debuff:GetDisableHealing()
	return 1
end