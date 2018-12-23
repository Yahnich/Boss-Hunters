item_lance_of_longinus = class({})

LinkLuaModifier( "modifier_item_lance_of_longinus", "items/item_lance_of_longinus.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_lance_of_longinus:GetIntrinsicModifierName()
	return "modifier_item_lance_of_longinus"
end

modifier_item_lance_of_longinus = class(itemBaseClass)

function modifier_item_lance_of_longinus:OnCreated()
	self.range = self:GetSpecialValueFor("bonus_attack_range")
	self.chance = self:GetSpecialValueFor("pierce_chance")
end

function modifier_item_lance_of_longinus:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function modifier_item_lance_of_longinus:GetAccuracy(bInfo)
	if not bInfo then
		self.miss = self:RollPRNG(self.chance)
		if self.miss then
			return 100
		end
	else
		return self.chance
	end
end

function modifier_item_lance_of_longinus:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and self.miss then
			self.miss = false
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_lance_of_longinus_proc", {duration = 0.1})
		end
	end
end

function modifier_item_lance_of_longinus:GetModifierAttackRangeBonus()
	return self.range
end

function modifier_item_lance_of_longinus:IsHidden()
	return true
end

modifier_item_lance_of_longinus_proc = class({})
LinkLuaModifier( "modifier_item_lance_of_longinus_proc", "items/item_lance_of_longinus.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_lance_of_longinus_proc:OnCreated()
	if IsServer() then
		local damage = self:GetSpecialValueFor("pierce_damage") / 100
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage * self:GetCaster():GetAttackDamage(), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_DAMAGE)
	end
end

function modifier_item_lance_of_longinus_proc:IsHidden()
	return true
end