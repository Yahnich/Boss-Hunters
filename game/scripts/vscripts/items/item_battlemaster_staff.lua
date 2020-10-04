item_battlemaster_staff = class({})

function item_battlemaster_staff:GetIntrinsicModifierName()
	return "modifier_item_battlemaster_staff_passive"
end

item_battlemaster_staff_2 = class(item_battlemaster_staff)
item_battlemaster_staff_3 = class(item_battlemaster_staff)
item_battlemaster_staff_4 = class(item_battlemaster_staff)
item_battlemaster_staff_5 = class(item_battlemaster_staff)
item_battlemaster_staff_6 = class(item_battlemaster_staff)
item_battlemaster_staff_7 = class(item_battlemaster_staff)
item_battlemaster_staff_8 = class(item_battlemaster_staff)
item_battlemaster_staff_9 = class(item_battlemaster_staff)


modifier_item_battlemaster_staff_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_battlemaster_staff_passive", "items/item_battlemaster_staff.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_battlemaster_staff_passive:OnCreatedSpecific()
	self.bash_chance = self:GetSpecialValueFor("bash_chance")
	self.bash_damage = self:GetSpecialValueFor("bash_damage")
end

function modifier_item_battlemaster_staff_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL )
	return funcs
end

function modifier_item_battlemaster_staff_passive:GetModifierProcAttack_BonusDamage_Physical(params)
	if params.attacker == self:GetParent() and not self:GetParent():IsMuted() and not self:GetParent():PassivesDisabled() then
		if self:RollPRNG( self.bash_chance ) then
			local damage = self.bash_damage
			if params.attacker:IsRangedAttacker() then
				EmitSoundOn("DOTA_Item.MKB.ranged", params.target)
			else
				EmitSoundOn("DOTA_Item.MKB.melee", params.target)
			end
			SendOverheadEventMessage(params.attacker:GetPlayerOwner(),OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,params.target,damage,params.attacker:GetPlayerOwner())
			return damage
		end
	end
end
function modifier_item_battlemaster_staff_passive:IsHidden()
	return true
end