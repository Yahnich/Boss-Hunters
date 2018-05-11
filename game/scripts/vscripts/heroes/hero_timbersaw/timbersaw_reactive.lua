timbersaw_reactive = class({})
LinkLuaModifier( "modifier_timbersaw_reactive_handle", "heroes/hero_timbersaw/timbersaw_reactive.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_timbersaw_reactive", "heroes/hero_timbersaw/timbersaw_reactive.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_timbersaw_reactive_mr", "heroes/hero_timbersaw/timbersaw_reactive.lua" ,LUA_MODIFIER_MOTION_NONE )

function timbersaw_reactive:GetIntrinsicModifierName()
    return "modifier_timbersaw_reactive_handle"
end

function timbersaw_reactive:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("stack_duration")
	local maxStacks = self:GetTalentSpecialValueFor("stack_limit")
	for i = 1, maxStacks do
		caster:AddNewModifier(caster, self, "modifier_timbersaw_reactive", {Duration = duration}):AddIndependentStack(duration, maxStacks)
		if caster:HasTalent("special_bonus_unique_timbersaw_reactive_2") then
            caster:AddNewModifier(caster, self, "modifier_timbersaw_reactive_mr", {Duration = duration}):AddIndependentStack(duration, maxStacks)
        end
	end
end

modifier_timbersaw_reactive_handle = class({})

function modifier_timbersaw_reactive_handle:OnCreated()
	self.duration = self:GetTalentSpecialValueFor("stack_duration")
	self.maxStacks = self:GetTalentSpecialValueFor("stack_limit")
end

function modifier_timbersaw_reactive_handle:OnRefresh()
	self.duration = self:GetTalentSpecialValueFor("stack_duration")
	self.maxStacks = self:GetTalentSpecialValueFor("stack_limit")
end

function modifier_timbersaw_reactive_handle:DeclareFunctions()
    local funcs = { MODIFIER_EVENT_ON_TAKEDAMAGE }
    return funcs
end

function modifier_timbersaw_reactive_handle:OnTakeDamage(params)
    local caster = self:GetCaster()
    if params.unit == caster then
        caster:AddNewModifier(caster, self:GetAbility(), "modifier_timbersaw_reactive", {Duration = self.duration}):AddIndependentStack(self.duration, self.maxStacks)
        if caster:HasTalent("special_bonus_unique_timbersaw_reactive_2") and params.damage_type == DAMAGE_TYPE_MAGICAL then
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_timbersaw_reactive_mr", {Duration = self.duration}):AddIndependentStack(self.duration, self.maxStacks)
        end
    end
end

function modifier_timbersaw_reactive_handle:IsHidden()
    return true
end

modifier_timbersaw_reactive = class({})

function modifier_timbersaw_reactive:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.regen = self:GetTalentSpecialValueFor("bonus_hp_regen")
end

function modifier_timbersaw_reactive:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.regen = self:GetTalentSpecialValueFor("bonus_hp_regen")
end

function modifier_timbersaw_reactive:DeclareFunctions()
    funcs = {   MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT  }
    return funcs
end

function modifier_timbersaw_reactive:GetModifierPhysicalArmorBonus()
    return self.armor * self:GetStackCount()
end

function modifier_timbersaw_reactive:GetModifierConstantHealthRegen()
    return self.regen * self:GetStackCount()
end

function modifier_timbersaw_reactive:IsPurgable()
    return false
end

modifier_timbersaw_reactive_mr = class({})
function modifier_timbersaw_reactive_mr:OnCreated()
	self.mr = self:GetCaster():FindTalentValue("special_bonus_unique_timbersaw_reactive_2")
end

function modifier_timbersaw_reactive_mr:OnRefresh()
	self.mr = self:GetCaster():FindTalentValue("special_bonus_unique_timbersaw_reactive_2")
end

function modifier_timbersaw_reactive_mr:DeclareFunctions()
    funcs = { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
    return funcs
end

function modifier_timbersaw_reactive_mr:GetModifierMagicalResistanceBonus()
    return self.mr * self:GetStackCount()
end

function modifier_timbersaw_reactive_mr:IsPurgable()
    return false
end

function modifier_timbersaw_reactive_mr:GetTexture()
    return "shredder_return_chakram_2"
end