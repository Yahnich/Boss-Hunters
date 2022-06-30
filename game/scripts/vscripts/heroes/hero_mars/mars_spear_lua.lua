mars_spear_lua = class({})

function mars_spear_lua:IsStealable()
	return true
end

function mars_spear_lua:IsHiddenWhenStolen()
	return false
end

function mars_spear_lua:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("spear_range")
end

function mars_spear_lua:OnSpellStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection( self:GetCursorPosition(), caster )
	self:LaunchSpear( caster, direction )
	if caster:HasTalent("special_bonus_unique_mars_spear_lua_1") then
		local rebuke = caster:FindAbilityByName("mars_gods_rebuke_lua")
		if rebuke then
			rebuke:EndCooldown()
			caster:AddNewModifier( caster, self, "modifier_mars_spear_rebuke_mana", {} )
		end
	end
	self.hitUnits = {}
	if caster:HasTalent("special_bonus_unique_mars_phalanx_1") then
		for _, warrior in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE } ) ) do
			if warrior:HasModifier("modifier_mars_phalanx_warrior") then
				warrior:StartGesture( ACT_DOTA_ATTACK )
				self:LaunchSpear( warrior, warrior:GetForwardVector(), true )
			end
		end
	end
end

--[[function mars_spear_lua:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	local damage = self:GetSpecialValueFor("damage")
	local knockback_duration = self:GetSpecialValueFor("knockback_duration")
	local knockback_distance = self:GetSpecialValueFor("knockback_distance")

	if hTarget then
		self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		if self.target == nil and hTarget:IsBoss() or hTarget:IsAncient() then
			self.target = hTarget
			self.target:AddNewModifier(caster, self, "modifier_mars_spear_lua_spear", {Duration = 3})
		else
			hTarget:ApplyKnockBack(vLocation, knockback_duration, knockback_duration, knockback_distance, 0, caster, self, true)
			
			if caster:HasTalent("special_bonus_unique_mars_spear_lua_2") and not hTarget:IsBoss() then
				Timers:CreateTimer(knockback_duration, function()
					self:Stun(hTarget, caster:FindTalentValue("special_bonus_unique_mars_spear_lua_2"), false)
				end)
			end
		end
	else
		if self.target ~= nil then
			FindClearSpaceForUnit(self.target, vLocation, true)
			self.target:RemoveModifierByName("modifier_mars_spear_lua_spear")
			self.target = nil
		end
	end
end]]

--[[function mars_spear_lua:OnProjectileThinkHandle(iProjectileHandle)
	local caster = self:GetCaster()

	if self.target and not self.target:IsNull() and self.target ~= nil then
		if self.target:IsAlive() then
			local vLocation = ProjectileManager:GetLinearProjectileLocation(iProjectileHandle)
			local projVel = ProjectileManager:GetLinearProjectileVelocity(iProjectileHandle)
			local projRadius = ProjectileManager:GetLinearProjectileRadius(iProjectileHandle)
			local targetHeight = GetGroundHeight(self.target:GetAbsOrigin(), self.target)
			local expected_location = vLocation + projVel / projRadius
			local expected_height = GetGroundHeight(expected_location, self.target)
			local heightDiff = targetHeight - expected_height
			--if GridNav:IsTraversable(expected_location) 
			if not GridNav:IsNearbyTree(expected_location, projRadius, false) 
				and not GridNav:IsBlocked(expected_location) and heightDiff >= 0 
				and not self.target:HasModifier("modifier_mars_innate_check") then
				
				self.target:SetForwardVector(-projVel)
				self.target:SetAbsOrigin(vLocation)
			else
				self.target:RemoveModifierByName("modifier_mars_spear_lua_spear")
				self.target:AddNewModifier(caster, self, "modifier_mars_spear_lua_debuff", {Duration = self:GetSpecialValueFor("stun_duration")})
				self.target = nil
				ProjectileManager:DestroyLinearProjectile(iProjectileHandle)
			end
		else
			self.target = nil
		end
	end
end]]

function mars_spear_lua:LaunchSpear( origin, direction, secondary )
	local caster = self:GetCaster()
	local source = origin or caster
	local startPos = source:GetAbsOrigin()

	local distance = self:GetTrueCastRange()
	local direction = direction or CalculateDirection(self:GetCursorPosition(), startPos)

	local speed = self:GetSpecialValueFor("spear_speed")

	local velocity = direction * speed

	local startWidth = self:GetSpecialValueFor("spear_width")

	local spear_vision = self:GetSpecialValueFor("spear_vision")

	local damage = self:GetSpecialValueFor("damage")
	local knockback_duration = self:GetSpecialValueFor("knockback_duration")
	local knockback_distance = self:GetSpecialValueFor("knockback_distance")

	local duration = distance/speed

	--Purely cosmetic only-------
	if caster == self:GetCaster() then
		EmitSoundOn("Hero_Mars.Spear.Cast", caster)
		EmitSoundOn("Hero_Mars.Spear", caster)
	end
	local projectile = self:FireLinearProjectile("particles/units/heroes/hero_mars/mars_spear.vpcf", velocity, distance, startWidth, {source = source}, false, true, spear_vision)
	-----------------------------

	--Projectile Data------------
	--OnHit data-----------------
	local ProjectileHit = function(self, target, position)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.hitUnits = self.hitUnits or {}
		self.target = self.target or nil
		if not self.hitUnits[target:entindex()] then
			if self.secondary and ability.hitUnits[target:entindex()] then return false end
			if target:TriggerSpellAbsorb(self) then return false end

			EmitSoundOn("Hero_Mars.Spear.Target", target)

			ability:DealDamage(caster, target, self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			if self.target == nil and (not self.secondary or not target:HasModifier("modifier_mars_spear_lua_spear") ) and not target:IsMinion() then
				self.target = target
				target:RemoveModifierByName("modifier_mars_spear_lua_spear")
				self.internalModifier = target:AddNewModifier(caster, self, "modifier_mars_spear_lua_spear", {Duration = self.duration})
			else
				EmitSoundOn("Hero_Mars.Spear.Knockback", target)
				if not target:HasModifier("modifier_mars_spear_lua_spear") then
					target:ApplyKnockBack(position, self.knockback_duration, self.knockback_duration, self.knockback_distance, 0, caster, ability, false)
				end
				if caster:HasTalent("special_bonus_unique_mars_spear_lua_2") then
					local stunDuration = TernaryOperator( caster:FindTalentValue("special_bonus_unique_mars_spear_lua_2"), target:IsMinion(), caster:FindTalentValue("special_bonus_unique_mars_spear_lua_2", "value2") )
					Timers:CreateTimer(self.knockback_duration, function()
						self:Stun(target, stunDuration, false)
					end)
				end
			end
			self.hitUnits[target:entindex()] = target
			if self.secondary then ability.hitUnits[target:entindex()] = target end
		end

		return true
	end
	
	--OnThink data--------------
	local ProjectileThink = function(self)
		local caster = self:GetCaster()
		local position = self:GetPosition()
		local velocity = self:GetVelocity()
		if velocity.z > 0 then velocity.z = 0 end

		self:SetPosition( position + (velocity*FrameTime()) )

		if self.target and not self.target:IsNull() and self.target ~= nil then
			if self.target:IsAlive() then
				local vLocation = position
				local projVel = velocity
				local projRadius = self.radius
				local targetHeight = GetGroundHeight(self.target:GetAbsOrigin(), self.target)
				local expected_location = vLocation + projVel / projRadius
				local expected_height = GetGroundHeight(expected_location, self.target)
				local heightDiff = targetHeight - expected_height
				--if GridNav:IsTraversable(expected_location) 
				if not GridNav:IsNearbyTree(expected_location, projRadius, false) 
					and not GridNav:IsBlocked(expected_location) and heightDiff >= 0 
					and not self.target:HasModifier("modifier_mars_innate_check") 
					and not self.internalModifier:IsNull() then
					
					self.target:SetForwardVector(-projVel)
					self.target:SetAbsOrigin(vLocation)
				else
					EmitSoundOn("Hero_Mars.Spear.Root", self.target)
					self.target:RemoveModifierByName("modifier_mars_spear_lua_spear")
					self.target:AddNewModifier(caster, self, "modifier_mars_spear_lua_debuff", {Duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
					self.target = nil
					ProjectileManager:DestroyLinearProjectile(projectile)
					return false
				end
			else
				self.target = nil
			end
		end
	end

	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  	
		FX = "",
		position = startPos,
		caster = caster,
		ability = self,
		speed = speed,
		secondary = secondary,
		radius = startWidth,
		velocity = velocity,
		distance = distance,
		damage = damage,
		duration = duration,
		knockback_duration = knockback_duration,
		knockback_distance = knockback_distance
	})
end

modifier_mars_spear_rebuke_mana = class({})
LinkLuaModifier( "modifier_mars_spear_rebuke_mana", "heroes/hero_mars/mars_spear_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_mars_spear_rebuke_mana:IsHidden()
	return true
end

modifier_mars_spear_lua_spear = class({})
LinkLuaModifier( "modifier_mars_spear_lua_spear", "heroes/hero_mars/mars_spear_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_mars_spear_lua_spear:OnRemoved()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

function modifier_mars_spear_lua_spear:CheckState()
	return { [MODIFIER_STATE_STUNNED] = true }
end

function modifier_mars_spear_lua_spear:IsPurgable()
	return true
end

function modifier_mars_spear_lua_spear:IsStunDebuff()
	return true
end

function modifier_mars_spear_lua_spear:IsPurgeException()
	return true
end

function modifier_mars_spear_lua_spear:IsDebuff()
	return true
end

function modifier_mars_spear_lua_spear:IsHidden()
	return true
end

function modifier_mars_spear_lua_spear:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_mars_spear_lua_spear:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

modifier_mars_spear_lua_debuff = class({})
LinkLuaModifier( "modifier_mars_spear_lua_debuff", "heroes/hero_mars/mars_spear_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_mars_spear_lua_debuff:OnCreated()
	if IsServer() then
		self.spear = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/mars/mars_spear.vmdl"})
		--self.spear:FollowEntity(self:GetParent(), false)
		local attachName = self:GetParent():ScriptLookupAttachment("attach_hitloc")
		self.spear:SetAbsOrigin(self:GetParent():GetAttachmentOrigin(attachName))
		self.spear:SetSequence("spear_impact")
		self.spear:SetForwardVector(-self:GetParent():GetForwardVector())

		self.secondsTime = 0

		self:StartIntervalThink(0.04)
	end
end

function modifier_mars_spear_lua_debuff:OnRefresh(table)
	if IsServer() and self.spear then
		UTIL_Remove(self.spear)
		self.spear = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/mars/mars_spear.vmdl"})
		local attachName = self:GetParent():ScriptLookupAttachment("attach_hitloc")
		self.spear:SetAbsOrigin(self:GetParent():GetAttachmentOrigin(attachName))
		self.spear:SetSequence("spear_impact")
		self.spear:SetForwardVector(-self:GetParent():GetForwardVector())

		self.secondsTime = 0

		self:StartIntervalThink(0.04)
	end
end

function modifier_mars_spear_lua_debuff:OnIntervalThink()
	local attachName = self:GetParent():ScriptLookupAttachment("attach_hitloc")
	self.spear:SetAbsOrigin(self:GetParent():GetAttachmentOrigin(attachName))
	self.spear:SetSequence("spear_impact")
	self.spear:SetForwardVector(-self:GetParent():GetForwardVector())

	if self.secondsTime >= 1.04 then
		self.secondsTime = 0
	else
		self.secondsTime = self.secondsTime + 0.04
	end
end

function modifier_mars_spear_lua_debuff:OnRemoved()
	if IsServer() then
		UTIL_Remove(self.spear)
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

function modifier_mars_spear_lua_debuff:CheckState()
	return { [MODIFIER_STATE_STUNNED] = true }
end

function modifier_mars_spear_lua_debuff:IsPurgable()
	return true
end

function modifier_mars_spear_lua_debuff:IsStunDebuff()
	return true
end

function modifier_mars_spear_lua_debuff:IsPurgeException()
	return true
end

function modifier_mars_spear_lua_spear:IsDebuff()
	return true
end

function modifier_mars_spear_lua_debuff:GetEffectName()
	return "particles/units/heroes/hero_mars/mars_spear_impact_debuff.vpcf"
end

function modifier_mars_spear_lua_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_mars_spear_lua_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_mars_spear.vpcf"
end

function modifier_mars_spear_lua_debuff:StatusEffectPriority()
	return 10
end

function modifier_mars_spear_lua_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_mars_spear_lua_debuff:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end