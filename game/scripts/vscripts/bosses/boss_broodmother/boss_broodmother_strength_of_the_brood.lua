boss_broodmother_strength_of_the_brood = class({})

function boss_broodmother_strength_of_the_brood:GetIntrinsicModifierName()
	return "modifier_boss_broodmother_strength_of_the_brood_passive"
end

modifier_boss_broodmother_strength_of_the_brood_passive = class({})
LinkLuaModifier("modifier_boss_broodmother_strength_of_the_brood_passive", "bosses/boss_broodmother/boss_broodmother_strength_of_the_brood", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_broodmother_strength_of_the_brood_passive:OnCreated()
	self.bonusdamage = self:GetSpecialValueFor("str_per_unit")
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_boss_broodmother_strength_of_the_brood_passive:OnRefresh()
	self.bonusdamage = self:GetSpecialValueFor("str_per_unit")
	self.radius = self:GetSpecialValueFor("aura_radius")
end

function modifier_boss_broodmother_strength_of_the_brood_passive:OnIntervalThink()
	local parent = self:GetParent()
	local allies = parent:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.radius )
	self:SetStackCount( #allies - 1 )
end

function modifier_boss_broodmother_strength_of_the_brood_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end

function modifier_boss_broodmother_strength_of_the_brood_passive:GetModifierDamageOutgoing_Percentage(params)
	if self:GetParent():PassivesDisabled() then return end
	return self.bonusdamage * (self:GetStackCount() - 1)
end
