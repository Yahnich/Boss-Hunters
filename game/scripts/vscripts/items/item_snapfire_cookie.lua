item_snapfire_cookie = class({})
LinkLuaModifier( "modifier_item_snapfire_cookie_buff", "items/item_snapfire_cookie.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_snapfire_cookie:OnSpellStart()
	local caster = self:GetCaster()

	if caster:IsAlive() then
		EmitSoundOn("Rune.Arcane", caster)
		
		local duration = self:GetSpecialValueFor("jump_duration")

		caster:AddNewModifier(caster, self, "modifier_item_snapfire_cookie_buff", {Duration = duration})
		--self:Destroy()
	end
end

modifier_item_snapfire_cookie_buff = class({})
if IsServer() then
	function modifier_item_snapfire_cookie_buff:OnCreated()
		local parent = self:GetParent()
		self.distance = self:GetSpecialValueFor("jump_horizontal_distance")
		self.direction = parent:GetForwardVector()
		self.speed = self.distance / self:GetSpecialValueFor("jump_duration") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = self:GetSpecialValueFor("jump_height")
		
		self.impact_damage = self:GetSpecialValueFor("impact_damage")
		self.impact_stun_duration = self:GetSpecialValueFor("impact_stun_duration")
		self.radius = self:GetSpecialValueFor("impact_radius")

		self:StartMotionController()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_snapfire/hero_snapfire_cookie_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
					ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx)
	end
	
	function modifier_item_snapfire_cookie_buff:OnRemoved()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		
		local ability = self:GetAbility()
		self:StopMotionController()

		EmitSoundOn("Hero_Snapfire.FeedCookie.Impact", parent)
		GridNav:DestroyTreesAroundPoint(parentPos, self.radius, false)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_snapfire/hero_snapfire_cookie_landing.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, parentPos)
					ParticleManager:SetParticleControl(nfx, 1, Vector(self.radius, self.radius, self.radius))
					ParticleManager:ReleaseParticleIndex(nfx)

		local enemies = parent:FindEnemyUnitsInRadius(parentPos, self.radius)
		for _,enemy in pairs(enemies) do
			ability:Stun(enemy, self.impact_stun_duration, false)
			--print("Ability Name: " .. ability:GetAbilityName())
			--print("Damage: " .. self.impact_damage)
			--print("Parent Name: " .. parent:GetName())
			--print("Enemy Name: " .. enemy:GetName())
			print(ability:DealDamage(parent, enemy, self.impact_damage, {damageType = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NONE}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE))
		end

		FindClearSpaceForUnit(parent, parentPos, true)

		parent:StartGesture(ACT_DOTA_CAST_ABILITY_2_END)

		ability:Destroy()
	end
	
	function modifier_item_snapfire_cookie_buff:DoControlledMotion()
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

function modifier_item_snapfire_cookie_buff:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_item_snapfire_cookie_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_item_snapfire_cookie_buff:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_item_snapfire_cookie_buff:GetEffectName()
	return "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_receive.vpcf"
end

function modifier_item_snapfire_cookie_buff:IsPurgable()
	return false
end

function modifier_item_snapfire_cookie_buff:IsHidden()
	return true
end