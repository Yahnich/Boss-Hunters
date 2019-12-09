drow_ranger_gust = class({})

function drow_ranger_gust:GetIntrinsicModifierName()
	return "modifier_drow_ranger_gust_handler"
end

function drow_ranger_gust:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local direction = CalculateDirection( position, caster )
	local speed = self:GetTalentSpecialValueFor("wave_speed")
	local distance = self:GetTrueCastRange()
	local width = self:GetTalentSpecialValueFor("wave_width")
	
	EmitSoundOn("Hero_DrowRanger.Silence", caster)
	self:FireLinearProjectile("particles/units/heroes/hero_drow/drow_silence_wave.vpcf", direction * speed, distance, width)
end

function drow_ranger_gust:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		local knockBackDuration = self:GetTalentSpecialValueFor("knockback_duration")
		local duration = knockBackDuration + self:GetTalentSpecialValueFor("silence_duration")
		local distance = self:GetTalentSpecialValueFor("knockback_distance_max") * ( self:GetTrueCastRange() - (CalculateDistance( caster, target ) - caster:GetHullRadius() - target:GetHullRadius() - caster:GetCollisionPadding() - target:GetCollisionPadding()) ) / self:GetTrueCastRange()
		
		target:ApplyKnockBack(caster:GetAbsOrigin(), knockBackDuration, knockBackDuration, distance, 0, caster, self, true)
		target:Silence(self, caster, duration)
		if caster:HasTalent("special_bonus_unique_drow_ranger_gust_2") then
			caster:PerformGenericAttack(target, false)
		end
		if caster:HasTalent("special_bonus_unique_drow_ranger_gust_1") then
			target:Blind(caster:FindTalentValue("special_bonus_unique_drow_ranger_gust_1"), self, caster, duration)
		end
	end
end