faceless_futures_past = class({})
LinkLuaModifier( "modifier_faceless_futures_past", "heroes/hero_faceless_void/faceless_futures_past.lua" ,LUA_MODIFIER_MOTION_NONE )

function faceless_futures_past:IsStealable()
    return true
end

function faceless_futures_past:IsHiddenWhenStolen()
    return false
end

function faceless_futures_past:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    --for i=1,self:GetSpecialValueFor("max_illusions") do
        local pointRando = target:GetAbsOrigin() + ActualRandomVector(target:GetAttackRange(), target:GetAttackRange())
        local image = caster:ConjureImage(pointRando, self:GetSpecialValueFor("duration"), self:GetSpecialValueFor("illusion_damage"), 0, "", self)
        image:AddNewModifier(caster, self, "modifier_faceless_futures_past", {})
    --end
end

modifier_faceless_futures_past = class({})
function modifier_faceless_futures_past:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
                    [MODIFIER_STATE_INVULNERABLE] = true,
                    [MODIFIER_STATE_UNSELECTABLE] = true,
                    [MODIFIER_STATE_UNTARGETABLE] = true,
                    [MODIFIER_STATE_COMMAND_RESTRICTED] = true
                }
    return state
end