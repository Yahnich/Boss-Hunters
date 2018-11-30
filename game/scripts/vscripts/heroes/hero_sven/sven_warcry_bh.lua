sven_warcry_bh = class({})
function sven_warcry_bh:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetTalentSpecialValueFor("warcry_radius")
	local duration = self:GetTalentSpecialValueFor("duration_tooltip")
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	for _,unit in pairs(units) do
		unit:AddNewModifier(caster, self, "modifier_sven_warcry_bh_buff", {duration = duration})
	end
	EmitSoundOn("Hero_Sven.WarCry", caster)
	local warcry = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_warcry.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(warcry)
	
	StartAnimation(caster, {duration = 1, activity = ACT_DOTA_OVERRIDE_ABILITY_3})
end

LinkLuaModifier( "modifier_sven_warcry_bh_buff", "heroes/hero_sven/sven_warcry_bh" ,LUA_MODIFIER_MOTION_NONE )
modifier_sven_warcry_bh_buff = class({})

function modifier_sven_warcry_bh_buff:OnCreated()
	self.ms = self:GetAbility():GetTalentSpecialValueFor("warcry_movespeed")
	self.armor = self:GetAbility():GetTalentSpecialValueFor("warcry_armor")
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_sven_warcry_1")
end

function modifier_sven_warcry_bh_buff:OnRefresh()
	self.ms = self:GetAbility():GetTalentSpecialValueFor("warcry_movespeed")
	self.armor = self:GetAbility():GetTalentSpecialValueFor("warcry_armor")
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_sven_warcry_1")
end

function modifier_sven_warcry_bh_buff:GetEffectName()
	return "particles/units/heroes/hero_sven/sven_warcry_buff.vpcf"
end

function modifier_sven_warcry_bh_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
				
				MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
				
			}
	return funcs
end

function modifier_sven_warcry_bh_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_sven_warcry_bh_buff:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_sven_warcry_bh_buff:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_sven_warcry_bh_buff:GetActivityTranslationModifiers()
	return "sven_warcry"
end