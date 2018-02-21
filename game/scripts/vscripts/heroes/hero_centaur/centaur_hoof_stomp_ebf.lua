centaur_hoof_stomp_ebf = class({})

function centaur_hoof_stomp_ebf:IsStealable()
	return true
end

function centaur_hoof_stomp_ebf:IsHiddenWhenStolen()
	return false
end

function centaur_hoof_stomp_ebf:GetCooldown(iLvl)
	local cooldown = self.BaseClass.GetCooldown(self, iLvl)
	if self:GetCaster():HasTalent("special_bonus_unique_centaur_hoof_stomp_1") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_centaur_hoof_stomp_1") end
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
		if caster:HasTalent("special_bonus_unique_centaur_hoof_stomp_2") then 
			target:AddNewModifier(caster, self, "modifier_centaur_hoof_stomp_slow", {duration = duration + caster:FindTalentValue("special_bonus_unique_centaur_hoof_stomp_2")})
		end
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, caster, {[1] = Vector(radius, 0, 0)})
	EmitSoundOn( "Hero_Centaur.HoofStomp", caster )
end

modifier_centaur_hoof_stomp_slow = class({})
LinkLuaModifier("modifier_centaur_hoof_stomp_slow", "heroes/hero_centaur/centaur_hoof_stomp_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_centaur_hoof_stomp_slow:OnCreated()
	local parent = self:GetParent()
	self.ms = parent:FindTalentValue("special_bonus_unique_centaur_hoof_stomp_2", "ms")
	self.as = parent:FindTalentValue("special_bonus_unique_centaur_hoof_stomp_2", "as")
end

function modifier_centaur_hoof_stomp_slow:OnRefresh()
	local parent = self:GetParent()
	self.ms = parent:FindTalentValue("special_bonus_unique_centaur_hoof_stomp_2", "ms")
	self.as = parent:FindTalentValue("special_bonus_unique_centaur_hoof_stomp_2", "as")
end

function modifier_centaur_hoof_stomp_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_centaur_hoof_stomp_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_centaur_hoof_stomp_slow:GetModifierAttackSpeedBonus_Constant()
	return self.as
end