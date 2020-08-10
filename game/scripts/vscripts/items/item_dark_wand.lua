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
item_dark_wand_6 = class(item_dark_wand)
item_dark_wand_7 = class(item_dark_wand)
item_dark_wand_8 = class(item_dark_wand)
item_dark_wand_9 = class(item_dark_wand)

modifier_item_dark_wand_passive = class(itemBasicBaseClass)