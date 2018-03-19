item_assault_2 = class({})

function item_assault_2:GetIntrinsicModifierName()
	return "modifier_item_assault_handler"
end

item_assault_3 = class(item_assault_2)

function item_assault_3:OnSpellStart()
	local caster = self:GetCaster()
	self:GetCaster():Dispel( caster, true)
	EmitSoundOn( "DOTA_Item.DiffusalBlade.Activate", caster )
	ParticleManager:FireParticle( "particles/generic_gameplay/generic_purge.vpcf", PATTACH_POINT_FOLLOW, caster )
end

item_assault_4 = class(item_assault_3)
item_assault_5 = class(item_assault_3)

function item_assault_5:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn( "DOTA_Item.DiffusalBlade.Activate", ally )
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), -1) ) do
		ally:Dispel(ally, true)
		ParticleManager:FireParticle( "particles/generic_gameplay/generic_purge.vpcf", PATTACH_POINT_FOLLOW, ally )
	end
end


modifier_item_assault_handler = class({})
LinkLuaModifier("modifier_item_assault_handler", "items/item_cuirass", LUA_MODIFIER_MOTION_NONE)

function modifier_item_assault_handler:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.attackspeed = self:GetTalentSpecialValueFor("bonus_attack_speed")
	self.mr = self:GetTalentSpecialValueFor("bonus_spell_resist")
	self.regen =  self:GetTalentSpecialValueFor("bonus_health_regen")
	self.all = self:GetTalentSpecialValueFor("all_stats")
	self.radius = self:GetTalentSpecialValueFor("aura_radius")
end

function modifier_item_assault_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_assault_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			
			}
end

function modifier_item_assault_handler:GetModifierPhysicalArmorBonus()
	return self.armor
end
function modifier_item_assault_handler:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_item_assault_handler:GetModifierConstantHealthRegen()
	return self.regen
end
function modifier_item_assault_handler:GetModifierBonusStats_Strength()
	return self.all
end
function modifier_item_assault_handler:GetModifierBonusStats_Agility()
	return self.all
end
function modifier_item_assault_handler:GetModifierBonusStats_Intellect()
	return self.all
end


function modifier_item_assault_handler:IsAura()
	return true
end

function modifier_item_assault_handler:GetModifierAura()
	return "modifier_item_assault_aura"
end

function modifier_item_assault_handler:GetAuraRadius()
	return self.radius
end

function modifier_item_assault_handler:GetAuraDuration()
	return 0.5
end

function modifier_item_assault_handler:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_item_assault_handler:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_assault_handler:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_assault_handler:IsHidden()
	return true
end


modifier_item_assault_aura = class({})
LinkLuaModifier("modifier_item_assault_aura", "items/item_cuirass", LUA_MODIFIER_MOTION_NONE)

function modifier_item_assault_aura:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("aura_positive_armor")
	self.attackspeed = self:GetTalentSpecialValueFor("aura_attack_speed")
	self.mr = self:GetTalentSpecialValueFor("bonus_spell_resist")
	if not self:GetParent():IsSameTeam( self:GetCaster() ) then
		self.armor = self:GetTalentSpecialValueFor("aura_negative_armor")
		self.mr = self.mr * (-1)
	end
end

function modifier_item_assault_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_item_assault_aura:GetModifierPhysicalArmorBonus()
	return self.armor
end
function modifier_item_assault_aura:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end
function modifier_item_assault_aura:GetModifierMagicalResistanceBonus()
	return self.mr
end