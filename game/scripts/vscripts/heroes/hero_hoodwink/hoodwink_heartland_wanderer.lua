hoodwink_heartland_wanderer = class({})

function hoodwink_heartland_wanderer:GetIntrinsicModifierName()
	return "modifier_hoodwink_heartland_wanderer_passive"
end

modifier_hoodwink_heartland_wanderer_passive = class({})
LinkLuaModifier("modifier_hoodwink_heartland_wanderer_passive", "heroes/hero_hoodwink/hoodwink_heartland_wanderer", LUA_MODIFIER_MOTION_NONE)

function modifier_hoodwink_heartland_wanderer_passive:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink( 0.25 )
	end
end

function modifier_hoodwink_heartland_wanderer_passive:OnRefresh()
	self.evasion = self:GetSpecialValueFor("evasion")
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_hoodwink_heartland_wanderer_passive:OnIntervalThink()
	if GridNav:IsNearbyTree( self:GetCaster():GetAbsOrigin(), self.radius, true ) then
		self:SetStackCount( 0 )
	else
		self:SetStackCount( 1 )
	end
end

function modifier_hoodwink_heartland_wanderer_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_hoodwink_heartland_wanderer_passive:GetModifierEvasion_Constant()
	if self:GetStackCount() == 0 then
		return self.evasion
	end
end

function modifier_hoodwink_heartland_wanderer_passive:IsHidden()
	return self:GetStackCount() ~= 0
end