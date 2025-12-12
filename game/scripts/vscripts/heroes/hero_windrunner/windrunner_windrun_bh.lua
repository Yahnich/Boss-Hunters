windrunner_windrun_bh = class({})

function windrunner_windrun_bh:IsStealable()
	return true
end

function windrunner_windrun_bh:IsHiddenWhenStolen()
	return false
end

function windrunner_windrun_bh:HasCharges()
	return self:GetCaster():HasScepter()
end


function windrunner_windrun_bh:GetIntrinsicModifierName()
	return "modifier_windrunner_windrun_bh_charges"
end

function windrunner_windrun_bh:OnInventoryContentsChanged()
	if self:GetCaster():HasScepter() then
		local charges = self:GetCaster():FindModifierByName("modifier_windrunner_windrun_bh_charges")
        if charges and charges:GetStackCount() > 0 then
			self:EndCooldown( )
		end
    else
		local charges = self:GetCaster():FindModifierByName("modifier_windrunner_windrun_bh_charges")
        if charges and charges:GetRemainingTime() > 0 then
			self:SetCooldown( charges:GetRemainingTime() )
		end
    end
end

function windrunner_windrun_bh:OnSpellStart()
	local caster = self:GetCaster()
	
    EmitSoundOn("Ability.Windrun", caster)
	caster:AddNewModifier(caster, self, "modifier_windrunner_windrun_bh_handle", {Duration = self:GetSpecialValueFor("buff_duration")})
	
	if caster:HasTalent("special_bonus_unique_windrunner_windrun_bh_1") then
		local knockback = caster:FindTalentValue("special_bonus_unique_windrunner_windrun_bh_1")
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), knockback ) ) do
			enemy:ApplyKnockBack( caster:GetAbsOrigin(), 0.5, 0.5, knockback, 0, caster, self, false)
		end
    end
end

modifier_windrunner_windrun_talent = class({})
LinkLuaModifier("modifier_windrunner_windrun_talent", "heroes/hero_windrunner/windrunner_windrun_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_windrunner_windrun_talent:OnCreated()
	self.crit = self:GetCaster():FindTalentValue("special_bonus_unique_windrunner_windrun_bh_2")
	self.duration = self:GetCaster():FindTalentValue("special_bonus_unique_windrunner_windrun_bh_2", "duration")
	
	self:GetParent():HookInModifier("GetModifierBaseCriticalChanceBonus", self)
end

function modifier_windrunner_windrun_talent:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierBaseCriticalChanceBonus", self)
end

function modifier_windrunner_windrun_talent:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = true}
end

function modifier_windrunner_windrun_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_windrunner_windrun_talent:GetModifierInvisibilityLevel()
	return 1.0
end

function modifier_windrunner_windrun_talent:GetModifierBaseCriticalChanceBonus()
	return self.crit
end

function modifier_windrunner_windrun_talent:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:Destroy()
		params.target:Break(self:GetAbility(), self:GetCaster(), self.duration)
	end
end

modifier_windrunner_windrun_talent_lesser = class(modifier_windrunner_windrun_talent)
LinkLuaModifier("modifier_windrunner_windrun_talent_lesser", "heroes/hero_windrunner/windrunner_windrun_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_windrunner_windrun_talent_lesser:OnCreated()
	local mult = self:GetCaster():FindTalentValue("special_bonus_unique_windrunner_powershot_bh_2") / 100
	self.crit = self:GetCaster():FindTalentValue("special_bonus_unique_windrunner_windrun_bh_2") * mult
	self.duration = self:GetCaster():FindTalentValue("special_bonus_unique_windrunner_windrun_bh_2", "duration") * mult
	
	self:GetParent():HookInModifier("GetModifierBaseCriticalChanceBonus", self)
end

modifier_windrunner_windrun_bh_handle = class({})
LinkLuaModifier("modifier_windrunner_windrun_bh_handle", "heroes/hero_windrunner/windrunner_windrun_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_windrunner_windrun_bh_handle:OnCreated(table)
	self:OnRefresh()
end

function modifier_windrunner_windrun_bh_handle:OnRefresh()
	self.movespeed = TernaryOperator( self:GetSpecialValueFor("scepter_ms"), self:GetCaster():HasScepter(), self:GetSpecialValueFor("movespeed_bonus_pct") )
	self.evasion = self:GetSpecialValueFor("evasion")
	
	self.aura_linger = self:GetSpecialValueFor("debuff_duration")
	self.aura_radius = self:GetSpecialValueFor("radius")
	
	if self:GetCaster():HasScepter() then
		self.limit = 9999
	end
	
	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )
    
	if IsServer() and self:GetCaster():HasTalent("special_bonus_unique_windrunner_windrun_bh_2") then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_windrunner_windrun_talent", {Duration =  self:GetSpecialValueFor("buff_duration")})
	end
end

function modifier_windrunner_windrun_bh_handle:OnDestroy()
	self:GetParent():HookOutModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_windrunner_windrun_bh_handle:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
    return state
end

function modifier_windrunner_windrun_bh_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    }
    return funcs
end

function modifier_windrunner_windrun_bh_handle:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end

function modifier_windrunner_windrun_bh_handle:GetMoveSpeedLimitBonus()
    return self.limit
end

function modifier_windrunner_windrun_bh_handle:GetModifierEvasion_Constant()
    return self.evasion
end

function modifier_windrunner_windrun_bh_handle:GetEffectName()
    return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function modifier_windrunner_windrun_bh_handle:IsAura()
    return true
end

function modifier_windrunner_windrun_bh_handle:GetAuraDuration()
    return self.aura_linger
end

function modifier_windrunner_windrun_bh_handle:GetAuraRadius()
    return self.aura_radius
end

function modifier_windrunner_windrun_bh_handle:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_windrunner_windrun_bh_handle:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_windrunner_windrun_bh_handle:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_windrunner_windrun_bh_handle:GetModifierAura()
    return "modifier_windrunner_windrun_bh_debuff"
end

function modifier_windrunner_windrun_bh_handle:IsDebuff()
    return false
end

modifier_windrunner_windrun_bh_lesser = class(modifier_windrunner_windrun_bh_handle)
LinkLuaModifier("modifier_windrunner_windrun_bh_lesser", "heroes/hero_windrunner/windrunner_windrun_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_windrunner_windrun_bh_lesser:OnRefresh()
	local mult = self:GetCaster():FindTalentValue("special_bonus_unique_windrunner_powershot_bh_2") / 100
	self.movespeed = TernaryOperator( self:GetSpecialValueFor("scepter_ms"), self:GetCaster():HasScepter(), self:GetSpecialValueFor("movespeed_bonus_pct") ) * mult
	self.evasion = self:GetSpecialValueFor("evasion") * mult
	
	self.aura_linger = self:GetSpecialValueFor("debuff_duration") * mult
	self.aura_radius = self:GetSpecialValueFor("radius")
	
	if self:GetCaster():HasScepter() then
		self.limit = 9999
	end
	
	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )
    
	if IsServer() and self:GetCaster():HasTalent("special_bonus_unique_windrunner_windrun_bh_2") then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_windrunner_windrun_talent_lesser", {Duration =  self:GetSpecialValueFor("buff_duration")})
	end
end

modifier_windrunner_windrun_bh_debuff = class({})
LinkLuaModifier("modifier_windrunner_windrun_bh_debuff", "heroes/hero_windrunner/windrunner_windrun_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_windrunner_windrun_bh_debuff:OnCreated()
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_windrunner_windrun_bh_1")
	if self.talent1 then
		if IsServer() then
			self.talent1Chill = self:GetCaster():FindTalentValue("special_bonus_unique_windrunner_windrun_bh_1",  "bonus_chill")
			self:GetParent():AddChill(self:GetAbility(), self:GetCaster(), self:GetSpecialValueFor("debuff_duration"), -self:GetSpecialValueFor("enemy_movespeed_bonus_pct"))
			self:StartIntervalThink(1)
		end
	else
		self.movespeed = self:GetSpecialValueFor("enemy_movespeed_bonus_pct")
	end
end

function modifier_windrunner_windrun_bh_debuff:OnIntervalThink()
	self:GetParent():AddChill(self:GetAbility(), self:GetCaster(), self:GetSpecialValueFor("debuff_duration"), self.talent1Chill)
end

function modifier_windrunner_windrun_bh_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_windrunner_windrun_bh_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed
end

function modifier_windrunner_windrun_bh_debuff:IsDebuff()
    return true
end

function modifier_windrunner_windrun_bh_debuff:GetEffectName()
    return "particles/units/heroes/hero_windrunner/windrunner_windrun_slow.vpcf"
end

modifier_windrunner_windrun_bh_charges = class({})
LinkLuaModifier("modifier_windrunner_windrun_bh_charges", "heroes/hero_windrunner/windrunner_windrun_bh", LUA_MODIFIER_MOTION_NONE)
if IsServer() then
    function modifier_windrunner_windrun_bh_charges:Update()
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetSpecialValueFor("scepter_charges")

		if self:GetStackCount() == self.kv.max_count then
			self:SetDuration(-1, true)
		elseif self:GetStackCount() > self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
		elseif self:GetStackCount() < self.kv.max_count then
			local duration = self.kv.replenish_time
            self:SetDuration(duration, true)
            self:StartIntervalThink(duration)
		end

        if self:GetStackCount() == 0 then
            self:GetAbility():StartCooldown(self:GetRemainingTime())
        end
    end

    function modifier_windrunner_windrun_bh_charges:OnCreated()
		kv = {
			max_count = self:GetSpecialValueFor("scepter_charges"),
			replenish_time = self:GetAbility():GetTrueCooldown()
		}
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv

        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
    end
	
	function modifier_windrunner_windrun_bh_charges:OnRefresh()
		self.kv.max_count = self:GetSpecialValueFor("scepter_charges")
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_windrunner_windrun_bh_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_windrunner_windrun_bh_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() and params.unit:HasScepter() then
			self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
			self.kv.max_count = self:GetSpecialValueFor("scepter_charges")
			
            local ability = params.ability
            if params.ability == self:GetAbility() then
                self:DecrementStackCount()
				ability:EndCooldown()
                self:Update()
			elseif string.find( params.ability:GetName(), "orb_of_renewal" ) and self:GetStackCount() < self.kv.max_count then
                self:IncrementStackCount()
                self:Update()
            end
        end

        return 0
    end

    function modifier_windrunner_windrun_bh_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		local octarine = caster:GetCooldownReduction()
		
		self.kv.replenish_time = self:GetSpecialValueFor("scepter_charge_restore_time") * octarine
		self.kv.max_count = self:GetSpecialValueFor("scepter_charges")
		
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
        end
    end
end

function modifier_windrunner_windrun_bh_charges:DestroyOnExpire()
    return false
end

function modifier_windrunner_windrun_bh_charges:IsPurgable()
    return false
end

function modifier_windrunner_windrun_bh_charges:RemoveOnDeath()
    return false
end

function modifier_windrunner_windrun_bh_charges:IsHidden()
	return not self:GetCaster():HasScepter()
end