item_tome_of_immense_knowledge = class({})

function item_tome_of_immense_knowledge:OnSpellStart()
	if self:GetCaster():IsAlive() then
		EmitSoundOn("Item.TomeOfKnowledge", self:GetCaster() )
		self:GetCaster():AddXP( self:GetSpecialValueFor("bonus_xp") * self:GetCurrentCharges() )
		self:Destroy()
	end
end