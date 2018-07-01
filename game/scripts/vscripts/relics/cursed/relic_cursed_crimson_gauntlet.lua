relic_cursed_crimson_gauntlet = class(relicBaseClass)

function relic_cursed_crimson_gauntlet:OnCreated()
	if IsServer() then
		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.75 )
		self:GetParent():CalculateStatBonus()
		self:StartIntervalThink(0.33)
	end
end

function relic_cursed_crimson_gauntlet:OnIntervalThink()
	if IsServer() then
		local hpPct = self:GetParent():GetHealth() / self:GetParent():GetMaxHealth()

		self:SetStackCount( 0 )
		self:GetParent():CalculateStatBonus()
		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.75 )
		self:GetParent():CalculateStatBonus()
		self:GetParent():SetHealth( hpPct * self:GetParent():GetMaxHealth() )
	end
end

function relic_cursed_crimson_gauntlet:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_TARGET_CRITICALSTRIKE, 
			MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function relic_cursed_crimson_gauntlet:GetModifierPreAttack_Target_CriticalStrike()
	if self:RollPRNG( 25 ) and not self:GetParent():HasModifier("relic_unique_ritual_candle") then
		return 300
	end
end

function relic_cursed_crimson_gauntlet:GetModifierExtraHealthBonus()
	return self:GetStackCount()
end
