shadow_fiend_dark_lord = class({})

function shadow_fiend_dark_lord:GetIntrinsicModifierName()
	return "modifier_shadow_fiend_dark_lord"
end

modifier_shadow_fiend_dark_lord = class({})
LinkLuaModifier( "modifier_shadow_fiend_dark_lord","heroes/hero_shadow_fiend/shadow_fiend_dark_lord.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_shadow_fiend_dark_lord:OnCreated()
	self:OnRefresh()
end

function modifier_shadow_fiend_dark_lord:OnRefresh()
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_shadow_fiend_dark_lord_1", "radius")
	self.duration = self:GetTalentSpecialValueFor("duration")
	if IsServer() then
		for _, ally in ipairs( self:GetCaster():FindFriendlyUnitsInRadius( self:GetCaster():GetAbsOrigin(), -1 ) ) do
			if ally:HasModifier("modifier_shadow_fiend_dark_lord_aura") then
				ally:RemoveModifierByName("modifier_shadow_fiend_dark_lord_aura")
			end
		end
	end
end

function modifier_shadow_fiend_dark_lord:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_shadow_fiend_dark_lord:OnAttackLanded(params)
	if params.attacker == self:GetCaster() then
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_shadow_fiend_dark_lord_mr", {duration = self.duration})
	end
end


function modifier_shadow_fiend_dark_lord:IsAura()
	return true
end

function modifier_shadow_fiend_dark_lord:GetModifierAura()
	return "modifier_shadow_fiend_dark_lord_aura"
end

function modifier_shadow_fiend_dark_lord:GetAuraRadius()
	return self.radius
end

function modifier_shadow_fiend_dark_lord:GetAuraDuration()
	return 0.5
end

function modifier_shadow_fiend_dark_lord:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_shadow_fiend_dark_lord:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_shadow_fiend_dark_lord:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_shadow_fiend_dark_lord:IsHidden()
	return true
end

modifier_shadow_fiend_dark_lord_aura = class({})
LinkLuaModifier( "modifier_shadow_fiend_dark_lord_aura","heroes/hero_shadow_fiend/shadow_fiend_dark_lord.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_shadow_fiend_dark_lord_aura:OnCreated()
	self:OnRefresh()
end

function modifier_shadow_fiend_dark_lord_aura:OnRefresh()
	self.evasion = self:GetTalentSpecialValueFor("evasion")
	self.movespeed = self:GetCaster():FindTalentValue("special_bonus_unique_shadow_fiend_dark_lord_2")
	self.threat_reduction = self.evasion * self:GetCaster():FindTalentValue("special_bonus_unique_shadow_fiend_dark_lord_2", "value2") * (-1)
end

function modifier_shadow_fiend_dark_lord_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_EVASION_CONSTANT }
end

function modifier_shadow_fiend_dark_lord_aura:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_shadow_fiend_dark_lord_aura:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_shadow_fiend_dark_lord_aura:Bonus_ThreatGain()
	return self.threat_reduction
end
modifier_shadow_fiend_dark_lord_mr = class({})
LinkLuaModifier( "modifier_shadow_fiend_dark_lord_mr","heroes/hero_shadow_fiend/shadow_fiend_dark_lord.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_shadow_fiend_dark_lord_mr:OnCreated()
	self:OnRefresh()
	if IsServer() then
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_fiend/shadow_fiend_dark_lord.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(fx)
	end
end

function modifier_shadow_fiend_dark_lord_mr:OnRefresh()
	self.mr = self:GetTalentSpecialValueFor("mr_reduction")
	if IsServer() then
		self:AddIndependentStack()
	end
end

function modifier_shadow_fiend_dark_lord_mr:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_shadow_fiend_dark_lord_mr:GetModifierMagicalResistanceBonus()
	return self.mr * self:GetStackCount()
end