item_mantle_of_the_fallen = class({})

function item_mantle_of_the_fallen:GetIntrinsicModifierName()
	return "modifier_item_mantle_of_the_fallen_stats"
end

modifier_item_mantle_of_the_fallen_stats = class({})
LinkLuaModifier( "modifier_item_mantle_of_the_fallen_stats", "items/item_mantle_of_the_fallen.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_mantle_of_the_fallen_stats:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_mantle_of_the_fallen_stats:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_mantle_of_the_fallen_stats:OnDestroy()
	if IsServer() then
		for _, ally in ipairs( self:GetParent():FindFriendlyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
			ally:RemoveModifierByName("modifier_item_mantle_of_the_fallen_aura")
		end
	end
end

function modifier_item_mantle_of_the_fallen_stats:IsAura()
	return true
end

function modifier_item_mantle_of_the_fallen_stats:GetModifierAura()
	return "modifier_item_mantle_of_the_fallen_aura"
end

function modifier_item_mantle_of_the_fallen_stats:GetAuraRadius()
	return self.radius
end

function modifier_item_mantle_of_the_fallen_stats:GetAuraDuration()
	return 0.5
end

function modifier_item_mantle_of_the_fallen_stats:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_mantle_of_the_fallen_stats:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_mantle_of_the_fallen_stats:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_mantle_of_the_fallen_stats:IsHidden()
	return true
end

modifier_item_mantle_of_the_fallen_aura = class({})
LinkLuaModifier( "modifier_item_mantle_of_the_fallen_aura", "items/item_mantle_of_the_fallen.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_mantle_of_the_fallen_aura:GetTextureName()
	return "custom/mantle_of_the_fallen"
end

function modifier_item_mantle_of_the_fallen_aura:OnCreated()
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
	-- if self:GetParent():IsRangedAttacker() then
		-- self.lifesteal = self:GetSpecialValueFor("vampiric_aura_ranged") / 100
	-- end
end

function modifier_item_mantle_of_the_fallen_aura:OnRefresh()
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
	-- if self:GetParent():IsRangedAttacker() then
		-- self.lifesteal = self:GetSpecialValueFor("vampiric_aura_ranged") / 100
	-- end
end

function modifier_item_mantle_of_the_fallen_aura:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_mantle_of_the_fallen_aura:OnTakeDamage(params)
	if params.attacker == self:GetParent() and not params.inflictor then
		local flHeal = params.damage * self.lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end