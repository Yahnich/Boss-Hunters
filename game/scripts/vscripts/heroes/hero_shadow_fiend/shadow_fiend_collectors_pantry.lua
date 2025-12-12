shadow_fiend_dark_lord = class({})
LinkLuaModifier( "modifier_shadow_fiend_dark_lord","heroes/hero_shadow_fiend/shadow_fiend_dark_lord.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadow_fiend_necro","heroes/hero_shadow_fiend/shadow_fiend_necro.lua",LUA_MODIFIER_MOTION_NONE )

function shadow_fiend_dark_lord:GetChannelAnimation()
	return ACT_DOTA_TELEPORT
end

function shadow_fiend_dark_lord:GetChannelTime()
    return self:GetSpecialValueFor("duration")
end

function shadow_fiend_dark_lord:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_shadow_fiend_dark_lord", {})
end

function shadow_fiend_dark_lord:OnChannelFinish(bInterrupted)
    self:GetCaster():RemoveModifierByName("modifier_shadow_fiend_dark_lord")
end

modifier_shadow_fiend_dark_lord = class({})
function modifier_shadow_fiend_dark_lord:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(self:GetSpecialValueFor("soul_rate") - 0.01 )
        if self:GetCaster():HasTalent("special_bonus_unique_shadow_fiend_dark_lord_2") then
            self.damage = -self:GetSpecialValueFor("damage_weak")
        else
            self.damage = self:GetSpecialValueFor("damage_weak")
        end
    end
end

function modifier_shadow_fiend_dark_lord:OnIntervalThink()
    for i=1,self:GetSpecialValueFor("souls_per_second") do
        EmitSoundOn("Hero_DeathProphet.SpiritSiphon.Cast", self:GetParent())
        local pointRando = self:GetParent():GetAbsOrigin() + ActualRandomVector(0, self:GetCaster():GetAttackRange())
       
        ParticleManager:FireParticle("particles/nevermore_shadowraze_lower_effect.vpcf", PATTACH_POINT, self:GetCaster(), {[0]=pointRando})

        local dummy = self:GetCaster():CreateDummy(pointRando, 0.04)
        
        self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf", self:GetCaster(), 1000, {source=dummy, origin=dummy:GetAbsOrigin()})
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("shadow_fiend_necro"), "modifier_shadow_fiend_necro", {})
    end
end

function modifier_shadow_fiend_dark_lord:IsDebuff()
    return false
end

function modifier_shadow_fiend_dark_lord:DeclareFunctions()
    funcs = {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
    return funcs
end

function modifier_shadow_fiend_dark_lord:GetModifierIncomingDamage_Percentage()
    return self.damage
end