modifier_boss_evasion = class({})

function modifier_boss_evasion:OnCreated()
	if IsServer() then
		self.critDelay = math.floor( 100 / ( 5 * GameRules:GetGameDifficulty() ) + 0.5 )
		self.enrageTimer = 310 - GameRules:GetGameDifficulty() * 20 - HeroList:GetActiveHeroCount() * 10
		self:StartIntervalThink( 0.5 )
	end
end

function modifier_boss_evasion:OnIntervalThink()
	self:StartIntervalThink( 0.5 )
	self.enrageTimer = self.enrageTimer - 0.5
	if self.enrageTimer <= 0 then
		self:StartIntervalThink(-1)
		self:GetParent():EmitSound("hero_bloodseeker.rupture.cast")
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss_hard_enrage", {})
	end
	self.hasBeenDelayed = false
end

function modifier_boss_evasion:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
    }

    return funcs
end

function modifier_boss_evasion:CheckState()
	if self.checkMiss then
		return {[MODIFIER_STATE_CANNOT_MISS] = true}
	end
end

function modifier_boss_evasion:OnTakeDamage( params )
	if not self.hasBeenDelayed then
		if params.unit:IsRealHero() and not params.attacker:IsSameTeam( params.unit ) then
			if params.damage > params.unit:GetHealth() then
				self:StartIntervalThink( 8 )
				self.hasBeenDelayed = true
				self.enrageTimer = 310 - GameRules:GetGameDifficulty() * 20 - HeroList:GetActiveHeroCount() * 10
				self:GetParent():RemoveModifierByName("modifier_boss_hard_enrage") 
			else
				self:StartIntervalThink( 1 )
				self.hasBeenDelayed = true
			end
		elseif params.attacker:IsRealHero() and not params.attacker:IsSameTeam( params.unit ) and CalculateDistance( params.attacker, params.unit ) < params.unit:GetIdealSpeed() * 1.5 then
			self:StartIntervalThink( 1 )
			self.hasBeenDelayed = true
		end
	end
end

function modifier_boss_evasion:OnAttackLanded( params )
	if params.attacker == self:GetParent() then
		self.checkMiss = false
	end
end

function modifier_boss_evasion:GetModifierPreAttack_CriticalStrike( params )
	self.ticks = (self.ticks or 0) + 1
	if self.ticks >= self.critDelay and self:RollPRNG( 50 ) then	
		self.ticks = 0
		local critDamage = 165 + 5 * self:GetStackCount()
		local critMax = 200 + 5 * self:GetStackCount()
		if self:GetParent():HasModifier("modifier_elite_assassin") then
			critDamage = 220 + 7.5 * self:GetStackCount()
			critMax = 300 + 5 * self:GetStackCount()
		end
		if self:GetParent():IsRangedAttacker() then
			critDamage = critDamage - 25
			critMax = critMax - 25
		end
		self.checkMiss = true
		return math.min( critMax, critDamage )
	end
end

function modifier_boss_evasion:GetModifierMagicalResistanceBonus( params )
	return math.min( 50, self:GetStackCount() * 3.5 )
end

function modifier_boss_evasion:IsHidden()
    return true
end

function modifier_boss_evasion:IsPurgable()
	return false
end