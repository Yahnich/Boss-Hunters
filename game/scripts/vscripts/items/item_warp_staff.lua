item_warp_staff = class({})

function item_warp_staff:PiercesDisableResistance()
    return true
end

function item_warp_staff:GetIntrinsicModifierName()
	return "modifier_item_warp_staff_handler"
end

function item_warp_staff:GetCooldown(iLvl)
	return self:GetSpecialValueFor("charge_restore_time")
end

function item_warp_staff:OnSpellStart()
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

modifier_item_warp_staff_handler = class({})
LinkLuaModifier("modifier_item_warp_staff_handler", "items/item_warp_staff", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
    function modifier_item_warp_staff_handler:OnCreated()
		self.max_count = self:GetTalentSpecialValueFor("blink_charges")
		self.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
		self:GetAbility().lastChargeTime = self:GetAbility().lastChargeTime or {}
		self:StartIntervalThink( FrameTime() )
    end
	
	function modifier_item_warp_staff_handler:OnRefresh()
		self.max_count = self:GetTalentSpecialValueFor("blink_charges")
		self.replenish_time = self:GetTalentSpecialValueFor("charge_restore_time")
    end
	
	function modifier_item_warp_staff_handler:OnIntervalThink()
		local ability = self:GetAbility()
		ability.lastChargeTime = ability.lastChargeTime or {}
		for id, gameTime in ipairs ( ability.lastChargeTime ) do
			ability.lastChargeTime[id] = gameTime - FrameTime()
		end
		for id, gameTime in ipairs ( ability.lastChargeTime ) do
			if gameTime <= 0 then 
				ability:SetCurrentCharges( math.min(ability:GetCurrentCharges() + 1, self.max_count ) )
				table.remove(ability.lastChargeTime, id)
			end
		end
	end

    function modifier_item_warp_staff_handler:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
            local ability = self:GetAbility()
            if params.ability == self:GetAbility() then
				ability:SetCurrentCharges( math.max( ability:GetCurrentCharges() - 1, 0 ) )
				local chargeDur = ability:GetCooldownTimeRemaining()
				if #ability.lastChargeTime < self.max_count then 
					table.insert(ability.lastChargeTime, chargeDur)
				else
					table.remove(ability.lastChargeTime, 1)
					table.insert(ability.lastChargeTime, chargeDur)
				end
				ability:EndCooldown()
				if ability:GetCurrentCharges() == 0 then ability:StartCooldown(ability.lastChargeTime[1]) end
			elseif params.ability:GetName() == "item_flashback" and ability:GetCurrentCharges() < self.max_count then
                ability:SetCurrentCharges( ability:GetCurrentCharges() + 1 )
            end
        end

        return 0
    end
end

function modifier_item_warp_staff_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
			}
end

function modifier_item_warp_staff_handler:GetModifierConstantManaRegen()
	return self:GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_warp_staff_handler:GetModifierBonusStats_Intellect()
	return self:GetSpecialValueFor("bonus_intellect")
end

function modifier_item_warp_staff_handler:DestroyOnExpire()
    return false
end

function modifier_item_warp_staff_handler:IsPurgable()
    return false
end

function modifier_item_warp_staff_handler:RemoveOnDeath()
    return false
end

function modifier_item_warp_staff_handler:IsHidden()
	return true
end

function modifier_item_warp_staff_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end