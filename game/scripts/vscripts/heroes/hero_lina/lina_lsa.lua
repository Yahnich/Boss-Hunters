lina_lsa = class({})
LinkLuaModifier( "modifier_lina_lsa_fire", "heroes/hero_lina/lina_lsa.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lina_lsa_slow", "heroes/hero_lina/lina_lsa.lua" ,LUA_MODIFIER_MOTION_NONE )

function lina_lsa:IsStealable()
    return true
end

function lina_lsa:IsHiddenWhenStolen()
    return false
end

function lina_lsa:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function lina_lsa:OnAbilityPhaseStart()
	EmitSoundOn("Ability.PreLightStrikeArray", self:GetCaster())
    return true
end

function lina_lsa:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    StopSoundOn("Ability.PreLightStrikeArray", caster)
    EmitSoundOnLocationWithCaster(point, "Ability.LightStrikeArray", caster)

    local radius = self:GetTalentSpecialValueFor("radius")

    ParticleManager:FireParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_POINT, caster, {[0]=point, [1]=Vector(radius,1,1)})

    local damage = self:GetTalentSpecialValueFor("damage")

	local enemies = caster:FindEnemyUnitsInRadius(point, radius)
    for _,enemy in pairs(enemies) do
    	self:DealDamage(caster, enemy, damage, {}, 0)
    	self:Stun(enemy, self:GetTalentSpecialValueFor("stun_duration"), false)
    end

    CreateModifierThinker(caster, self, "modifier_lina_lsa_fire", {Duration = self:GetTalentSpecialValueFor("duration")}, point, caster:GetTeam(), false)
end

modifier_lina_lsa_fire = class({})
function modifier_lina_lsa_fire:OnCreated(table)
	if IsServer() then
		self.fireFX = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_lsa_fire.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
		--self.fireFX = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_lsa_aoe.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
    	ParticleManager:SetParticleControl(self.fireFX, 0, self:GetParent():GetAbsOrigin())
    	ParticleManager:SetParticleControl(self.fireFX, 1, Vector(self:GetTalentSpecialValueFor("radius"),1,1))
		self:StartIntervalThink(0.5)
	end
end

function modifier_lina_lsa_fire:OnIntervalThink()
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
    for _,enemy in pairs(enemies) do
    	self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetTalentSpecialValueFor("damage_flame"), {}, 0)
    end
end

function modifier_lina_lsa_fire:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.fireFX, false)
	end
end

function modifier_lina_lsa_fire:IsAura()
    if self:GetCaster():HasTalent("special_bonus_unique_lina_lsa_2") then
        return true
    end

    return false
end

function modifier_lina_lsa_fire:GetAuraDuration()
    return 0.5
end

function modifier_lina_lsa_fire:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_lina_lsa_fire:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_lina_lsa_fire:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_lina_lsa_fire:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_lina_lsa_fire:GetModifierAura()
    return "modifier_lina_lsa_slow"
end

function modifier_lina_lsa_fire:IsAuraActiveOnDeath()
    return false
end

modifier_lina_lsa_slow = class({})
function modifier_lina_lsa_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_lina_lsa_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_unique_lina_lsa_2")
end