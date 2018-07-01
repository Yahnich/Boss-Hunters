item_creed_of_knowledge = class({})

function item_creed_of_knowledge:OnSpellStart()
	if self:GetCaster():IsAlive() then
		EmitSoundOn("Item.TomeOfKnowledge", self:GetCaster() )
		self:GetCaster():AddXP( self:GetSpecialValueFor("bonus_xp") )
		self:Destroy()
	end
end