boss_centaur_charge = class({})

function boss_centaur_charge:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	
	local direction = CalculateDirection( self:GetCursorPosition(), caster )
	for _, unit in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1) ) do
		ParticleManager:FireLinearWarningParticle( unit:GetAbsOrigin(), unit:GetAbsOrigin() + direction * self:GetSpecialValueFor("speed") * 2, ( self:GetSpecialValueFor("radius") + caster:GetHullRadius() + caster:GetCollisionPadding() ) * 2 )
		unit:FaceTowards( unit:GetAbsOrigin() + direction * 1200 )
	end
	caster:EmitSound( "Hero_Centaur.Stampede.Cast" )
	return true
end

function boss_centaur_charge:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound( "Hero_Centaur.Stampede.Cast" )
end

function boss_centaur_charge:OnSpellStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection( self:GetCursorPosition(), caster )
	caster:SetForwardVector( direction )
	
	for _, unit in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1) ) do
		ParticleManager:FireParticle("particles/units/heroes/hero_centaur/centaur_stampede_cast.vpcf", PATTACH_POINT_FOLLOW, unit)
		unit:FaceTowards( unit:GetAbsOrigin() + direction * 1200 )
		unit:AddNewModifier( caster, self, "modifier_boss_centaur_charge", {duration = 5} )
	end
end

modifier_boss_centaur_charge = class({})
LinkLuaModifier( "modifier_boss_centaur_charge", "bosses/boss_centaur/boss_centaur_charge", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_boss_centaur_charge:OnCreated()
		local parent = self:GetParent()
		self.caster = self:GetCaster()
		self.direction = CalculateDirection( self:GetAbility():GetCursorPosition(), self.caster )
		self.angle = self.caster:GetAnglesAsVector().y
		self.hitUnits = {}
		
		self.radius = self:GetSpecialValueFor("radius") + parent:GetHullRadius() + parent:GetCollisionPadding()
		self.damage = self:GetSpecialValueFor("damage")
		self.duration = self:GetSpecialValueFor("duration")
		self.buffDur = self:GetSpecialValueFor("buff_duration")
		self.selfStun = self:GetSpecialValueFor("stun_duration")
		local startPos = parent:GetAbsOrigin()
		self.lastPos = startPos + self.direction * parent:GetIdealSpeed() * 0.1
		self.prevAngle = parent:GetAnglesAsVector().y
		parent:MoveToPosition( self.lastPos )
		self:StartIntervalThink(0.1)
	end
	
	function modifier_boss_centaur_charge:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
			if not self.hitUnits[enemy] then
				if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
					ability:Stun( enemy, self.duration )
					ability:DealDamage( parent, enemy, self.damage )
					enemy:EmitSound( "Hero_Centaur.Stampede.Stun" )
				end
				self.hitUnits[enemy] = true
				self.hasHitEnemy = true
			end
		end
		local startPos = parent:GetAbsOrigin()
		if parent:IsRooted() or parent:IsStunned() or ( math.abs( CalculateDistance( self.lastPos, parent ) - parent:GetIdealSpeed() * 0.1 ) < 15 and parent:GetAnglesAsVector().y - self.prevAngle < 1 ) then
			self:Destroy()
			if not self.hasHitEnemy then
				ability:Stun( parent, self.selfStun )
			else
				parent:AddNewModifier(self.caster, ability, "modifier_boss_centaur_charge_ms", {duration = self.buffDur})
			end
		else
			self.lastPos = startPos + self.direction * parent:GetIdealSpeed() * 0.1
			parent:MoveToPosition( self.lastPos )
		end
		self.prevAngle = parent:GetAnglesAsVector().y
	end
end

function modifier_boss_centaur_charge:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_CANNOT_TARGET_ENEMIES] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
end

function modifier_boss_centaur_charge:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE}
end

function modifier_boss_centaur_charge:GetModifierMoveSpeed_Absolute()
	return self:GetSpecialValueFor("speed")
end

function modifier_boss_centaur_charge:GetEffectName()
	return "particles/units/heroes/hero_centaur/centaur_stampede.vpcf"
end

modifier_boss_centaur_charge_ms = class({})
LinkLuaModifier( "modifier_boss_centaur_charge_ms", "bosses/boss_centaur/boss_centaur_charge", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_centaur_charge_ms:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_centaur_charge_ms:GetModifierMoveSpeedBonus_Percentage()
	return self:GetSpecialValueFor("ms_boost")
end