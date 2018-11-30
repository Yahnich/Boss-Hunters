abaddon_curse_ebf = class({})

function abaddon_curse_ebf:GetIntrinsicModifierName()
	return "modifier_abaddon_curse_passive"
end

LinkLuaModifier( "modifier_abaddon_curse_passive", "heroes/hero_abaddon/abaddon_curse_ebf", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_curse_passive = class({})

function modifier_abaddon_curse_passive:IsHidden()
	return true
end

function modifier_abaddon_curse_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_TAKEDAMAGE
			}
	return funcs
end

function modifier_abaddon_curse_passive:OnTakeDamage(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_abaddon_curse_debuff", {duration = self:GetAbility():GetTalentSpecialValueFor("debuff_duration")} )
			params.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_abaddon_curse_buff", {duration = self:GetAbility():GetTalentSpecialValueFor("buff_duration")} )
		end
		if params.unit:HasModifier("modifier_abaddon_curse_debuff") then
			params.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_abaddon_curse_buff", {duration = self:GetAbility():GetTalentSpecialValueFor("buff_duration")} )
		end
	end
end

LinkLuaModifier( "modifier_abaddon_curse_buff", "heroes/hero_abaddon/abaddon_curse_ebf", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_curse_buff = class({})

function modifier_abaddon_curse_buff:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_frost_buff.vpcf"
end

function modifier_abaddon_curse_buff:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("move_speed_pct")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_abaddon_curse_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				
			}
	return funcs
end

function modifier_abaddon_curse_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_abaddon_curse_buff:GetModifierAttackSpeedBonus()
	return self.attackspeed
end

LinkLuaModifier( "modifier_abaddon_curse_debuff", "heroes/hero_abaddon/abaddon_curse_ebf", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_curse_debuff = class({})

function modifier_abaddon_curse_debuff:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_frost_slow.vpcf"
end

function modifier_abaddon_curse_debuff:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("slow_pct")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("attack_slow_tooltip")
end

function modifier_abaddon_curse_debuff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				
			}
	return funcs
end

function modifier_abaddon_curse_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_abaddon_curse_debuff:GetModifierAttackSpeedBonus()
	return self.attackspeed
end