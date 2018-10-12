item_legionnaires_dualswords = class({})

function item_legionnaires_dualswords:GetIntrinsicModifierName()
	return "modifier_item_legionnaires_dualswords"
end

modifier_item_legionnaires_dualswords = class(itemBaseClass)
LinkLuaModifier( "modifier_item_legionnaires_dualswords", "items/item_legionnaires_dualswords.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_legionnaires_dualswords:OnCreated()
	self.attackSpeed = self:GetSpecialValueFor("bonus_attackspeed")
	self.strength = self:GetSpecialValueFor("bonus_strength")
	self.agility = self:GetSpecialValueFor("bonus_agility")
	self.movespeed = self:GetSpecialValueFor("bonus_movespeed")
	
	self.disableChance = self:GetSpecialValueFor("disable_chance")
	self.disableDuration = self:GetSpecialValueFor("disable_duration")
end

function modifier_item_legionnaires_dualswords:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
end

function modifier_item_legionnaires_dualswords:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and RollPercentage(self.disableChance) then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_legionnaires_dualswords_debuff", {duration = self.disableDuration})
			EmitSoundOn("DOTA_Item.Maim", params.target)
		end
	end
end

function modifier_item_legionnaires_dualswords:GetModifierAttackSpeedBonus_Constant()
	return self.attackSpeed
end

function modifier_item_legionnaires_dualswords:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_item_legionnaires_dualswords:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_item_legionnaires_dualswords:GetModifierBonusStats_Agility()
	return self.agility
end

function modifier_item_legionnaires_dualswords:IsHidden()
	return true
end

function modifier_item_legionnaires_dualswords:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


LinkLuaModifier( "modifier_legionnaires_dualswords_debuff", "items/item_legionnaires_dualswords.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_legionnaires_dualswords_debuff = class({})

function modifier_legionnaires_dualswords_debuff:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("attack_slow")
end

function modifier_legionnaires_dualswords_debuff:OnRefresh()
	self.slow = self:GetAbility():GetSpecialValueFor("attack_slow")
end

function modifier_legionnaires_dualswords_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_DISABLE_HEALING
			}
end

function modifier_legionnaires_dualswords_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.slow
end

function modifier_legionnaires_dualswords_debuff:GetDisableHealing()
	return 1
end

function modifier_legionnaires_dualswords_debuff:GetEffectName()
	return "particles/items2_fx/sange_maim.vpcf"
end