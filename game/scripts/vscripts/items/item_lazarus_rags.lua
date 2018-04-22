item_lazarus_rags = class({})

LinkLuaModifier( "modifier_item_lazarus_rags", "items/item_lazarus_rags.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_lazarus_rags:GetIntrinsicModifierName()
	return "modifier_item_lazarus_rags"
end

function item_lazarus_rags:OnSpellStart()
	local caster = self:GetCaster()
	
	local healPct = self:GetSpecialValueFor("heal") / 100
	local managain = self:GetSpecialValueFor("mana_restore") / 100
	local minRestore = self:GetSpecialValueFor("min_restore")
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		ParticleManager:FireParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_POINT_FOLLOW, ally)
		ParticleManager:FireParticle("particles/items3_fx/warmage_recipient.vpcf", PATTACH_POINT_FOLLOW, ally)
		EmitSoundOn("DOTA_Item.Mekansm.Target", ally)
		ally:HealEvent(math.max(minRestore, healPct * ally:GetMaxHealth() ), self, caster)
		ally:GiveMana( math.max(minRestore, ally:GetMaxMana() * managain ) )
	end

	ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("DOTA_Item.ArcaneBoots.Activate", caster)
	ParticleManager:FireParticle("particles/items2_fx/mekanism.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("DOTA_Item.Mekansm.Activate", caster)
end

modifier_item_lazarus_rags = class({})
function modifier_item_lazarus_rags:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_block")
	self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
	self.spellamp = self:GetSpecialValueFor("spell_amp")
	self.manaregen = self:GetSpecialValueFor("mana_regen")
	self.hp_regen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
	self.bonus_mana = self:GetSpecialValueFor("bonus_mana")
end

function modifier_item_lazarus_rags:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_BONUS}
end

function modifier_item_lazarus_rags:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_lazarus_rags:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_item_lazarus_rags:GetModifierTotal_ConstantBlock(params)
	if RollPercentage(self.chance) and params.attacker ~= self:GetParent() then
		return self.block
	end
end

function modifier_item_lazarus_rags:GetModifierSpellAmplify_Percentage()
	return self.spellamp
end

function modifier_item_lazarus_rags:GetModifierConstantManaRegen()
	return self.manaregen
end

function modifier_item_lazarus_rags:IsHidden()
	return true
end