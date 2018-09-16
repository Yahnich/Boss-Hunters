item_cultists_veil = class({})

function item_cultists_veil:GetIntrinsicModifierName()
	return "modifier_item_cultists_veil_passive"
end

function item_cultists_veil:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	
	EmitSoundOn( "DOTA_Item.VeilofDiscord.Activate", self:GetCaster() )
	ParticleManager:FireParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = point, [1] = Vector(radius,1,1)})
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( point, radius ) ) do
		enemy:AddNewModifier(caster, self, "modifier_cultists_veil_debuff", {duration = duration})
	end
end

LinkLuaModifier( "modifier_cultists_veil_debuff", "items/item_cultists_veil.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_cultists_veil_debuff = class(itemBaseClass)

function modifier_cultists_veil_debuff:OnCreated()
	self.mr = (-1) * self:GetAbility():GetSpecialValueFor("bonus_magic_damage")
end

function modifier_cultists_veil_debuff:OnRefresh()
	self.mr = math.min(self.mr, (-1) * self:GetAbility():GetSpecialValueFor("bonus_magic_damage"))
end

function modifier_cultists_veil_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_cultists_veil_debuff:GetModifierMagicalResistanceBonus()
	return self.mr
end


modifier_item_cultists_veil_passive = class({})
LinkLuaModifier( "modifier_item_cultists_veil_passive", "items/item_cultists_veil.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_cultists_veil_passive:OnCreated()
	self.manacost = self:GetSpecialValueFor("mana_cost_reduction")
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.int = self:GetSpecialValueFor("bonus_intellect")
end

function modifier_item_cultists_veil_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_cultists_veil_passive:GetModifierPercentageManacost()
	return self.manacost
end

function modifier_item_cultists_veil_passive:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_cultists_veil_passive:GetModifierBonusStats_Intellect()
	return self.int
end