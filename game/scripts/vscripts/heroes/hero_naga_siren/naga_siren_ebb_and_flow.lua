naga_siren_ebb_and_flow = class({})

function naga_siren_ebb_and_flow:GetIntrinsicModifierName()
	return "modifier_naga_siren_ebb_and_flow_handler"
end

modifier_naga_siren_ebb_and_flow_handler = class({})
LinkLuaModifier("modifier_naga_siren_ebb_and_flow_handler", "heroes/hero_naga_siren/naga_siren_ebb_and_flow", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_ebb_and_flow_handler:OnCreated()
	self.duration = self:GetTalentSpecialValueFor("duration")
end

function modifier_naga_siren_ebb_and_flow_handler:OnRefresh()
	self.duration = self:GetTalentSpecialValueFor("duration")
end

function modifier_naga_siren_ebb_and_flow_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_naga_siren_ebb_and_flow_handler:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		self:AddIndependentStack(self.duration)
	end
end

function modifier_naga_siren_ebb_and_flow_handler:IsAura()
	return true
end

function modifier_naga_siren_ebb_and_flow_handler:GetModifierAura()
	return "modifier_naga_siren_ebb_and_flow_buff"
end

function modifier_naga_siren_ebb_and_flow_handler:GetAuraRadius()
	local radius = 0
	if self:GetCaster():HasScepter() then radius = self:GetTalentSpecialValueFor("scepter_radius") end
	return radius
end

function modifier_naga_siren_ebb_and_flow_handler:GetAuraDuration()
	return 0.5
end

function modifier_naga_siren_ebb_and_flow_handler:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_naga_siren_ebb_and_flow_handler:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_naga_siren_ebb_and_flow_handler:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_naga_siren_ebb_and_flow_handler:IsHidden()
	return true
end

modifier_naga_siren_ebb_and_flow_buff = class({})
LinkLuaModifier("modifier_naga_siren_ebb_and_flow_buff", "heroes/hero_naga_siren/naga_siren_ebb_and_flow", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_ebb_and_flow_buff:OnCreated()
	self.hp_regen = self:GetTalentSpecialValueFor("health_regeneration")
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function modifier_naga_siren_ebb_and_flow_buff:OnRefresh()
	self.hp_regen = self:GetTalentSpecialValueFor("health_regeneration")
end

function modifier_naga_siren_ebb_and_flow_buff:OnIntervalThink()
	self:SetStackCount( self:GetCaster():GetModifierStackCount( "modifier_naga_siren_ebb_and_flow_handler", self:GetCaster() ) )
end

function modifier_naga_siren_ebb_and_flow_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_naga_siren_ebb_and_flow_buff:GetModifierHealthRegenPercentage()
	return self.hp_regen * self:GetStackCount()
end