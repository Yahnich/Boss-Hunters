sniper_rangefinder = class({})

function sniper_rangefinder:GetIntrinsicModifierName()
    return "modifier_sniper_rangefinder"
end

modifier_sniper_rangefinder = class({})
LinkLuaModifier("modifier_sniper_rangefinder", "heroes/hero_sniper/sniper_rangefinder", LUA_MODIFIER_MOTION_NONE)

function modifier_sniper_rangefinder:OnCreated()
    self:OnRefresh()
end

function modifier_sniper_rangefinder:OnRefresh()
    self.stability_gain = self:GetSpecialValueFor("stability_gain")
    self.maximum_stability = self:GetSpecialValueFor("maximum_stability")
    self.cast_speed_per_stability = self:GetSpecialValueFor("cast_speed_per_stability")
    self.accuracy_per_stability = self:GetSpecialValueFor("accuracy_per_stability")
	if IsServer() then
		self._internalCounter = 0
		self:StartIntervalThink( 0 )
	end
end

function modifier_sniper_rangefinder:OnIntervalThink()
	local caster = self:GetCaster()
	if caster:IsMoving() then
		self._internalCounter = 0
		self:SetStackCount( 0 )
	elseif self._internalCounter < self.maximum_stability then
		self._internalCounter = math.min( self.maximum_stability, self._internalCounter + self.stability_gain  * FrameTime() )
		self:SetStackCount( math.floor( self._internalCounter ) )
	end
end

function modifier_sniper_rangefinder:DeclareFunctions()
    return {MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
			MODIFIER_EVENT_ON_ATTACK_START}
end

function modifier_sniper_rangefinder:CheckState()
	if self._nextHitHits then
		return {[MODIFIER_STATE_CANNOT_MISS] = true}
	end
end

function modifier_sniper_rangefinder:GetModifierPercentageCasttime()
    return self.cast_speed_per_stability * self:GetStackCount()
end

function modifier_sniper_rangefinder:OnAttackStart( params )
	if params.attacker ~= self:GetParent() then return end
	self._nextHitHitsq = self:RollPRNG( self.accuracy_per_stability * self:GetStackCount() )
end

function modifier_sniper_rangefinder:IsHidden()
    return self:GetStackCount() <= 0
end