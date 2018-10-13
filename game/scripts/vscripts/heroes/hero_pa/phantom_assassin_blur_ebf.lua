phantom_assassin_blur_ebf = class({})

function phantom_assassin_blur_ebf:GetIntrinsicModifierName()
    return "modifier_phantom_assassin_blur_ebf"
end

LinkLuaModifier( "modifier_phantom_assassin_blur_ebf", "heroes/hero_pa/phantom_assassin_blur_ebf", LUA_MODIFIER_MOTION_NONE )
modifier_phantom_assassin_blur_ebf = class({})

function modifier_phantom_assassin_blur_ebf:OnCreated()
    self.evasion = self:GetAbility():GetSpecialValueFor("bonus_evasion_tooltip")
    self.evasion_stack = self:GetAbility():GetSpecialValueFor("evasion_stacks")
    self.trueEvasion = self:GetAbility():GetSpecialValueFor("true_evasion")
end

function modifier_phantom_assassin_blur_ebf:OnRefresh()
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
            if RollPercentage(self:GetModifierEvasion_Constant()/2) then
                params.attacker:AddNewModifier(params.target, self:GetAbility(), "modifier_phantom_assassin_blur_true_evasion", {})
				if self:GetParent():HasTalent("special_bonus_unique_pa_blur_1") then
					local kunai = self:GetParent():FindAbilityByName("pa_kunai_toss")
					if kunai then
						for _, enemy in ipairs( self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), self:GetParent():FindTalentValue("special_bonus_unique_pa_blur_1") ) ) do
							kunai:tossKunai(enemy)
						end
					end
				end
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
    return math.min(100, self.evasion + self:GetStackCount() * self.evasion_stack)
end

LinkLuaModifier( "modifier_phantom_assassin_blur_true_evasion", "heroes/hero_pa/phantom_assassin_blur_ebf", LUA_MODIFIER_MOTION_NONE )
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

function modifier_phantom_assassin_blur_true_evasion:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end