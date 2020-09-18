pango_swift_dash = class({})
LinkLuaModifier( "modifier_pango_swift_dash_as", "heroes/hero_pango/pango_swift_dash.lua" ,LUA_MODIFIER_MOTION_NONE )

function pango_swift_dash:IsStealable()
    return true
end

function pango_swift_dash:IsHiddenWhenStolen()
    return false
end

function pango_swift_dash:OnSpellStart()
	EmitSoundOn("Hero_Pangolier.Swashbuckle.Cast", self:GetCaster())
	EmitSoundOn("Hero_Pangolier.Swashbuckle.Layer", self:GetCaster())
	
	local distance = CalculateDistance(self:GetCursorPosition(), self:GetCaster():GetAbsOrigin())
	local speed = self:GetTalentSpecialValueFor("speed")
	local duration = distance / speed
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pango_swift_dash", {duration = duration})

    ProjectileManager:ProjectileDodge(self:GetCaster())
end

modifier_pango_swift_dash_as = class({})
function modifier_pango_swift_dash_as:OnCreated(table)
	self.bonus_as = self:GetCaster():FindTalentValue("special_bonus_unique_pango_swift_dash_2")
end

function modifier_pango_swift_dash_as:OnRefresh(table)
	self.bonus_as = self:GetCaster():FindTalentValue("special_bonus_unique_pango_swift_dash_2")
end

function modifier_pango_swift_dash_as:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_pango_swift_dash_as:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_pango_swift_dash_as:IsDebuff()
	return false
end