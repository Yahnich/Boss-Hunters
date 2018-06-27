tusk_punch = class({})
LinkLuaModifier( "modifier_tusk_punch", "heroes/hero_tusk/tusk_punch.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tusk_punch_crit", "heroes/hero_tusk/tusk_punch.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tusk_punch_slow", "heroes/hero_tusk/tusk_punch.lua" ,LUA_MODIFIER_MOTION_NONE )

function tusk_punch:IsStealable()
    return true
end

function tusk_punch:IsHiddenWhenStolen()
    return false
end

function tusk_punch:GetCastRange(vLocation, hTarget)
    return self:GetCaster():GetAttackRange()
end

function tusk_punch:GetIntrinsicModifierName()
    return "modifier_tusk_punch"
end

function tusk_punch:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    caster:AddNewModifier(caster, self, "modifier_tusk_punch_crit", {})
    caster:PerformAttack(target, true, true, true, false, false, false, true)
end

modifier_tusk_punch = class({})
function modifier_tusk_punch:OnCreated(kv)
    self:StartIntervalThink(FrameTime())
end

function modifier_tusk_punch:OnIntervalThink()
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        if ability:GetAutoCastState() then
            if caster:IsAlive() and ability:IsCooldownReady() and caster:GetMana() >= ability:GetManaCost(ability:GetLevel()) and caster:IsHero() then
                self:GetAbility().cd = true
                caster:AddNewModifier(caster, self:GetAbility(), "modifier_tusk_punch_crit", {})
            end
        else
            caster:RemoveModifierByName("modifier_tusk_punch_crit")
        end
    end
end

function modifier_tusk_punch:DeclareFunctions()
    local funcs = { MODIFIER_EVENT_ON_ATTACK_RECORD  }
    return funcs
end

function modifier_tusk_punch:OnAttackRecord(params)
    if IsServer() then
		local caster = self:GetCaster()
        if caster:HasTalent("special_bonus_unique_tusk_punch_1") then
            if RollPercentage(caster:FindTalentValue("special_bonus_unique_tusk_punch_1")) and params.attacker == self:GetParent() and caster:IsHero() then
                self:GetAbility().cd = false
				EmitSoundOn("Hero_Tusk.WalrusPunch.Cast", self:GetParent())
				self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, self:GetParent():GetIncreasedAttackSpeed() )
                caster:AddNewModifier(caster, self:GetAbility(), "modifier_tusk_punch_crit", {})
            end
        end
    end
end

function modifier_tusk_punch:IsHidden() return true end

modifier_tusk_punch_crit = ({})
function modifier_tusk_punch_crit:OnCreated(table)
    if IsServer() then
        self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_status.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
    end
end

function modifier_tusk_punch_crit:OnRemoved()
    if IsServer() then
        ParticleManager:ClearParticle(self.nfx)
    end
end

function modifier_tusk_punch_crit:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_START
    }
    return funcs
end

function modifier_tusk_punch_crit:GetModifierPreAttack_CriticalStrike(params)
	StopSoundOn("Hero_Tusk.WalrusPunch.Cast", self:GetParent())
	EmitSoundOn("Hero_Tusk.WalrusPunch.Target", params.target)
	
	ParticleManager:FireParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_txt_ult.vpcf", PATTACH_POINT, self:GetParent(), {[2]=params.target:GetAbsOrigin()})
	ParticleManager:FireParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_POINT, self:GetParent(), {[0]=params.target:GetAbsOrigin()})
	local airTime = self:GetTalentSpecialValueFor("air_time")
	params.target:ApplyKnockBack(self:GetParent():GetAbsOrigin(), airTime, airTime, 1, self:GetTalentSpecialValueFor("height"), params.attacker, self:GetAbility())
	params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_tusk_punch_slow", {Duration = airTime + self:GetTalentSpecialValueFor("duration")})
	Timers:CreateTimer(airTime, function() EmitSoundOn("Hero_Tusk.WalrusPunch.Damage", params.target) end)
	if self:GetAbility().cd then
		self:GetAbility():UseResources(true, false, true)
	end
	self:Destroy()
    return self:GetTalentSpecialValueFor("crit_multiplier")
end

function modifier_tusk_punch_crit:OnAttackStart(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            EmitSoundOn("Hero_Tusk.WalrusPunch.Cast", self:GetParent())
            self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4, self:GetParent():GetIncreasedAttackSpeed())
        end
    end
end

function modifier_tusk_punch_crit:IsHidden() return false end

modifier_tusk_punch_slow = ({})
function modifier_tusk_punch_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_tusk_punch_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("move_slow")
end

function modifier_tusk_punch_slow:GetEffectName()
    return "particles/units/heroes/hero_tusk/tusk_walruspunch_tgt_status.vpcf"
end