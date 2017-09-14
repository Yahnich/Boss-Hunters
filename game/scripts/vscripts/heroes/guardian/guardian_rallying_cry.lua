guardian_rallying_cry = class({})

function guardian_rallying_cry:OnSpellStart()
	if IsServer() then
		local radius = self:GetTalentSpecialValueFor("radius")
		local duration = self:GetTalentSpecialValueFor("duration")
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _,unit in pairs(units) do
			unit:AddNewModifier(self:GetCaster(), self, "modifier_guardian_rallying_cry_buff", {duration = duration})
		end
		EmitSoundOn("Hero_Sven.WarCry", self:GetCaster())
		ParticleManager:FireParticle("particles/units/heroes/hero_sven/sven_spell_warcry.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	end
end

LinkLuaModifier( "modifier_guardian_rallying_cry_buff", "heroes/guardian/guardian_rallying_cry.lua", LUA_MODIFIER_MOTION_NONE )
modifier_guardian_rallying_cry_buff = class({})

function modifier_guardian_rallying_cry_buff:OnCreated()
	self.ms = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.magic = self:GetAbility():GetSpecialValueFor("bonus_magic_resist")
end

function modifier_guardian_rallying_cry_buff:OnRefresh()
	self.ms = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.magic = self:GetAbility():GetSpecialValueFor("bonus_magic_resist")
end

function modifier_guardian_rallying_cry_buff:GetEffectName()
	return "particles/units/heroes/hero_sven/sven_warcry_buff.vpcf"
end

function modifier_guardian_rallying_cry_buff:DeclareFunctions()
	funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_guardian_rallying_cry_buff:GetModifierIncomingDamage_Percentage(params)
	if self:GetCaster():HasTalent("guardian_rallying_cry_talent_1") and self:GetParent() ~= self:GetCaster() then
		local redirect = self:GetCaster():FindTalentValue("guardian_rallying_cry_talent_1") / 100
		ParticleManager:FireRopeParticle("particles/heroes/guardian/guardian_rallying_cry_redirect.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), self:GetParent())
		ApplyDamage({victim = self:GetCaster(), attacker = params.attacker, damage = params.damage * redirect, damage_type = params.damage_type, ability = self:GetAbility(), damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
		return redirect
	end
end

function modifier_guardian_rallying_cry_buff:GetModifierMagicalResistanceBonus()
	return self.magic
end

function modifier_guardian_rallying_cry_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_guardian_rallying_cry_buff:GetModifierPhysicalArmorBonus()
	return self.armor
end