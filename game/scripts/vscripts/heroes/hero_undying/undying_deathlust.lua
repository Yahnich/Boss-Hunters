undying_deathlust = class({})

function undying_deathlust:GetIntrinsicModifierName()
	return "modifier_undying_deathlust"
end

modifier_undying_deathlust = class({})
LinkLuaModifier("modifier_undying_deathlust", "heroes/hero_undying/undying_deathlust", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_deathlust:OnCreated()
	self.hpThreshold = self:GetTalentSpecialValueFor("health_threshold_pct")
	self.attackSpeed = self:GetTalentSpecialValueFor("bonus_attack_speed")
	self.moveSpeed = self:GetTalentSpecialValueFor("bonus_move_speed")
	
	self.attackSpeedLvlup = self:GetTalentSpecialValueFor("bonus_as_lvlup")
	self.moveSpeedLvlup = self:GetTalentSpecialValueFor("bonus_ms_lvlup")
	
	self.delay = self:GetTalentSpecialValueFor("linger_duration")
	self.duration = self:GetTalentSpecialValueFor("duration")
end

function modifier_undying_deathlust:OnIntervalThink()
	self:StartIntervalThink( -1 )
	self:SetDuration( -1, true )
end

function modifier_undying_deathlust:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT  }
end

function modifier_undying_deathlust:OnAttackLanded( params )
	if params.attacker == self:GetParent() then
		Timers:CreateTimer( function()
			if params.target:GetHealthPercent() <= self.hpThreshold then
				self:StartIntervalThink( self.delay )
				self:SetDuration( self.delay, true )
			end
		end)
		local debuff = params.target:FindModifierByNameAndCaster( "modifier_undying_deathlust_debuff", params.attacker )
		if not debuff then
			params.target:AddNewModifier( params.attacker, self:GetAbility(), "modifier_undying_deathlust_debuff", {duration = self.duration} )
		else
			debuff:SetDuration( self.duration, true )
		end
	end
end

function modifier_undying_deathlust:GetModifierMoveSpeedBonus_Percentage()
	if self:GetDuration() > 0 then
		return self.moveSpeed + self:GetParent():GetLevel() * self.moveSpeedLvlup
	end
end

function modifier_undying_deathlust:GetModifierAttackSpeedBonus_Constant()
	if self:GetDuration() > 0 then
		return self.attackSpeed + self:GetParent():GetLevel() * self.attackSpeedLvlup
	end
end

function modifier_undying_deathlust:IsHidden()
	return self:GetDuration() < 0
end

function modifier_undying_deathlust:IsPurgable()
	return false
end

function modifier_undying_deathlust:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_undying_deathlust:DestroyOnExpire()
	return false
end


modifier_undying_deathlust_debuff = class({})
LinkLuaModifier("modifier_undying_deathlust_debuff", "heroes/hero_undying/undying_deathlust", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_deathlust_debuff:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("slow")
end

function modifier_undying_deathlust_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_undying_deathlust_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_undying_deathlust_debuff:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_fg_aura_debuff.vpcf"
end

function modifier_undying_deathlust_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end