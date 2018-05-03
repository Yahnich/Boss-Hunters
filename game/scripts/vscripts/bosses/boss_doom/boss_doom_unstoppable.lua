boss_doom_unstoppable = class({})

function boss_doom_unstoppable:GetIntrinsicModifierName()
	return "modifier_boss_doom_unstoppable"
end

function boss_doom_unstoppable:ShouldUseResources()
	return true
end

modifier_boss_doom_unstoppable = class({})
LinkLuaModifier("modifier_boss_doom_unstoppable", "bosses/boss_doom/boss_doom_unstoppable", LUA_MODIFIER_MOTION_NONE)


function modifier_boss_doom_unstoppable:OnCreated()
	self.dmg = self:GetSpecialValueFor("bonus_damage")
	self.as = self:GetSpecialValueFor("bonus_attackspeed")
	self.red = self:GetSpecialValueFor("damage_reduction")
	if IsServer() then self:StartIntervalThink(0.1) end
end

function modifier_boss_doom_unstoppable:OnIntervalThink()
	if self:GetParent():IsDisabled(true) and self:GetAbility():IsCooldownReady() and not self:GetParent():HasModifier("modifier_spawn_immunity") then
		self:GetAbility():SetCooldown()
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_status_immunity", {duration = self:GetSpecialValueFor("duration")})
	end
end


function modifier_boss_doom_unstoppable:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_doom_demonic_servants_handler:GetModifierIncomingDamage_Percentage()
	return self.red
end

function modifier_boss_doom_unstoppable:GetModifierDamageOutgoing_Percentage()
	return self.dmg
end

function modifier_boss_doom_unstoppable:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_boss_doom_unstoppable:IsHidden()
	return true
end