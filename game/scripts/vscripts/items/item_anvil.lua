item_anvil = class({})

function item_anvil:GetIntrinsicModifierName()
	return "modifier_item_anvil_passive"
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


modifier_item_anvil_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_anvil_passive", "items/item_anvil.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_anvil_passive:OnCreatedSpecific()
	self.bash_chance_melee = self:GetSpecialValueFor("bash_chance")
	self.bash_chance_ranged = self:GetSpecialValueFor("bash_chance_ranged")
	self.bash_duration = self:GetSpecialValueFor("bash_duration")
	self.bash_damage = self:GetSpecialValueFor("bash_damage")
	self.bash_damage_cd = self.bash_damage * self:GetSpecialValueFor("bash_damage_cd") / 100
end

function modifier_item_anvil_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL )
	return funcs
end

function modifier_item_anvil_passive:GetModifierProcAttack_BonusDamage_Physical(params)
	if params.attacker == self:GetParent() and not self:GetParent():IsMuted() and not self:GetParent():PassivesDisabled() then
		local chance = TernaryOperator( self.bash_chance_ranged, params.attacker:IsRangedAttacker(), self.bash_chance_melee )
		if self:RollPRNG( chance ) then
			local damage = self.bash_damage_cd
			if self:GetAbility():IsCooldownReady() then
				damage = self.bash_damage
				self:GetAbility():Stun(params.target, self.bash_duration, true)
				self:GetAbility():SetCooldown()
				EmitSoundOn("DOTA_Item.SkullBasher", params.target)
			else
				if params.attacker:IsRangedAttacker() then
					EmitSoundOn("DOTA_Item.MKB.ranged", params.target)
				else
					EmitSoundOn("DOTA_Item.MKB.melee", params.target)
				end
			end
			SendOverheadEventMessage(params.attacker:GetPlayerOwner(),OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,params.target,damage,params.attacker:GetPlayerOwner())
			return damage
		end
	end
end
function modifier_item_anvil_passive:IsHidden()
	return true
end