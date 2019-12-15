lifestealer_flesh_wounds = class({})
LinkLuaModifier( "modifier_lifestealer_flesh_wounds", "heroes/hero_lifestealer/lifestealer_flesh_wounds.lua" ,LUA_MODIFIER_MOTION_NONE )

function lifestealer_flesh_wounds:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    
    EmitSoundOn("Hero_LifeStealer.OpenWounds.Cast", target)
	if target:TriggerSpellAbsorb( self ) then return end
    target:AddNewModifier(caster, self, "modifier_lifestealer_flesh_wounds", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_lifestealer_flesh_wounds = class({})
function modifier_lifestealer_flesh_wounds:OnCreated(table)
	self.slow = self:GetTalentSpecialValueFor("slow")
	self.slow_decay = ( self.slow / self:GetRemainingTime() ) * 0.5
    self:StartIntervalThink(0.5)
end

function modifier_lifestealer_flesh_wounds:OnIntervalThink()
	self.slow = self.slow - self.slow_decay
	if IsServer() then 
		local damage = self:GetParent():GetHealth() * self:GetTalentSpecialValueFor("damage")/100
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage * 0.5, {damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_DAMAGE)
	 end
end

function modifier_lifestealer_flesh_wounds:DeclareFunctions()
    funcs = {
                MODIFIER_EVENT_ON_TAKEDAMAGE,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            }
    return funcs
end

function modifier_lifestealer_flesh_wounds:OnTakeDamage(params)
    if IsServer() then
        if params.attacker:GetTeam() == self:GetCaster():GetTeam() then
            ParticleManager:FireParticle("particles/units/heroes/hero_life_stealer/life_stealer_open_wounds_impact.vpcf", PATTACH_POINT, self:GetCaster(), {[0]=params.unit:GetAbsOrigin()})
            local heal = params.damage * self:GetTalentSpecialValueFor("heal_percent")/100
            params.attacker:HealEvent(heal, self:GetAbility(), self:GetCaster(), false)
        end
    end
end

function modifier_lifestealer_flesh_wounds:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

function modifier_lifestealer_flesh_wounds:IsDebuff()
    return true
end

function modifier_lifestealer_flesh_wounds:GetEffectName()
    return "particles/units/heroes/hero_life_stealer/life_stealer_open_wounds.vpcf"
end

function modifier_lifestealer_flesh_wounds:GetStatusEffectName()
    return "particles/status_fx/status_effect_life_stealer_open_wounds.vpcf"
end

function modifier_lifestealer_flesh_wounds:StatusEffectPriority()
    return 10
end