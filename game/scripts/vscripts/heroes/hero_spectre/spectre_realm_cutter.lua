spectre_realm_cutter = class({})

function spectre_realm_cutter:Spawn()
	self:GetCaster()._dimensionalInterjunction:HookInShadowPathEvents( self )
end

function spectre_realm_cutter:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local position = self:GetCursorPosition()
	
	caster:LaunchShadowPath( target or position, {radius = self:GetSpecialValueFor("dagger_radius")} )
end

function spectre_realm_cutter:OnShadowPathHit( target, position, projectile, bNotFinal )
	local caster = self:GetCaster()
	if target then
		projectileData.units[target] = true
		if target:TriggerSpellAbsorb(self) then return false end
		EmitSoundOn("Hero_Spectre.DaggerImpact", target)
		if projectileData.tracking and not bNotFinal then
			target:AddNewModifier( caster, self, "modifier_spectre_realm_cutter_path", {self:GetSpecialValueFor("dagger_slow_duration")} )
		end
		target:AddNewModifier( caster, self, "modifier_spectre_realm_cutter_slow", {self:GetSpecialValueFor("dagger_slow_duration")} )
		self:DealDamage( caster, target, self:GetSpecialValueFor("damage") )
	else
end


modifier_spectre_realm_cutter_path = class({})
LinkLuaModifier("modifier_spectre_realm_cutter_path", "heroes/hero_spectre/spectre_realm_cutter", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_realm_cutter_path:OnCreated()
	self.duration = self:GetSpecialValueFor("dagger_path_duration")
	self.radius = self:GetSpecialValueFor("dagger_path_duration")
	if IsServer() then
		self:StartIntervalThink(0.15)
		local pathFX = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_shadow_path.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(pathFX, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl( pathFX, 5, Vector(self.duration, 0, 0) )
		self:AddEffect(pathFX)
	end
end


function modifier_spectre_realm_cutter_slow:OnIntervalThink()
	local caster = self:GetCaster()
	caster:CreateShadowPath( self:GetParent():GetAbsOrigin(), {duration = self.duration, radius = self.radius} )
end

function modifier_spectre_realm_cutter_path:IsHidden()    
	return true
end

modifier_spectre_realm_cutter_slow = class({})
LinkLuaModifier("modifier_spectre_realm_cutter_slow", "heroes/hero_spectre/spectre_realm_cutter", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_realm_cutter_slow:OnCreated()
	self.bonus_movespeed = self:GetSpecialValueFor("bonus_movespeed")
end


function modifier_spectre_realm_cutter_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_spectre_realm_cutter_slow:GetModifierMoveSpeedBonus_Percentage()    
	return self.bonus_movespeed
end