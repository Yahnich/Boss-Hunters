drow_ranger_bullseye = class({})

function drow_ranger_bullseye:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local direction = CalculateDirection( target, caster )
	local speed = self:GetTalentSpecialValueFor("arrow_speed")
	local distance = self:GetTalentSpecialValueFor("arrow_range")
	local width = self:GetTalentSpecialValueFor("arrow_width")
	
	self:FireLinearProjectile("particles/drow_bullseye_arrow.vpcf", direction * speed, distance, width)
	
	ParticleManager:FireParticle("particles/units/heroes/hero_mirana/mirana_spell_arrow_launch.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn( "Hero_Mirana.ArrowCast", caster )
end

function drow_ranger_bullseye:OnProjectileHit( target, position )
	local caster = self:GetCaster()
	if target then
		self:BreakAndDamage(target)
	end
	if caster:HasTalent("special_bonus_unique_drow_ranger_bullseye_1") then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, caster:FindTalentValue("special_bonus_unique_drow_ranger_bullseye_1") ) ) do
			self:BreakAndDamage(enemy)
		end
		ParticleManager:FireParticle( "particles/units/heroes/hero_drow_ranger/drow_ranger_bullseye_burst.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position + Vector(0,0,64)})
	end
	return caster:HasTalent("special_bonus_unique_drow_ranger_bullseye_1")
end

function drow_ranger_bullseye:BreakAndDamage(target)
	local caster = self:GetCaster()
	target:Break( self, caster, self:GetTalentSpecialValueFor("break_duration"))
	local damage = caster:GetAgility() * self:GetTalentSpecialValueFor("arrow_agi_multiplier")
	caster:PerformGenericAttack(target, true, damage - caster:GetAttackDamage() )
end