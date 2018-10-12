windrunner_focusfire_bh = class({})
LinkLuaModifier("modifier_windrunner_focusfire_bh", "heroes/hero_windrunner/windrunner_focusfire_bh", LUA_MODIFIER_MOTION_NONE)

function windrunner_focusfire_bh:IsStealable()
	return true
end

function windrunner_focusfire_bh:IsHiddenWhenStolen()
	return false
end

function windrunner_focusfire_bh:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Ability.Windrun", caster)
	caster:AddNewModifier(caster, self, "modifier_windrunner_focusfire_bh", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_windrunner_focusfire_bh = class({})
function modifier_windrunner_focusfire_bh:OnCreated(table)
	self.as = self:GetTalentSpecialValueFor("bonus_as")
	self.bat = self:GetTalentSpecialValueFor("bonus_at")
	self.dmg = TernaryOperator( self:GetTalentSpecialValueFor("scepter_dmg_reduction"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("dmg_reduction") )
    if IsServer() then
        self:StartIntervalThink(self:GetCaster():GetSecondsPerAttack())
    end
end

function modifier_windrunner_focusfire_bh:OnIntervalThink()
    local caster = self:GetCaster()
    if not caster:IsAttacking() and (not caster:IsChanneling()) then
        local enemies = self:GetCaster():FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange())
        if #enemies > 0 then
            caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1/caster:GetSecondsPerAttack())
        else
            caster:RemoveGesture(ACT_DOTA_ATTACK)
        end
        for _,enemy in pairs(enemies) do
            if not caster:IsMoving() then
                caster:FaceTowards(enemy:GetAbsOrigin())
            end
            caster:PerformAttack(enemy, true, true, true, true, true, false, false)
            break
        end
    else
        caster:RemoveGesture(ACT_DOTA_ATTACK)
    end
    self:StartIntervalThink(self:GetCaster():GetSecondsPerAttack())
end

function modifier_windrunner_focusfire_bh:OnRemoved()
	if IsServer() then
        --self:GetCaster():SetForceAttackTarget(nil)
	end
end

function modifier_windrunner_focusfire_bh:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
    return funcs
end

function modifier_windrunner_focusfire_bh:GetModifierAttackSpeedBonus_Constant()
    return self.as
end

function modifier_windrunner_focusfire_bh:GetModifierDamageOutgoing_Percentage()
    return self.dmg
end

function modifier_windrunner_focusfire_bh:GetBaseAttackTime_Bonus()
    return self.bat
end

function modifier_windrunner_focusfire_bh:IsDebuff()
    return false
end