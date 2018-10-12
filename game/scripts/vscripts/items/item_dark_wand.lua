item_dark_wand = class({})
LinkLuaModifier( "modifier_item_dark_wand_passive", "items/item_dark_wand.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_dark_wand:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("DOTA_Item.Dagon.Activate", caster)
	EmitSoundOn("DOTA_Item.Dagon5.Target", caster)

	ParticleManager:FireRopeParticle("particles/items_fx/dagon.vpcf", PATTACH_POINT, caster, target, {}, "attach_attack1")
	
	self:DealDamage(caster, target, self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
end

function item_dark_wand:GetIntrinsicModifierName()
	return "modifier_item_dark_wand_passive"
end

item_dark_wand_2 = class(item_dark_wand)
item_dark_wand_3 = class(item_dark_wand)
item_dark_wand_4 = class(item_dark_wand)
item_dark_wand_5 = class(item_dark_wand)

modifier_item_dark_wand_passive = class(itemBaseClass)
function modifier_item_dark_wand_passive:OnCreated()
	self.agi = self:GetSpecialValueFor("bonus_agi")
	self.int = self:GetSpecialValueFor("bonus_int")
	self.str = self:GetSpecialValueFor("bonus_str")
end

function modifier_item_dark_wand_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_dark_wand_passive:GetModifierBonusStats_Agility()
	return self.agi
end

function modifier_item_dark_wand_passive:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_item_dark_wand_passive:GetModifierBonusStats_Intellect()
	return self.int
end