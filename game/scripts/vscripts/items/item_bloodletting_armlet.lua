item_bloodletting_armlet = class({})

function item_bloodletting_armlet:GetIntrinsicModifierName()
	return "modifier_item_bloodletting_armlet_passive"
end

function item_bloodletting_armlet:GetAbilityTextureName()
	if self.toggleModifier then
		return "armlet/bloodletting_armlet_"..self:GetLevel().."_active"
	else
		return "armlet/bloodletting_armlet_"..self:GetLevel()
	end
end

function item_bloodletting_armlet:OnToggle()
	if self:GetToggleState()then
		if not self.toggleModifier then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_bloodletting_armlet", {})
		end
	elseif self.toggleModifier and not self.toggleModifier:IsNull() then
		self.toggleModifier:Destroy()
	end
end

item_bloodletting_armlet_2 = class(item_bloodletting_armlet)
item_bloodletting_armlet_3 = class(item_bloodletting_armlet)
item_bloodletting_armlet_4 = class(item_bloodletting_armlet)
item_bloodletting_armlet_5 = class(item_bloodletting_armlet)
item_bloodletting_armlet_6 = class(item_bloodletting_armlet)
item_bloodletting_armlet_7 = class(item_bloodletting_armlet)
item_bloodletting_armlet_8 = class(item_bloodletting_armlet)
item_bloodletting_armlet_9 = class(item_bloodletting_armlet)


LinkLuaModifier( "modifier_item_bloodletting_armlet_passive", "items/item_bloodletting_armlet.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_bloodletting_armlet_passive = class(itemBasicBaseClass)

function modifier_item_bloodletting_armlet_passive:OnCreatedSpecific()
	if IsServer() then
		self:GetAbility():OnToggle()
	end
end

function modifier_item_bloodletting_armlet_passive:OnRefreshSpecific()
	if IsServer() then
		self:GetAbility():OnToggle()
	end
end

function modifier_item_bloodletting_armlet_passive:OnDestroySpecific()
	if IsServer() and not self:GetCaster():HasModifier("modifier_item_bloodletting_armlet_passive") then
		self:GetCaster():RemoveModifierByName("modifier_item_bloodletting_armlet")
	end
end

LinkLuaModifier( "modifier_item_bloodletting_armlet", "items/item_bloodletting_armlet.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_bloodletting_armlet = class(toggleModifierBaseClass)

function modifier_item_bloodletting_armlet:OnCreated()
	self.bonus_strength = self:GetSpecialValueFor("bonus_str")
	self.hp_damage = self:GetSpecialValueFor("max_hp_dmg") / 100
	self.drain = self:GetSpecialValueFor("health_drain")
	self:GetAbility().toggleModifier = self
	self:SetHasCustomTransmitterData( true )
	if IsServer() then
		self.damage = self:GetCaster():GetHealth() * self.hp_damage
		self.healthToGrant = self.bonus_strength * GameRules:GetGameModeEntity():GetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_HP, self:GetCaster() )
		self.healthStep = self.healthToGrant / 6
		self:StartIntervalThink( 0.1 )
		self:SendBuffRefreshToClients()
	end
end

function modifier_item_bloodletting_armlet:OnRefresh()
	if IsServer() then
		self.damage = self:GetCaster():GetHealth() * self.hp_damage
		self:SendBuffRefreshToClients()
	end
end

function modifier_item_bloodletting_armlet:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if not ability or ability:IsNull() or ability:GetItemSlot() > 5 then 
		self:Destroy()
		return
	end
	if self.healthToGrant > 0 then
		self.healthToGrant = self.healthToGrant - self.healthStep
		caster:SetHealth( math.min( caster:GetHealth() + self.healthStep, caster:GetMaxHealth() ) )
	end
	if caster:IsIllusion() then
		ability:DealDamage( caster, caster, self.drain * 0.1, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL } )
	else
		ability:DealDamage( caster, caster, self.drain * 0.1, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL } )
	end
	self:ForceRefresh()
end

function modifier_item_bloodletting_armlet:OnRemoved()
	if not self:GetAbility() then return end
	self:GetAbility().toggleModifier = nil
	if IsServer() then
		if self:GetAbility():GetToggleState() then
			self:GetAbility():ToggleAbility()
		end
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local damageToDeal = self.bonus_strength * GameRules:GetGameModeEntity():GetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_HP, self:GetCaster() )
		ability:DealDamage( caster, caster, damageToDeal, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL } )
	end
end

function modifier_item_bloodletting_armlet:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_item_bloodletting_armlet:GetModifierExtraStrengthBonus()
	return self.bonus_strength
end

function modifier_item_bloodletting_armlet:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_bloodletting_armlet:GetEffectName()
	return "particles/items_fx/armlet.vpcf"
end

function modifier_item_bloodletting_armlet:IsHidden()    
	return false
end

function modifier_item_bloodletting_armlet:AddCustomTransmitterData( )
	return
	{
		damage = self.damage
	}
end

--------------------------------------------------------------------------------

function modifier_item_bloodletting_armlet:HandleCustomTransmitterData( data )
	self.damage = data.damage
end

function modifier_item_bloodletting_armlet:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end