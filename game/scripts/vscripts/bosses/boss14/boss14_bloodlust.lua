boss14_bloodlust = class({})

function boss14_bloodlust:GetIntrinsicModifierName()
	return "modifier_boss14_bloodlust_passive"
end

modifier_boss14_bloodlust_passive = class({})
LinkLuaModifier("modifier_boss14_bloodlust_passive", "bosses/boss14/boss14_bloodlust", 0)

function modifier_boss14_bloodlust_passive:OnCreated()
	self.ms = self:GetSpecialValueFor("movespeed")
	self.amp = self:GetSpecialValueFor("damage_amp")
	if IsServer() then self:StartIntervalThink(0.2) end
end

function modifier_boss14_bloodlust_passive:OnIntervalThink()
	if self:GetParent().AIprevioustarget then 
		local difference = self:GetParent().AIprevioustarget:GetThreat() - self:GetStackCount()
		if math.abs(difference) > 0 then
			local clamp = ((difference<0 and -1) or 1)
			self:SetStackCount( math.max(0, self:GetStackCount() + clamp) )
		end
	else 
		self:DecrementStackCount() 
	end
end

function modifier_boss14_bloodlust_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MODEL_SCALE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS  }
end

function modifier_boss14_bloodlust_passive:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetStackCount() * self.amp
end

function modifier_boss14_bloodlust_passive:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount() * self.ms
end

function modifier_boss14_bloodlust_passive:GetModifierModelScale()
	return math.min( 100, self:GetStackCount() )
end

function modifier_boss14_bloodlust_passive:GetModifierAttackRangeBonus()
	return 2.56 * math.min( 100, self:GetStackCount() )
end

function modifier_boss14_bloodlust_passive:GetActivityTranslationModifiers()
	if self:GetStackCount() > 50 then
		return "chase"
	else	
		return "run"
	end
end