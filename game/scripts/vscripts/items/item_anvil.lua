item_anvil = class({})

function item_anvil:GetCooldown( iLvl )
	local cd = self:GetSpecialValueFor("cooldown")
	if self:GetCaster():IsRangedAttacker() then
		cd = self:GetSpecialValueFor("ranged_cooldown")
	end
	return cd
end

function item_anvil:GetIntrinsicModifierName()
	return "modifier_item_anvil"
end

function item_anvil:ShouldUseResources()
	return true
end

item_anvil_2 = class(item_anvil)
item_anvil_3 = class(item_anvil)
item_anvil_4 = class(item_anvil)
item_anvil_5 = class(item_anvil)
item_anvil_6 = class(item_anvil)
item_anvil_7 = class(item_anvil)
item_anvil_8 = class(item_anvil)
item_anvil_9 = class(item_anvil)

modifier_item_anvil = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_anvil", "items/item_anvil.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_anvil:OnCreatedSpecific()
	self.bash_duration = self:GetSpecialValueFor("bash_duration")
	self.minion_duration = self:GetSpecialValueFor("minion_duration")
end

function modifier_item_anvil:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_EVENT_ON_ATTACK_LANDED )
	return funcs
end

function modifier_item_anvil:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() and not params.attacker:HasModifier("modifier_item_anvil_buff") then
			local parent = self:GetParent()
			
			self:GetAbility():SetCooldown()
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_anvil_buff", {})
			self:GetAbility():Stun(params.target, TernaryOperator( self.minion_duration, params.target:IsMinion(), self.bash_duration ), true)
			EmitSoundOn("DOTA_Item.SkullBasher", params.target)
		end
	end
end

modifier_item_anvil_buff = class({})
LinkLuaModifier( "modifier_item_anvil_buff", "items/item_anvil.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_anvil_buff:OnCreated()
	self.bash_duration = self:GetSpecialValueFor("bash_duration")
	self.minion_duration = self:GetSpecialValueFor("minion_duration")
end

function modifier_item_anvil_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT_ADJUST, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_item_anvil_buff:OnAttack(params)
	if params.attacker == self:GetParent() then
		local parent = self:GetParent()
		self:GetAbility():Stun(params.target, TernaryOperator( self.minion_duration, params.target:IsMinion(), self.bash_duration ), true)
		EmitSoundOn("DOTA_Item.SkullBasher", params.target)
		self:Destroy()
	end
end

function modifier_item_anvil_buff:GetModifierAttackSpeedBonus_Constant(params)
	return 490
end