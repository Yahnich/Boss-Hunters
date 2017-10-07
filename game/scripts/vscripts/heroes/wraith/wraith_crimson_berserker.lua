wraith_crimson_berserker = class({})


function wraith_crimson_berserker:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		EmitSoundOn("Hero_OgreMagi.Bloodlust.Target", caster)
		caster:AddNewModifier(caster, self, "modifier_wraith_crimson_berserker_toggle", {})
	else
		caster:RemoveModifierByName("modifier_wraith_crimson_berserker_toggle")
	end
end

modifier_wraith_crimson_berserker_toggle = class({})
LinkLuaModifier("modifier_wraith_crimson_berserker_toggle", "heroes/wraith/wraith_crimson_berserker.lua", 0)

function modifier_wraith_crimson_berserker_toggle:OnCreated()
	self.damageRed = (self:GetSpecialValueFor("damage_reduction") / 100)
	self.asPct = (self:GetSpecialValueFor("bonus_attackspeed") / 100)
	self.damagePct = (self:GetSpecialValueFor("bonus_damage") / 100)
	self.talentCrit = self:GetSpecialValueFor("talent_crit")
	self.drain = (self:GetTalentSpecialValueFor("hp_cost") / 100) * 0.03
	if IsServer() then self:StartIntervalThink(0.03) end
end

function modifier_wraith_crimson_berserker_toggle:OnIntervalThink()
	self:GetParent():SetHealth( math.max(1, self:GetParent():GetHealth() - math.ceil(self:GetParent():GetHealth() * self.drain) ) )
end

function modifier_wraith_crimson_berserker_toggle:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
			MODIFIER_PROPERTY_MODEL_SCALE}
end

function modifier_wraith_crimson_berserker_toggle:GetModifierIncomingDamage_Percentage()
	return self.damageRed * (100 - self:GetParent():GetHealthPercent())
end

function modifier_wraith_crimson_berserker_toggle:GetModifierAttackSpeedBonus_Constant()
	return self.asPct * (100 - self:GetParent():GetHealthPercent())
end

function modifier_wraith_crimson_berserker_toggle:GetModifierDamageOutgoing_Percentage()
	return self.damagePct * (100 - self:GetParent():GetHealthPercent())
end

function modifier_wraith_crimson_berserker_toggle:GetModifierPreAttack_CriticalStrike()
	if self:GetCaster():HasTalent("wraith_crimson_berserker_talent_1") then
		if RollPercentage( 100 - self:GetParent():GetHealthPercent() ) then
			return self.talentCrit
		end
	end
end

function modifier_wraith_crimson_berserker_toggle:GetModifierModelScale()
	return (100 - self:GetParent():GetHealthPercent())
end

function modifier_wraith_crimson_berserker_toggle:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end