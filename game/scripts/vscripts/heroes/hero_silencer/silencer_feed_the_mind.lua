silencer_feed_the_mind = class({})

function silencer_feed_the_mind:GetCastRange( target, position )
	return self:GetTalentSpecialValueFor("radius")
end

function silencer_feed_the_mind:GetIntrinsicModifierName()
	return "modifier_silencer_feed_the_mind"
end

modifier_silencer_feed_the_mind = class({})
LinkLuaModifier( "modifier_silencer_feed_the_mind", "heroes/hero_silencer/silencer_feed_the_mind", LUA_MODIFIER_MOTION_NONE )

function modifier_silencer_feed_the_mind:OnCreated()
	self.bossInt = self:GetTalentSpecialValueFor("boss_int")
	self.minionInt = self:GetTalentSpecialValueFor("minion_int")
	self.minionDur = self:GetTalentSpecialValueFor("minion_duration")
	self.radius = self:GetTalentSpecialValueFor("radius")
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_silencer_int_steal")
		self:SetStackCount(0)
	end
end

function modifier_silencer_feed_the_mind:OnIntervalThink()
	self:SetDuration( -1, false )
	self:StartIntervalThink( -1 )
end

function modifier_silencer_feed_the_mind:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_silencer_feed_the_mind:OnDeath(params)
	if params.attacker == self:GetParent() or CalculateDistance( self:GetParent(), params.unit ) <= self.radius then
		if params.unit:IsRoundBoss() then
			for i = 1, self.bossInt do
				self:IncrementStackCount()
			end
		else
			self:MinionDeath(self.minionInt)
		end
	end
end

function modifier_silencer_feed_the_mind:MinionDeath(amount, duration)
	if self:GetRemainingTime() < (duration or self.minionDur) then
		self:SetDuration( (duration or self.minionDur) + 0.01, true )
	end
	self:StartIntervalThink( duration or self.minionDur )
	for i = 1, amount do
		self:AddIndependentStack( duration or self.minionDur )
	end
end

function modifier_silencer_feed_the_mind:GetModifierBonusStats_Intellect()
	return self:GetStackCount()
end

function modifier_silencer_feed_the_mind:IsPurgable()
	return false
end

function modifier_silencer_feed_the_mind:DestroyOnExpire()
	return false
end