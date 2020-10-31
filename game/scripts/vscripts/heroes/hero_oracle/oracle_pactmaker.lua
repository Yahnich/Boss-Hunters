oracle_pactmaker = class({})

function oracle_pactmaker:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_oracle_pactmaker_1")
end

function oracle_pactmaker:ShouldUseResources()
	return true
end