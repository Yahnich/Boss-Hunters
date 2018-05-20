boss15_exorcise = class({})

function boss15_exorcise:OnAbilityPhaseStart()
	ParticleManager:FireLinearWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetCaster():GetAbsOrigin() + CalculateDirection(self:GetCursorPosition(), self:GetCaster()) * self:GetSpecialValueFor( "distance" ), self:GetSpecialValueFor( "width_end" ) * 2)
	return true
end

function boss15_exorcise:OnSpellStart()
	local speed = self:GetSpecialValueFor( "speed" )
	local width_initial = self:GetSpecialValueFor( "width_initial" )
	local width_end = self:GetSpecialValueFor( "width_end" )
	local distance = self:GetSpecialValueFor( "distance" )
	local damage = self:GetSpecialValueFor( "damage" ) 
	
	local caster = self:GetCaster()
	local ability = self

	EmitSoundOn( "Hero_DeathProphet.CarrionSwarm.Mortis", self:GetCaster() )

	local vPos = nil
	if self:GetCursorTarget() then
		vPos = self:GetCursorTarget():GetAbsOrigin()
	else
		vPos = self:GetCursorPosition()
	end

	local vDirection = vPos - self:GetCaster():GetAbsOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()
	
	local vPerpend = GetPerpendicularVector(vDirection)

	speed = speed * ( distance / ( distance - width_initial ) ) * FrameTime()
	local width_growth = (width_end - width_initial) / (distance / speed) * FrameTime()
	local width = width_initial
	local position = self:GetCaster():GetAbsOrigin()
	local velocity = vDirection * speed
	local distTravelled = 0
	local hitTable = {}
	
	local exorciseProj = ParticleManager:CreateParticle("particles/units/heroes/hero_death_prophet/death_prophet_carrion_swarm.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( exorciseProj, 0, position )
	ParticleManager:SetParticleControl( exorciseProj, 3, position )
	ParticleManager:SetParticleControl( exorciseProj, 5, position )
	ParticleManager:SetParticleControl( exorciseProj, 1, velocity / FrameTime() )
	ParticleManager:SetParticleControl( exorciseProj, 2, Vector(0,width,0) )

	Timers:CreateTimer(FrameTime(), function()
		local startPos = position + vPerpend * width/2
		local endPos = position - vPerpend * width/2
		local enemies = caster:FindEnemyUnitsInLine(startPos, endPos, width)
		for _, enemy in ipairs(enemies) do
			if not hitTable[enemy:entindex()] then
				ability:OnLinearProjectileHit(enemy)
				hitTable[enemy:entindex()] = true
			end
		end
		
		if width < width_end then width = math.min( width + width_growth, width_end ) end
		position = position + velocity
		distTravelled = distTravelled + speed

		ParticleManager:SetParticleControl( exorciseProj, 2, Vector(0,width,0) )
		
		if distTravelled < distance then
			return FrameTime()
		else
			ParticleManager:DestroyParticle(exorciseProj, false)
			ParticleManager:ReleaseParticleIndex(exorciseProj)
		end
	end)
	
end

--------------------------------------------------------------------------------

function boss15_exorcise:OnLinearProjectileHit( hTarget )
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage( damage )
		EmitSoundOn( "Hero_DeathProphet.CarrionSwarm.Damage.Mortis", self:GetCaster() )
		if self:GetCaster():GetHealthPercent() > 50 then
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_boss15_exorcise_damage_debuff", {duration = self:GetSpecialValueFor("debuff_duration")})
		elseif self:GetCaster():GetHealthPercent() < 50 then
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_silence", {duration = self:GetSpecialValueFor("debuff_duration")})
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_disarmed", {duration = self:GetSpecialValueFor("debuff_duration")})
		end
		
		ParticleManager:FireParticle( "particles/units/heroes/hero_death_prophet/death_prophet_carrion_swarm_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
	end

	return false
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