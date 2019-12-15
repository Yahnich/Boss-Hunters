boss_arthromos_dessicate = class({})

function boss_arthromos_dessicate:GetChannelTime()
	return self:GetSpecialValueFor("channel_time")
end

function boss_arthromos_dessicate:OnSpellStart()
	self.timer = self:GetSpecialValueFor("tick_time")
end

function boss_arthromos_dessicate:OnChannelThink(dt)
	self.timer = self.timer - dt
	if self.timer <= 0 then
		local caster = self:GetCaster()
		self.timer = self:GetSpecialValueFor("tick_time")
		local tickDamage = self:GetSpecialValueFor("channel_damage")
		EmitSoundOn( "hero_viper.poisonAttack.Cast", caster )
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
			self:FireTrackingProjectile("particles/units/heroes/hero_viper/viper_poison_attack.vpcf", enemy, 250, {extraData = {}})
		end
	end
end

function boss_arthromos_dessicate:OnChannelFinish(bInterrupt)
	if not bInterrupt then
		local caster = self:GetCaster()
		local endDamage = self:GetSpecialValueFor("end_damage")
		EmitSoundOn( "Hero_Dazzle.Poison_Cast", caster )
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
			self:FireTrackingProjectile("particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf", enemy, 150, {extraData = {["end"] = 1}})
		end
	end
end

function boss_arthromos_dessicate:OnProjectileHit_ExtraData( target, location, extraData )
	if not self or not self:GetCaster() or self:IsNull() or self:GetCaster():IsNull() then 
		return
	end
	if target and not target:TriggerSpellAbsorb( self ) then
		local damage = self:GetSpecialValueFor("channel_damage")
		if extraData["end"] then
			damage = self:GetSpecialValueFor("end_damage")
		else
			EmitSoundOn( "Hero_Dazzle.Poison_Touch", target )
		end
		self:DealDamage( self:GetCaster(), target, damage )
	end
end