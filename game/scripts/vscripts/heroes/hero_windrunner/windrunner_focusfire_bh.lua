windrunner_focusfire_bh = class({})

function windrunner_focusfire_bh:IsStealable()
	return true
end

function windrunner_focusfire_bh:IsHiddenWhenStolen()
	return false
end

function windrunner_focusfire_bh:GetCastRange( position, target ) 
	return self:GetCaster():GetAttackRange()
end

function windrunner_focusfire_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local duration = self:GetSpecialValueFor("duration")
	EmitSoundOn("Ability.Focusfire", caster)
	self.targetModifier = target:AddNewModifier(caster, self, "modifier_windrunner_focusfire_target_bh", {duration = duration})
	ExecuteOrderFromTable({
					UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = target:entindex()
				})
end

function windrunner_focusfire_bh:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		caster:PerformAbilityAttack(target, true, self)
	end
end

modifier_windrunner_focusfire_target_bh = class({})
LinkLuaModifier("modifier_windrunner_focusfire_target_bh", "heroes/hero_windrunner/windrunner_focusfire_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_windrunner_focusfire_target_bh:OnRemoved()
	if self:GetRemainingTime() > 0 and IsServer() and self:GetCaster():HasTalent("special_bonus_unique_windrunner_focusfire_bh_2") then
		self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_windrunner_focusfire_target_talent", {duration = self:GetRemainingTime(), ignoreStatusAmp = true})
	end
end

function modifier_windrunner_focusfire_target_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER, MODIFIER_EVENT_ON_ATTACK_RECORD}
end

function modifier_windrunner_focusfire_target_bh:OnAttackRecord(params)
	if params.attacker == self:GetCaster() and not params.attacker:IsInAbilityAttackMode() then
		if self:GetParent() == params.target then
			self.targetModifier = self
			params.attacker:AddNewModifier( params.attacker, self:GetAbility(), "modifier_windrunner_focusfire_bh", {} )
		else
			params.attacker:RemoveModifierByName("modifier_windrunner_focusfire_bh")
		end
	end
end

function modifier_windrunner_focusfire_target_bh:OnOrder(params)
	if params.unit == self:GetCaster() and params.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
		if self:GetParent() == params.target then
			params.unit:AddNewModifier( params.unit, self:GetAbility(), "modifier_windrunner_focusfire_bh", {} )
		else
			params.unit:RemoveModifierByName("modifier_windrunner_focusfire_bh")
		end
	end
end

modifier_windrunner_focusfire_target_talent = class({})
LinkLuaModifier("modifier_windrunner_focusfire_target_talent", "heroes/hero_windrunner/windrunner_focusfire_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_windrunner_focusfire_target_talent:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER, MODIFIER_EVENT_ON_ATTACK_RECORD}
end

function modifier_windrunner_focusfire_target_talent:OnAttackRecord(params)
	if params.attacker == self:GetCaster() then
		if self:GetParent() == params.target then
			params.attacker:AddNewModifier( params.attacker, self:GetAbility(), "modifier_windrunner_focusfire_bh", {} )
		else
			params.attacker:RemoveModifierByName("modifier_windrunner_focusfire_bh")
		end
	end
end

function modifier_windrunner_focusfire_target_talent:OnOrder(params)
	if params.unit == self:GetCaster() and params.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
		self:GetAbility().targetModifier = params.target:AddNewModifier( params.unit, self:GetAbility(), "modifier_windrunner_focusfire_target_bh", {duration = self:GetRemainingTime(), ignoreStatusAmp = true} )
		self:Destroy()
	end
end

modifier_windrunner_focusfire_bh = class({})
LinkLuaModifier("modifier_windrunner_focusfire_bh", "heroes/hero_windrunner/windrunner_focusfire_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_windrunner_focusfire_bh:OnCreated(table)
	self.as = self:GetSpecialValueFor("bonus_as")
	self.dmg = self:GetSpecialValueFor("dmg_reduction")
    if IsServer() then
		local caster = self:GetCaster()
		self:StartIntervalThink( math.max( 0.31, ( caster:GetLastAttackTime( ) - GameRules:GetGameTime() ) + caster:GetSecondsPerAttack() ) )
    end
end

function modifier_windrunner_focusfire_bh:OnIntervalThink()
    local caster = self:GetCaster()
	if self:GetAbility().targetModifier:IsNull() then
		self:Destroy()
		return
	end
    if not caster:HasActiveAbility() and ( GameRules:GetGameTime() - caster:GetLastAttackTime( ) ) >= caster:GetSecondsPerAttack() then
		self.lastAttackTarget = self:GetAbility().targetModifier:GetParent()  or self.lastAttackTarget
		if not self.lastAttackTarget or self.lastAttackTarget:IsNull() or not self.lastAttackTarget:IsAlive() then
			self:Destroy()
			return
		end
        if self.lastAttackTarget and self.lastAttackTarget:IsAlive() then
			caster:PerformAttack(self.lastAttackTarget, true, true, true, true, true, false, false)
            caster:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, caster:GetDisplayAttackSpeed() )
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
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_windrunner_focusfire_bh:GetModifierAttackSpeedBonus_Constant()
    return self.as
end

function modifier_windrunner_focusfire_bh:GetModifierDamageOutgoing_Percentage()
    return self.dmg
end

function modifier_windrunner_focusfire_bh:GetActivityTranslationModifiers()
    return "focusfire"
end

function modifier_windrunner_focusfire_bh:OnOrder( params )
	if params.unit == self:GetParent() and (params.order_type == DOTA_UNIT_ORDER_STOP or params.order_type == DOTA_UNIT_ORDER_HOLD_POSITION) then
		self:Destroy()
	end
end


function modifier_windrunner_focusfire_bh:OnAttackLanded( params )
	if params.attacker == self:GetParent() and params.target == self:GetAbility().targetModifier:GetParent() then
		local ability = self:GetAbility()
		for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), -1 ) ) do
			if enemy ~= params.target and enemy:HasModifier("modifier_windrunner_bolas_primary") then
				params.attacker:FireAbilityAutoAttack( enemy, ability, params.target )
			end
		end
	end
end

function modifier_windrunner_focusfire_bh:IsDebuff()
    return false
end