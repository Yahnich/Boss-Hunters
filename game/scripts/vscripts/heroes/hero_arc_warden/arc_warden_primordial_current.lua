arc_warden_primordial_current = class({})
LinkLuaModifier("modifier_arc_warden_primordial_current", "heroes/hero_arc_warden/arc_warden_primordial_current", LUA_MODIFIER_MOTION_NONE)

function arc_warden_primordial_current:IsStealable()
	return true
end

function arc_warden_primordial_current:IsHiddenWhenStolen()
	return false
end

function arc_warden_primordial_current:GetChannelAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

function arc_warden_primordial_current:GetChannelTime()
	return self:GetTalentSpecialValueFor( "channel_time" )
end

function arc_warden_primordial_current:OnSpellStart()
	local hTarget = self:GetCursorTarget()
	local hCaster = self:GetCaster()
	
	-- cosmetic
	EmitSoundOn("Hero_ShadowShaman.EtherShock", hCaster)
	if hTarget:TriggerSpellAbsorb(self) then return end
	if hTarget:IsIllusion() then
		hTarget:ForceKill(true)
		self:RefundManaCost()
		self:EndCooldown()
	else
		EmitSoundOn("Hero_Leshrac.Lightning_Storm", hTarget)
		local duration = self:GetTalentSpecialValueFor("channel_time")
		hTarget:Daze(self, hCaster, duration)
		hTarget:Paralyze(self, hCaster, duration)
		hTarget:AddNewModifier(hCaster, self, "modifier_arc_warden_primordial_current", {duration = duration})
		
		if hCaster:HasTalent("special_bonus_unique_arc_warden_primordial_current_1") then
			local modifier = hCaster:AddNewModifier(hCaster, self, "modifier_invulnerable", {duration = duration})
			Timers:CreateTimer(function()
				if not hCaster:IsChanneling() and not modifier:IsNull() then
					modifier:Destroy()
				end
				if not modifier:IsNull() then return 0.2 end
			end)
		end
		if hCaster:HasTalent("special_bonus_unique_arc_warden_primordial_current_2") then
			local enemies = hCaster:FindEnemyUnitsInRadius(hCaster:GetAbsOrigin(), self:GetTrueCastRange())
			for _,enemy in pairs(enemies) do
				if enemy ~= hTarget then
					enemy:Daze(self, hCaster, duration)
					enemy:Paralyze(self, hCaster, duration)
					enemy:AddNewModifier(hCaster, self, "modifier_arc_warden_primordial_current", {duration = self:GetTalentSpecialValueFor("channel_time")})
					break
				end
			end
		end
	end
end

modifier_arc_warden_primordial_current = class({})

function modifier_arc_warden_primordial_current:OnCreated(kv)
	self.duration = self:GetRemainingTime()
	self.damage = self:GetAbility():GetTalentSpecialValueFor("total_damage")
	self.tick = self:GetAbility():GetTalentSpecialValueFor("tick_interval")

	EmitSoundOn("Ability.static.loop", self:GetParent())

	if IsServer() then
		self:StartIntervalThink(self.tick)
		self:GetAbility():StartDelayedCooldown()
		
		local origin = self:GetCaster()
		if kv.origin then origin = EntIndexToHScript( tonumber(kv.origin) ) end
		local shackles = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_primordial_current.vpcf", PATTACH_POINT_FOLLOW, origin)
		ParticleManager:SetParticleControlEnt(shackles, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(shackles, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(shackles, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(shackles, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		
		ParticleManager:SetParticleControlEnt(shackles, 5, origin, PATTACH_POINT_FOLLOW, "attach_attack2", origin:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(shackles, 6, origin, PATTACH_POINT_FOLLOW, "attach_attack1", origin:GetAbsOrigin(), true)

		local shackles2 = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_primordial_current.vpcf", PATTACH_POINT_FOLLOW, origin)
		ParticleManager:SetParticleControlEnt(shackles2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(shackles2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(shackles2, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(shackles2, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		
		ParticleManager:SetParticleControlEnt(shackles2, 5, origin, PATTACH_POINT_FOLLOW, "attach_attack1", origin:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(shackles2, 6, origin, PATTACH_POINT_FOLLOW, "attach_attack2", origin:GetAbsOrigin(), true)
		
		self:AttachEffect(shackles)
		self:AttachEffect(shackles2)
	end
end

function modifier_arc_warden_primordial_current:OnRemoved()
	if IsServer() then
		if self:GetParent():IsDazed() then
			self:GetParent():RemoveDaze()
		end
		if self:GetParent():IsParalyzed() then
			self:GetParent():RemoveParalyze()
		end
		StopSoundOn("Ability.static.loop", self:GetParent())
	end
end

function modifier_arc_warden_primordial_current:OnIntervalThink()
	if not self:GetCaster():IsChanneling() then self:Destroy() end
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage*self.tick)
end

function modifier_arc_warden_primordial_current:OnDestroy()
	StopSoundOn("Hero_ShadowShaman.Shackles", self:GetParent())
	if IsServer() then
		self:GetCaster():InterruptChannel()
		self:GetAbility():EndDelayedCooldown()
	end
end