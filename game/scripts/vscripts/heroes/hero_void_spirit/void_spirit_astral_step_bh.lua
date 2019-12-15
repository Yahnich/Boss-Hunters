void_spirit_astral_step_bh = class({})

function void_spirit_astral_step_bh:IsStealable()
	return false
end

function void_spirit_astral_step_bh:IsHiddenWhenStolen()
	return false
end

function void_spirit_astral_step_bh:GetIntrinsicModifierName()
	return "modifier_void_spirit_astral_step_charges"
end

function void_spirit_astral_step_bh:HasCharges()
	return true
end

function void_spirit_astral_step_bh:OnAbilityPhaseStart()
	EmitSoundOn( "Hero_VoidSpirit.AstralStep.Start", self:GetCaster() )
	return true
end

function void_spirit_astral_step_bh:OnAbilityPhaseInterrupted()
	StopSoundOn( "Hero_VoidSpirit.AstralStep.Start", self:GetCaster() )
end

function void_spirit_astral_step_bh:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetAbsOrigin()
	local position = self:GetCursorPosition()
	position = origin + CalculateDirection( position, caster ) * math.max( self:GetTalentSpecialValueFor("min_travel_distance"), math.min( CalculateDistance( position, caster ), self:GetTalentSpecialValueFor("max_travel_distance") ) )
	ParticleManager:FireParticle( "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step.vpcf", PATTACH_POINT, caster, {[0] = origin, [1] = position} )
	FindClearSpaceForUnit( caster, position, true )
	
	local delay = self:GetTalentSpecialValueFor("pop_damage_delay")
	
	local talent1 = caster:HasTalent("special_bonus_unique_void_spirit_astral_step_2")
	local talent1Value = caster:FindTalentValue("special_bonus_unique_void_spirit_astral_step_2") / 100
	for _, enemy in ipairs( caster:FindEnemyUnitsInLine( origin, position, self:GetTalentSpecialValueFor("radius") * 2 ) ) do
		if enemy:TriggerSpellAbsorb( self ) then
			enemy:AddNewModifier( caster, self, "modifier_void_spirit_astral_step_debuff", {duration = delay} )
			local hp = enemy:GetHealth()
			caster:PerformAbilityAttack(enemy, true, self)
			if talent1 then
				caster:HealEvent( hp * talent1Value, self, caster )
			end
			local damage = hp - enemy:GetHealth()
		end
		EmitSoundOn( "Hero_VoidSpirit.AstralStep.Target", caster )
	end
	
	EmitSoundOn( "Hero_VoidSpirit.AstralStep.End", caster )
	
	if caster:HasTalent("special_bonus_unique_void_spirit_astral_step_1") then
		caster:AddNewModifier( caster, self, "modifier_invisible", {duration = caster:FindTalentValue("special_bonus_unique_void_spirit_astral_step_1")} )
	end
end

modifier_void_spirit_astral_step_debuff = class({})
LinkLuaModifier("modifier_void_spirit_astral_step_debuff", "heroes/hero_void_spirit/void_spirit_astral_step_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_void_spirit_astral_step_debuff:OnCreated()
		self.slow = self:GetTalentSpecialValueFor("movement_slow_pct") * (-1)
		self.dmg = self:GetTalentSpecialValueFor("pop_damage")
	end
	
	function modifier_void_spirit_astral_step_debuff:OnCreated()
		self:OnDestroy()
		self.slow = self:GetTalentSpecialValueFor("movement_slow_pct") * (-1)
		self.dmg = self:GetTalentSpecialValueFor("pop_damage")
	end

	function modifier_void_spirit_astral_step_debuff:OnDestroy()
		EmitSoundOn( "Hero_VoidSpirit.AstralStep.MarkExplosion", self:GetParent() )
		local damage = self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.dmg )
		if self:GetCaster():HasTalent("special_bonus_unique_void_spirit_astral_step_2") then
			caster:HealEvent( damage * self:GetCaster():FindTalentValue("special_bonus_unique_void_spirit_astral_step_2") / 100, self, caster )
		end
	end
end

function modifier_void_spirit_astral_step_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_void_spirit_astral_step_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_void_spirit_astral_step_debuff:GetEffectName()
	return "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step_dmg.vpcf"
end

modifier_void_spirit_astral_step_charges = class({})
LinkLuaModifier("modifier_void_spirit_astral_step_charges", "heroes/hero_void_spirit/void_spirit_astral_step_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
    function modifier_void_spirit_astral_step_charges:Update()
		self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
		self.kv.max_count = self:GetTalentSpecialValueFor("max_charges")
		if self:GetStackCount() == self.kv.max_count then
			self:SetDuration(-1, true)
		elseif self:GetStackCount() > self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
		elseif self:GetStackCount() < self.kv.max_count and self:GetRemainingTime() < 0.1 then
			local duration = self.kv.replenish_time* self:GetCaster():GetCooldownReduction()
            self:SetDuration(duration, true)
            self:StartIntervalThink(duration)
		elseif self:GetStackCount() < self.kv.max_count then
			self:StartIntervalThink( self:GetRemainingTime() )
		end
        if self:GetStackCount() == 0 then
            self:GetAbility():StartCooldown(self:GetRemainingTime())
        end
    end

    function modifier_void_spirit_astral_step_charges:OnCreated()
		kv = {
			max_count = self:GetTalentSpecialValueFor("max_charges"),
			replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
		}
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv

        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
    end
	
	function modifier_void_spirit_astral_step_charges:OnRefresh()
		self.kv.max_count = self:GetTalentSpecialValueFor("max_charges")
		self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_void_spirit_astral_step_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_void_spirit_astral_step_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
			self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
			self.kv.max_count = self:GetTalentSpecialValueFor("max_charges")
			
            local ability = params.ability
            if params.ability == self:GetAbility() then
                self:DecrementStackCount()
				ability:EndCooldown()
                self:Update()
			elseif params.ability:GetName() == "item_refresher" and self:GetStackCount() < self.kv.max_count then
                self:IncrementStackCount()
                self:Update()
            end
        end

        return 0
    end

    function modifier_void_spirit_astral_step_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		local octarine = caster:GetCooldownReduction()
		
		self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
		self.kv.max_count = self:GetTalentSpecialValueFor("max_charges")
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
        end
    end
end

function modifier_void_spirit_astral_step_charges:DestroyOnExpire()
    return false
end

function modifier_void_spirit_astral_step_charges:IsPurgable()
    return false
end

function modifier_void_spirit_astral_step_charges:RemoveOnDeath()
    return false
end