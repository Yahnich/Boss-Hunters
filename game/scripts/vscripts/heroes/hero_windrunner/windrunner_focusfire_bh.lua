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
	self:GetParent():HookInModifier("GetBaseAttackTime_Bonus", self)
    if IsServer() then
		local caster = self:GetCaster()
		self:StartIntervalThink( math.max( 0.31, ( caster:GetLastAttackTime( ) - GameRules:GetGameTime() ) + caster:GetSecondsPerAttack() ) )
    end
end

function modifier_windrunner_focusfire_bh:OnIntervalThink()
    local caster = self:GetCaster()
    if not caster:HasActiveAbility() and ( GameRules:GetGameTime() - caster:GetLastAttackTime( ) ) >= caster:GetSecondsPerAttack() then
		self.lastAttackTarget = caster:GetAttackTarget() or self.lastAttackTarget
		if not self.lastAttackTarget or self.lastAttackTarget:IsNull() or ( self.lastAttackTarget and CalculateDistance( self.lastAttackTarget, caster ) > caster:GetAttackRange() ) or not self.lastAttackTarget:IsAlive() then
			self.lastAttackTarget = nil
			local enemies = self:GetCaster():FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange())
			for _,enemy in pairs(enemies) do
				self.lastAttackTarget = enemy
				break
			end
		end
        if self.lastAttackTarget and self.lastAttackTarget:IsAlive() then
			caster:PerformAttack(self.lastAttackTarget, true, true, true, true, true, false, false)
            caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.7/caster:GetAttackSpeed())
        else
            caster:RemoveGesture(ACT_DOTA_ATTACK)
        end
		self:StartIntervalThink( self:GetCaster():GetSecondsPerAttack( ) - 0.03 )
    else
        caster:RemoveGesture(ACT_DOTA_ATTACK)
		self:StartIntervalThink(0)
    end
end

function modifier_windrunner_focusfire_bh:OnRemoved()
	self:GetParent():HookOutModifier("GetBaseAttackTime_Bonus", self)
	if IsServer() then
        --self:GetCaster():SetForceAttackTarget(nil)
	end
end

function modifier_windrunner_focusfire_bh:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		
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