boss_durva_consume_soul = class({})

function boss_durva_consume_soul:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local casterPos = caster:GetAbsOrigin()
	ParticleManager:FireLinearWarningParticle( casterPos, casterPos + CalculateDirection( self:GetCursorPosition(), caster ) * self:GetTrueCastRange(), self:GetSpecialValueFor("width") * 2 )
	return true
end

function boss_durva_consume_soul:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn( "Hero_ShadowDemon.ShadowPoison.Cast", caster )
	self:FireLinearProjectile( "particles/units/heroes/hero_shadow_demon/shadow_demon_shadow_poison_projectile.vpcf", CalculateDirection( self:GetCursorPosition(), caster ) * self:GetSpecialValueFor("speed"), self:GetTrueCastRange(), self:GetSpecialValueFor("width") * 2 )
end

function boss_durva_consume_soul:OnProjectileHit( target, position )
	if target and not target:TriggerSpellAbsorb( self ) then
		local caster = self:GetCaster()
		
		EmitSoundOn( "Hero_Bane.BrainSap.Target", target )
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_bane/bane_sap.vpcf", PATTACH_POINT_FOLLOW, caster, target)
		
		local damage = target:GetHealth() * self:GetSpecialValueFor("sap_damage") / 100
		local heal = self:DealDamage( caster, target, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		if target:IsRealHero() then caster:HealEvent( heal, self, caster ) end
	end
end