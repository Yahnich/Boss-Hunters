boss19_shield = class({})

function boss19_shield:GetIntrinsicModifierName()
	return "modifier_boss19_shield_passive"
end

modifier_boss19_shield_passive = class({})
LinkLuaModifier("modifier_boss19_shield_passive", "bosses/boss19/boss19_shield.lua", 0)

function modifier_boss19_shield_passive:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
	if IsServer() then self:StartIntervalThink(0) end
end

function modifier_boss19_shield_passive:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss19_shield_passive:OnIntervalThink()
	local caster = self:GetCaster()
	if not self:GetAbility():IsCooldownReady() or not caster:IsDisabled() then return end
	caster:Dispel(caster, true)
	EmitSoundOn("Hero_NyxAssassin.ManaBurn.Target", caster)
	self:GetAbility():UseResources(false, false, true)
	caster:AddNewModifier(caster, self:GetAbility(), "modifier_boss19_shield_buff", {duration = self.duration})
	ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_POINT_FOLLOW, caster)
end

function modifier_boss19_shield_passive:IsHidden()
	return true
end

function modifier_boss19_shield_passive:IsPurgable()
	return false
end

modifier_boss19_shield_buff = class({})
LinkLuaModifier("modifier_boss19_shield_buff", "bosses/boss19/boss19_shield.lua", 0)

function modifier_boss19_shield_buff:OnCreated()
	self.dmg = self:GetSpecialValueFor("damage_reduction")
end

function modifier_boss19_shield_buff:OnRefresh()
	self.dmg = self:GetSpecialValueFor("damage_reduction")
end

function modifier_boss19_shield_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end


function modifier_boss19_shield_buff:GetModifierIncomingDamage_Percentage()
	return self.dmg
end

function modifier_boss19_shield_buff:GetModifierTotalDamageOutgoing_Percentage()
	return self.dmg
end

function modifier_boss19_shield_buff:GetEffectName()
	return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace.vpcf"
end