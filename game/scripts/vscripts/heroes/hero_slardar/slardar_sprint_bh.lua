slardar_sprint_bh = class({})

function slardar_sprint_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	caster:AddNewModifier( caster, self, "modifier_slardar_sprint_bh", {duration = duration} )
	caster:EmitSound("Hero_Slardar.Sprint")
end

modifier_slardar_sprint_bh = class({})
LinkLuaModifier( "modifier_slardar_sprint_bh", "heroes/hero_slardar/slardar_sprint_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_slardar_sprint_bh:OnCreated()
	self.movespeed = self:GetTalentSpecialValueFor("bonus_speed")
	self.red = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_sprint_1")
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_sprint_2")
	self.dmg = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_sprint_2", "value2")
	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_slardar_sprint_bh:OnRefresh()
	self.movespeed = self:GetTalentSpecialValueFor("bonus_speed")
	self.red = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_sprint_1")
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_sprint_2")
	self.dmg = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_sprint_2", "value2")
	self:GetParent():HookOutModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_slardar_sprint_bh:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }
    return funcs
end

function modifier_slardar_sprint_bh:GetModifierMoveSpeedBonus_Percentage()
	local ms = self.movespeed
	if self:GetCaster():InWater() then ms = ms * 2 end
    return ms
end

function modifier_slardar_sprint_bh:GetMoveSpeedLimitBonus()
	if self:GetCaster():InWater() then return 99999 end
end

function modifier_slardar_sprint_bh:GetModifierIncomingDamage_Percentage()
	if self.red <= 0 then return end
	local red = self.red
	if self:GetCaster():InWater() then red = red * 2 end
    return red
end

function modifier_slardar_sprint_bh:GetModifierAttackSpeedBonus_Constant()
	if self.as <= 0 then return end
	local as = self.as
	if self:GetCaster():InWater() then as = as * 2 end
    return as
end


function modifier_slardar_sprint_bh:GetModifierBaseDamageOutgoing_Percentage()
	if self.dmg <= 0 then return end
	local dmg = self.dmg
	if self:GetCaster():InWater() then dmg = dmg * 2 end
    return dmg
end

function modifier_slardar_sprint_bh:GetActivityTranslationModifiers()
	return "sprint"
end

function modifier_slardar_sprint_bh:GetEffectName()
	return "particles/units/heroes/hero_slardar/slardar_sprint.vpcf"
end