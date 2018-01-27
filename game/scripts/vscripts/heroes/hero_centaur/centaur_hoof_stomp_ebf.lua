centaur_hoof_stomp_ebf = class({})

function centaur_hoof_stomp_ebf:GetCooldown(iLvl)
	local cooldown = self.BaseClass.GetCooldown(self, iLvl)
	if self:GetCaster():HasTalent("special_bonus_unique_centaur_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_centaur_2") end
	return cooldown
end

function centaur_hoof_stomp_ebf:GetCastRange(target, position)
	return ( self:GetTalentSpecialValueFor("radius") + self:GetCaster():GetStrength() * self:GetTalentSpecialValueFor("str_to_radius") / 100 )
end

function centaur_hoof_stomp_ebf:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius =  self:GetTalentSpecialValueFor("radius") + self:GetCaster():GetStrength() * self:GetTalentSpecialValueFor("str_to_radius") / 100
	local duration = self:GetTalentSpecialValueFor("stun_duration")
	local damage = self:GetTalentSpecialValueFor("stomp_damage") + caster:GetStrength() * self:GetTalentSpecialValueFor("str_to_damage") / 100
	
	local targets = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
	for _, target in ipairs( targets ) do
		self:DealDamage( caster, target, damage )
		self:Stun( target, duration, false )
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, caster, {[1] = Vector(radius, 0, 0)})
	EmitSoundOn( "Hero_Centaur.HoofStomp", caster )
end