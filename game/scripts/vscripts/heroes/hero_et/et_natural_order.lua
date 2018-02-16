et_natural_order = class({})
LinkLuaModifier( "modifier_et_natural_order", "heroes/hero_et/et_natural_order.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_et_natural_order_enemy", "heroes/hero_et/et_natural_order.lua",LUA_MODIFIER_MOTION_NONE )

function et_natural_order:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_elder_spirit") or self:GetCaster():HasModifier("modifier_elder_spirit_check_out") then
		return "elder_titan_natural_order_spirit"
	end

	return "elder_titan_natural_order"
end

function et_natural_order:GetIntrinsicModifierName()
    return "modifier_et_natural_order"
end

modifier_et_natural_order = class({})
function modifier_et_natural_order:IsAura()
    return true
end

function modifier_et_natural_order:GetAuraDuration()
    return 0.5
end

function modifier_et_natural_order:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_et_natural_order:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_et_natural_order:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_et_natural_order:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_et_natural_order:GetModifierAura()
    return "modifier_et_natural_order_enemy"
end

function modifier_et_natural_order:IsAuraActiveOnDeath()
    return false
end

function modifier_et_natural_order:IsHidden()
    return true
end

function modifier_et_natural_order:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
    return funcs
end

function modifier_et_natural_order:GetModifierPhysicalArmorBonus()
	local bonus = 0
	if self:GetCaster():HasScepter() then
		bonus = self:GetCaster():GetPhysicalArmorBaseValue() * (-self:GetTalentSpecialValueFor("reduc")) / 100
	end
	return bonus
end

function modifier_et_natural_order:GetModifierMagicalResistanceBonus()
	local bonus = 0
	if self:GetCaster():HasScepter() then
		bonus = -self:GetTalentSpecialValueFor("reduc")
	end
	return bonus
end

modifier_et_natural_order_enemy = class({})
function modifier_et_natural_order_enemy:OnCreated(table)
	self.armor = self:GetParent():GetPhysicalArmorValue() + self:GetParent():GetPhysicalArmorValue() * self:GetTalentSpecialValueFor("reduc")/100
end


function modifier_et_natural_order_enemy:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DIRECT_MODIFICATION
    }
    return funcs
end

function modifier_et_natural_order_enemy:GetModifierPhysicalArmorBonus()
	local caster = self:GetCaster()
	local amount = 0

	if not caster:HasModifier("modifier_elder_spirit") then
		if self.armor then
			amount = self.armor * -1
		end
	else
		amount = 0
	end

	return amount
end

function modifier_et_natural_order_enemy:GetModifierMagicalResistanceDirectModification()
	local caster = self:GetCaster()
	local amount = 0

	if not caster:HasModifier("modifier_elder_spirit") then
		if caster:HasModifier("modifier_elder_spirit_check_out") then
			amount = 0
		else
			amount = self:GetTalentSpecialValueFor("reduc")
		end	
	else
		amount = self:GetTalentSpecialValueFor("reduc")
	end

	return amount
end

