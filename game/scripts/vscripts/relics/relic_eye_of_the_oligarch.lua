relic_eye_of_the_oligarch = class(relicBaseClass)

function relic_eye_of_the_oligarch:OnCreated(kv)
	if IsServer() then
		self:SetStackCount( self:GetParent():GetGold() )
		self:StartIntervalThink(0.33)
	end
end

function relic_eye_of_the_oligarch:OnIntervalThink()
	self:SetStackCount( self:GetParent():GetGold() )
end

function relic_eye_of_the_oligarch:DeclareFunctions()
	return {MODIFIER_PROPERTY_FIXED_DAY_VISION,
			MODIFIER_PROPERTY_FIXED_NIGHT_VISION}
end

function relic_eye_of_the_oligarch:GetFixedDayVision(params)
	if not self:GetParent():HasModifier("relic_ritual_candle") then
		return self:GetStackCount()
	else
		return math.max( 1800, self:GetStackCount() )
	end
end

function relic_eye_of_the_oligarch:GetFixedNightVision(params)
	if not self:GetParent():HasModifier("relic_ritual_candle") then
		return self:GetStackCount()
	else
		return math.max( 800, self:GetStackCount() )
	end
end