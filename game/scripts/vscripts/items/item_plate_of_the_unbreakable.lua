item_plate_of_the_unbreakable = class({})

function item_plate_of_the_unbreakable:OnSpellStart()
	local caster = self:GetCaster()
	caster:Dispel(caster, true)
	self:HealEvent(self:GetSpecialValueFor("heal"), self, caster)
	ParticleManager:FireParticle("particles/generic_gameplay/generic_purge.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("DOTA_Item.Tango.Activate", caster)
end

modifier_plate_of_the_unbreakable_passive = class({})
LinkLuaModifier("modifier_plate_of_the_unbreakable_passive", "items/item_plate_of_the_unbreakable", LUA_MODIFIER_MOTION_NONE)

function modifier_plate_of_the_unbreakable_passive:OnCreated()
	self.armor = self:GetSpecialValueFor("armor")
	self.ms = self:GetParent():GetIdealSpeedNoSlows()
	self:StartIntervalThink(0.5)
end

function modifier_plate_of_the_unbreakable_passive:OnIntervalThink()
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

function modifier_plate_of_the_unbreakable_passive:IsHidden()
	return true
end

function modifier_plate_of_the_unbreakable_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end