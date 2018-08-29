item_lifeweavers_clockwork = class({})
LinkLuaModifier( "modifier_item_lifeweavers_clockwork_passive", "items/item_lifeweavers_clockwork.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_lifeweavers_clockwork:GetIntrinsicModifierName()
	return "modifier_item_lifeweavers_clockwork_passive"
end

modifier_item_lifeweavers_clockwork_passive = class({})

function modifier_item_lifeweavers_clockwork_passive:OnCreated()
	self.cdr = self:GetSpecialValueFor("cooldown_reduction")
	self.mr = self:GetSpecialValueFor("bonus_mana_regen")
	self.intellect = self:GetSpecialValueFor("bonus_intellect")
	self.bonus_mana = self:GetSpecialValueFor("bonus_mana")
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
end

function modifier_item_lifeweavers_clockwork_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_MANA_BONUS,
			MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_lifeweavers_clockwork_passive:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and self:GetParent():GetHealth() > 0 and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		local flHeal = params.damage * self.lifesteal
		if params.inflictor then ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self) end
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end

function modifier_item_lifeweavers_clockwork_passive:GetCooldownReduction(params)
	return self.cdr
end

function modifier_item_lifeweavers_clockwork_passive:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_lifeweavers_clockwork_passive:GetModifierConstantManaRegen()
	return self.mr
end

function modifier_item_lifeweavers_clockwork_passive:GetModifierBonusStats_Intellect()
	return self.intellect
end

function modifier_item_lifeweavers_clockwork_passive:IsHidden()
	return true
end

function modifier_item_lifeweavers_clockwork_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end