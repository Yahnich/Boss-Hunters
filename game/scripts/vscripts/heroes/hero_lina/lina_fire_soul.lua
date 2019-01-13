lina_fire_soul = class({})

function lina_fire_soul:GetIntrinsicModifierName()
    return "modifier_lina_fire_soul_handle"
end

modifier_lina_fire_soul_handle = class({})
LinkLuaModifier( "modifier_lina_fire_soul_handle", "heroes/hero_lina/lina_fire_soul.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_lina_fire_soul_handle:OnCreated()
	self.duration = self:GetTalentSpecialValueFor("stack_duration")
	self.max_stacks = self:GetTalentSpecialValueFor("max_stacks")
end

function modifier_lina_fire_soul_handle:OnRefresh()
	self.duration = self:GetTalentSpecialValueFor("stack_duration")
	self.max_stacks = self:GetTalentSpecialValueFor("max_stacks")
end

function modifier_lina_fire_soul_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }

    return funcs
end

function modifier_lina_fire_soul_handle:OnAbilityExecuted(params)
    if params.unit == self:GetCaster() and params.ability:GetCooldown(-1) > 0 then
        local souls = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_lina_fire_soul", {Duration = self.duration})
		if souls then
			souls:SetStackCount( math.min( (souls:GetStackCount() or 0) + 1, self.max_stacks ) )
		end
    end
end

function modifier_lina_fire_soul_handle:IsHidden()
    return true
end

modifier_lina_fire_soul = class({})
LinkLuaModifier( "modifier_lina_fire_soul", "heroes/hero_lina/lina_fire_soul.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_lina_fire_soul:OnCreated(kv)
    self.as = self:GetTalentSpecialValueFor("attack_speed_bonus")
	self.ms = self:GetTalentSpecialValueFor("move_speed_bonus")
	self.dmg = TernaryOperator( self:GetTalentSpecialValueFor("scepter_bonus_damage"), self:GetCaster():HasScepter(), 0 )
	self.amp = TernaryOperator( self:GetTalentSpecialValueFor("scepter_spell_amp"), self:GetCaster():HasScepter(), 0 )
end

function modifier_lina_fire_soul:OnRefresh(kv)
    self.as = self:GetTalentSpecialValueFor("attack_speed_bonus")
	self.ms = self:GetTalentSpecialValueFor("move_speed_bonus")
	self.dmg = TernaryOperator( self:GetTalentSpecialValueFor("scepter_bonus_damage"), self:GetCaster():HasScepter(), 0 )
	self.amp = TernaryOperator( self:GetTalentSpecialValueFor("scepter_spell_amp"), self:GetCaster():HasScepter(), 0 )
end

function modifier_lina_fire_soul:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_lina_fire_soul:GetModifierSpellAmplify_Percentage()
    return self.dmg * self:GetStackCount()
end

function modifier_lina_fire_soul:GetModifierBaseDamageOutgoing_Percentage()
    return self.amp * self:GetStackCount()
end

function modifier_lina_fire_soul:GetModifierAttackSpeedBonus()
    return self.as * self:GetStackCount()
end

function modifier_lina_fire_soul:GetModifierMoveSpeedBonus_Percentage()
    return self.ms * self:GetStackCount()
end