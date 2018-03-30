item_arcane_reaver = class({})

function item_arcane_reaver:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_arcane_reaver_active") then
		return "custom/arcane_reaver_on"
	else
		return "custom/arcane_reaver_off"
	end
end

function item_arcane_reaver:GetIntrinsicModifierName()
	return "modifier_item_arcane_reaver"
end

function item_arcane_reaver:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_item_arcane_reaver_active", {})
	else
		caster:RemoveModifierByName("modifier_item_arcane_reaver_active")
	end
end

modifier_item_arcane_reaver_active = class({})
LinkLuaModifier( "modifier_item_arcane_reaver_active", "items/item_arcane_reaver.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_arcane_reaver_active:GetTexture()
	return "custom/arcane_reaver_on"
end

function modifier_item_arcane_reaver_active:OnCreated()
	self.dmgPct = self:GetSpecialValueFor("minus_damage")
	
	self.onHitDmg = self:GetSpecialValueFor("damage_pct") / 100
	self.manaBurn = self:GetSpecialValueFor("mana_on_hit")
	self.duration = self:GetSpecialValueFor("debuff_duration")
end

function modifier_item_arcane_reaver_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_EVENT_ON_ATTACK,
			
			}
end

function modifier_item_arcane_reaver_active:GetModifierDamageOutgoing_Percentage()
	return self.dmgPct
end

function modifier_item_arcane_reaver_active:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:GetAbility():DealDamage(params.attacker, params.target, self.onHitDmg * params.attacker:GetPrimaryStatValue(), {damage_type = DAMAGE_TYPE_MAGICAL} )
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_arcane_reaver_debuff", {duration = self.duration})
	end
end

function modifier_item_arcane_reaver_active:OnAttack(params)
	if params.attacker == self:GetParent() then
		params.attacker:SpendMana(self.manaBurn, self:GetAbility())
	end
end

modifier_item_arcane_reaver_debuff = class({})
LinkLuaModifier( "modifier_item_arcane_reaver_debuff", "items/item_arcane_reaver.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_arcane_reaver_debuff:OnCreated()
	self.mr = self:GetSpecialValueFor("magic_resistance")
end

function modifier_item_arcane_reaver_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,}
end

function modifier_item_arcane_reaver_debuff:GetModifierMagicalResistanceBonus()
	return self.mr
end

modifier_item_arcane_reaver = class({})
LinkLuaModifier( "modifier_item_arcane_reaver", "items/item_arcane_reaver.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_arcane_reaver:OnCreated()
	self.mr = self:GetSpecialValueFor("bonus_mana_regen")
	self.intellect = self:GetSpecialValueFor("bonus_intellect")
end

function modifier_item_arcane_reaver:OnDestroy()
	self:GetCaster():RemoveModifierByName("modifier_item_arcane_reaver_active")
end

function modifier_item_arcane_reaver:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			}
end

function modifier_item_arcane_reaver:GetModifierConstantManaRegen()
	return self.mr
end

function modifier_item_arcane_reaver:GetModifierBonusStats_Intellect()
	return self.intellect
end

function modifier_item_arcane_reaver:IsHidden()
	return true
end

function modifier_item_arcane_reaver:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
