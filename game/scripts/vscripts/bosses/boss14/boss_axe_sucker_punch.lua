boss_axe_sucker_punch = class({})

function boss_axe_sucker_punch:GetCastRange( position, target )
	return self:GetCaster():GetAttackRange()
end

function boss_axe_sucker_punch:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:EmitSound( "Hero_Tusk.WalrusPunch.Cast" )
	ParticleManager:FireLinearWarningParticle( caster:GetAbsOrigin(), caster:GetAbsOrigin() + CalculateDirection( self:GetCursorPosition(), caster ) * caster:GetAttackRange(), self:GetSpecialValueFor("effect_width") )
	return true
end

function boss_axe_sucker_punch:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound( "Hero_Tusk.WalrusPunch.Cast" )
end

function boss_axe_sucker_punch:OnSpellStart()
	local caster = self:GetCaster()
	local startPos = caster:GetAbsOrigin()
	local endPos = startPos + CalculateDirection( self:GetCursorPosition(), caster ) * caster:GetAttackRange()
	
	local knockbackSpeed = self:GetSpecialValueFor("speed")
	local knockbackDistance = self:GetSpecialValueFor("knockback")
	local knockbackDuration = knockbackDistance / knockbackSpeed
	local dazeDuration = knockbackDuration + self:GetSpecialValueFor("daze_duration")
	local width = self:GetSpecialValueFor("effect_width")
	local radius = self:GetSpecialValueFor("search_radius")
	local tauntDuration = self:GetSpecialValueFor("taunt_duration")
	local damage = self:GetSpecialValueFor("damage")
	
	caster:EmitSound( "Hero_Tusk.WalrusPunch.Target" )
	
	local enemies = caster:FindEnemyUnitsInLine(startPos, endPos, width)
	for _, enemy in ipairs( enemies ) do
		if not enemy:TriggerSpellAbsorb( self ) then
			enemy:ApplyKnockBack(startPos, knockbackDuration, knockbackDuration, knockbackDistance, 0, caster, self, true)
			self:DealDamage( caster, enemy, damage )
		end
	end
	
	if enemies[1] then
		caster:EmitSound( "Hero_Tusk.WalrusPunch.Damage" )
	end
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( startPos, radius ) ) do
		caster:Taunt(self, enemy, tauntDuration)
		break
	end
end