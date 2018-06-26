item_kitteh_amulet = class({})

function item_kitteh_amulet:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	local ogPos = caster:GetAbsOrigin()
	
	local distance = CalculateDistance( targetPos, caster )
	local direction = CalculateDirection( targetPos, caster )
	if distance > 9999 then
		targetPos = caster:GetAbsOrigin() + direction * 9999
	end

	EmitSoundOn("DOTA_Item.BlinkDagger.Activate", caster)
	ParticleManager:FireParticle("particles/econ/events/ti6/blink_dagger_start_ti6_lvl2.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	FindClearSpaceForUnit(caster, targetPos, true)
	ProjectileManager:ProjectileDodge( caster )
	ParticleManager:FireParticle("particles/econ/events/ti6/blink_dagger_end_ti6_lvl2.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	EmitSoundOn("DOTA_Item.BlinkDagger.NailedIt", caster)
	
	local illusion = caster:ConjureImage( ogPos, 30, 0, 0 )
	illusion:SetThreat( caster:GetThreat() )
	caster:SetThreat( 0 )
	caster:RefreshAllCooldowns(true)
end


function item_kitteh_amulet:GetIntrinsicModifierName()
	return "modifier_item_kitteh_amulet_passive"
end


modifier_item_kitteh_amulet_passive = class({})
LinkLuaModifier( "modifier_item_kitteh_amulet_passive", "items/item_kitteh_amulet.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_kitteh_amulet_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
			MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
			MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
			MODIFIER_PROPERTY_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_MOVESPEED_MAX,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS_UNIQUE,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
			MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_CAST_RANGE_BONUS,
			MODIFIER_PROPERTY_CAST_RANGE_BONUS_TARGET,
			MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}

end

function modifier_item_kitteh_amulet_passive:GetModifierSpellAmplify_Percentage()
		return 1000
end

function modifier_item_kitteh_amulet_passive:GetModifierConstantManaRegen()
		return 8888
end

function modifier_item_kitteh_amulet_passive:GetModifierConstantHealthRegen()
		return 8888
end

function modifier_item_kitteh_amulet_passive:GetModifierHealthRegenPercentage()
		return 25
end

function modifier_item_kitteh_amulet_passive:GetModifierManaRegenPercentage()
		return 25
end

function modifier_item_kitteh_amulet_passive:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and self:GetParent():GetHealth() > params.damage then
		local flHeal = params.damage * 100
		if params.inflictor then ParticleManager:FireParticle ("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self) end
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
		end
end

function modifier_item_kitteh_amulet_passive:GetModifierMoveSpeed_AbsoluteMin()
	return 550
end

function modifier_item_kitteh_amulet_passive:GetModifierMoveSpeedBonus_Constant()
	return 550
end

function modifier_item_kitteh_amulet_passive:GetModifierMoveSpeed_Limit()
	return 5000
end

function modifier_item_kitteh_amulet_passive:GetModifierMoveSpeedBonus_Special_Boots()
	return 550
end

function modifier_item_kitteh_amulet_passive:GetModifierMoveSpeed_Max()
	return 5000
end

function modifier_item_kitteh_amulet_passive:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			local parent = self:GetParent()
			parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1)
				Timers:CreateTimer(0.1, function()
				EmitSoundOn("DOTA_Item.SkullBasher", params.target)
				parent:PerformGenericAttack(params.target, true, 0, false, true)  
				self:GetAbility():Stun(params.target, 1, true)
				GetAbility():DealDamage(self:GetParent(), params.target, 100, {damage_type = DAMAGE_TYPE_PURE})
				params.target:DisableHealing(8)
			end)
		end
	end

end

function modifier_item_kitteh_amulet_passive:GetModifierAttackRangeBonusUnique()
		return 800
end


function modifier_item_kitteh_amulet_passive:GetModifierPercentageCooldownStacking()
		return 95
end


function modifier_item_kitteh_amulet_passive:GetModifierPercentageCooldown()
		return 95
end


function modifier_item_kitteh_amulet_passive:GetModifierTotal_ConstantBlock()
		return 500
end


function modifier_item_kitteh_amulet_passive:GetModifierAttackRangeBonus()
		return 500
end

function modifier_item_kitteh_amulet_passive:GetModifierPreAttack_CriticalStrike()
	if RollPercentage(95) then
		return 500
	end
end

function modifier_item_kitteh_amulet_passive:GetModifierHealthBonus()
	return self:GetParent():GetStrength() * 50
end

function modifier_item_kitteh_amulet_passive:GetModifierBaseDamageOutgoing_Percentage()
	return 100
end

function modifier_item_kitteh_amulet_passive:GetModifierBonusStats_Intellect()
	return 888
end

function modifier_item_kitteh_amulet_passive:GetModifierBonusStats_Strength()
	return 888
end

function modifier_item_kitteh_amulet_passive:GetModifierBonusStats_Agility()
	return 888
end

function modifier_item_kitteh_amulet_passive:GetModifierCastRangeBonus()
	return 5000
end

function modifier_item_kitteh_amulet_passive:GetModifierCastRangeBonusTarget()
	return 5000
end

function modifier_item_kitteh_amulet_passive:GetModifierCastRangeBonusStacking()
	return 5000
end

function modifier_item_kitteh_amulet_passive:GetModifierMoveSpeedBonus_Percentage()
	return 100
end

function modifier_item_kitteh_amulet_passive:IsHidden()
	return true
end

function modifier_item_kitteh_amulet_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
