item_plate_of_the_unbreakable = class({})

function item_plate_of_the_unbreakable:GetIntrinsicModifierName()
	return "modifier_plate_of_the_unbreakable_passive"
end

function item_plate_of_the_unbreakable:OnSpellStart()
	local caster = self:GetCaster()
	caster:Dispel(caster, true)
	caster:HealEvent(self:GetSpecialValueFor("heal"), self, caster)
	ParticleManager:FireParticle("particles/generic_gameplay/generic_purge.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("DOTA_Item.Tango.Activate", caster)
end

modifier_plate_of_the_unbreakable_passive = class({})
LinkLuaModifier("modifier_plate_of_the_unbreakable_passive", "items/item_plate_of_the_unbreakable", LUA_MODIFIER_MOTION_NONE)

function modifier_plate_of_the_unbreakable_passive:OnCreated()
	self.armor = self:GetSpecialValueFor("armor")
	self.radius = self:GetSpecialValueFor("radius")
	self.ms = self:GetParent():GetIdealSpeedNoSlows()
	self:StartIntervalThink(0.5)
end

function modifier_plate_of_the_unbreakable_passive:OnIntervalThink()
	self.ms = 0
	self.ms = self:GetParent():GetIdealSpeedNoSlows()
end

function modifier_plate_of_the_unbreakable_passive:CheckState()
	return {[MODIFIER_STATE_ROOTED] = false}
end

function modifier_plate_of_the_unbreakable_passive:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_plate_of_the_unbreakable_passive:DeclareFunctions()
	funcs = {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
			 MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
	return funcs
end

function modifier_plate_of_the_unbreakable_passive:GetModifierMoveSpeed_AbsoluteMin()
	return self.ms
end

function modifier_plate_of_the_unbreakable_passive:GetModifierPhysicalArmorBonus()
	return self.armor
end


function modifier_plate_of_the_unbreakable_passive:IsAura()
	return true
end

function modifier_plate_of_the_unbreakable_passive:GetModifierAura()
	return "modifier_plate_of_the_unbreakable_aura"
end

function modifier_plate_of_the_unbreakable_passive:GetAuraRadius()
	return self.radius
end

function modifier_plate_of_the_unbreakable_passive:GetAuraDuration()
	return 0.5
end

function modifier_plate_of_the_unbreakable_passive:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_plate_of_the_unbreakable_passive:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_plate_of_the_unbreakable_passive:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_plate_of_the_unbreakable_passive:IsHidden()
	return true
end

function modifier_plate_of_the_unbreakable_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_plate_of_the_unbreakable_aura = class({})
LinkLuaModifier("modifier_plate_of_the_unbreakable_aura", "items/item_plate_of_the_unbreakable", LUA_MODIFIER_MOTION_NONE)

function modifier_plate_of_the_unbreakable_aura:OnCreated()
	self.armor = self:GetSpecialValueFor("armor_aura")
end

function modifier_plate_of_the_unbreakable_aura:OnRefresh()
	self.armor = self:GetSpecialValueFor("armor_aura")
end

function modifier_plate_of_the_unbreakable_aura:DeclareFunctions()
	funcs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
	return funcs
end

function modifier_plate_of_the_unbreakable_aura:GetModifierPhysicalArmorBonus()
	return self.armor
end