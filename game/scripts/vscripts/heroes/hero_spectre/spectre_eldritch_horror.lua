spectre_eldritch_horror = class({})

function spectre_eldritch_horror:Spawn()
	self:GetCaster()._dimensionalInterjunction:HookInShadowPathEvents( self )
end

function spectre_eldritch_horror:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("duration")
	local range = self:GetCastRange( caster:GetAbsOrigin(), caster )
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), range ) ) do
		caster:LaunchShadowPath( enemy )
	end
	caster:LaunchShadowPath( caster:GetAbsOrigin() + caster:GetForwardVector( ) * range, {distance = range} )
	
	ParticleManager:FireParticle( "particles/econ/items/spectre/spectre_arcana/spectre_arcana_haunt_caster.vpcf", PATTACH_POINT_FOLLOW, caster )
	EmitSoundOn( "Hero_Spectre.HauntCast", caster )
	EmitSoundOn( "Hero_Spectre.Taunt", caster )
	EmitSoundOn( "Hero_Spectre.ShadowStep.Reality", caster )
end

function spectre_eldritch_horror:OnShadowPathHit( target, position, projectileData, bNotFinal )
	local caster = self:GetCaster()
	if target then
		local duration = self:GetSpecialValueFor("duration")
		
		target:AddNewModifier( caster, self, "modifier_spectre_eldritch_horror_fear", {duration = duration} )
		target:Fear(self, caster, duration)
		self:DealDamage( caster, target, self:GetSpecialValueFor("damage") )
	end
end

modifier_spectre_eldritch_horror_fear = class({})
LinkLuaModifier("modifier_spectre_eldritch_horror_fear", "heroes/hero_spectre/spectre_eldritch_horror", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_eldritch_horror_fear:OnCreated()
	self.bonus_movespeed = -self:GetSpecialValueFor("slow")
	print( self.bons_movespeed, "fear" )
end


function modifier_spectre_eldritch_horror_fear:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_spectre_eldritch_horror_fear:GetModifierMoveSpeedBonus_Percentage()    
	return self.bonus_movespeed
end

function modifier_spectre_eldritch_horror_fear:IsHidden()
	return true
end