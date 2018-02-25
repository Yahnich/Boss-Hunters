chen_sup_mr = class({})
LinkLuaModifier( "modifier_chen_sup_mr_handle", "heroes/hero_chen/chen_sup_mr.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chen_sup_mr", "heroes/hero_chen/chen_sup_mr.lua" ,LUA_MODIFIER_MOTION_NONE )

function chen_sup_mr:GetIntrinsicModifierName()
	return "modifier_chen_sup_mr_handle" 
end

modifier_chen_sup_mr_handle = class({})
function modifier_chen_sup_mr_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_chen_sup_mr_handle:OnAttackLanded(params)
	if IsServer() and params.attacker == self:GetParent() and RollPercentage(self:GetTalentSpecialValueFor("chance")) then
		params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_chen_sup_mr", {Duration = self:GetSpecialValueFor("duration")})
	end
end

function modifier_chen_sup_mr_handle:OnRemoved()
    if IsServer() then
        ParticleManager:FireParticle("particles/units/heroes/hero_brewmaster/brewmaster_storm_death.vpcf", PATTACH_POINT, self:GetParent(), {[0]=self:GetParent():GetAbsOrigin(),[1]=self:GetParent():GetForwardVector(),[3]=self:GetParent():GetForwardVector()})

        self:GetParent():AddNoDraw()
    end
end

function modifier_chen_sup_mr_handle:OnDeath(params)
    if IsServer() and params.unit == self:GetParent() then
        self:GetParent():AddNoDraw()
    end
end

function modifier_chen_sup_mr_handle:IsHidden()
	return true
end

function modifier_chen_sup_mr_handle:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_storm_ambient.vpcf"
end

modifier_chen_sup_mr = class({})
function modifier_chen_sup_mr:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
    return funcs
end

function modifier_chen_sup_mr:GetModifierMagicalResistanceBonus()
	return self:GetSpecialValueFor("reduc")
end