tusk_frozen_wasteland = class({})
LinkLuaModifier( "modifier_tusk_frozen_wasteland", "heroes/hero_tusk/tusk_frozen_wasteland.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tusk_frozen_wasteland_effect", "heroes/hero_tusk/tusk_frozen_wasteland.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tusk_frozen_wasteland_bonus_damage", "heroes/hero_tusk/tusk_frozen_wasteland.lua" ,LUA_MODIFIER_MOTION_NONE )

function tusk_frozen_wasteland:IsStealable()
    return true
end

function tusk_frozen_wasteland:IsHiddenWhenStolen()
    return false
end

function tusk_frozen_wasteland:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function tusk_frozen_wasteland:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget() or caster

    EmitSoundOn("Hero_Tusk.TagTeam.Cast", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_tusk/tusk_tag_team_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	
	target:AddNewModifier(caster, self, "modifier_tusk_frozen_wasteland", {Duration = self:GetSpecialValueFor("duration")})    
end

modifier_tusk_frozen_wasteland = class({})
function modifier_tusk_frozen_wasteland:OnCreated(table)
    if IsServer() then
        EmitSoundOn("Hero_Tusk.TagTeam.Layer", self:GetParent())

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_tag_team.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
                    ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
                    ParticleManager:SetParticleControl(nfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, -self:GetSpecialValueFor("radius")))
        self:AttachEffect(nfx)
        self:StartIntervalThink(0.1)
    end
end

function modifier_tusk_frozen_wasteland:OnIntervalThink()
    if self:GetCaster():HasTalent("special_bonus_unique_tusk_frozen_wasteland_2") then
        local damage = self:GetParent():GetStrength() * self:GetCaster():FindTalentValue("special_bonus_unique_tusk_frozen_wasteland_2")/100
        local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
        for _,enemy in pairs(enemies) do
            self:GetAbility():DealDamage(self:GetCaster(), enemy, damage, {damage_type=DAMAGE_TYPE_MAGICAL})
        end
        self:StartIntervalThink(1.0)
    end
end

function modifier_tusk_frozen_wasteland:OnRemoved()
    if IsServer() then
        StopSoundOn("Hero_Tusk.TagTeam.Layer", self:GetParent())
    end
end

function modifier_tusk_frozen_wasteland:IsAura()
    return true
end

function modifier_tusk_frozen_wasteland:GetAuraDuration()
    return 0.5
end

function modifier_tusk_frozen_wasteland:GetAuraRadius()
    return self:GetSpecialValueFor("radius")
end

function modifier_tusk_frozen_wasteland:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_tusk_frozen_wasteland:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_tusk_frozen_wasteland:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_tusk_frozen_wasteland:GetModifierAura()
    return "modifier_tusk_frozen_wasteland_effect"
end

function modifier_tusk_frozen_wasteland:IsAuraActiveOnDeath()
    return false
end

function modifier_tusk_frozen_wasteland:IsHidden()
    return false
end

modifier_tusk_frozen_wasteland_effect = class({})
function modifier_tusk_frozen_wasteland_effect:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
				    MODIFIER_EVENT_ON_ATTACK_START,
				    MODIFIER_EVENT_ON_ATTACK_LANDED}
    return funcs
end

function modifier_tusk_frozen_wasteland_effect:GetModifierMoveSpeedBonus_Percentage()
    return self:GetSpecialValueFor("slow_move")
end

function modifier_tusk_frozen_wasteland_effect:OnAttackStart(params)
	if params.target:HasModifier("modifier_tusk_frozen_wasteland_effect") then
		params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_tusk_frozen_wasteland_bonus_damage", {duration = params.attacker:GetCastPoint(true) + 0.1})
	else
		params.attacker:RemoveModifierByName("modifier_tusk_frozen_wasteland_bonus_damage")
	end
end

function modifier_tusk_frozen_wasteland_effect:OnAttackLanded(params)
	if params.target == self:GetParent() then
		params.attacker:RemoveModifierByName("modifier_tusk_frozen_wasteland_bonus_damage")
		ParticleManager:FireParticle("particles/units/heroes/hero_tusk/tusk_tag_team_debuff.vpcf", PATTACH_POINT, params.target)
	end
end

function modifier_tusk_frozen_wasteland_effect:GetModifierAttackSpeedBonus_Constant()
    return self:GetSpecialValueFor("slow_attack")
end

function modifier_tusk_frozen_wasteland_effect:GetEffectName()
    return "particles/units/heroes/hero_tusk/tusk_frozen_sigil_status.vpcf"
end

function modifier_tusk_frozen_wasteland_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_tusk_tag_team_debuff.vpcf"
end

function modifier_tusk_frozen_wasteland_effect:StatusEffectPriority()
	return 5
end

modifier_tusk_frozen_wasteland_bonus_damage = class({})
function modifier_tusk_frozen_wasteland_bonus_damage:OnCreated()
	self.damage = self:GetSpecialValueFor("bonus_damage_taken")
end

function modifier_tusk_frozen_wasteland_bonus_damage:OnRefresh()
	self.damage = self:GetSpecialValueFor("bonus_damage_taken")
end

function modifier_tusk_frozen_wasteland_bonus_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_tusk_frozen_wasteland_bonus_damage:GetModifierPreAttack_BonusDamage()
	if IsServer() then return self.damage end
end

function modifier_tusk_frozen_wasteland_bonus_damage:IsHidden()
	return true
end