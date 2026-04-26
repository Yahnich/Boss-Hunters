drow_ranger_frozen_breath = class({})

function drow_ranger_frozen_breath:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()

	local direction = CalculateDirection( position, caster )
	local speed = self:GetSpecialValueFor("wave_speed")
	local distance = self:GetTrueCastRange()
	local width = self:GetSpecialValueFor("wave_width")

	EmitSoundOn("Hero_DrowRanger.Silence", caster)
	self:FireLinearProjectile("particles/units/heroes/hero_drow/drow_silence_wave.vpcf", direction * speed, distance, width)

	if self:GetSpecialValueFor("mspd") ~= 0 then
		caster:AddNewModifier(caster, self, "modifier_drow_ranger_frozen_breath_archery", {duration = self:GetSpecialValueFor("buff_duration")})
	end
end

function drow_ranger_frozen_breath:OnProjectileHit( target, position )
	if target and not target:TriggerSpellAbsorb(self) then
		local caster = self:GetCaster()
		local knockBackDuration = self:GetSpecialValueFor("knockback_duration")
		local duration = knockBackDuration + self:GetSpecialValueFor("silence_duration")
		local distance = self:GetSpecialValueFor("knockback_distance_max") * ( self:GetTrueCastRange() - (CalculateDistance( caster, target ) - caster:GetHullRadius() - target:GetHullRadius() - caster:GetCollisionPadding() - target:GetCollisionPadding()) ) / self:GetTrueCastRange()

		target:ApplyKnockBack(caster:GetAbsOrigin(), knockBackDuration, knockBackDuration, distance, 0, caster, self, true)
		target:Silence(self, caster, duration)
		target:AddNewModifier(caster, self, "modifier_drow_ranger_frozen_breath_re", {duration = duration})
		if self:GetSpecialValueFor("attacks") ~= 0 then
			caster:PerformGenericAttack(target, false)
		end
		if self:GetSpecialValueFor("miss_chance") ~= 0 then
			target:Blind(self:GetSpecialValueFor("miss_chance"), self, caster, self:GetSpecialValueFor("miss_duration"))
			target:Root(self,  caster, knockBackDuration + self:GetSpecialValueFor("miss_duration") )
		end

		local damage_per_chill = self:GetSpecialValueFor("damage_per_chill")
		if target:GetChillCount() ~= 0 and damage_per_chill ~= 0 then
			self:DealDamage(caster, target, target:GetChillCount() * damage_per_chill)
			target:Freeze(self, caster, self:GetSpecialValueFor("freeze_duration"))
		else
			if target:GetChillCount() == 0 then return end
		end
	end
end

modifier_drow_ranger_frozen_breath_re = class({})
LinkLuaModifier("modifier_drow_ranger_frozen_breath_re", "heroes/hero_drow_ranger/drow_ranger_frozen_breath", LUA_MODIFIER_MOTION_NONE)

function modifier_drow_ranger_frozen_breath_re:IsHidden()
	return true
end

modifier_drow_ranger_frozen_breath_archery = class({})
LinkLuaModifier("modifier_drow_ranger_frozen_breath_archery", "heroes/hero_drow_ranger/drow_ranger_frozen_breath", LUA_MODIFIER_MOTION_NONE)

function modifier_drow_ranger_frozen_breath_archery:OnCreated()
	self:OnRefresh()
end

function modifier_drow_ranger_frozen_breath_archery:OnRefresh()
	self.mspd = self:GetSpecialValueFor("mspd")
	self.aspd = self:GetSpecialValueFor("aspd")
end

function modifier_drow_ranger_frozen_breath_archery:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_drow_ranger_frozen_breath_archery:GetModifierMoveSpeedBonus_Percentage()
	return self.mspd
end

function modifier_drow_ranger_frozen_breath_archery:GetModifierAttackSpeedBonus_Constant()
	return self.aspd
end