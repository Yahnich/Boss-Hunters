snapfire_firesnap_cookie_lua = class({})
LinkLuaModifier("modifier_snapfire_firesnap_cookie_lua_movement", "heroes/hero_snapfire/snapfire_firesnap_cookie_lua", LUA_MODIFIER_MOTION_NONE)

function snapfire_firesnap_cookie_lua:IsStealable()
	return true
end

function snapfire_firesnap_cookie_lua:IsHiddenWhenStolen()
	return false
end

function snapfire_firesnap_cookie_lua:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("jump_horizontal_distance")
end

function snapfire_firesnap_cookie_lua:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Snapfire.FeedCookie.Cast", caster)

	if target == caster then
		EmitSoundOn("Hero_Snapfire.FeedCookie.Consume", caster)
		ParticleManager:FireParticle("particles/units/heroes/hero_snapfire/hero_snapfire_cookie_selfcast.vpcf", PATTACH_POINT, caster, {})
		
		if caster:HasTalent("special_bonus_unique_snapfire_firesnap_cookie_lua_2") then
			local ability = caster:FindAbilityByName("snapfire_mortimer_kisses_lua")
			ability:CreateFirePit(caster:GetAbsOrigin())
		end

		caster:AddNewModifier(caster, self, "modifier_snapfire_firesnap_cookie_lua_movement", {})
	else
		EmitSoundOn("Hero_Snapfire.FeedCookie.Projectile", caster)
		local speed = self:GetTalentSpecialValueFor("projectile_speed")
		self:FireTrackingProjectile("particles/units/heroes/hero_snapfire/hero_snapfire_cookie_projectile.vpcf", target, speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, false, 0)
	end
end

function snapfire_firesnap_cookie_lua:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		EmitSoundOn("Hero_Snapfire.FeedCookie.Consume", hTarget)

		if caster:HasTalent("special_bonus_unique_snapfire_firesnap_cookie_lua_1") then
			local heal = caster:FindTalentValue("special_bonus_unique_snapfire_firesnap_cookie_lua_1")/100 * hTarget:GetHealthDeficit()
			hTarget:HealEvent(heal, self, caster, false)
		end

		if hTarget:IsHero() then
			if hTarget:HasAnyAvailableInventorySpace() then
				local item = hTarget:AddItemByName("item_snapfire_cookie")
				item:SetLevel(self:GetLevel())
				item.itemGranter = caster
			else
				local item = CreateItem("item_snapfire_cookie", hTarget, hTarget)
				local randoPoint = GetGroundPosition(vLocation, hTarget) + ActualRandomVector(150, 50)
				item:SetLevel(self:GetLevel())
				CreateItemOnPositionSync(randoPoint, item)
				item.itemGranter = caster
			end
		else
			hTarget:AddNewModifier(caster, self, "modifier_snapfire_firesnap_cookie_lua_movement", {})
		end
	end
end

modifier_snapfire_firesnap_cookie_lua_movement = class({})
if IsServer() then
	function modifier_snapfire_firesnap_cookie_lua_movement:OnCreated()
		local parent = self:GetParent()
		self.distance = self:GetTalentSpecialValueFor("jump_horizontal_distance")
		self.direction = parent:GetForwardVector()
		self.speed = self.distance / self:GetTalentSpecialValueFor("jump_duration") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = self:GetTalentSpecialValueFor("jump_height")

		self.impact_damage = self:GetTalentSpecialValueFor("impact_damage")
		self.impact_stun_duration = self:GetTalentSpecialValueFor("impact_stun_duration")

		self:StartMotionController()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_snapfire/hero_snapfire_cookie_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
					ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx)
	end
	
	function modifier_snapfire_firesnap_cookie_lua_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		FindClearSpaceForUnit(parent, parentPos, true)
		local ability = self:GetAbility()
		local radius = self:GetTalentSpecialValueFor("impact_radius")
		self:StopMotionController()

		EmitSoundOn("Hero_Snapfire.FeedCookie.Impact", parent)
		CutTreesInRadius(parentPos, radius)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_snapfire/hero_snapfire_cookie_landing.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, parentPos)
					ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
					ParticleManager:ReleaseParticleIndex(nfx)

		local enemies = parent:FindEnemyUnitsInRadius(parentPos, radius)
		for _,enemy in pairs(enemies) do
			ability:Stun(enemy, self.impact_stun_duration, false)
			ability:DealDamage(parent, enemy, self.impact_damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end

		parent:StartGesture(ACT_DOTA_CAST_ABILITY_2_END)
	end
	
	function modifier_snapfire_firesnap_cookie_lua_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled = self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			newPos.z = self.height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
			self:Destroy()
			return nil
		end       
	end
end

function modifier_snapfire_firesnap_cookie_lua_movement:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_snapfire_firesnap_cookie_lua_movement:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_snapfire_firesnap_cookie_lua_movement:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_snapfire_firesnap_cookie_lua_movement:GetEffectName()
	return "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_receive.vpcf"
end

function modifier_snapfire_firesnap_cookie_lua_movement:IsPurgable()
	return false
end

function modifier_snapfire_firesnap_cookie_lua_movement:IsHidden()
	return true
end