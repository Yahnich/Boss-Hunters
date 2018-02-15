item_blink_2 = class({})

function item_blink_2:PiercesDisableResistance()
    return true
end

function item_blink_2:GetIntrinsicModifierName()
	return "modifier_item_blink_handler"
end

function item_blink_2:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	
	local distance = CalculateDistance( targetPos, caster )
	local direction = CalculateDirection( targetPos, caster )
	if distance > self:GetSpecialValueFor("blink_range") then
		targetPos = caster:GetAbsOrigin() + direction * self:GetSpecialValueFor("blink_range")
	end
	EmitSoundOn("DOTA_Item.BlinkDagger.Activate", caster)
	ParticleManager:FireParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	FindClearSpaceForUnit(caster, targetPos, true)
	ParticleManager:FireParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	EmitSoundOn("DOTA_Item.BlinkDagger.NailedIt", caster)
end

item_blink = class(item_blink_2)
item_blink_3 = class(item_blink_2)
item_blink_4 = class(item_blink_2)
item_blink_5 = class(item_blink_2)

modifier_item_blink_handler = class({})
LinkLuaModifier("modifier_item_blink_handler", "items/item_blink", LUA_MODIFIER_MOTION_NONE)

function modifier_item_blink_handler:OnCreated()
	self.cd = self:GetSpecialValueFor("blink_damage_cooldown")
end

if IsServer() then
    function modifier_item_blink_handler:Update()
		self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
		self.kv.max_count = self:GetTalentSpecialValueFor("blink_charges")
	
		if self:GetStackCount() >= self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
		elseif self:GetStackCount() > 0 then
			local duration = self.kv.replenish_time* get_octarine_multiplier( self:GetCaster() )
			self:SetDuration(duration, true)
			self:StartIntervalThink(duration)
		else
			self:GetAbility():StartCooldown(self:GetRemainingTime())
		end
		
		if not self:GetAbility():IsCooldownReady() then
			local duration = self:GetAbility():GetCooldownTimeRemaining()
			self:SetDuration(duration, true)
			self:StartIntervalThink(duration)
		end
		
		self:GetAbility():SetCurrentCharges(self:GetStackCount())
    end

    function modifier_item_blink_handler:OnCreated()
		kv = {
			start_count = self:GetAbility():GetCurrentCharges(),
			max_count = self:GetSpecialValueFor("blink_charges"),
			replenish_time = self:GetSpecialValueFor("charge_restore_time")
		}
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv
		
		self.dmg_cd = self:GetSpecialValueFor("blink_damage_cooldown")

        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
    end
	
	function modifier_item_blink_handler:OnRefresh()
		self.kv.max_count = self:GetTalentSpecialValueFor("blink_charges")
		self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
	function modifier_item_blink_handler:OnTakeDamage(params)
        if params.unit == self:GetParent() then
			if self:GetAbility():GetCooldownTimeRemaining() < self.dmg_cd 
			and ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) )
			and params.damage > self:GetMaxHealth() * 0.05 
			and GameRules.gameDifficulty > 2 then
				self:GetAbility():EndCooldown()
				self:GetAbility():SetCooldown(self.dmg_cd)
			end
        end
        return 0
    end


    function modifier_item_blink_handler:OnAbilityFullyCast(params)
		print(params.unit, self:GetParent())
        if params.unit == self:GetParent() then
			self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
			self.kv.max_count = self:GetTalentSpecialValueFor("blink_charges")
			
            local ability = params.ability
			print(params.ability == self:GetAbility() )
            if params.ability == self:GetAbility() then
                self:DecrementStackCount()
				if self.kv.max_count == 1 then ability:EndCooldown() end
                self:Update()
			elseif params.ability:GetName() == "item_refresher" and self:GetStackCount() < self.kv.max_count then
                self:IncrementStackCount()
                self:Update()
            end
        end

        return 0
    end

    function modifier_item_blink_handler:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		local octarine = get_octarine_multiplier(caster)
		
		self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
		self.kv.max_count = self:GetTalentSpecialValueFor("blink_charges")
		
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
		else
			self:SetDuration(-1, true)
        end
    end
end

function modifier_item_blink_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, 
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS, 
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
			MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_blink_handler:GetModifierBonusStats_Strength()
	return self:GetSpecialValueFor("all_stats")
end

function modifier_item_blink_handler:GetModifierBonusStats_Agility()
	return self:GetSpecialValueFor("all_stats")
end

function modifier_item_blink_handler:GetModifierBonusStats_Intellect()
	return self:GetSpecialValueFor("all_stats")
end

function modifier_item_blink_handler:DestroyOnExpire()
    return false
end

function modifier_item_blink_handler:IsPurgable()
    return false
end

function modifier_item_blink_handler:RemoveOnDeath()
    return false
end

function modifier_item_blink_handler:IsHidden()
	return false
end