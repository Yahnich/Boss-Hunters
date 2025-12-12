weaver_shukuchi_bh = class({})
LinkLuaModifier( "modifier_weaver_shukuchi_bh", "heroes/hero_weaver/weaver_shukuchi_bh.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_weaver_shukuchi_bh_scepter", "heroes/hero_weaver/weaver_shukuchi_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function weaver_shukuchi_bh:IsStealable()
    return true
end

function weaver_shukuchi_bh:IsHiddenWhenStolen()
    return false
end

function weaver_shukuchi_bh:OnSpellStart()
    local caster = self:GetCaster()
    local fadeTime = self:GetSpecialValueFor("fade_time")

    EmitSoundOn("Hero_Weaver.Shukuchi", caster)

    Timers:CreateTimer(fadeTime, function()
        ProjectileManager:ProjectileDodge(caster)
        caster:AddNewModifier(caster, self, "modifier_weaver_shukuchi_bh", {Duration = self:GetSpecialValueFor("duration")})
    end)
end

modifier_weaver_shukuchi_bh = class({})
function modifier_weaver_shukuchi_bh:OnCreated(table)
    if IsServer() then
        local caster = self:GetCaster()

        self:GetParent():SetThreat(0)
		
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_shukuchi.vpcf", PATTACH_POINT_FOLLOW, caster)
                    ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        self:AttachEffect(nfx)
    end
	self:OnRefresh()
end

function modifier_weaver_shukuchi_bh:OnRefresh(table)
    self.bonus_ms = self:GetSpecialValueFor("speed")
	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )

    if IsServer() then 
        local caster = self:GetCaster()

        self.hitUnits = {}

        self.radius = self:GetSpecialValueFor("radius")
        self.damage = self:GetSpecialValueFor("damage")
		
        self.talent2 = caster:HasTalent("special_bonus_unique_weaver_shukuchi_bh_2") 
		self.talent2Heal = self.damage * caster:FindTalentValue("special_bonus_unique_weaver_shukuchi_bh_2") / 100
		
        self:GetCaster():CalculateStatBonus()
        self:StartIntervalThink(0.05)
        self:GetAbility():StartDelayedCooldown()
    end
end

function modifier_weaver_shukuchi_bh:OnDestroy()
	self:GetParent():HookOutModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_weaver_shukuchi_bh:OnIntervalThink()
    local caster = self:GetParent()
	local ability = self:GetAbility()
    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.radius)
    for _,enemy in pairs(enemies) do
        if not self.hitUnits[enemy:entindex()] then
            local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_shukuchi_damage.vpcf", PATTACH_POINT_FOLLOW, caster)
                        ParticleManager:SetParticleControlEnt(nfx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
                        ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
                        ParticleManager:ReleaseParticleIndex(nfx)
			if not enemy:TriggerSpellAbsorb( ability ) then
				ability:DealDamage(caster, enemy, self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)

				if caster:HasScepter() then
					caster:AddNewModifier(caster, ability, "modifier_weaver_shukuchi_bh_scepter", {Duration = 10}):AddIndependentStack()
				end
			end
            self.hitUnits[enemy:entindex()] = true
        end
    end
	if self.talent2 then
		local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self.radius)
		for _,ally in pairs(allies) do
			if not self.hitUnits[ally:entindex()] then
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_shukuchi_damage.vpcf", PATTACH_POINT_FOLLOW, caster)
							ParticleManager:SetParticleControlEnt(nfx, 0, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true)
							ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
							ParticleManager:ReleaseParticleIndex(nfx)
				ally:HealEvent( self.talent2Heal, ability, caster )
				ally:RestoreMana( self.talent2Heal )
				if caster:HasScepter() then
					caster:AddNewModifier(caster, ability, "modifier_weaver_shukuchi_bh_scepter", {Duration = 10}):AddIndependentStack(10)
				end
				self.hitUnits[ally:entindex()] = true
			end
		end
	end
end

function modifier_weaver_shukuchi_bh:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }

    return funcs
end

function modifier_weaver_shukuchi_bh:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_ms
end

function modifier_weaver_shukuchi_bh:GetMoveSpeedLimitBonus()
    return self.bonus_ms
end

function modifier_weaver_shukuchi_bh:CheckState()
    local state = { [MODIFIER_STATE_INVISIBLE] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_UNSLOWABLE] = true}
    return state
end

function modifier_weaver_shukuchi_bh:GetActivityTranslationModifiers()
    return "shukuchi"
end

function modifier_weaver_shukuchi_bh:OnAbilityExecuted(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            self:Destroy()
        end
    end
end

function modifier_weaver_shukuchi_bh:OnAttack(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            self:Destroy()
        end
    end
end

function modifier_weaver_shukuchi_bh:OnRemoved()
    if IsServer() then
        self:GetAbility():EndDelayedCooldown()
    end
end

function modifier_weaver_shukuchi_bh:GetModifierInvisibilityLevel()
    return 1
end

function modifier_weaver_shukuchi_bh:IsHidden()
    return false
end

function modifier_weaver_shukuchi_bh:IsPurgable()
    return false
end

function modifier_weaver_shukuchi_bh:IsPurgeException()
    return false
end

function modifier_weaver_shukuchi_bh:IsDebuff()
    return false
end

function modifier_weaver_shukuchi_bh:GetEffectName()
    return "particles/generic_hero_status/status_invisibility_start.vpcf"
end

modifier_weaver_shukuchi_bh_scepter = class({})
function modifier_weaver_shukuchi_bh_scepter:OnCreated(table)
    self.bonus_agi = 10 * self:GetStackCount()
    self.bonus_int = 10 * self:GetStackCount()

    if IsServer() then
        self:GetCaster():CalculateStatBonus()
    end
end

function modifier_weaver_shukuchi_bh_scepter:OnRefresh(table)
    self.bonus_agi = 10 * self:GetStackCount()
    self.bonus_int = 10 * self:GetStackCount()

    if IsServer() then
        self:GetCaster():CalculateStatBonus()
    end
end

function modifier_weaver_shukuchi_bh_scepter:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_weaver_shukuchi_bh_scepter:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_weaver_shukuchi_bh_scepter:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

function modifier_weaver_shukuchi_bh_scepter:OnRemoved()
    if IsServer() then
        self:GetCaster():CalculateStatBonus()
    end
end

function modifier_weaver_shukuchi_bh_scepter:IsPurgable()
    return false
end

function modifier_weaver_shukuchi_bh_scepter:IsPurgeException()
    return false
end

function modifier_weaver_shukuchi_bh_scepter:IsDebuff()
    return false
end