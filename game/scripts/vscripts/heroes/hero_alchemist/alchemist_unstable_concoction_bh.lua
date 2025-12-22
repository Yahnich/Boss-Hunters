alchemist_volatile_brew = class({})

function alchemist_volatile_brew:IsStealable()
	return true
end

function alchemist_volatile_brew:IsHiddenWhenStolen()
	return false
end

function alchemist_volatile_brew:GetBehavior()
	if self:GetCaster():HasModifier("modifier_alchemist_volatile_brew_charge") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function alchemist_volatile_brew:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function alchemist_volatile_brew:GetManaCost( iLvl )
	if self:GetCaster():HasModifier("modifier_alchemist_volatile_brew_charge") then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end
function alchemist_volatile_brew:OnSpellStart()
	local caster = self:GetCaster()
	
	self.projectiles = self.projectiles or {}
	if caster:HasModifier("modifier_alchemist_volatile_brew_charge") then
		local modifier = caster:FindModifierByName("modifier_alchemist_volatile_brew_charge")
		modifier:Destroy()
		local charge = modifier:GetStackCount() / 100
		
		local projectileID = self:FireTrackingProjectile("particles/units/heroes/hero_alchemist/alchemist_volatile_brew_projectile.vpcf", self:GetCursorTarget(), 900, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_3, false, true, 300)
		self.projectiles[projectileID] = charge
		self:EndCooldown()
		self:StartCooldown( self.actualCooldownTime - ( GameRules:GetGameTime() - self.castTime ) )
		caster:StartGesture( ACT_DOTA_CAST_ABILITY_4 )
		EmitSoundOn( "Hero_Alchemist.UnstableConcoction.Throw", caster )
	else
		self.castTime = GameRules:GetGameTime()
		self.actualCooldownTime = self:GetCooldownTimeRemaining()
		caster:AddNewModifier( caster, self, "modifier_alchemist_volatile_brew_charge", {duration = self:GetSpecialValueFor("brew_explosion")})
		self:EndCooldown()
	end
end

function alchemist_volatile_brew:OnProjectileHitHandle( target, position, projectile )
	if target then
		self:UnstableConcoctionEffect( target, self.projectiles[projectile] )
		self.projectiles[projectile] = nil
	end
end

function alchemist_volatile_brew:UnstableConcoctionEffect( target, strength )
	local caster = self:GetCaster()
	
	local damage = math.max( self:GetSpecialValueFor("max_damage") * strength, self:GetSpecialValueFor("min_damage") )
	local stun = math.max( self:GetSpecialValueFor("max_stun") * strength, self:GetSpecialValueFor("min_stun") )
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		if enemy ~= target then
			enemy:AddNewModifier( caster, self, "modifier_alchemist_volatile_brew_gold", {duration = stun} ):SetStackCount( math.ceil(strength * 100) )
			self:DealDamage( caster, enemy, damage )
			self:Stun( enemy, stun )
		end
	end
	target:AddNewModifier( caster, self, "modifier_alchemist_volatile_brew_gold", {duration = stun} ):SetStackCount( math.ceil(strength * 100) )
	self:DealDamage( caster, target, damage )
	self:Stun( target, stun )
	
	ParticleManager:FireParticle( "particles/units/heroes/hero_alchemist/alchemist_volatile_brew_explosion.vpcf", PATTACH_POINT_FOLLOW, target )
	EmitSoundOn( "Hero_Alchemist.UnstableConcoction.Stun", target )
end

modifier_alchemist_volatile_brew_charge = class({})
LinkLuaModifier( "modifier_alchemist_volatile_brew_charge", "heroes/hero_alchemist/alchemist_volatile_brew", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_volatile_brew_charge:OnCreated()
	self.chargeUp = ( 100 / self:GetSpecialValueFor("brew_time") ) * 0.1
	if IsServer() then
		self:StartIntervalThink( 0.1 )
		
		EmitSoundOn( "Hero_Alchemist.UnstableConcoction.Fuse", self:GetParent() )
		
		local remaining = self:GetRemainingTime()
		local seconds = math.ceil( remaining )
		self.half = (seconds-remaining)>0.5 
	end
end

function modifier_alchemist_volatile_brew_charge:OnIntervalThink()
	if self:GetStackCount() < 100 then
		self:SetStackCount( math.min( self:GetStackCount() + self.chargeUp, 100 ) )
	end
	
	local remaining = self:GetRemainingTime()
	local seconds = math.ceil( remaining )
	local isHalf = (seconds-remaining)>0.5
	local len = 1
	if seconds >= 10 then len = 2 end

	if self.half ~= isHalf and seconds > 0 then
		self.half = isHalf 
		ParticleManager:FireParticle( "particles/units/heroes/hero_alchemist/alchemist_volatile_brew_timer.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), {[1] = Vector( 8, seconds, 0 ), [2] = Vector( len, 0, 0 )} )
	end
end

function modifier_alchemist_volatile_brew_charge:OnDestroy()
	if IsServer() then
		StopSoundOn( "Hero_Alchemist.UnstableConcoction.Fuse", self:GetParent() )
		if ( self:GetRemainingTime() <= 0 or not self:GetParent():IsAlive() ) then
			self:GetAbility():UnstableConcoctionEffect( self:GetParent(), self:GetStackCount()/100 )
		end
	end
end

modifier_alchemist_volatile_brew_gold = class({})
LinkLuaModifier( "modifier_alchemist_volatile_brew_gold", "heroes/hero_alchemist/alchemist_volatile_brew", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_volatile_brew_gold:OnCreated()
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_alchemist_volatile_brew_1")
	self.talent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_alchemist_volatile_brew_1") / 100
end

function modifier_alchemist_volatile_brew_gold:CheckState()
	if self:GetParent():IsStunned() then
		return {[MODIFIER_STATE_FROZEN] = true}
	end
end

function modifier_alchemist_volatile_brew_gold:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_alchemist_volatile_brew_gold:OnAttackLanded( params )
	if self.talent1 and params.target == self:GetParent() and params.attacker:IsRealHero() then
		self:GetAbility():DealDamage( self:GetCaster(), params.target, params.attacker:GetGold( ) * self.talent1Val * self:GetStackCount() / 100, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE )
	end
end

function modifier_alchemist_volatile_brew_gold:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf"
end

function modifier_alchemist_volatile_brew_gold:StatusEffectPriority()
	return 20
end

function modifier_alchemist_volatile_brew_gold:IsHidden()
	return true
end