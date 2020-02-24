item_tome_of_immense_knowledge = class({})

function item_tome_of_immense_knowledge:IsConsumable()
	return true
end

function item_tome_of_immense_knowledge:OnSpellStart()
	if self:GetCaster():IsAlive() then
		EmitSoundOn("Item.TomeOfKnowledge", self:GetCaster() )
		print( self:GetSpecialValueFor("max_xp"), self:GetSpecialValueFor("bonus_xp"), self:GetSpecialValueFor("xp_gain") * RoundManager:GetEventsFinished() )
		self:GetCaster():AddXP( math.min( self:GetSpecialValueFor("max_xp"), self:GetSpecialValueFor("bonus_xp") + self:GetSpecialValueFor("xp_gain") * RoundManager:GetEventsFinished() ) * self:GetCurrentCharges() )
		self:Destroy()
	end
end