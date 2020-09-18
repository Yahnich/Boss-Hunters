obsidian_destroyer_avatar_of_power = class({})

function  obsidian_destroyer_avatar_of_power:GetIntrinsicModifierName()
	return "modifier_obsidian_destroyer_avatar_of_power_passive"
end

function obsidian_destroyer_avatar_of_power:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_obsidian_destroyer_avatar_of_power_active", {})
	else
		self:GetCaster():RemoveModifierByName("modifier_obsidian_destroyer_avatar_of_power_active")
	end
end

modifier_obsidian_destroyer_avatar_of_power_active = class(toggleModifierBaseClass)
LinkLuaModifier("modifier_obsidian_destroyer_avatar_of_power_active", "heroes/hero_outworld_devourer/obsidian_destroyer_avatar_of_power", 0)

function modifier_obsidian_destroyer_avatar_of_power_active:OnCreated()
	self.spell_amp = self:GetTalentSpecialValueFor("bonus_spell_amp") * self:GetParent():FindTalentValue("special_bonus_unique_obsidian_destroyer_avatar_of_power_1")
	if IsServer() then
		ParticleManager:FireParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	end
end

function modifier_obsidian_destroyer_avatar_of_power_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_obsidian_destroyer_avatar_of_power_active:GetModifierIncomingDamage_Percentage(params)
	if HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) then return end
	if params.damage < self:GetParent():GetMana() then
		self:GetParent():SpendMana(params.damage, self:GetAbility() )
		return -999
	else
		local dmgPct = self:GetParent():GetMana() / params.damage
		self:GetParent():SpendMana(self:GetParent():GetMana(), self:GetAbility() )
		self:ToggleAbility()
		return -(100 - dmgPct*100)
	end
end

function modifier_obsidian_destroyer_avatar_of_power_active:GetModifierTotalDamageOutgoing_Percentage()
	return self.spell_amp
end

function modifier_obsidian_destroyer_avatar_of_power_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_siren_song.vpcf"
end

function modifier_obsidian_destroyer_avatar_of_power_active:StatusEffectPriority()
	return 10
end

function modifier_obsidian_destroyer_avatar_of_power_active:GetEffectName()
	return "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_avatar.vpcf"
end

modifier_obsidian_destroyer_avatar_of_power_passive = class({})
LinkLuaModifier("modifier_obsidian_destroyer_avatar_of_power_passive", "heroes/hero_outworld_devourer/obsidian_destroyer_avatar_of_power", 0)


function modifier_obsidian_destroyer_avatar_of_power_passive:OnCreated()
	self.mana = self:GetTalentSpecialValueFor("bonus_mana")
	self.spellamp = self:GetTalentSpecialValueFor("bonus_spell_amp")
	
	self.chance = self:GetTalentSpecialValueFor("mana_restore_chance")
	self.essence = self:GetTalentSpecialValueFor("mana_restore_pct") / 100
end

function modifier_obsidian_destroyer_avatar_of_power_passive:OnRefresh()
	self.mana = self:GetTalentSpecialValueFor("bonus_mana")
	self.spellamp = self:GetTalentSpecialValueFor("bonus_spell_amp")

	self.chance = self:GetTalentSpecialValueFor("mana_restore_chance")
	self.essence = self:GetTalentSpecialValueFor("mana_restore_pct") / 100
end
	
function modifier_obsidian_destroyer_avatar_of_power_passive:IsHidden()
	return true
end

function modifier_obsidian_destroyer_avatar_of_power_passive:IsActive()
	return self:GetCaster():HasModifier("modifier_obsidian_destroyer_avatar_of_power_active")
end

function modifier_obsidian_destroyer_avatar_of_power_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_SPENT_MANA,
			MODIFIER_PROPERTY_MANA_BONUS,
			MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_obsidian_destroyer_avatar_of_power_passive:OnSpentMana(params)
	if IsServer() and not self:IsActive() then
		if params.unit == self:GetCaster() and self:RollPRNG( self.chance ) and params.cost > 0 then
			local manaGain = math.ceil( self:GetCaster():GetMaxMana() * self.essence )
			ParticleManager:FireParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
			EmitSoundOn("Hero_ObsidianDestroyer.EssenceAura", self:GetCaster() )
			self:GetCaster():RestoreMana( manaGain )
		end
	end
end

function modifier_obsidian_destroyer_avatar_of_power_passive:GetModifierManaBonus()
	if self:IsActive() then
		return self.mana
	end
end

function modifier_obsidian_destroyer_avatar_of_power_passive:GetModifierContantManaRegen()
	if self:IsActive() then
		return self.manaregen
	end
end

function modifier_obsidian_destroyer_avatar_of_power_passive:GetModifierTotalDamageOutgoing_Percentage()
	if self:IsActive() then
		return self.spellamp
	end
end