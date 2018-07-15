item_rapture = class({})

function item_rapture:OnSpellStart()
	if self:GetCursorTarget():IsSameTeam(self:GetCaster() ) then
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_rapture_ally", {duration = self:GetSpecialValueFor("disarm_duration")})
	else
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_rapture_enemy", {duration = self:GetSpecialValueFor("disarm_duration")})
	end
	self:GetCaster():FindModifierByName("modifier_item_rapture"):SetStackCount(0)
end

function item_rapture:GetIntrinsicModifierName()
	return "modifier_item_rapture"
end

------------------------------------------------------------------------
------------------------------------------------------------------------

modifier_item_rapture = class({})
LinkLuaModifier( "modifier_item_rapture", "items/item_rapture.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_rapture:OnCreated()
	self.strength = self:GetSpecialValueFor("bonus_strength")
	self.evasion = self:GetSpecialValueFor("bonus_evasion")
	self.chance = self:GetSpecialValueFor("block_chance")
	self.block = self:GetSpecialValueFor("damage_block")
	self.hp_regen = self:GetSpecialValueFor("bonus_hp_regen")
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.heal_amp = self:GetSpecialValueFor("bonus_heal_amp")
	self:SetStackCount(1)
end

function modifier_item_rapture:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_EVASION_CONSTANT,
			MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_rapture:GetModifierConstantHealthRegen()
	if self:GetStackCount() ~= 0 then return self.hp_regen end
end

function modifier_item_rapture:GetModifierPhysicalArmorBonus()
	if self:GetStackCount() ~= 0 then return self.armor end
end

function modifier_item_rapture:GetModifierTotal_ConstantBlock(params)
	if self:GetStackCount() ~= 0 then
		if RollPercentage(self.chance) and params.attacker ~= self:GetParent() then
			return self.block
		end
	end
end

function modifier_item_rapture:GetModifierBonusStats_Strength()
	if self:GetStackCount() ~= 0 then return self.strength end
end

function modifier_item_rapture:GetModifierEvasion_Constant()
	if self:GetStackCount() ~= 0 then return self.evasion end
end

function modifier_item_rapture:GetModifierHealAmplify_Percentage()
	if self:GetStackCount() ~= 0 then return self.heal_amp end
end

function modifier_item_rapture:IsHidden()
	return true
end

function modifier_item_rapture:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

------------------------------------------------------------------------
------------------------------------------------------------------------

modifier_item_rapture_ally = class(modifier_item_rapture)
LinkLuaModifier( "modifier_item_rapture_ally", "items/item_rapture.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_rapture_ally:OnCreated()
	self.strength = self:GetSpecialValueFor("bonus_strength")
	self.evasion = self:GetSpecialValueFor("bonus_evasion")
	self.chance = self:GetSpecialValueFor("block_chance")
	self.block = self:GetSpecialValueFor("damage_block")
	self.hp_regen = self:GetSpecialValueFor("bonus_hp_regen")
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.heal_amp = self:GetSpecialValueFor("bonus_heal_amp")
	self:SetStackCount(1)
end

function modifier_item_rapture_ally:OnDestroy()
	if IsServer() then self:GetCaster():FindModifierByName("modifier_item_rapture"):SetStackCount(1) end
end

function modifier_item_rapture_ally:IsHidden()
	return false
end

------------------------------------------------------------------------
------------------------------------------------------------------------

LinkLuaModifier( "modifier_rapture_enemy", "items/item_rapture.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_rapture_enemy = class({})


function modifier_rapture_enemy:OnCreated()
	self.evasion = self:GetSpecialValueFor("bonus_evasion") * (-1)
	self.hp_regen = self:GetSpecialValueFor("bonus_hp_regen") * (-1)
	self.armor = self:GetSpecialValueFor("bonus_armor") * (-1)
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_rapture_enemy:OnRemoved()
	if IsServer() then 
		self:GetAbility():EndDelayedCooldown() 
		self:GetCaster():FindModifierByName("modifier_item_rapture"):SetStackCount(1)
	end
end

function modifier_rapture_enemy:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_DISABLE_HEALING,}
end

function modifier_rapture_enemy:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_rapture_enemy:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_rapture_enemy:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_rapture_enemy:GetDisableHealing()
	return 1
end

function modifier_rapture_enemy:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true}
end

function modifier_rapture_enemy:GetEffectName()
	return "particles/items2_fx/heavens_halberd_debuff_disarm.vpcf"
end

function modifier_rapture_enemy:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end