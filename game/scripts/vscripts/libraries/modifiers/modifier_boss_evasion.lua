modifier_boss_evasion = class({})

function modifier_boss_evasion:OnCreated()
	if IsServer() then
		self.critDelay = math.floor( 100 / ( 5 * GameRules:GetGameDifficulty() ) + 0.5 )
		self:StartIntervalThink(310 - GameRules:GetGameDifficulty() * 20 - HeroList:GetActiveHeroCount() * 10 )
	end
end

function modifier_boss_evasion:OnIntervalThink()
	self:StartIntervalThink(-1)
	self:GetParent():EmitSound("hero_bloodseeker.rupture.cast")
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss_hard_enrage", {})
end

function modifier_boss_evasion:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }

    return funcs
end


function modifier_boss_evasion:GetModifierPreAttack_CriticalStrike( params )
	self.ticks = (self.ticks or 0) + 1
	if self.ticks >= self.critDelay then	
		self.ticks = 0
		if self:GetParent():HasModifier("modifier_elite_assassin") then
			return math.min( 300, 220 + 7.5 * self:GetStackCount() )
		else
			return math.min( 200, 165 + 5 * self:GetStackCount() )
		end
	end
end

function modifier_boss_evasion:GetModifierEvasion_Constant()
	local raidsBeaten = self:GetStackCount() % 100
	local zonesBeaten = math.floor( raidsBeaten / 2 )
	local raidTier = (raidsBeaten % 2) + 1
	local ascensions = math.floor( self:GetStackCount() / 100 )
	return math.min( 80, 10 + (2.5 * raidsBeaten) + (5 * zonesBeaten) + (7.5 * math.floor(zonesBeaten / 2) ) + 10 * math.max(0, ascensions - 1) )
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