boss_hellbear_clap = class({})

function boss_hellbear_clap:OnAbilityPhaseStart()
	self:GetCaster():EmitSound( "n_creep_Ursa.Clap" )
	ParticleManager:FireWarningParticle( self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 150, self:GetSpecialValueFor("radius") )
	return true
end

function boss_hellbear_clap:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound( "n_creep_Ursa.Clap" )
end

function boss_hellbear_clap:OnSpellStart()
	local caster = self:GetCaster()
	
	local position = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 150
	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("radius") 
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius) ) do
		if not enemy:TriggerSpellAbsorb( self ) then
			enemy:AddNewModifier( caster, self, "modifier_boss_hellbear_clap", {duration = duration} )
			self:DealDamage( caster, enemy, damage )
		end
	end
	ParticleManager:FireParticle("particles/neutral_fx/ursa_thunderclap.vpcf", PATTACH_ABSORIGIN, caster, {[0] = position, [1] = Vector(radius,1,1)})
end

modifier_boss_hellbear_clap = class({})
LinkLuaModifier( "modifier_boss_hellbear_clap", "bosses/boss_hellbear/boss_hellbear_clap", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_hellbear_clap:OnCreated()
	self.as = self:GetSpecialValueFor("as_slow")
	self.ms = self:GetSpecialValueFor("ms_slow")
end

function modifier_boss_hellbear_clap:OnRefresh()
	self.as = self:GetSpecialValueFor("as_slow")
	self.ms = self:GetSpecialValueFor("ms_slow")
end

function modifier_boss_hellbear_clap:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_boss_hellbear_clap:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end


function modifier_boss_hellbear_clap:GetModifierAttackSpeedBonus()
	return self.as
end