jakiro_dual_breath_bh = class({})
LinkLuaModifier("modifier_jakiro_dual_breath_bh_burn", "heroes/hero_jakiro/jakiro_dual_breath_bh", LUA_MODIFIER_MOTION_NONE)

function jakiro_dual_breath_bh:IsStealable()
	return true
end

function jakiro_dual_breath_bh:IsHiddenWhenStolen()
	return false
end

function jakiro_dual_breath_bh:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	if self:GetCursorTarget() then
		point = self:GetCursorTarget():GetAbsOrigin()
	end

	EmitSoundOn("Hero_Jakiro.DualBreath.Cast", caster)

	local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local speed = 1050
	local range = self:GetTrueCastRange() + self:GetSpecialValueFor("extra_travel_distance")

	--Frost Breath
	--/////////////////////////////////////////////////
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_dual_breath_ice.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, direction * speed)
				ParticleManager:SetParticleControl(nfx, 3, Vector(0,0,0) )
				ParticleManager:SetParticleControlEnt(nfx, 9, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)

	Timers:CreateTimer( range/speed+FrameTime(), function()
		ParticleManager:ClearParticle(nfx)
	end)
	
	self.frost = self:FireLinearProjectile("", direction*speed, range, self:GetSpecialValueFor("start_radius"), {width_end = self:GetSpecialValueFor("end_radius")}, false, true, 300)

	--Fire Breath
	--/////////////////////////////////////////////////
	Timers:CreateTimer( 0.3, function() ---because dota
		EmitSoundOn("Hero_Jakiro.DualBreath.Cast", caster)
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 1, direction * speed)
					ParticleManager:SetParticleControl(nfx, 3, Vector(0,0,0) )
					ParticleManager:SetParticleControlEnt(nfx, 9, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)

		Timers:CreateTimer( range/speed+FrameTime(), function()
			ParticleManager:ClearParticle(nfx)
		end)

		self.fire = self:FireLinearProjectile("", direction*speed, range, self:GetSpecialValueFor("start_radius"), {width_end = self:GetSpecialValueFor("end_radius")}, false, true, 300)
	end)
end

function jakiro_dual_breath_bh:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
	local caster = self:GetCaster()
	if hTarget and not hTarget:TriggerSpellAbsorb( self ) then
		if iProjectileHandle == self.frost then
			hTarget:AddChill(self, caster, self:GetSpecialValueFor("duration"), self:GetSpecialValueFor("chill_amount"))
		elseif iProjectileHandle == self.fire then
			hTarget:AddNewModifier(caster, self, "modifier_jakiro_dual_breath_bh_burn", {Duration = self:GetSpecialValueFor("duration")})
		end
	end
	local convergence = caster:FindAbilityByName("jakiro_elemental_convergence")
	if convergence and not hTarget then
		if iProjectileHandle == self.fire then
			convergence:AddFireAttunement()
		elseif iProjectileHandle == self.frost then
			convergence.preventConvergence = true
			convergence:AddIceAttunement()
			convergence.preventConvergence = false
		end
	end
end


modifier_jakiro_dual_breath_bh_burn = class({})
function modifier_jakiro_dual_breath_bh_burn:OnCreated(table)
	self.damage = self:GetSpecialValueFor("damage")
	if IsServer() then
		EmitSoundOn("Hero_Jakiro.DualBreath.Burn", self:GetParent())
		self:StartIntervalThink(0.5)
	end
end

function modifier_jakiro_dual_breath_bh_burn:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Jakiro.DualBreath.Burn", self:GetParent())
	end
end

function modifier_jakiro_dual_breath_bh_burn:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage*0.5, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
end

function modifier_jakiro_dual_breath_bh_burn:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_jakiro_dual_breath_bh_burn:GetStatusEffectName()
	return "particles/status_fx/status_effect_burn.vpcf"
end

function modifier_jakiro_dual_breath_bh_burn:StatusEffectPriority()
	return 10
end

function modifier_jakiro_dual_breath_bh_burn:IsDebuff()
	return true
end