oracle_pactbreaker = class({})

function oracle_pactbreaker:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl )  + self:GetCaster():FindTalentValue("special_bonus_unique_oracle_pactmaker_1")
end

function oracle_pactbreaker:ShouldUseResources()
	return true
end