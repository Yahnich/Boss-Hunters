item_cloak_of_the_hunter = class({})
LinkLuaModifier( "modifier_item_cloak_of_the_hunter_passive", "items/item_cloak_of_the_hunter.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_cloak_of_the_hunter_passive_aura", "items/item_cloak_of_the_hunter.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_cloak_of_the_hunter_active", "items/item_cloak_of_the_hunter.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_cloak_of_the_hunter:GetIntrinsicModifierName()
	return "modifier_item_cloak_of_the_hunter_passive"
end

function item_cloak_of_the_hunter:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("DOTA_Item.ShadowAmulet.Activate", caster)

	local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	for _,ally in pairs(allies) do
		ally:AddNewModifier(caster, self, "modifier_item_cloak_of_the_hunter_active", {Duration = self:GetSpecialValueFor("invis_duration")})
		ally:SetThreat(0)
	end
end

modifier_item_cloak_of_the_hunter_passive = class({})
function modifier_item_cloak_of_the_hunter_passive:OnCreated()
	self.bonus_all = self:GetSpecialValueFor("bonus_all")
	self.bonus_attack_speed = self:GetSpecialValueFor("bonus_attack_speed")
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_cloak_of_the_hunter_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_cloak_of_the_hunter_passive:GetModifierBonusStats_Strength()
	return self.bonus_all
end

function modifier_item_cloak_of_the_hunter_passive:GetModifierBonusStats_Agility()
	return self.bonus_all
end

function modifier_item_cloak_of_the_hunter_passive:GetModifierBonusStats_Intellect()
	return self.bonus_all
end

function modifier_item_cloak_of_the_hunter_passive:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed
end

function modifier_item_cloak_of_the_hunter_passive:IsAura()
	return true
end

function modifier_item_cloak_of_the_hunter_passive:GetModifierAura()
	return "modifier_item_cloak_of_the_hunter_passive_aura"
end

function modifier_item_cloak_of_the_hunter_passive:GetAuraRadius()
	return self.radius
end

function modifier_item_cloak_of_the_hunter_passive:GetAuraDuration()
	return 0.5
end

function modifier_item_cloak_of_the_hunter_passive:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_cloak_of_the_hunter_passive:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_ALL
end

function modifier_item_cloak_of_the_hunter_passive:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_cloak_of_the_hunter_passive:IsHidden()
	return true
end

function modifier_item_cloak_of_the_hunter_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_item_cloak_of_the_hunter_passive_aura = class({})
function modifier_item_cloak_of_the_hunter_passive_aura:GetTextureName()
	return "ancient_janggo"
end

function modifier_item_cloak_of_the_hunter_passive_aura:OnCreated()
	self.attackspeed = self:GetSpecialValueFor("bonus_aura_as")
	self.accuracy = self:GetSpecialValueFor("bonus_accuracy")
end

function modifier_item_cloak_of_the_hunter_passive_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_cloak_of_the_hunter_passive_aura:GetAccuracy()
	return self.accuracy
end

function modifier_item_cloak_of_the_hunter_passive_aura:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

modifier_item_cloak_of_the_hunter_active = class({})

function modifier_item_cloak_of_the_hunter_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }

    return funcs
end

function modifier_item_cloak_of_the_hunter_active:CheckState()
	local state = { [MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	
	return state
end

function modifier_item_cloak_of_the_hunter_active:OnAbilityExecuted(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_item_cloak_of_the_hunter_active:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_item_cloak_of_the_hunter_active:GetModifierInvisibilityLevel()
    return 1
end