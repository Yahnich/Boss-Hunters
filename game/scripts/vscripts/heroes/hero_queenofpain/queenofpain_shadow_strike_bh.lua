queenofpain_shadow_strike_bh = class({})

function queenofpain_shadow_strike_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_queenofpain_shadow_strike_1") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function queenofpain_shadow_strike_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local speed = self:GetTalentSpecialValueFor("projectile_speed")
	caster:EmitSound("Hero_QueenOfPain.ShadowStrike")
	if caster:HasTalent("special_bonus_unique_queenofpain_shadow_strike_1") then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() ) ) do
			self:FireTrackingProjectile("particles/units/heroes/hero_queenofpain/queen_shadow_strike.vpcf", enemy, speed)
		end
	else
		self:FireTrackingProjectile("particles/units/heroes/hero_queenofpain/queen_shadow_strike.vpcf", target, speed)
	end
end

function queenofpain_shadow_strike_bh:OnProjectileHit( target, position )
	if target and not target:TriggerSpellAbsorb( self ) then
		local caster = self:GetCaster()
		
		local damage = self:GetTalentSpecialValueFor("strike_damage")
		local duration = self:GetTalentSpecialValueFor("duration_tooltip")
		self:DealDamage( caster, target, damage )
		target:AddNewModifier( caster, self, "modifier_queen_of_pain_shadow_strike_bh", {duration = duration})
		
		target:EmitSound("Hero_QueenOfPain.ShadowStrike.Target")
	end
end

modifier_queen_of_pain_shadow_strike_bh = class({})
LinkLuaModifier("modifier_queen_of_pain_shadow_strike_bh", "heroes/hero_queenofpain/queenofpain_shadow_strike_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_queen_of_pain_shadow_strike_bh:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("duration_damage")
	self.slow = self:GetTalentSpecialValueFor("movement_slow")
	self.tick = 3 * ( self:GetRemainingTime() / self:GetTalentSpecialValueFor("duration_tooltip") )
	self.slowRed = self.slow / ( self:GetRemainingTime() / self.tick )
	self:StartIntervalThink( self.tick )
	if IsServer() then
		local dFX = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_shadow_strike_debuff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(dFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(dFX)
	end
end

function modifier_queen_of_pain_shadow_strike_bh:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("duration_damage")
	self.slow = self:GetTalentSpecialValueFor("movement_slow")
	local newTick = 3 * ( self:GetRemainingTime() / self:GetTalentSpecialValueFor("duration_tooltip") )
	
	if math.abs( self.tick - newTick ) > 0.01 then
		self.tick = newTick
		self.slowRed = ( self.slow / self:GetRemainingTime() ) * self.tick
		self:StartIntervalThink( self.tick )
	end
end

function modifier_queen_of_pain_shadow_strike_bh:OnIntervalThink()
	if IsServer() then
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage )
	end
	self.slow = math.min( self.slow - self.slowRed, 0 )
end

function modifier_queen_of_pain_shadow_strike_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_queen_of_pain_shadow_strike_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end