boss_ifdat_flamethrower = class({})

function boss_ifdat_flamethrower:OnSpellStart()
	self.think = 0
	self.interval = 1 / math.floor(self:GetSpecialValueFor("flames_per_sec"))
	self.radius = self:GetSpecialValueFor("impact_radius")
	self.damage = self:GetSpecialValueFor("damage")
	self.duration = self:GetSpecialValueFor("duration")
	self.stun = self:GetSpecialValueFor("impact_stun")
	if RollPercentage(50) then
		self.initialVector = self:GetCaster():GetRightVector()
	else
		self.initialVector = self:GetCaster():GetForwardVector()
	end
	ParticleManager:FireLinearWarningParticle( self:GetCaster():GetAbsOrigin(), self:GetCaster():GetAbsOrigin() + self.initialVector * 900 )
	ParticleManager:FireLinearWarningParticle( self:GetCaster():GetAbsOrigin(), self:GetCaster():GetAbsOrigin() - self.initialVector * 900 )
	self.angle = 0;
	self:GetCaster():EmitSound("Hero_Lina.DragonSlave")
end

function boss_ifdat_flamethrower:OnChannelThink(dt)
	self.think = self.think + dt
	if self.interval <= self.think then
		local vector = RotateVector2D(self.initialVector, ToRadians( self.angle ) )
		self:FireLinearProjectile("particles/units/bosses/boss_ifdat/boss_ifdat_flamethrower.vpcf", vector*500, 900, 125, {}, false, true, 125)
		self:FireLinearProjectile("particles/units/bosses/boss_ifdat/boss_ifdat_flamethrower.vpcf", -vector*500, 900, 125, {}, false, true, 125)
		if self.angle >= 120 then
			self.triggered = true
		elseif self.angle <= 0 then
			self.triggered = false
		end
		if self.triggered then
			self.angle = self.angle - ( 60 * self.interval )
		else
			self.angle = self.angle + ( 60 * self.interval )
		end
		self:GetCaster():EmitSound("Hero_Lina.attack")
		self.think = 0
	end
end

function boss_ifdat_flamethrower:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    
    if hTarget ~= nil and not hTarget:TriggerSpellAbsorb( self ) then
        self:DealDamage(caster, hTarget, self.damage, {}, 0)
		hTarget:AddNewModifier( caster, self, "modifier_boss_ifdat_flamethrower", {duration = self.duration})
    end
end

modifier_boss_ifdat_flamethrower = class({})
LinkLuaModifier( "modifier_boss_ifdat_flamethrower", "bosses/boss_ifdat/boss_ifdat_flamethrower", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ifdat_flamethrower:OnCreated()
	self.red = self:GetSpecialValueFor("dmg_red")
end

function modifier_boss_ifdat_flamethrower:OnRefresh()
	self:OnCreated()
end

function modifier_boss_ifdat_flamethrower:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_boss_ifdat_flamethrower:GetModifierTotalDamageOutgoing_Percentage()
	return self.red
end