item_gauntlet_of_the_void = class({})

function item_gauntlet_of_the_void:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_gauntlet_of_the_void_active") then
		return "custom/gauntlet_of_the_void_on"
	else
		return "custom/gauntlet_of_the_void_off"
	end
end

function item_gauntlet_of_the_void:GetIntrinsicModifierName()
	return "modifier_item_gauntlet_of_the_void"
end

function item_gauntlet_of_the_void:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_item_gauntlet_of_the_void_active", {})
	else
		caster:RemoveModifierByName("modifier_item_gauntlet_of_the_void_active")
	end
end

modifier_item_gauntlet_of_the_void_active = class(itemBaseClass)
LinkLuaModifier( "modifier_item_gauntlet_of_the_void_active", "items/item_gauntlet_of_the_void.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_gauntlet_of_the_void_active:GetTexture()
	return "custom/gauntlet_of_the_void_on"
end

function modifier_item_gauntlet_of_the_void_active:OnCreated()
	self.dmgPct = self:GetSpecialValueFor("minus_damage")
	
	self.onHitDmg = self:GetSpecialValueFor("damage_pct") / 100
	self.manaBurn = self:GetSpecialValueFor("mana_on_hit")
	self.duration = self:GetSpecialValueFor("debuff_duration")
end

function modifier_item_gauntlet_of_the_void_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_EVENT_ON_ATTACK,
			
			}
end

function modifier_item_gauntlet_of_the_void_active:GetModifierDamageOutgoing_Percentage()
	return self.dmgPct
end

function modifier_item_gauntlet_of_the_void_active:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:GetAbility():DealDamage(params.attacker, params.target, self.onHitDmg * params.attacker:GetPrimaryStatValue(), {damage_type = DAMAGE_TYPE_MAGICAL} )
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_gauntlet_of_the_void_debuff", {duration = self.duration})
	end
end

function modifier_item_gauntlet_of_the_void_active:OnAttack(params)
	if params.attacker == self:GetParent() then
		params.attacker:SpendMana(self.manaBurn, self:GetAbility())
	end
end

modifier_item_gauntlet_of_the_void_debuff = class({})
LinkLuaModifier( "modifier_item_gauntlet_of_the_void_debuff", "items/item_gauntlet_of_the_void.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_gauntlet_of_the_void_debuff:OnCreated()
	self.mr = self:GetSpecialValueFor("magic_resistance")
end

function modifier_item_gauntlet_of_the_void_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,}
end

function modifier_item_gauntlet_of_the_void_debuff:GetModifierMagicalResistanceBonus()
	return self.mr
end

modifier_item_gauntlet_of_the_void = class(itemBaseClass)
LinkLuaModifier( "modifier_item_gauntlet_of_the_void", "items/item_gauntlet_of_the_void.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_gauntlet_of_the_void:OnCreated()
	self.mr = self:GetSpecialValueFor("bonus_mana_regen")
	self.intellect = self:GetSpecialValueFor("bonus_intellect")
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
	self.mLifesteal = self:GetSpecialValueFor("mob_lifesteal") / 100
end

function modifier_item_gauntlet_of_the_void:OnDestroy()
	self:GetCaster():RemoveModifierByName("modifier_item_gauntlet_of_the_void_active")
end

function modifier_item_gauntlet_of_the_void:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_gauntlet_of_the_void:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and self:GetParent():GetHealth() > 0 and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		local lifesteal = self.lifesteal
		if params.inflictor then 
			ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
			if not params.unit:IsRoundBoss() then
				lifesteal = self.mLifesteal
			end
		end
		local flHeal = params.damage * lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end

function modifier_item_gauntlet_of_the_void:GetModifierConstantManaRegen()
	return self.mr
end

function modifier_item_gauntlet_of_the_void:GetModifierBonusStats_Intellect()
	return self.intellect
end

function modifier_item_gauntlet_of_the_void:IsHidden()
	return true
end

function modifier_item_gauntlet_of_the_void:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
