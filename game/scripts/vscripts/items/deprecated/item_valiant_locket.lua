item_valiant_locket = class({})

function item_valiant_locket:OnSpellStart()
	if self:GetCursorTarget():IsSameTeam(self:GetCaster() ) then
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_valiant_locket_ally", {duration = self:GetSpecialValueFor("disarm_duration")})
	else
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_valiant_locket_enemy", {duration = self:GetSpecialValueFor("disarm_duration")})
	end
	self:GetCaster():FindModifierByNameAndAbility("modifier_item_valiant_locket", self ):SetStackCount(0)
end

function item_valiant_locket:GetIntrinsicModifierName()
	return "modifier_item_valiant_locket"
end

------------------------------------------------------------------------
------------------------------------------------------------------------

modifier_item_valiant_locket = class(itemBaseClass)
LinkLuaModifier( "modifier_item_valiant_locket", "items/item_valiant_locket.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_valiant_locket:OnCreated()
	self.chance = self:GetSpecialValueFor("block_chance")
	self.block = self:GetSpecialValueFor("damage_block")
	self.hp_regen = self:GetSpecialValueFor("bonus_hp_regen")
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.heal_amp = self:GetSpecialValueFor("bonus_heal_amp")
	self:SetStackCount(1)
end

function modifier_item_valiant_locket:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_valiant_locket:GetModifierConstantHealthRegen()
	if self:GetStackCount() ~= 0 then return self.hp_regen end
end 

function modifier_item_valiant_locket:GetModifierTotal_ConstantBlock(params)
	if self:GetStackCount() ~= 0 then
		if RollPercentage(self.chance) and params.attacker ~= self:GetParent() then
			return self.block
		end
	end
end

function modifier_item_valiant_locket:GetModifierPhysicalArmorBonus()
	if self:GetStackCount() ~= 0 then return self.armor end
end

function modifier_item_valiant_locket:GetModifierHealAmplify_Percentage()
	if self:GetStackCount() ~= 0 then return self.heal_amp end
end

------------------------------------------------------------------------
------------------------------------------------------------------------

modifier_item_valiant_locket_ally = class(modifier_item_valiant_locket)
LinkLuaModifier( "modifier_item_valiant_locket_ally", "items/item_valiant_locket.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_valiant_locket_ally:OnCreated()
	self.chance = self:GetSpecialValueFor("block_chance")
	self.block = self:GetSpecialValueFor("damage_block")
	self.hp_regen = self:GetSpecialValueFor("bonus_hp_regen")
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.heal_amp = self:GetSpecialValueFor("bonus_heal_amp")
	self:SetStackCount(1)
end

function modifier_item_valiant_locket_ally:OnDestroy()
	if IsServer() then self:GetCaster():FindModifierByNameAndAbility("modifier_item_valiant_locket", self:GetAbility() ):SetStackCount(1) end
end

function modifier_item_valiant_locket_ally:GetEffectName()
	return "particles/items2_fx/medallion_of_courage_friend.vpcf"
end

function modifier_item_valiant_locket_ally:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_valiant_locket_ally:IsHidden()
	return false
end

------------------------------------------------------------------------
------------------------------------------------------------------------

LinkLuaModifier( "modifier_valiant_locket_enemy", "items/item_valiant_locket.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_valiant_locket_enemy = class({})


function modifier_valiant_locket_enemy:OnCreated()
	self.hp_regen = self:GetSpecialValueFor("bonus_hp_regen") * (-1)
	self.armor = self:GetSpecialValueFor("bonus_armor") * (-1)
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_valiant_locket_enemy:OnRemoved()
	if IsServer() then 
		self:GetAbility():EndDelayedCooldown() 
		self:GetCaster():FindModifierByNameAndAbility("modifier_item_valiant_locket", self:GetAbility() ):SetStackCount(1)
	end
end

function modifier_valiant_locket_enemy:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_DISABLE_HEALING,}
end

function modifier_valiant_locket_enemy:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_valiant_locket_enemy:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_valiant_locket_enemy:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_valiant_locket_enemy:GetDisableHealing()
	return 1
end

function modifier_valiant_locket_enemy:GetEffectName()
	return "particles/items2_fx/medallion_of_courage.vpcf"
end

function modifier_valiant_locket_enemy:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_valiant_locket_enemy:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end