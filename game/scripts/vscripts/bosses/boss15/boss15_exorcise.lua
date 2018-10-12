boss15_exorcise = class({})

function boss15_exorcise:OnAbilityPhaseStart()
	ParticleManager:FireLinearWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetCaster():GetAbsOrigin() + CalculateDirection(self:GetCursorPosition(), self:GetCaster()) * self:GetSpecialValueFor( "distance" ), self:GetSpecialValueFor( "width_end" ) * 2)
	return true
end

function boss15_exorcise:OnSpellStart()
	local caster = self:GetCaster()
	local vPos = self:GetCursorPosition()
	if self:GetCursorTarget() then
		vPos = self:GetCursorTarget():GetAbsOrigin()
	end
	
	local speed = self:GetSpecialValueFor( "speed" )
	local width_initial = self:GetSpecialValueFor( "width_initial" ) / 2
	local width_end = self:GetSpecialValueFor( "width_end" ) / 2
	local distance = self:GetSpecialValueFor( "distance" )
	local damage = self:GetSpecialValueFor( "damage" ) 
	local velocity = CalculateDirection( vPos, caster ) * speed
	
	self:FireLinearProjectile("", velocity, distance, width_initial, {width_end = width_end})
	if self.exorciseProj then ParticleManager:ClearParticle( self.exorciseProj ) end
	self.exorciseProj = ParticleManager:CreateParticle("particles/units/heroes/hero_death_prophet/death_prophet_carrion_swarm.vpcf", PATTACH_CUSTOMORIGIN, nil)
	local position = caster:GetAbsOriginCenter()
	ParticleManager:SetParticleControl( self.exorciseProj, 0, position )
	ParticleManager:SetParticleControl( self.exorciseProj, 2, Vector(0,width_initial,0) )
	ParticleManager:SetParticleControl( self.exorciseProj, 3, position )
	ParticleManager:SetParticleControl( self.exorciseProj, 5, position )
	ParticleManager:SetParticleControl( self.exorciseProj, 1, velocity )

	EmitSoundOn( "Hero_DeathProphet.CarrionSwarm.Mortis", self:GetCaster() )
end

--------------------------------------------------------------------------------

function boss15_exorcise:OnProjectileHit( hTarget, vPosition )
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		if hTarget:TriggerSpellAbsorb(self) then return true end
		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage( damage )
		EmitSoundOn( "Hero_DeathProphet.CarrionSwarm.Damage.Mortis", self:GetCaster() )
		if self:GetCaster():GetHealthPercent() > 66 then
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_boss15_exorcise_damage_debuff", {duration = self:GetSpecialValueFor("debuff_duration")})
		elseif self:GetCaster():GetHealthPercent() > 33 then
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_silence", {duration = self:GetSpecialValueFor("debuff_duration")})
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_disarmed", {duration = self:GetSpecialValueFor("debuff_duration")})
		else
			self:Stun( hTarget, self:GetSpecialValueFor("stun_duration"), true )
		end
		
		ParticleManager:FireParticle( "particles/units/heroes/hero_death_prophet/death_prophet_carrion_swarm_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
	end
	print("what", hTarget)
	if not hTarget then ParticleManager:ClearParticle( self.exorciseProj ) end
end

modifier_boss15_exorcise_damage_debuff = class({})
LinkLuaModifier("modifier_boss15_exorcise_damage_debuff", "bosses/boss15/boss15_exorcise.lua", 0)

function modifier_boss15_exorcise_damage_debuff:OnCreated()
	self.damage_reduction = self:GetSpecialValueFor("damage_reduction")
end

function modifier_boss15_exorcise_damage_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_boss15_exorcise_damage_debuff:GetModifierTotalDamageOutgoing_Percentage()
	return self.damage_reduction
end

function modifier_boss15_exorcise_damage_debuff:GetEffectName()
	return "particles/units/heroes/hero_queenofpain/queen_shadow_strike_debuff_poison.vpcf"
end