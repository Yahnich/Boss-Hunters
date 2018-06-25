item_angelic_guard = class({})

LinkLuaModifier( "modifier_item_angelic_guard", "items/item_angelic_guard.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_angelic_guard:GetIntrinsicModifierName()
	return "modifier_item_angelic_guard"
end

function item_angelic_guard:OnSpellStart()
	local caster = self:GetCaster()
	local healPct = self:GetSpecialValueFor("heal") / 100
	local minRestore = self:GetSpecialValueFor("min_heal")
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		ParticleManager:FireParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_POINT_FOLLOW, ally)
		EmitSoundOn("DOTA_Item.Mekansm.Target", ally)
		ally:HealEvent( math.max(minRestore, healPct * ally:GetMaxHealth()), self, caster)
	end
	ParticleManager:FireParticle("particles/items2_fx/mekanism.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("DOTA_Item.Mekansm.Activate", caster)
end

modifier_item_angelic_guard = class({})
function modifier_item_angelic_guard:OnCreated()
	self.block = self:GetAbility():GetSpecialValueFor("damage_block")
	self.chance = self:GetAbility():GetSpecialValueFor("block_chance")
	self.hp_regen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_angelic_guard:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,}
end

function modifier_item_angelic_guard:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_item_angelic_guard:GetModifierTotal_ConstantBlock(params)
	if RollPercentage(self.chance) and params.attacker ~= self:GetParent() then
		return self.block
	end
end

function modifier_item_angelic_guard:IsHidden()
	return true
end

function modifier_item_angelic_guard:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end