item_behemoths_heart = class({})

function item_behemoths_heart:GetIntrinsicModifierName()
	return "modifier_item_behemoths_heart_passive"
end

function item_behemoths_heart:GetAssociatedUpgradeModifier()
	return "modifier_item_battlemaster_staff_passive"
end

function item_behemoths_heart:ShouldUseResources()
	return true
end

item_behemoths_heart_2 = class(item_behemoths_heart)
item_behemoths_heart_3 = class(item_behemoths_heart)
item_behemoths_heart_4 = class(item_behemoths_heart)
item_behemoths_heart_5 = class(item_behemoths_heart)
item_behemoths_heart_6 = class(item_behemoths_heart)
item_behemoths_heart_7 = class(item_behemoths_heart)
item_behemoths_heart_8 = class(item_behemoths_heart)
item_behemoths_heart_9 = class(item_behemoths_heart)


modifier_item_behemoths_heart_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_behemoths_heart_passive", "items/item_behemoths_heart.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_behemoths_heart_passive:OnCreatedSpecific()
	self.hp_regen = self:GetSpecialValueFor("max_regen")
	self.heal_amp = self:GetSpecialValueFor("health_regen_amp")
end

function modifier_item_behemoths_heart_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_EVENT_ON_TAKEDAMAGE )
	table.insert( funcs, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE )
	table.insert( funcs, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE )
	return funcs
end

function modifier_item_behemoths_heart_passive:GetModifierHealthRegenPercentage()
	if not self:GetParent():IsMuted() and not self:GetParent():PassivesDisabled() then
		return self.hp_regen
	end
end

function modifier_item_behemoths_heart_passive:GetModifierHPRegenAmplify_Percentage()
	if not self:GetParent():IsMuted() and not self:GetParent():PassivesDisabled() and not self:GetParent():HasModifier("modifier_item_behemoths_heart_broken") then
		return self.heal_amp
	end
end

function modifier_item_behemoths_heart_passive:OnTakeDamage(params)
	if params.unit == self:GetParent() and not params.attacker:IsMinion() then
		local ability = self:GetAbility()
		ability:SetCooldown()
		params.unit:AddNewModifier( self:GetCaster(), ability, "modifier_item_behemoths_heart_broken",{duration = ability:GetCooldownTimeRemaining(), ignoreStatusAmp = true} )
	end
end
function modifier_item_behemoths_heart_passive:IsHidden()
	return true
end


modifier_item_behemoths_heart_broken = class({})
LinkLuaModifier( "modifier_item_behemoths_heart_broken", "items/item_behemoths_heart.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_behemoths_heart_broken:IsDebuff()
	return true
end

function modifier_item_behemoths_heart_broken:IsPurgable()
	return false
end