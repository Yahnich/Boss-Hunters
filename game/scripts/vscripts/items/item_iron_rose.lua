item_iron_rose = class({})
LinkLuaModifier( "modifier_item_iron_rose_passive", "items/item_iron_rose.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_iron_rose_aura", "items/item_iron_rose.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_iron_rose:GetIntrinsicModifierName()
	return "modifier_item_iron_rose_passive"
end

modifier_item_iron_rose_passive = class({})
function modifier_item_iron_rose_passive:OnCreated(table)
	self.mana = self:GetSpecialValueFor("bonus_mana")
	self.int = self:GetSpecialValueFor("bonus_int")
	self.str = self:GetSpecialValueFor("bonus_str")
end

function modifier_item_iron_rose_passive:OnRefresh(table)
	self.mana = self:GetSpecialValueFor("bonus_mana")
	self.int = self:GetSpecialValueFor("bonus_int")
	self.str = self:GetSpecialValueFor("bonus_str")
end

function modifier_item_iron_rose_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_iron_rose_passive:GetModifierManaBonus()
	return self.mana
end

function modifier_item_iron_rose_passive:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_item_iron_rose_passive:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_item_iron_rose_passive:IsAura()
    return true
end

function modifier_item_iron_rose_passive:GetAuraDuration()
    return 0.5
end

function modifier_item_iron_rose_passive:GetAuraRadius()
    return self:GetSpecialValueFor("radius")
end

function modifier_item_iron_rose_passive:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_item_iron_rose_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_iron_rose_passive:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_item_iron_rose_passive:GetModifierAura()
    return "modifier_item_iron_rose_aura"
end

function modifier_item_iron_rose_passive:IsAuraActiveOnDeath()
    return false
end

function modifier_item_iron_rose_passive:IsHidden()
	return true
end

modifier_item_iron_rose_passive = class({})
function modifier_item_iron_rose_passive:OnCreated(table)
	self.reflect = self:GetSpecialValueFor("reflect")
end

function modifier_item_iron_rose_passive:OnRefresh(table)
	self.reflect = self:GetSpecialValueFor("reflect")
end

function modifier_item_iron_rose_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_iron_rose_passive:OnTakeDamage(params)
	local hero = self:GetParent()
    local dmg = params.original_damage
	local dmgtype = params.damage_type
	local attacker = params.attacker
    local reflectpct = self.reflect / 100

	if attacker:GetTeamNumber() ~= hero:GetTeamNumber() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) then
		if params.unit == hero then
			dmg = dmg * reflectpct
			self:GetAbility():DealDamage( hero, attacker, dmg, {damage_type = dmgtype, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION} )
		end
	end
end