item_archmages_orb = class({})

function item_archmages_orb:GetIntrinsicModifierName()
	return "modifier_item_archmages_orb_passive"
end

function item_archmages_orb:OnSpellStart()
	local caster = self:GetCaster()
	
	ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("DOTA_Item.ArcaneBoots.Activate", caster)
	local managain = self:GetSpecialValueFor("mana_restore") / 100
	local minRestore = self:GetSpecialValueFor("min_restore")
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		ally:GiveMana( math.max(minRestore, ally:GetMaxMana() * managain) )
		ParticleManager:FireParticle("particles/items3_fx/warmage_recipient.vpcf", PATTACH_POINT_FOLLOW, ally)
	end
end

modifier_item_archmages_orb_passive = class({})
LinkLuaModifier( "modifier_item_archmages_orb_passive", "items/item_archmages_orb.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_archmages_orb_passive:OnCreated()
	self.spellamp = self:GetSpecialValueFor("spell_amp")
	self.manaregen = self:GetSpecialValueFor("mana_regen")
	self.bonus_mana = self:GetSpecialValueFor("bonus_mana")
end

function modifier_item_archmages_orb_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_BONUS}
end

function modifier_item_archmages_orb_passive:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_archmages_orb_passive:GetModifierSpellAmplify_Percentage()
	return self.spellamp
end

function modifier_item_archmages_orb_passive:GetModifierConstantManaRegen()
	return self.manaregen
end

function modifier_item_archmages_orb_passive:IsHidden()
	return true
end