death_prophet_spirit_siphon_bh = class({})

function death_prophet_spirit_siphon_bh:IsStealable()
	return true
end

function death_prophet_spirit_siphon_bh:IsHiddenWhenStolen()
	return false
end

function death_prophet_spirit_siphon_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_death_prophet_spirit_siphon_2") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
end

function death_prophet_spirit_siphon_bh:GetIntrinsicModifierName()
	return "modifier_death_prophet_spirit_siphon_bh_charges"
end

function death_prophet_spirit_siphon_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	caster:EmitSound("Hero_DeathProphet.SpiritSiphon.Cast")
	if self:GetCaster():HasTalent("special_bonus_unique_death_prophet_spirit_siphon_2") then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() ) ) do
			enemy:AddNewModifier(caster, self, "modifier_death_prophet_spirit_siphon_bh_debuff", {duration = self:GetTalentSpecialValueFor("haunt_duration")})
		end
	else
		target:AddNewModifier(caster, self, "modifier_death_prophet_spirit_siphon_bh_debuff", {duration = self:GetTalentSpecialValueFor("haunt_duration")})
	end
end

modifier_death_prophet_spirit_siphon_bh_debuff = class({})
LinkLuaModifier( "modifier_death_prophet_spirit_siphon_bh_debuff", "heroes/hero_death_prophet/death_prophet_spirit_siphon_bh.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_death_prophet_spirit_siphon_bh_debuff:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage_pct") / 100
	self.slow = math.abs( self:GetTalentSpecialValueFor("movement_slow") ) * (-1)
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_death_prophet_spirit_siphon_1")
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		self.range = self:GetAbility():GetTrueCastRange() + self:GetTalentSpecialValueFor("siphon_buffer")
		self.nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_death_prophet/death_prophet_spiritsiphon.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControlEnt(self.nFX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.nFX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.nFX, 5, Vector(self:GetRemainingTime(), 0,0 ) )
		self:GetParent():EmitSound("Hero_DeathProphet.SpiritSiphon.Target")
		if self.talent1 then
			local damage = self:GetParent():GetMaxHealth() * self.damage * self:GetRemainingTime()
			local heal = ability:DealDamage( caster, parent, damage )
			caster:HealEvent( heal, ability, caster)
			self:StartIntervalThink(1)
		else
			self:StartIntervalThink( 0.2 * self:GetRemainingTime() / self:GetTalentSpecialValueFor("haunt_duration") )
		end
	end
end

function modifier_death_prophet_spirit_siphon_bh_debuff:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("damage_pct") / 100
	self.slow = math.abs( self:GetTalentSpecialValueFor("movement_slow") ) * (-1)
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_death_prophet_spirit_siphon_1")
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		self.range = self:GetAbility():GetTrueCastRange() + self:GetTalentSpecialValueFor("siphon_buffer")
		if self.talent1 then
			local damage = self:GetParent():GetMaxHealth() * self.damage * self:GetRemainingTime()
			local heal = ability:DealDamage( caster, parent, damage )
			caster:HealEvent( heal, ability, caster)
			self:StartIntervalThink(1)
		else
			self:StartIntervalThink( 0.2 * self:GetRemainingTime() / self:GetTalentSpecialValueFor("haunt_duration") )
		end
	end
end


function modifier_death_prophet_spirit_siphon_bh_debuff:OnIntervalThink()
	if self.talent1 then
		self:Destroy()
	else
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local heal = ability:DealDamage( caster, parent, parent:GetMaxHealth() * self.damage * 0.2 )
		caster:HealEvent( heal, ability, caster)
		if CalculateDistance( caster, parent ) > self.range then
			self:Destroy()
		end
	end
end

function modifier_death_prophet_spirit_siphon_bh_debuff:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_DeathProphet.SpiritSiphon.Target")
		ParticleManager:ClearParticle(self.nFX)
	end
end

function modifier_death_prophet_spirit_siphon_bh_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_death_prophet_spirit_siphon_bh_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

modifier_death_prophet_spirit_siphon_bh_charges = class({})
LinkLuaModifier( "modifier_death_prophet_spirit_siphon_bh_charges", "heroes/hero_death_prophet/death_prophet_spirit_siphon_bh.lua", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
    function modifier_death_prophet_spirit_siphon_bh_charges:Update()
		local caster = self:GetCaster()
		self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
		self.kv.max_count = math.floor( self:GetTalentSpecialValueFor("max_charges") )
		
		if self:GetStackCount() == self.kv.max_count then
			self:SetDuration(-1, true)
		elseif self:GetStackCount() > self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
		elseif self:GetStackCount() < self.kv.max_count then
			if self:GetRemainingTime() < -1 then
				local duration = self.kv.replenish_time * caster:GetCooldownReduction() 
				self:SetDuration(duration, true)
			end
			self:StartIntervalThink(self:GetRemainingTime())
			if self:GetStackCount() == 0 then
				self:GetAbility():StartCooldown(self:GetRemainingTime())
			end
		end
    end

    function modifier_death_prophet_spirit_siphon_bh_charges:OnCreated()
		kv = {
			max_count = math.floor( self:GetTalentSpecialValueFor("max_charges") ),
			replenish_time = self:GetTalentSpecialValueFor("charge_restore_time"),
			start_count = math.floor( self:GetTalentSpecialValueFor("max_charges") )
		}
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv
	
        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
		else
			self:SetDuration(-1, true)
        end
    end
	
	function modifier_death_prophet_spirit_siphon_bh_charges:OnRefresh()
		self.kv.max_count = math.floor( self:GetTalentSpecialValueFor("max_charges") )
		self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_death_prophet_spirit_siphon_bh_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_death_prophet_spirit_siphon_bh_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
			self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
			self.kv.max_count = math.floor( self:GetTalentSpecialValueFor("max_charges") )
			
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

    function modifier_death_prophet_spirit_siphon_bh_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		
		self:StartIntervalThink(-1)
		
		local duration = self.kv.replenish_time * caster:GetCooldownReduction() 
		self:SetDuration(duration, true)
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
		elseif stacks == self.kv.max_count then
			self:SetDuration( -1, true )
        end
    end
end

function modifier_death_prophet_spirit_siphon_bh_charges:DestroyOnExpire()
    return false
end

function modifier_death_prophet_spirit_siphon_bh_charges:IsPurgable()
    return false
end

function modifier_death_prophet_spirit_siphon_bh_charges:RemoveOnDeath()
    return false
end