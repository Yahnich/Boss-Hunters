boss_apotheosis_latent_potential = class({})

function boss_apotheosis_latent_potential:GetIntrinsicModifierName()
	return "modifier_boss_apotheosis_latent_potential"
end

modifier_boss_apotheosis_latent_potential = class({})
LinkLuaModifier( "modifier_boss_apotheosis_latent_potential", "bosses/boss_apotheosis/boss_apotheosis_latent_potential", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_apotheosis_latent_potential:OnCreated()
	self.amp = self:GetSpecialValueFor("damage_amp")
	self.interval = self:GetSpecialValueFor("double_timer")
	self:SetStackCount( 1 )
	
	self:StartIntervalThink( self.interval)
end

function modifier_boss_apotheosis_latent_potential:OnRefresh()
	self.amp = self:GetSpecialValueFor("damage_amp")
	self.interval = self:GetSpecialValueFor("double_timer")
end

function modifier_boss_apotheosis_latent_potential:OnIntervalThink()
	if not self:GetParent():PassivesDisabled() then
		self:StartIntervalThink(self.interval)
		self:SetStackCount( math.min( 1000, self:GetStackCount() * 2 ) )
	else
		self:StartIntervalThink( 1 )
	end
end

function modifier_boss_apotheosis_latent_potential:DeclareFunctions()
	return { MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE }
end

function modifier_boss_apotheosis_latent_potential:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetStackCount() * self.amp
end

function modifier_boss_apotheosis_latent_potential:IsPurgable()
	return false
end