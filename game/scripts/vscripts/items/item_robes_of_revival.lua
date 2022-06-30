item_robes_of_revival = class({})

LinkLuaModifier( "modifier_item_robes_of_revival_passive", "items/item_robes_of_revival.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_robes_of_revival:GetIntrinsicModifierName()
	return "modifier_item_robes_of_revival_passive"
end

function item_robes_of_revival:OnSpellStart()
	local caster = self:GetCaster()
	
	local heal = self:GetSpecialValueFor("heal")
	local managain = self:GetSpecialValueFor("mana_restore")
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		ParticleManager:FireParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_POINT_FOLLOW, ally)
		ParticleManager:FireParticle("particles/items3_fx/warmage_recipient.vpcf", PATTACH_POINT_FOLLOW, ally)
		EmitSoundOn("DOTA_Item.Mekansm.Target", ally)
		ally:HealEvent(heal, self, caster)
		ally:RestoreMana( managain )
		ally:Dispel(caster, false)
	end

	ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("DOTA_Item.ArcaneBoots.Activate", caster)
	ParticleManager:FireParticle("particles/items2_fx/mekanism.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("DOTA_Item.Mekansm.Activate", caster)
end

item_robes_of_revival_2 = class(item_robes_of_revival)
item_robes_of_revival_3 = class(item_robes_of_revival)
item_robes_of_revival_4 = class(item_robes_of_revival)
item_robes_of_revival_5 = class(item_robes_of_revival)
item_robes_of_revival_6 = class(item_robes_of_revival)
item_robes_of_revival_7 = class(item_robes_of_revival)
item_robes_of_revival_8 = class(item_robes_of_revival)
item_robes_of_revival_9 = class(item_robes_of_revival)

modifier_item_robes_of_revival_passive = class(itemBasicBaseClass)