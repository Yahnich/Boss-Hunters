item_orb_of_shadows = class({})

function item_orb_of_shadows:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invisible", {duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():SetThreat(0)
end