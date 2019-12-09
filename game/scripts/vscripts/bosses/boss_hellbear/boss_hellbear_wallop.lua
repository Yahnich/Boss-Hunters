boss_hellbear_wallop = class({})

function boss_hellbear_wallop:GetCastRange( target, position )
	return self:GetCaster():GetAttackRange()
end

function boss_hellbear_wallop:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	self:GetCaster():EmitSound( "Hero_Tusk.WalrusPunch.Cast" )
	self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, 0.35 )
	return true
end

function boss_hellbear_wallop:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound( "Hero_Tusk.WalrusPunch.Cast" )
end

function boss_hellbear_wallop:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
    local damage = caster:GetAttackDamage() * self:GetSpecialValueFor("damage") / 100
	SendOverheadEventMessage(caster, OVERHEAD_ALERT_CRITICAL, target, damage, caster)
	StopSoundOn("Hero_Tusk.WalrusPunch.Cast", target)
	EmitSoundOn("Hero_Tusk.WalrusPunch.Target", target)
	
	ParticleManager:FireParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_txt_ult.vpcf", PATTACH_POINT, target, {[2]=target:GetAbsOrigin()})
	ParticleManager:FireParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_POINT, target, {[0]=target:GetAbsOrigin()})
	local airTime = self:GetSpecialValueFor("stun_duration")
	local knockback = self:GetSpecialValueFor("knockback")
	
	target:ApplyKnockBack(caster:GetAbsOrigin(), airTime, airTime/2, knockback, 500, caster, self, true)
	self:DealDamage( caster, target, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
end