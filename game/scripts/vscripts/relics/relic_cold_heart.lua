relic_cold_heart = class(relicBaseClass)

function relic_cold_heart:OnCreated()
	if IsServer() then
		LinkLuaModifier( "modifier_relic_cold_heart", "relics/unique/relic_cold_heart", LUA_MODIFIER_MOTION_NONE)
		self:StartIntervalThink(0.03)
	end
end

function relic_cold_heart:OnIntervalThink()
	local parent = self:GetParent()
	for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), 900 ) ) do
		enemy:AddNewModifier(enemy, self:GetAbility(), "modifier_relic_cold_heart", {duration = 0.5})
	end
end

modifier_relic_cold_heart = class({})
function modifier_relic_cold_heart:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, }
end

function modifier_relic_cold_heart:GetModifierMoveSpeedBonus_Percentage()
	return -20
end

function modifier_relic_cold_heart:GetModifierAttackSpeedBonus()
	return -50
end

function modifier_relic_cold_heart:IsHidden() return false end