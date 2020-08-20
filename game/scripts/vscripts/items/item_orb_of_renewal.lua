item_orb_of_renewal = class({})

function item_orb_of_renewal:GetIntrinsicModifierName()
	return "modifier_item_orb_of_renewal_passive"
end

function item_orb_of_renewal:IsRefreshable()
	return false
end

function item_orb_of_renewal:OnSpellStart()
	local caster = self:GetCaster()
	caster:RefreshAllCooldowns(true)
	
	caster:EmitSound( "DOTA_Item.Refresher.Activate" )
	ParticleManager:FireParticle("particles/items2_fx/refresher.vpcf", PATTACH_POINT_FOLLOW, caster)
end

item_orb_of_renewal_2 = class(item_orb_of_renewal)
item_orb_of_renewal_3 = class(item_orb_of_renewal)
item_orb_of_renewal_4 = class(item_orb_of_renewal)
item_orb_of_renewal_5 = class(item_orb_of_renewal)
item_orb_of_renewal_6 = class(item_orb_of_renewal)
item_orb_of_renewal_7 = class(item_orb_of_renewal)
item_orb_of_renewal_8 = class(item_orb_of_renewal)
item_orb_of_renewal_9 = class(item_orb_of_renewal)

modifier_item_orb_of_renewal_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_orb_of_renewal_passive", "items/item_orb_of_renewal.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_orb_of_renewal_passive:OnCreatedSpecific()
	self.mRestore = self:GetSpecialValueFor("mana_gain")
	self.hRestore = self:GetSpecialValueFor("hp_gain")
end

function modifier_item_orb_of_renewal_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert(funcs, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST)
	return funcs
end


function modifier_item_orb_of_renewal_passive:OnAbilityFullyCast(params)	
	if params.unit == self:GetParent() and params.ability:GetCooldown(-1) > 0 then
		self:GetParent():RestoreMana(self.mRestore)
		self:GetParent():HealEvent(self.hRestore, self:GetAbility(), self:GetParent())
	end
end