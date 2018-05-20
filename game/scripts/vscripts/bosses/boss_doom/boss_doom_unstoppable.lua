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
	if IsServer() then 
		self:StartIntervalThink(0.1) 
	end
end

function modifier_boss_doom_unstoppable:OnIntervalThink()
	if self:GetParent():IsDisabled(true) and self:GetAbility():IsCooldownReady() and not self:GetParent():HasModifier("modifier_spawn_immunity") then
		self:GetAbility():SetCooldown()
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss_doom_unstoppable_effect", {duration = self:GetSpecialValueFor("duration")})
	end
end
function modifier_boss_doom_unstoppable:IsHidden()
	return true
end

modifier_boss_doom_unstoppable_effect = class({})
LinkLuaModifier("modifier_boss_doom_unstoppable_effect", "bosses/boss_doom/boss_doom_unstoppable", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_doom_unstoppable_effect:OnCreated()
	self.dmg = self:GetSpecialValueFor("bonus_damage")
	self.as = self:GetSpecialValueFor("bonus_attackspeed")
	self.red = self:GetSpecialValueFor("damage_reduction")
end

function modifier_boss_doom_unstoppable_effect:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_doom_unstoppable_effect:CheckState()
	return {[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_DISARMED] = false,
			[MODIFIER_STATE_SILENCED] = false,
			[MODIFIER_STATE_MUTED] = false,
			[MODIFIER_STATE_STUNNED] = false,
			[MODIFIER_STATE_HEXED] = false,
			[MODIFIER_STATE_FROZEN] = false,
			[MODIFIER_STATE_PASSIVES_DISABLED] = false}
end

function modifier_boss_doom_unstoppable_effect:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_boss_doom_unstoppable_effect:GetModifierIncomingDamage_Percentage()
	return self.red
end

function modifier_boss_doom_unstoppable_effect:GetModifierDamageOutgoing_Percentage()
	return self.dmg
end

function modifier_boss_doom_unstoppable_effect:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_boss_doom_unstoppable_effect:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end

function modifier_boss_doom_unstoppable_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf"
end

function modifier_boss_doom_unstoppable_effect:StatusEffectPriority()
	return 50
end