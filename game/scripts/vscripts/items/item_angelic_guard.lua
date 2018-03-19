item_angelic_guard = class({})

LinkLuaModifier( "modifier_item_angelic_guard", "items/item_angelic_guard.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_angelic_guard:GetIntrinsicModifierName()
	return "modifier_item_angelic_guard"
end

function item_angelic_guard:OnSpellStart()
	local caster = self:GetCaster()
	local healPct = self:GetSpecialValueFor("heal") / 100
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		ParticleManager:FireParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_POINT_FOLLOW, ally)
		EmitSoundOn("DOTA_Item.Mekansm.Target", ally)
		ally:HealEvent(healPct * ally:GetMaxHealth(), self, caster)
	end
	ParticleManager:FireParticle("particles/items2_fx/mekanism.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("DOTA_Item.Mekansm.Activate", caster)
end

modifier_item_angelic_guard = class({})
function modifier_item_angelic_guard:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_block")
	self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
end

function modifier_item_angelic_guard:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end

function modifier_item_angelic_guard:GetModifierTotal_ConstantBlock()
	if RollPercentage(self.chance) then
		return self.block
	end
end

function modifier_item_angelic_guard:IsHidden()
	return true
end