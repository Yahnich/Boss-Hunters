undying_deathlust = class({})

function undying_deathlust:GetIntrinsicModifierName()
	return "modifier_undying_deathlust"
end

modifier_undying_deathlust = class({})
LinkLuaModifier("modifier_undying_deathlust", "heroes/hero_undying/undying_deathlust", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_deathlust:OnCreated()
	self:OnRefresh()
end

function modifier_undying_deathlust:OnRefresh()
	self.hpThreshold = self:GetSpecialValueFor("health_threshold_pct")
	self.delay = self:GetSpecialValueFor("linger_duration")
	self.duration = self:GetSpecialValueFor("duration")
	self.undying_stacks = self:GetSpecialValueFor("undying_stacks")
	
	self.max_threshold = self:GetSpecialValueFor("max_threshold")
end

function modifier_undying_deathlust:OnIntervalThink()
	self:StartIntervalThink( -1 )
	self:SetDuration( -1, true )
end

function modifier_undying_deathlust:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_undying_deathlust:OnAttackLanded( params )
	local caster = self:GetCaster()
	if params.attacker:GetPlayerOwnerID() ~= caster:GetPlayerOwnerID() then return end
	local ability = self:GetAbility()
	if params.target:GetHealthPercent() <= self.hpThreshold then
		local buff = params.attacker:FindModifierByNameAndCaster( "modifier_undying_deathlust_buff", caster )
		local oldStrength = buff:GetStackCount()
		local strength = 100
		if self.max_threshold > 0 then
			local strength =  math.min( 100, ( 100-params.target:GetHealthPercent() ) * (100/(100-self.max_threshold)) )
		end
		if oldStrength <= strength then
			params.attackert:AddNewModifier( caster, ability, "modifier_undying_deathlust_buff", {duration = self.duration} ):SetStackCount( strength )
		end
	end
	local debuff = params.target:FindModifierByNameAndCaster( "modifier_undying_deathlust_debuff", params.attacker )
	if not debuff then
		local strength = 1
		if params.attacker == self:GetCaster() then
			strength = self.undying_stacks
		end
		params.target:AddNewModifier( caster, ability, "modifier_undying_deathlust_debuff", {duration = self.duration} ):SetStackCount( strength )
	else
		debuff:SetDuration( self.duration, true )
	end
end

function modifier_undying_deathlust:IsHidden()
	return true
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

modifier_undying_deathlust_buff = class({})
LinkLuaModifier("modifier_undying_deathlust_buff", "heroes/hero_undying/undying_deathlust", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_deathlust:OnCreated()
	self:OnRefresh()
end

function modifier_undying_deathlust_buff:OnRefresh()
	self.attackSpeed = self:GetSpecialValueFor("bonus_attack_speed")
	self.moveSpeed = self:GetSpecialValueFor("bonus_move_speed")
end

function modifier_undying_deathlust_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT  }
end

function modifier_undying_deathlust_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.moveSpeed * self:GetStackCount() / 100
end

function modifier_undying_deathlust_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackSpeed * self:GetStackCount() / 100
end

modifier_undying_deathlust_debuff = class({})
LinkLuaModifier("modifier_undying_deathlust_debuff", "heroes/hero_undying/undying_deathlust", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_deathlust_debuff:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
	self.attackslow = self:GetSpecialValueFor("slow") * self:GetSpecialValueFor("attack_slow")
end

function modifier_undying_deathlust_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT  }
end

function modifier_undying_deathlust_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow * self:GetStackCount()
end

function modifier_undying_deathlust_debuff:GetModifierAttackSpeedBonus_Constant()
	return -self.attackslow * self:GetStackCount()
end

function modifier_undying_deathlust_debuff:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_fg_aura_debuff.vpcf"
end

function modifier_undying_deathlust_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end