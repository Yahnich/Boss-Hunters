item_ferrum_ascensus = class({})

function item_ferrum_ascensus:GetIntrinsicModifierName()
	return "modifier_item_ferrum_ascensus"
end

modifier_item_ferrum_ascensus = class(itemBaseClass)
LinkLuaModifier( "modifier_item_ferrum_ascensus", "items/item_ferrum_ascensus.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_ferrum_ascensus:OnCreated()
	self.attackSpeed = self:GetSpecialValueFor("bonus_attackspeed")
	self.strength = self:GetSpecialValueFor("bonus_strength")
	self.agility = self:GetSpecialValueFor("bonus_agility")
	self.movespeed = self:GetSpecialValueFor("bonus_movespeed")
	self.spellamp = self:GetSpecialValueFor("bonus_spell_amp")
	self.manacost = self:GetSpecialValueFor("mana_cost_reduction")
	
	self.disableChance = self:GetSpecialValueFor("disable_chance")
	self.disableDuration = self:GetSpecialValueFor("disable_duration")
end

function modifier_item_ferrum_ascensus:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
			}
end

function modifier_item_ferrum_ascensus:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and RollPercentage(self.disableChance) then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_ferrum_ascensus_debuff", {duration = self.disableDuration})
			EmitSoundOn("DOTA_Item.Maim", params.target)
		end
	end
end

function modifier_item_ferrum_ascensus:GetModifierSpellAmplify_Percentage()
	return self.spellamp
end

function modifier_item_ferrum_ascensus:GetModifierPercentageManacost()
	return self.manacost
end

function modifier_item_ferrum_ascensus:GetModifierAttackSpeedBonus()
	return self.attackSpeed
end

function modifier_item_ferrum_ascensus:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_item_ferrum_ascensus:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_item_ferrum_ascensus:GetModifierBonusStats_Agility()
	return self.agility
end

function modifier_item_ferrum_ascensus:IsHidden()
	return true
end

function modifier_item_ferrum_ascensus:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


LinkLuaModifier( "modifier_ferrum_ascensus_debuff", "items/item_ferrum_ascensus.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_ferrum_ascensus_debuff = class({})

function modifier_ferrum_ascensus_debuff:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("attack_slow")
end

function modifier_ferrum_ascensus_debuff:OnRefresh()
	self.slow = self:GetAbility():GetSpecialValueFor("attack_slow")
end

function modifier_ferrum_ascensus_debuff:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_DISABLE_HEALING
			}
end

function modifier_ferrum_ascensus_debuff:GetModifierAttackSpeedBonus()
	return self.slow
end

function modifier_ferrum_ascensus_debuff:GetDisableHealing()
	return 1
end

function modifier_ferrum_ascensus_debuff:GetEffectName()
	return "particles/items2_fx/sange_maim.vpcf"
end