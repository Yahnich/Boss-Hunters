item_mirror_blade = class({})

function item_mirror_blade:GetCooldown( iLvl )
	local cd = self:GetSpecialValueFor("cooldown")
	if self:GetCaster():IsRangedAttacker() then
		cd = self:GetSpecialValueFor("ranged_cooldown")
	end
	return cd
end

function item_mirror_blade:GetIntrinsicModifierName()
	return "modifier_item_mirror_blade"
end

function item_mirror_blade:ShouldUseResources()
	return true
end

item_mirror_blade_2 = class(item_mirror_blade)
item_mirror_blade_3 = class(item_mirror_blade)
item_mirror_blade_4 = class(item_mirror_blade)
item_mirror_blade_5 = class(item_mirror_blade)
item_mirror_blade_6 = class(item_mirror_blade)
item_mirror_blade_7 = class(item_mirror_blade)
item_mirror_blade_8 = class(item_mirror_blade)
item_mirror_blade_9 = class(item_mirror_blade)

modifier_item_mirror_blade = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_mirror_blade", "items/item_mirror_blade.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_mirror_blade:OnCreatedSpecific()
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
end

function modifier_item_mirror_blade:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_EVENT_ON_ATTACK_LANDED )
	return funcs
end

function modifier_item_mirror_blade:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() and not params.attacker:HasModifier("modifier_item_mirror_blade_buff") then
			local parent = self:GetParent()
			print( "actually triggered" )
			self:GetAbility():SetCooldown()
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_mirror_blade_buff", {})
			params.target:AddNewModifier(parent, self:GetAbility(), "modifier_item_mirror_blade_debuff", {duration = self.duration})
		end
	end
end

modifier_item_mirror_blade_buff = class({})
LinkLuaModifier( "modifier_item_mirror_blade_buff", "items/item_mirror_blade.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_mirror_blade_buff:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_item_mirror_blade_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT_ADJUST, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_item_mirror_blade_buff:OnAttack(params)
	if params.attacker == self:GetParent() then
		local parent = self:GetParent()
		params.target:AddNewModifier(parent, self:GetAbility(), "modifier_item_mirror_blade_debuff", {duration = self.duration})
		self:Destroy()
	end
end

function modifier_item_mirror_blade_buff:GetModifierAttackSpeedBonus_Constant(params)
	return 490
end

modifier_item_mirror_blade_debuff = class({})
LinkLuaModifier( "modifier_item_mirror_blade_debuff", "items/item_mirror_blade.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_mirror_blade_debuff:OnCreated()
	self.evasion = self:GetSpecialValueFor("evasion_loss")
end

function modifier_item_mirror_blade_debuff:OnRefresh()
	self.evasion = math.min(self.evasion, self:GetSpecialValueFor("evasion_loss") )
end

function modifier_item_mirror_blade_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_item_mirror_blade_debuff:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_item_mirror_blade_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -100
end