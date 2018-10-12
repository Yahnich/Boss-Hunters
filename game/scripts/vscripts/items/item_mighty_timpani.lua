item_mighty_timpani = class({})
LinkLuaModifier( "modifier_item_mighty_timpani_passive", "items/item_mighty_timpani.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mighty_timpani_passive_aura", "items/item_mighty_timpani.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mighty_timpani_active", "items/item_mighty_timpani.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_mighty_timpani:GetIntrinsicModifierName()
	return "modifier_item_mighty_timpani_passive"
end

function item_mighty_timpani:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("DOTA_Item.DoE.Activate", caster)

	local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	for _,ally in pairs(allies) do
		ally:AddNewModifier(caster, self, "modifier_item_mighty_timpani_active", {Duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_item_mighty_timpani_passive = class(itemBaseClass)
function modifier_item_mighty_timpani_passive:OnCreated()
	self.bonus_agi = self:GetSpecialValueFor("bonus_agi")
	self.bonus_int = self:GetSpecialValueFor("bonus_int")
	self.bonus_str = self:GetSpecialValueFor("bonus_str")
	self.bonus_mregen = self:GetSpecialValueFor("bonus_mregen")
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_mighty_timpani_passive:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end

function modifier_item_mighty_timpani_passive:GetModifierBonusStats_Strength()
	return self.bonus_str
end

function modifier_item_mighty_timpani_passive:GetModifierBonusStats_Agility()
	return self.bonus_agi
end

function modifier_item_mighty_timpani_passive:GetModifierBonusStats_Intellect()
	return self.bonus_int
end

function modifier_item_mighty_timpani_passive:GetModifierConstantManaRegen()
	return self.bonus_mregen
end

function modifier_item_mighty_timpani_passive:IsAura()
	return true
end

function modifier_item_mighty_timpani_passive:GetModifierAura()
	return "modifier_item_mighty_timpani_passive_aura"
end

function modifier_item_mighty_timpani_passive:GetAuraRadius()
	return self.radius
end

function modifier_item_mighty_timpani_passive:GetAuraDuration()
	return 0.5
end

function modifier_item_mighty_timpani_passive:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_mighty_timpani_passive:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_ALL
end

function modifier_item_mighty_timpani_passive:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_item_mighty_timpani_passive_aura = class({})
function modifier_item_mighty_timpani_passive_aura:GetTextureName()
	return "ancient_janggo"
end

function modifier_item_mighty_timpani_passive_aura:OnCreated()
	self.bonus_ms_aura = self:GetSpecialValueFor("bonus_ms_aura")
end

function modifier_item_mighty_timpani_passive_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function modifier_item_mighty_timpani_passive_aura:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms_aura
end

modifier_item_mighty_timpani_active = class({})
function modifier_item_mighty_timpani_active:GetTextureName()
	return "ancient_janggo"
end

function modifier_item_mighty_timpani_active:OnCreated()
	self.bonus_as = self:GetSpecialValueFor("bonus_as")
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
	self.bonus_ms_buff = self:GetSpecialValueFor("bonus_ms_buff")
end

function modifier_item_mighty_timpani_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_item_mighty_timpani_active:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_ms_buff
end

function modifier_item_mighty_timpani_active:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_item_mighty_timpani_active:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus_dmg
end

function modifier_item_mighty_timpani_active:GetEffectName()
	return "particles/items_fx/drum_of_endurance_buff.vpcf"
end