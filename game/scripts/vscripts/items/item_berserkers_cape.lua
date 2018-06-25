item_berserkers_cape = class({})

function item_berserkers_cape:GetAbilityTextureName()
	if not self:GetCaster():HasModifier("modifier_item_berserkers_cape_active") then
		return "custom/berserkers_cape"
	else
		return "custom/berserkers_cape_on"
	end
end

function item_berserkers_cape:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():RemoveModifierByName("modifier_item_berserkers_cape_active")
		self:GetCaster():RemoveModifierByName("modifier_item_berserkers_cape_visual")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_berserkers_cape_active", {})
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_berserkers_cape_visual", {})
	end
end

function item_berserkers_cape:GetIntrinsicModifierName()
	return "modifier_item_berserkers_cape"
end

item_berserkers_cape_2 = class(item_berserkers_cape)
item_berserkers_cape_3 = class(item_berserkers_cape)
item_berserkers_cape_4 = class(item_berserkers_cape)

LinkLuaModifier( "modifier_item_berserkers_cape_visual", "items/item_berserkers_cape.lua", LUA_MODIFIER_MOTION_NONE )
modifier_item_berserkers_cape_visual = class({})

function modifier_item_berserkers_cape_visual:GetTexture()
	return "custom/berserkers_cape_on"
end

LinkLuaModifier( "modifier_item_berserkers_cape_active", "items/item_berserkers_cape.lua", LUA_MODIFIER_MOTION_NONE )
modifier_item_berserkers_cape_active = class({})
function modifier_item_berserkers_cape_active:OnCreated()
	self.damagePct = self:GetSpecialValueFor("max_hp_damage") / 100
	self.drain = self:GetSpecialValueFor("max_hp_drain") / 100
	if IsServer() then self:StartIntervalThink(0.25) end
end

function modifier_item_berserkers_cape_active:OnIntervalThink()
	self:SetStackCount( math.floor(self:GetParent():GetMaxHealth() * self.damagePct) )
end

function modifier_item_berserkers_cape_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_EVENT_ON_ATTACK}
end

function modifier_item_berserkers_cape_active:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

function modifier_item_berserkers_cape_active:OnAttack(params)
	if params.attacker == self:GetParent() then
		self:GetAbility():DealDamage( self:GetParent(), self:GetParent(), math.ceil(params.attacker:GetMaxHealth() * self.drain), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_NON_LETHAL} )
	end
end

function modifier_item_berserkers_cape_active:IsHidden()
	return true
end

LinkLuaModifier( "modifier_item_berserkers_cape", "items/item_berserkers_cape.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_berserkers_cape = class({})
function modifier_item_berserkers_cape:OnCreated()
	self.attackspeed = self:GetSpecialValueFor("bonus_attack_speed")
	self.armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_item_berserkers_cape:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_berserkers_cape:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_berserkers_cape:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_item_berserkers_cape:IsHidden()
	return true
end

function modifier_item_berserkers_cape:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end