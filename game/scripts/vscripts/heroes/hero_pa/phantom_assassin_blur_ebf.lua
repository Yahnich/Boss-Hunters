phantom_assassin_blur_ebf = class({})

function phantom_assassin_blur_ebf:GetIntrinsicModifierName()
    return "modifier_phantom_assassin_blur_ebf"
end

LinkLuaModifier( "modifier_phantom_assassin_blur_ebf", "lua_abilities/heroes/phantom_assassin.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_phantom_assassin_blur_ebf = class({})

function modifier_phantom_assassin_blur_ebf:OnCreated()
    self.evasion = self:GetAbility():GetSpecialValueFor("bonus_evasion_tooltip")
    self.evasion_stack = self:GetAbility():GetSpecialValueFor("evasion_stacks")
    self.trueEvasion = self:GetAbility():GetSpecialValueFor("true_evasion")
end

function modifier_phantom_assassin_blur_ebf:DeclareFunctions()
    funcs = {
                MODIFIER_EVENT_ON_ATTACK_START,
                MODIFIER_EVENT_ON_ATTACK_LANDED,
                MODIFIER_EVENT_ON_ATTACK_FAIL,
                MODIFIER_PROPERTY_EVASION_CONSTANT,
            }
    return funcs
end

function modifier_phantom_assassin_blur_ebf:OnAttackStart(params)
    if IsServer() then
        if params.target == self:GetParent() then
            if RollPercentage(self.trueEvasion) then
                params.attacker:AddNewModifier(params.target, self:GetAbility(), "modifier_phantom_assassin_blur_true_evasion", {})
            end
        else
            params.attacker:RemoveModifierByName("modifier_phantom_assassin_blur_true_evasion")
        end
    end
end

function modifier_phantom_assassin_blur_ebf:OnAttackLanded(params)
    if IsServer() then
        if params.target == self:GetParent() then
            params.attacker:RemoveModifierByName("modifier_phantom_assassin_blur_true_evasion")
            self:IncrementStackCount()
        end
    end
end

function modifier_phantom_assassin_blur_ebf:OnAttackFail(params)
    if IsServer() then
        if params.target == self:GetParent() then
            params.attacker:RemoveModifierByName("modifier_phantom_assassin_blur_true_evasion")
            self:SetStackCount(0)
        end
    end
end

function modifier_phantom_assassin_blur_ebf:GetModifierEvasion_Constant(params)
    return self.evasion + self:GetStackCount() * self.evasion_stack
end

LinkLuaModifier( "modifier_phantom_assassin_blur_true_evasion", "lua_abilities/heroes/phantom_assassin.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_phantom_assassin_blur_true_evasion = class({})

function modifier_phantom_assassin_blur_true_evasion:IsHidden()
    return true
end

function modifier_phantom_assassin_blur_true_evasion:CheckState()
    local state = {
        [MODIFIER_STATE_CANNOT_MISS] = false,
    }
    return state
end