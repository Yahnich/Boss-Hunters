item_creed_of_knowledge = class({})

function item_creed_of_knowledge:OnSpellStart()
	if self:GetCaster():IsAlive() then
		EmitSoundOn("Item.TomeOfKnowledge", self:GetCaster() )
		self:GetCaster():AddExperience( self:GetSpecialValueFor("bonus_xp"), 0, false, false )
		self:Destroy()
	end
end