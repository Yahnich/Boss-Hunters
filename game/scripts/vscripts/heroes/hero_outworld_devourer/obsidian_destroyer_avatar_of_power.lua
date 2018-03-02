obsidian_destroyer_avatar_of_power = class({})

function  obsidian_destroyer_avatar_of_power:GetIntrinsicModifierName()
	return "modifier_obsidian_destroyer_avatar_of_power_passive"
end

function obsidian_destroyer_avatar_of_power:OnSpellStart()
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_obsidian_destroyer_avatar_of_power_active", {duration = self:GetTalentSpecialValueFor("buff_duration")})
end

modifier_obsidian_destroyer_avatar_of_power_active = class({})
LinkLuaModifier("modifier_obsidian_destroyer_avatar_of_power_active", "heroes/hero_outworld_devourer/obsidian_destroyer_avatar_of_power", 0)

function modifier_obsidian_destroyer_avatar_of_power_active:OnCreated()
	self.spell_amp = self:GetTalentSpecialValueFor("bonus_spell_amp") * self:GetParent():FindTalentValue("special_bonus_unique_obsidian_destroyer_avatar_of_power_1")
	if IsServer() then
		ParticleManager:FireParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	end
end

function modifier_obsidian_destroyer_avatar_of_power_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_obsidian_destroyer_avatar_of_power_active:GetModifierIncomingDamage_Percentage(params)
	if params.damage < self:GetParent():GetMana() then
		self:GetParent():SpendMana(params.damage, self:GetAbility() )
		return -100
	else
		local dmgPct = self:GetParent():GetMana() / params.damage
		self:GetParent():SpendMana(self:GetParent():GetMana(), self:GetAbility() )
		return -(100 - dmgPct*100)
	end
end

function modifier_obsidian_destroyer_avatar_of_power_active:GetModifierSpellAmplify_Percentage()
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
	self.manaregen = self:GetTalentSpecialValueFor("bonus_mana_regen")
	self.spellamp = self:GetTalentSpecialValueFor("bonus_spell_amp")
	
	self.chance = self:GetCaster():FindTalentValue("special_bonus_unique_obsidian_destroyer_avatar_of_power_2", "chance")
	self.essence = self:GetCaster():FindTalentValue("special_bonus_unique_obsidian_destroyer_avatar_of_power_2") / 100
	self:SetStackCount( 1 )
	if IsServer() then self:StartIntervalThink(0.3) end
end

function modifier_obsidian_destroyer_avatar_of_power_passive:OnRefresh()
	self.mana = self:GetTalentSpecialValueFor("bonus_mana")
	self.manaregen = self:GetTalentSpecialValueFor("bonus_mana_regen")
	self.spellamp = self:GetTalentSpecialValueFor("bonus_spell_amp")

	self.chance = self:GetCaster():FindTalentValue("special_bonus_unique_obsidian_destroyer_avatar_of_power_2", "chance")
	self.essence = self:GetCaster():FindTalentValue("special_bonus_unique_obsidian_destroyer_avatar_of_power_2") / 100
end

function modifier_obsidian_destroyer_avatar_of_power_passive:OnIntervalThink()
	if self:GetAbility():IsCooldownReady() then
		self:SetStackCount( 0 )
	else
		self:SetStackCount( 1 )
	end
end
	
function modifier_obsidian_destroyer_avatar_of_power_passive:IsHidden()
	return true
end

function modifier_obsidian_destroyer_avatar_of_power_passive:IsActive()
	return self:GetStackCount() == 0
end

function modifier_obsidian_destroyer_avatar_of_power_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_SPENT_MANA,
			MODIFIER_PROPERTY_MANA_BONUS, 
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, 
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_obsidian_destroyer_avatar_of_power_passive:OnSpentMana(params)
	if IsServer() and self:IsActive() then
		if params.unit == self:GetCaster() and RollPercentage( self.chance ) then
			local manaGain = self:GetCaster():GetMaxMana() * self.essence
			ParticleManager:FireParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
			EmitSoundOn("Hero_ObsidianDestroyer.EssenceAura", self:GetCaster() )
			self:GetCaster():GiveMana( manaGain )
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

function modifier_obsidian_destroyer_avatar_of_power_passive:GetModifierSpellAmplify_Percentage()
	if self:IsActive() then
		return self.spellamp
	end
end