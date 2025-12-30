alchemist_volatile_brew = class({})

function alchemist_volatile_brew:IsStealable()
	return true
end

function alchemist_volatile_brew:IsHiddenWhenStolen()
	return false
end

function alchemist_volatile_brew:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_alchemist_volatile_brew_charge") then
		return "alchemist_unstable_concoction_throw"
	else
		return "alchemist_unstable_concoction"
	end
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

function alchemist_volatile_brew:CastFilterResultTarget( target )
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	if self:GetSpecialValueFor("buff_duration") > 0 then
		target_team = DOTA_UNIT_TARGET_TEAM_BOTH
	end
	return UnitFilter(target, target_team, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber() )
end


function alchemist_volatile_brew:OnSpellStart()
	local caster = self:GetCaster()
	
	self.projectiles = self.projectiles or {}
	if caster:HasModifier("modifier_alchemist_volatile_brew_charge") then
		local modifier = caster:FindModifierByName("modifier_alchemist_volatile_brew_charge")
		modifier:Destroy()
		local charge = modifier:GetStackCount() / 100
		
		local projectileID = self:FireTrackingProjectile("particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile.vpcf", self:GetCursorTarget(), 900, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_3, false, true, 300)
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
	local bonus_physical_damage = self:GetSpecialValueFor("self.bonus_physical_damage")
	
	local radius = self:GetSpecialValueFor("radius")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
		if enemy ~= target then
			enemy:AddNewModifier( caster, self, "modifier_alchemist_volatile_brew_debuff", {duration = stun} )
			self:DealDamage( caster, enemy, damage )
		end
	end
	local buffDuration = self:GetSpecialValueFor("buff_duration") * stun
	if target:IsSameTeam( caster ) and buffDuration > 0 then
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
			ally:AddNewModifier( caster, self, "modifier_alchemist_volatile_brew_panacea", {duration = buffDuration} ):SetStackCount( math.ceil(strength * 100) )
		end
	else
		enemy:AddNewModifier( caster, self, "modifier_alchemist_volatile_brew_debuff", {duration = stun} )
		self:DealDamage( caster, target, damage )
	end
	
	ParticleManager:FireParticle( "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_explosion.vpcf", PATTACH_POINT_FOLLOW, target )
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
		ParticleManager:FireParticle( "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), {[1] = Vector( 8, seconds, 0 ), [2] = Vector( len, 0, 0 )} )
	end
end

function modifier_alchemist_volatile_brew_charge:OnDestroy()
	if IsServer() then
		StopSoundOn( "Hero_Alchemist.UnstableConcoction.Fuse", self:GetParent() )
		if ( self:GetRemainingTime() <= 0 or not self:GetParent():IsAlive() ) then
			self:GetAbility():UnstableConcoctionEffect( self:GetParent(), self:GetStackCount()/100 )
		end
		self._lastBrewTime = self:GetElapedTime()
	end
end

modifier_alchemist_volatile_brew_panacea = class({})
LinkLuaModifier( "modifier_alchemist_volatile_brew_panacea", "heroes/hero_alchemist/alchemist_volatile_brew", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_volatile_brew_panacea:OnCreated()
	self:OnRefresh()
	if IsServer() then self:SetHasCustomTransmitterData(true) end
end
function modifier_alchemist_volatile_brew_panacea:OnRefresh()
	self.barrier =  math.floor( math.max( self:GetSpecialValueFor("max_damage") * self:GetStackCount() / 100, self:GetSpecialValueFor("min_damage") ) * self:GetSpecialValueFor("barrier") / 100 )
	self.bonus_attack_speed = self:GetSpecialValueFor("bonus_attack_speed")
	if IsServer() then
		self:SendBuffRefreshToClients()
	end
end
function modifier_alchemist_volatile_brew_panacea:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_alchemist_volatile_brew_panacea:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed
end

function modifier_alchemist_volatile_brew_panacea:GetModifierIncomingDamageConstant(params)
	if IsServer() then
		local barrier = math.min( self.barrier, math.max( self.barrier, params.damage ) )
		self.barrier = math.max( 0, self.barrier - params.damage )
		if self.barrier > 0 then
			self:SendBuffRefreshToClients()
		else
			self:Destroy()
		end
		return -barrier
	else
		return self.barrier
	end
end

function modifier_alchemist_volatile_brew_panacea:AddCustomTransmitterData()
	return {
		barrier = self.barrier
	}
end
function modifier_alchemist_volatile_brew_panacea:HandleCustomTransmitterData(data)
	self.barrier = data.barrier
end

modifier_alchemist_volatile_brew_debuff = class({})
LinkLuaModifier( "modifier_alchemist_volatile_brew_debuff", "heroes/hero_alchemist/alchemist_volatile_brew", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_volatile_brew_debuff:OnCreated()
	self.bonus_physical_damage = self:GetSpecialValueFor("bonus_physical_damage")
	self.freezes_cooldowns = self:GetSpecialValueFor("freezes_cooldowns")
	if IsClient() then return end
	local parent = self:GetParent()
	for i = 0, parent:GetAbilityCount() do
		local ability = parent:GetAbilityByIndex( i )
		if ability then
			ability:SetFrozenCooldown( true )
		end
	end
end

function modifier_alchemist_volatile_brew_debuff:OnDestroy()
	if IsClient() then return end
	local parent = self:GetParent()
	for i = 0, parent:GetAbilityCount() do
		local ability = parent:GetAbilityByIndex( i )
		if ability then
			ability:SetFrozenCooldown( false )
		end
	end
end

function modifier_alchemist_volatile_brew_debuff:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	if self.freezes_cooldowns > 0 then
		state[MODIFIER_STATE_FROZEN] = true
	end
	return state
end

function modifier_alchemist_volatile_brew_debuff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_alchemist_volatile_brew_debuff:OnAttackLanded( params )
	if self.bonus_physical_damage <= 0 then return end
	if params.target == self:GetParent() and params.attacker:IsRealHero() then
		self:GetAbility():DealDamage( self:GetCaster(), params.target, self.bonus_physical_damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE )
	end
end

function modifier_alchemist_volatile_brew_debuff:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf"
end

function modifier_alchemist_volatile_brew_debuff:StatusEffectPriority()
	return 20
end

function modifier_alchemist_volatile_brew_debuff:IsHidden()
	return true
end

function modifier_alchemist_volatile_brew_debuff:IsStunDebuff()
	return true
end
