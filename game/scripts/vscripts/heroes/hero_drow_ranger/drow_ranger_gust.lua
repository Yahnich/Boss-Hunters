drow_ranger_gust = class({})

function drow_ranger_gust:GetIntrinsicModifierName()
	return "modifier_drow_ranger_gust_handler"
end

function drow_ranger_gust:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local direction = CalculateDirection( position, caster )
	local speed = self:GetSpecialValueFor("wave_speed")
	local distance = self:GetTrueCastRange()
	local width = self:GetSpecialValueFor("wave_width")
	
	EmitSoundOn("Hero_DrowRanger.Silence", caster)
	self:FireLinearProjectile("particles/units/heroes/hero_drow/drow_silence_wave.vpcf", direction * speed, distance, width)
end

function drow_ranger_gust:OnProjectileHit( target, position )
	if target and not target:TriggerSpellAbsorb(self) then
		local caster = self:GetCaster()
		local knockBackDuration = self:GetSpecialValueFor("knockback_duration")
		local duration = knockBackDuration + self:GetSpecialValueFor("silence_duration")
		local distance = self:GetSpecialValueFor("knockback_distance_max") * ( self:GetTrueCastRange() - (CalculateDistance( caster, target ) - caster:GetHullRadius() - target:GetHullRadius() - caster:GetCollisionPadding() - target:GetCollisionPadding()) ) / self:GetTrueCastRange()
		
		target:ApplyKnockBack(caster:GetAbsOrigin(), knockBackDuration, knockBackDuration, distance, 0, caster, self, true)
		target:Silence(self, caster, duration)
		if caster:HasTalent("special_bonus_unique_drow_ranger_gust_2") then
			caster:PerformGenericAttack(target, false)
		end
		if caster:HasTalent("special_bonus_unique_drow_ranger_gust_1") then
			target:Blind(caster:FindTalentValue("special_bonus_unique_drow_ranger_gust_1"), self, caster, duration)
			target:Root( self,  caster, knockBackDuration + caster:FindTalentValue("special_bonus_unique_drow_ranger_gust_1", "duration") )
		end
	end
end