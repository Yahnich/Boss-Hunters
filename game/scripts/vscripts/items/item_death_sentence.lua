item_death_sentence = class({})

function item_death_sentence:GetIntrinsicModifierName()
	return "modifier_item_death_sentence_passive"
end

function item_death_sentence:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:RemoveModifierByNameAndCaster("modifier_item_death_sentence_active", caster)
	if self.currTarget and not self.currTarget:IsNull() then self.currTarget:RemoveModifierByNameAndCaster("modifier_item_death_sentence_active", caster) end
	self.currTarget = target
	target:AddNewModifier(caster, self, "modifier_item_death_sentence_active", {})
end

LinkLuaModifier( "modifier_item_death_sentence_passive", "items/item_death_sentence.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_death_sentence_passive = class(itemBaseClass)
function modifier_item_death_sentence_passive:OnCreated()
	self.castrange = self:GetAbility():GetSpecialValueFor("bonus_cast_range")
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.int = self:GetSpecialValueFor("bonus_int")
	self.agi = self:GetSpecialValueFor("bonus_agi")
	self.accuracy = self:GetSpecialValueFor("bonus_accuracy")
	self.targetrange = self:GetAbility():GetSpecialValueFor("target_cast_range")
	self.target_acc = self:GetSpecialValueFor("target_accuracy")
end

function modifier_item_death_sentence_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS, 
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, 
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_item_death_sentence_passive:GetModifierCastRangeBonus()
	local castrange = self.castrange
	if self:GetAbility().currTarget 
	and not self:GetAbility().currTarget:IsNull() then
		castrange = castrange + self.targetrange
	end
	return castrange
end

function modifier_item_death_sentence_passive:GetAccuracy(params)
	if params == true then
		acc = self.accuracy
		if self:GetAbility().currTarget then
			local acc = acc + self.target_acc
		end
	else
		acc = self.accuracy
		if params.target == self:GetAbility().currTarget then
			local acc = acc + self.target_acc
		end
	end
	return acc
end

function modifier_item_death_sentence_passive:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_death_sentence_passive:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_item_death_sentence_passive:GetModifierBonusStats_Agility()
	return self.agi
end

function modifier_item_death_sentence_passive:IsHidden()
	return true
end

function modifier_item_death_sentence_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier( "modifier_item_death_sentence_active", "items/item_death_sentence.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_death_sentence_active = class({})

function modifier_item_death_sentence_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_item_death_sentence_active:OnCreated()
	self:GetAbility().currTarget = self:GetParent()
end

function modifier_item_death_sentence_active:OnDestroy()
	self:GetAbility().currTarget = nil
end

function modifier_item_death_sentence_active:GetModifierIncomingDamage_Percentage(params)
	if params.attacker == self:GetCaster() then
		return self:GetSpecialValueFor("target_amp")
	end
end

function modifier_item_death_sentence_active:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_death_sentence_active:GetEffectName()
	return "particles/econ/items/bounty_hunter/bounty_hunter_hunters_hoard/bounty_hunter_hoard_track_trail.vpcf"
end