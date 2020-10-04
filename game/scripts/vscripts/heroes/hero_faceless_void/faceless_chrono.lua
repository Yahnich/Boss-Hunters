faceless_chrono = class({})
LinkLuaModifier( "modifier_faceless_chrono", "heroes/hero_faceless_void/faceless_chrono.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_faceless_chrono_lock", "heroes/hero_faceless_void/faceless_chrono.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_faceless_chrono_buff", "heroes/hero_faceless_void/faceless_chrono.lua" ,LUA_MODIFIER_MOTION_NONE )

function faceless_chrono:IsStealable()
    return true
end

function faceless_chrono:IsHiddenWhenStolen()
    return false
end

function faceless_chrono:OnSpellStart()
    self:CreateChronosphere( self:GetCursorPosition() )
end

function faceless_chrono:CreateChronosphere( position, duration, radius )
    local caster = self:GetCaster()
	EmitSoundOn("Hero_FacelessVoid.Chronosphere", caster)
	
	local fDur = duration or self:GetTalentSpecialValueFor("duration")
	local fRadius = radius or self:GetTalentSpecialValueFor("radius")
    CreateModifierThinker(caster, self, "modifier_faceless_chrono", {duration = fDur, radius = fRadius}, position, caster:GetTeam(), false)
    AddFOWViewer(caster:GetTeam(), position, fRadius, fDur, true)
end

modifier_faceless_chrono = class({})
function modifier_faceless_chrono:OnCreated(kv)
    if IsServer() then
        local caster = self:GetCaster()
        local point = self:GetParent():GetAbsOrigin()
        local radius = kv.radius or self:GetTalentSpecialValueFor("radius")

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere_surface.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControl(nfx, 0, point)
                    ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
        self:AttachEffect(nfx)

        local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere_rim.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControl(nfx2, 0, point)
                    ParticleManager:SetParticleControl(nfx2, 1, Vector(radius, radius, radius))
        self:AttachEffect(nfx2)

        local nfx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControl(nfx3, 0, point)
                    ParticleManager:SetParticleControl(nfx3, 1, Vector(radius, radius, radius))
        self:AttachEffect(nfx3)

        self:StartIntervalThink(FrameTime())
        self:StartMotionController()
		self:GetAbility():StartDelayedCooldown()
    end
end

function modifier_faceless_chrono:OnDestroy()
	if IsServer() then 
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_faceless_chrono:OnIntervalThink()
    local caster = self:GetCaster()
    local point = self:GetParent():GetAbsOrigin()

    local friends = caster:FindFriendlyUnitsInRadius(point, self:GetTalentSpecialValueFor("radius"))
    for _,friend in pairs(friends) do
        if friend == caster then
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_faceless_chrono_buff", {Duration = 0.1})
        end
    end
end

function modifier_faceless_chrono:IsAura()
    return true
end

function modifier_faceless_chrono:GetAuraDuration()
    return 0.1
end

function modifier_faceless_chrono:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_faceless_chrono:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_faceless_chrono:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_faceless_chrono:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_faceless_chrono:GetModifierAura()
    return "modifier_faceless_chrono_lock"
end

modifier_faceless_chrono_lock = class({}) 
function modifier_faceless_chrono_lock:IsDebuff()    return true end
function modifier_faceless_chrono_lock:IsHidden()    return true end

function modifier_faceless_chrono_lock:CheckState()
    local state = { [MODIFIER_STATE_STUNNED] = true,
                    [MODIFIER_STATE_FROZEN] = true,
                    [MODIFIER_STATE_SILENCED] = true
                }
    return state
end

modifier_faceless_chrono_buff = class({}) 
function modifier_faceless_chrono_buff:OnCreated()
	self:GetParent():HookInModifier("GetMoveSpeedLimitBonus", self)
	if self:GetCaster():HasTalent("special_bonus_unique_faceless_chrono_2") then
		self.talent2Val = self:GetCaster():FindTalentValue("special_bonus_unique_faceless_chrono_2")
		self:GetParent():HookInModifier("GetModifierBaseCriticalChanceBonus", self)
	end
end

function modifier_faceless_chrono_buff:OnDestroy()
	self:GetParent():HookOutModifier("GetMoveSpeedLimitBonus", self)
	self:GetParent():HookOutModifier("GetModifierBaseCriticalChanceBonus", self)
end

function modifier_faceless_chrono_buff:IsDebuff()    return false end
function modifier_faceless_chrono_buff:IsHidden()    return true end

function modifier_faceless_chrono_buff:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
                }
    return state
end

function modifier_faceless_chrono_buff:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
                    MODIFIER_PROPERTY_EVASION_CONSTANT}
    return funcs
end

function modifier_faceless_chrono_buff:GetModifierMoveSpeed_AbsoluteMin()
    return 2000
end

function modifier_faceless_chrono_buff:GetMoveSpeedLimitBonus()
    return 2000
end

function modifier_faceless_chrono_buff:GetModifierBaseCriticalChanceBonus()
    return self.talent2Val
end

function modifier_faceless_chrono_buff:GetModifierEvasion_Constant()
    return 100
end

function modifier_faceless_chrono_buff:GetEffectName()
    return "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf"
end

function modifier_faceless_chrono_buff:GetStatusEffectName()
    return "particles/status_fx/status_effect_faceless_chronosphere.vpcf"
end

function modifier_faceless_chrono_buff:StatusEffectPriority()
    return 10
end