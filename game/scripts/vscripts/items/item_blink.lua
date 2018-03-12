item_blink_2 = class({})

function item_blink_2:PiercesDisableResistance()
    return true
end

function item_blink_2:GetIntrinsicModifierName()
	return "modifier_item_blink_handler"
end

function item_blink_2:GetCooldown(iLvl)
	return self:GetSpecialValueFor("charge_restore_time")
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
	ProjectileManager:ProjectileDodge( caster )
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
    function modifier_item_blink_handler:OnCreated()
		self.max_count = self:GetTalentSpecialValueFor("blink_charges")
		self.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
		self:GetAbility().lastChargeTime = self:GetAbility().lastChargeTime or {}
		if self.max_count > 1 then self:StartIntervalThink( FrameTime() ) end
    end
	
	function modifier_item_blink_handler:OnRefresh()
		self.max_count = self:GetTalentSpecialValueFor("blink_charges")
		self.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
    end
	
	function modifier_item_blink_handler:OnIntervalThink()
		self:GetAbility().lastChargeTime = self:GetAbility().lastChargeTime or {}
		for id, gameTime in ipairs ( self:GetAbility().lastChargeTime ) do
			self:GetAbility().lastChargeTime[id] = gameTime - FrameTime()
		end
		for id, gameTime in ipairs ( self:GetAbility().lastChargeTime ) do
			if gameTime <= 0 then 
				self:GetAbility():SetCurrentCharges( math.min(self:GetAbility():GetCurrentCharges() + 1, self.max_count ) )
				table.remove(self:GetAbility().lastChargeTime, id)
			end
		end
	end
	
	function modifier_item_blink_handler:OnTakeDamage(params)
        if params.unit == self:GetParent() then
			if self:GetAbility():GetCooldownTimeRemaining() < self.dmg_cd 
			and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) )
			and params.damage > self:GetMaxHealth() * 0.03
			and GameRules.gameDifficulty > 2 then
				self:GetAbility():EndCooldown()
				self:GetAbility():SetCooldown(self.dmg_cd)
			end
        end
        return 0
    end


    function modifier_item_blink_handler:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() and self.max_count > 1  then
            local ability = self:GetAbility()
            if params.ability == self:GetAbility() then
				ability:SetCurrentCharges( ability:GetCurrentCharges() - 1 )
				local chargeDur = ability:GetCooldownTimeRemaining()
				table.insert(ability.lastChargeTime, chargeDur)
				ability:EndCooldown()
				if ability:GetCurrentCharges() == 0 then ability:StartCooldown(ability.lastChargeTime[1]) end
			elseif params.ability:GetName() == "item_refresher" and ability:GetCurrentCharges() < self.max_count then
                ability:SetCurrentCharges( self:GetCurrentCharges() + 1 )
            end
        end

        return 0
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
	return true
end