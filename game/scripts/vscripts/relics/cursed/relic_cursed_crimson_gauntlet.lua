relic_cursed_crimson_gauntlet = class(relicBaseClass)

function relic_cursed_crimson_gauntlet:OnCreated()
	if IsServer() then
		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.75 )
		self:GetParent():CalculateStatBonus()
		self:StartIntervalThink(0.33)
		LinkLuaModifier( "modifier_relic_cursed_crimson_gauntlet", "relics/cursed/relic_cursed_crimson_gauntlet", LUA_MODIFIER_MOTION_NONE)
	end
end

function relic_cursed_crimson_gauntlet:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), 900 ) ) do
			enemy:AddNewModifier(parent, self:GetAbility(), "modifier_relic_cursed_crimson_gauntlet", {duration = 0.5})
		end
	
		local hpPct = self:GetParent():GetHealth() / self:GetParent():GetMaxHealth()

		self:SetStackCount( 0 )
		self:GetParent():CalculateStatBonus()
		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.75 )
		self:GetParent():CalculateStatBonus()
		self:GetParent():SetHealth( hpPct * self:GetParent():GetMaxHealth() )
	end
end

function relic_cursed_crimson_gauntlet:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function relic_cursed_crimson_gauntlet:GetModifierExtraHealthBonus()
	return self:GetStackCount()
end

modifier_relic_cursed_crimson_gauntlet = class({})
function modifier_relic_cursed_crimson_gauntlet:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_relic_cursed_crimson_gauntlet:GetModifierPreAttack_CriticalStrike(params)
	if params.target == self:GetCaster() and RollPercentage(25) then
		return 300
	end
end

function modifier_relic_cursed_crimson_gauntlet:IsHidden() return true end