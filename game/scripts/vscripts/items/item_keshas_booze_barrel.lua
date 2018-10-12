item_keshas_booze_barrel = class({})

function item_keshas_booze_barrel:OnSpellStart()
	if self:GetCursorTarget():IsSameTeam(self:GetCaster() ) then
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_keshas_booze_barrel_ally", {duration = self:GetSpecialValueFor("disarm_duration")})
	else
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_keshas_booze_barrel_enemy", {duration = self:GetSpecialValueFor("disarm_duration")})
	end
	self:GetCaster():FindModifierByNameAndAbility("modifier_item_keshas_booze_barrel", self):SetStackCount(0)
end

function item_keshas_booze_barrel:GetIntrinsicModifierName()
	return "modifier_item_keshas_booze_barrel"
end

------------------------------------------------------------------------
------------------------------------------------------------------------

modifier_item_keshas_booze_barrel = class(itemBaseClass)
LinkLuaModifier( "modifier_item_keshas_booze_barrel", "items/item_keshas_booze_barrel.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_keshas_booze_barrel:OnCreated()
	self.chance = self:GetSpecialValueFor("block_chance")
	self.block = self:GetSpecialValueFor("damage_block")
	self.hp_regen = self:GetSpecialValueFor("bonus_hp_regen")
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.bonus_all = self:GetSpecialValueFor("bonus_all")
	self.bonus_evasion = self:GetSpecialValueFor("bonus_evasion")
	self.heal_amp = self:GetSpecialValueFor("bonus_heal_amp")
	self:SetStackCount(1)
end

function modifier_item_keshas_booze_barrel:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_item_keshas_booze_barrel:GetModifierConstantHealthRegen()
	if self:GetStackCount() ~= 0 then return self.hp_regen end
end 

function modifier_item_keshas_booze_barrel:GetModifierTotal_ConstantBlock(params)
	if self:GetStackCount() ~= 0 then
		if RollPercentage(self.chance) and params.attacker ~= self:GetParent() then
			return self.block
		end
	end
end

function modifier_item_keshas_booze_barrel:GetModifierBonusStats_Strength()
	if self:GetStackCount() ~= 0 then return self.bonus_all end
end

function modifier_item_keshas_booze_barrel:GetModifierBonusStats_Agility()
	if self:GetStackCount() ~= 0 then return self.bonus_all end
end

function modifier_item_keshas_booze_barrel:GetModifierBonusStats_Intellect()
	if self:GetStackCount() ~= 0 then return self.bonus_all end
end

function modifier_item_keshas_booze_barrel:GetModifierEvasion_Constant()
	if self:GetStackCount() ~= 0 then return self.bonus_evasion end
end

function modifier_item_keshas_booze_barrel:GetModifierPhysicalArmorBonus()
	if self:GetStackCount() ~= 0 then return self.armor end
end

function modifier_item_keshas_booze_barrel:GetModifierHealAmplify_Percentage()
	if self:GetStackCount() ~= 0 then return self.heal_amp end
end

function modifier_item_keshas_booze_barrel:IsHidden()
	return true
end

function modifier_item_keshas_booze_barrel:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

------------------------------------------------------------------------
------------------------------------------------------------------------

modifier_item_keshas_booze_barrel_ally = class(modifier_item_keshas_booze_barrel)
LinkLuaModifier( "modifier_item_keshas_booze_barrel_ally", "items/item_keshas_booze_barrel.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_keshas_booze_barrel_ally:OnDestroy()
	if IsServer() then self:GetCaster():FindModifierByNameAndAbility("modifier_item_keshas_booze_barrel", self:GetAbility() ):SetStackCount(1) end
end

function modifier_item_keshas_booze_barrel_ally:GetEffectName()
	return "particles/items2_fx/medallion_of_courage_friend.vpcf"
end

function modifier_item_keshas_booze_barrel_ally:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_keshas_booze_barrel_ally:IsHidden()
	return false
end

------------------------------------------------------------------------
------------------------------------------------------------------------

LinkLuaModifier( "modifier_keshas_booze_barrel_enemy", "items/item_keshas_booze_barrel.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_keshas_booze_barrel_enemy = class({})


function modifier_keshas_booze_barrel_enemy:OnCreated()
	self.hp_regen = self:GetSpecialValueFor("bonus_hp_regen") * (-1)
	self.armor = self:GetSpecialValueFor("bonus_armor") * (-1)
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_keshas_booze_barrel_enemy:OnRemoved()
	if IsServer() then 
		self:GetAbility():EndDelayedCooldown() 
		self:GetCaster():FindModifierByNameAndAbility( "modifier_item_keshas_booze_barrel", self:GetAbility() ):SetStackCount(1)
	end
end

function modifier_keshas_booze_barrel_enemy:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_DISABLE_HEALING,}
end

function modifier_keshas_booze_barrel_enemy:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_keshas_booze_barrel_enemy:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_keshas_booze_barrel_enemy:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_keshas_booze_barrel_enemy:GetDisableHealing()
	return 1
end

function modifier_keshas_booze_barrel_enemy:GetEffectName()
	return "particles/items2_fx/medallion_of_courage.vpcf"
end

function modifier_keshas_booze_barrel_enemy:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_keshas_booze_barrel_enemy:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end