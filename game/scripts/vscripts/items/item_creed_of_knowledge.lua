item_creed_of_knowledge = class({})

function item_creed_of_knowledge:OnSpellStart()
	EmitSoundOn("Item.TomeOfKnowledge", self:GetCaster() )
	self:GetCaster():AddExperience( self:GetSpecialValueFor("bonus_xp"), false, false )
	self:Destroy()
end