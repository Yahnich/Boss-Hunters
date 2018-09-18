boss_sloth_demon_slime_hide = class({})

function boss_sloth_demon_slime_hide:GetIntrinsicModifierName()
	return "modifier_boss_sloth_demon_slime_hide"
end

modifier_boss_sloth_demon_slime_hide = class({})
LinkLuaModifier( "modifier_boss_sloth_demon_slime_hide", "bosses/boss_sloth_demon/boss_sloth_demon_slime_hide", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_sloth_demon_slime_hide:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_sloth_demon_slime_hide:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_sloth_demon_slime_hide:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_sloth_demon_slime_hide:OnTakeDamage(params)
	if params.attacker == self:GetParent() then
		params.unit:AddNewModifier( params.attacker, self:GetAbility(), "modifier_boss_sloth_demon_slime_hide_debuff", {duration = self.duration} )
	end
end

function modifier_boss_sloth_demon_slime_hide:IsHidden()
	return true
end

modifier_boss_sloth_demon_slime_hide_debuff = class({})
LinkLuaModifier( "modifier_boss_sloth_demon_slime_hide_debuff", "bosses/boss_sloth_demon/boss_sloth_demon_slime_hide", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_sloth_demon_slime_hide_debuff:OnCreated()
	self.as = self:GetSpecialValueFor("attack_slow")
	self.cdr = self:GetSpecialValueFor("cdr_slow")
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_boss_sloth_demon_slime_hide_debuff:OnRefresh()
	self.as = self:GetSpecialValueFor("attack_slow")
	self.cdr = self:GetSpecialValueFor("cdr_slow")
	if IsServer() then
		self:IncrementStackCount()
	end
end

function modifier_boss_sloth_demon_slime_hide_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_boss_sloth_demon_slime_hide_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.as * self:GetStackCount()
end

function modifier_boss_sloth_demon_slime_hide_debuff:GetCooldownReduction()
	return self.cdr * self:GetStackCount()
end