relic_unique_hestias_hearth = class(relicBaseClass)

function relic_unique_hestias_hearth:OnCreated()
	if IsServer() then
		LinkLuaModifier( "modifier_relic_unique_hestias_hearth", "relics/unique/relic_unique_hestias_hearth", LUA_MODIFIER_MOTION_NONE)
		self:StartIntervalThink(0.03)
	end
end

function relic_unique_hestias_hearth:OnIntervalThink()
	local parent = self:GetParent()
	for _, ally in ipairs( parent:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), 900 ) ) do
		ally:AddNewModifier(ally, self:GetAbility(), "modifier_relic_unique_hestias_hearth", {duration = 0.5})
	end
end

modifier_relic_unique_hestias_hearth = class(relicBaseClass)
function modifier_relic_unique_hestias_hearth:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_relic_unique_hestias_hearth:GetModifierConstantHealthRegen()
	return 10
end

function modifier_relic_unique_hestias_hearth:IsHidden() return false end