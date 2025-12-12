snapfire_lil_shredder_bh = class({})

function snapfire_lil_shredder_bh:IsStealable()
    return true
end

function snapfire_lil_shredder_bh:IsHiddenWhenStolen()
    return false
end

function snapfire_lil_shredder_bh:GetBehavior()
    -- if self:GetCaster():HasScepter() then
        -- return DOTA_ABILITY_BEHAVIOR_TOGGLE
    -- end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function snapfire_lil_shredder_bh:GetManaCost( iLvl )
	-- if self:GetCaster():HasScepter() then
		-- return nil
	-- else
		return self.BaseClass.GetManaCost( self, iLvl )
	-- end
end

function snapfire_lil_shredder_bh:OnSpellStart()
    local caster = self:GetCaster()

    local duration = self:GetSpecialValueFor("buff_duration_tooltip")
    local buffed_attacks = self:GetSpecialValueFor("buffed_attacks")
    
    EmitSoundOn("Hero_Snapfire.ExplosiveShells.Cast", caster)

    caster:AddNewModifier(caster, self, "modifier_snapfire_lil_shredder_bh_buff", {Duration = duration}):SetStackCount(buffed_attacks)
end

-- function snapfire_lil_shredder_bh:OnToggle()
    -- local caster = self:GetCaster()

    -- if not self:GetToggleState() then
        -- caster:RemoveModifierByName("modifier_snapfire_lil_shredder_bh_buff")
    -- else
        -- caster:AddNewModifier(caster, self, "modifier_snapfire_lil_shredder_bh_buff", {})
    -- end
-- end

modifier_snapfire_lil_shredder_bh_buff = class({})
LinkLuaModifier("modifier_snapfire_lil_shredder_bh_buff", "heroes/hero_snapfire/snapfire_lil_shredder_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_snapfire_lil_shredder_bh_buff:OnCreated(table)
    self:OnRefresh()
end

function modifier_snapfire_lil_shredder_bh_buff:OnRefresh(table)
    self.bonus_as = self:GetSpecialValueFor("attack_speed_bonus")
    self.bonus_ar = self:GetSpecialValueFor("attack_range_bonus")
    self.bonus_bat = self:GetSpecialValueFor("base_attack_time")
	self.damage = self:GetSpecialValueFor("damage") - 100
	self.debuffStackCount = self:GetSpecialValueFor("buffed_attacks")
	self.debuffDuration = self:GetSpecialValueFor("duration")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_snapfire_lil_shredder_1")
	self.talent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_snapfire_lil_shredder_1", "duration")
	self.attackList = {}
	
	self:GetParent():HookInModifier("GetBaseAttackTime_BonusPercentage", self)
end

function modifier_snapfire_lil_shredder_bh_buff:OnRemoved()
	self:GetParent():HookOutModifier("GetBaseAttackTime_BonusPercentage", self)
    if IsServer() then        
        if self:GetStackCount() < 2 then
            self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_3_END)
        end
    end
end

function modifier_snapfire_lil_shredder_bh_buff:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
                    MODIFIER_EVENT_ON_ATTACK_LANDED,
					MODIFIER_EVENT_ON_ATTACK_FAIL,
                    MODIFIER_PROPERTY_PROJECTILE_NAME,
                    MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
                    MODIFIER_EVENT_ON_ATTACK,
                    MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE }
    return funcs
end

function modifier_snapfire_lil_shredder_bh_buff:GetModifierDamageOutgoing_Percentage()
    if self:GetStackCount() > 0 then return self.damage end
end

function modifier_snapfire_lil_shredder_bh_buff:GetModifierProjectileName()
    if self:GetStackCount() > 0 then return "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf" end
end

function modifier_snapfire_lil_shredder_bh_buff:MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS ()
    if self:GetStackCount() > 0 then return "turret" end
end

function modifier_snapfire_lil_shredder_bh_buff:GetModifierAttackSpeedBonus_Constant()
    if self:GetStackCount() > 0 then return self.bonus_as end
end

function modifier_snapfire_lil_shredder_bh_buff:GetModifierAttackRangeBonus()
    if self:GetStackCount() > 0 then return self.bonus_ar end
end

function modifier_snapfire_lil_shredder_bh_buff:GetBaseAttackTime_BonusPercentage()
    if self:GetStackCount() > 0 then return self.bonus_bat end
end

function modifier_snapfire_lil_shredder_bh_buff:OnAttack(params)
    if IsServer() then
        local attacker = params.attacker
        local target = params.target

		if attacker == self:GetParent() then
			EmitSoundOn("Hero_Snapfire.ExplosiveShellsBuff.Attack", attacker)
			
			if attacker:HasScepter() and not self.disableStackLoss then
				self.disableStackLoss = true
				local attacks = self.scepter_attacks
				for _, enemy in ipairs( attacker:FindEnemyUnitsInRadius( attacker:GetAbsOrigin(), attacker:GetAttackRange() ) ) do
					if enemy ~= target then
						attacker:PerformGenericAttack(enemy, false)
					end
				end
				self.disableStackLoss = false
			end
			
			if self:GetStackCount() > 0 then
				if not self.disableStackLoss then self:DecrementStackCount() end
				self.attackList[params.record] = true
			end
		end
    end
end

function modifier_snapfire_lil_shredder_bh_buff:OnAttackLanded(params)
    if IsServer() then
        local attacker = params.attacker
        local target = params.target
		if attacker == self:GetParent() and target and target:IsAlive() and not target:IsSameTeam( attacker ) then
			target:AddNewModifier(attacker, self:GetAbility(), "modifier_snapfire_lil_shredder_bh_debuff", {Duration = self.debuffDuration})
			if self.talent1 then
				if target:HasModifier("modifier_snapfire_lil_shredder_bh_talent") then
					local duration = target:FindModifierByName("modifier_snapfire_lil_shredder_bh_talent"):GetRemainingTime() + self.talent1Val * attacker:GetStatusAmplification()
					target:AddNewModifier(attacker, self:GetAbility(), "modifier_snapfire_lil_shredder_bh_talent", {Duration = duration, ignoreStatusAmp = true})
				else
					target:AddNewModifier(attacker, self:GetAbility(), "modifier_snapfire_lil_shredder_bh_talent", {Duration = self.talent1Val})
				end
			end

			EmitSoundOn("Hero_Snapfire.ExplosiveShellsBuff.Target", target)
			
			self:HandleStacks( params )
		end
    end
end

function modifier_snapfire_lil_shredder_bh_buff:OnAttackFail(params)
    if IsServer() then
        local attacker = params.attacker
        local target = params.target
		if attacker == self:GetParent() then
			self:HandleStacks( params )
		end
    end
end

function modifier_snapfire_lil_shredder_bh_buff:HandleStacks( params )
	self.attackList[params.record] = nil
	for record, _ in pairs( self.attackList ) do -- no attacks on route
		return true
	end
	if self:GetStackCount() == 0 then
		self:Destroy()
	end
	return false
end

function modifier_snapfire_lil_shredder_bh_buff:GetEffectName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_shells_buff.vpcf"
end

function modifier_snapfire_lil_shredder_bh_buff:IsPurgable()
    return true
end

function modifier_snapfire_lil_shredder_bh_buff:IsDebuff()
    return false
end

function modifier_snapfire_lil_shredder_bh_buff:IsHidden()
    return self:GetStackCount() == 0
end

modifier_snapfire_lil_shredder_bh_talent = class({})
LinkLuaModifier("modifier_snapfire_lil_shredder_bh_talent", "heroes/hero_snapfire/snapfire_lil_shredder_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_snapfire_lil_shredder_bh_talent:OnCreated(kv)
	self:OnRefresh()
end

function modifier_snapfire_lil_shredder_bh_talent:OnRefresh(kv)
    self.talent1Val = -self:GetCaster():FindTalentValue("special_bonus_unique_snapfire_lil_shredder_1")
end

function modifier_snapfire_lil_shredder_bh_talent:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
    return funcs
end

function modifier_snapfire_lil_shredder_bh_talent:GetModifierMoveSpeedBonus_Percentage()
    return self.talent1Val
end

function modifier_snapfire_lil_shredder_bh_talent:IsPurgable()
    return true
end

function modifier_snapfire_lil_shredder_bh_talent:IsDebuff()
    return true
end

modifier_snapfire_lil_shredder_bh_debuff = class({})
LinkLuaModifier("modifier_snapfire_lil_shredder_bh_debuff", "heroes/hero_snapfire/snapfire_lil_shredder_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_snapfire_lil_shredder_bh_debuff:OnCreated(table)
	self:OnRefresh()
end

function modifier_snapfire_lil_shredder_bh_debuff:OnRefresh(table)
    self.armor = -self:GetSpecialValueFor("armor_reduction_stack") * self:GetStackCount()
	self.debuffStackCount = self:GetSpecialValueFor("buffed_attacks")
	if IsServer() then
		self:SetStackCount( math.min( self.debuffStackCount, self:GetStackCount() + 1 ) )
	end
end

function modifier_snapfire_lil_shredder_bh_debuff:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
    return funcs
end

function modifier_snapfire_lil_shredder_bh_debuff:GetModifierPhysicalArmorBonus()
    return self.armor
end

function modifier_snapfire_lil_shredder_bh_debuff:IsPurgable()
    return true
end

function modifier_snapfire_lil_shredder_bh_debuff:IsDebuff()
    return true
end