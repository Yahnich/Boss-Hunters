pango_shield = class({})
LinkLuaModifier("modifier_pango_shield_movement", "heroes/hero_pango/pango_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pango_shield", "heroes/hero_pango/pango_shield", LUA_MODIFIER_MOTION_NONE)

function pango_shield:IsStealable()
	return true
end

function pango_shield:IsHiddenWhenStolen()
	return false
end

function pango_shield:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasScepter() and self:GetCaster():HasModifier("modifier_pango_ball_movement") then
    	cooldown = 2
    end
    return cooldown
end

function pango_shield:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("distance")
end

function pango_shield:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Pangolier.TailThump.Cast", caster)

	caster:AddNewModifier(caster, self, "modifier_pango_shield_movement", {Duration = self:GetTalentSpecialValueFor("jump_duration")})
end

modifier_pango_shield_movement = class({})

function modifier_pango_shield_movement:OnCreated()
	self.reduction = self:GetTalentSpecialValueFor("reduction")
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		self.startPos = caster:GetAbsOrigin()
		
		self.distance = self:GetTalentSpecialValueFor("distance")
		
		self.direction = caster:GetForwardVector()

		self.height = GetGroundHeight(self.startPos, caster)
		self.maxHeight = self:GetTalentSpecialValueFor("height")
		self.jump_duration = self:GetTalentSpecialValueFor("jump_duration")

		self.speed = self.distance / self.jump_duration * FrameTime() 

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_tailthump_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self:StartMotionController()
	end
end

function modifier_pango_shield_movement:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local damage = self:GetTalentSpecialValueFor("damage")
		local radius = self:GetTalentSpecialValueFor("radius")
		local duration = self:GetTalentSpecialValueFor("duration")

		if self:GetCaster():HasScepter() and self:GetCaster():HasModifier("modifier_pango_ball_movement") then
    		damage = damage * 2
    	end

		local vectorRadius = Vector(radius, radius, radius)

		EmitSoundOn("Hero_Pangolier.TailThump", caster)

		ParticleManager:FireParticle("particles/units/heroes/hero_pangolier/pangolier_tailthump.vpcf", PATTACH_POINT, caster, {[1]=vectorRadius})

		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
				if caster:HasTalent("special_bonus_unique_pango_shield_2") then
					enemy:ApplyKnockBack(enemy:GetAbsOrigin(), 1, 1, 0, 350, caster, self:GetAbility(), true)
				end

				self:GetAbility():DealDamage(caster, enemy, damage)
			end
		end
		if caster:HasTalent("special_bonus_unique_pango_shield_1") then
			if #enemies > 0 then
				EmitSoundOn("Hero_Pangolier.TailThump.Shield", caster)
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_pango_shield", {Duration = duration})
			end
		else
			EmitSoundOn("Hero_Pangolier.TailThump.Shield", caster)
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_pango_shield", {Duration = duration})
		end
		self:StopMotionController(false)
	end
end

function modifier_pango_shield_movement:DoControlledMotion()
	if IsServer() then
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
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

function modifier_pango_shield_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
end

function modifier_pango_shield_movement:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_pango_shield_movement:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end

function modifier_pango_shield_movement:IsHidden()
	return true
end

modifier_pango_shield = class({})

function modifier_pango_shield:OnCreated()
	self.reduction = self:GetTalentSpecialValueFor("reduction")
	if IsServer() then
		local caster = self:GetCaster()
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_tailthump_buff.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 3, Vector(50, 0, 0))
					ParticleManager:SetParticleControl(nfx, 5, Vector(0, 0, 0))
					ParticleManager:SetParticleControl(nfx, 8, Vector(50, 0, 0))
		self:AttachEffect(nfx)
	end

	self:StartIntervalThink(FrameTime())
end

function modifier_pango_shield:OnRefresh(table)
	self.reduction = self:GetTalentSpecialValueFor("reduction")
end

function modifier_pango_shield:OnRemoved()
	self.reduction = self:GetTalentSpecialValueFor("reduction")
end

function modifier_pango_shield:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_pango_shield:GetModifierIncomingDamage_Percentage(params)
	return -self.reduction
end

function modifier_pango_shield:IsDebuff()
	return false
end