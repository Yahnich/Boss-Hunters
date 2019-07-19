boss_durva_filled_to_burst = class({})

function boss_durva_filled_to_burst:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCaster():GetAbsOrigin(), self:GetTrueCastRange() )
	EmitSoundOn("Hero_Nevermore.RequiemOfSoulsCast", self:GetCaster())
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_wings.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), {[5]="attach_attack1", [6]="attach_attack2", [7]="attach_hitloc"})
	return true
end

function boss_durva_filled_to_burst:OnSpellStart()
	local caster = self:GetCaster()
	
	local direction = caster:GetForwardVector()
	local projectiles = self:GetSpecialValueFor("projectile_count")
	local speed = self:GetSpecialValueFor("speed")
	local distance = self:GetTrueCastRange()
	local width = self:GetSpecialValueFor("radius")
	local angle = 360 / projectiles
	
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_a.vpcf", PATTACH_ABSORIGIN, caster, {[1]=Vector(projectiles, 0, 0),[2]=caster:GetAbsOrigin()})
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf", PATTACH_ABSORIGIN, caster, {[1]=Vector(projectiles, 0, 0)})
	EmitSoundOn("Hero_Nevermore.RequiemOfSouls", caster)
	
	for i=0, projectiles do
		direction = RotateVector2D(direction, ToRadians( angle ) )
		
		local particle_lines_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_lines_fx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_lines_fx, 1, direction*speed)
		ParticleManager:SetParticleControl(particle_lines_fx, 2, Vector(0, distance/speed, 0))
		ParticleManager:ReleaseParticleIndex(particle_lines_fx)

		self:FireLinearProjectile("", direction*speed, distance, width)
	end
end

function boss_durva_filled_to_burst:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		
		self:DealDamage( caster, target, self:GetSpecialValueFor("projectile_damage") )
		target:AddNewModifier( caster, self, "modifier_boss_durva_filled_to_burst", {duration = self:GetSpecialValueFor("duration")})
	end
end


modifier_boss_durva_filled_to_burst = class({})
LinkLuaModifier("modifier_boss_durva_filled_to_burst", "bosses/boss_durva/boss_durva_filled_to_burst", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_durva_filled_to_burst:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
end

function modifier_boss_durva_filled_to_burst:OnRefresh()
	self:OnCreated()
end

function modifier_boss_durva_filled_to_burst:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_durva_filled_to_burst:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end