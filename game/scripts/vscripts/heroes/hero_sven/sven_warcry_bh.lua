sven_warcry_bh = class({})

function sven_warcry_bh:GetIntrinsicModifierName()
	return "modifier_sven_warcry_bh_talent_aura"
end

function sven_warcry_bh:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetTalentSpecialValueFor("warcry_radius")
	local duration = self:GetTalentSpecialValueFor("duration")
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	for _,unit in pairs(units) do
		unit:AddNewModifier(caster, self, "modifier_sven_warcry_bh_buff", {duration = duration})
	end
	EmitSoundOn("Hero_Sven.WarCry", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_sven/sven_spell_warcry.vpcf", PATTACH_POINT_FOLLOW, caster)
	
	if caster:HasTalent("special_bonus_unique_sven_warcry_1") then
		local stormBolt = caster:FindAbilityByName("sven_storm_bolt_bh")
		if stormBolt:IsTrained() then
			caster:SetCursorCastTarget( caster )
			stormBolt:OnSpellStart()
		end
	end
	
	StartAnimation(caster, {duration = 1, activity = ACT_DOTA_OVERRIDE_ABILITY_3})
end

LinkLuaModifier( "modifier_sven_warcry_bh_talent_aura", "heroes/hero_sven/sven_warcry_bh" ,LUA_MODIFIER_MOTION_NONE )
modifier_sven_warcry_bh_talent_aura = class({})

function modifier_sven_warcry_bh_talent_aura:OnCreated()
	self:OnRefresh( )
end

function modifier_sven_warcry_bh_talent_aura:OnRefresh()
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_sven_warcry_2")
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_sven_warcry_2", "radius")
	print( self.talent2, "refresh" )
end

function modifier_sven_warcry_bh_talent_aura:IsAura()
	return self.talent2
end

function modifier_sven_warcry_bh_talent_aura:GetModifierAura()
	return "modifier_sven_warcry_bh_talent_buff"
end

function modifier_sven_warcry_bh_talent_aura:GetAuraRadius()
	return self.radius
end

function modifier_sven_warcry_bh_talent_aura:GetAuraEntityReject(entity)
	return not self.talent2
end

function modifier_sven_warcry_bh_talent_aura:GetAuraDuration()
	return 0.5
end

function modifier_sven_warcry_bh_talent_aura:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_sven_warcry_bh_talent_aura:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_HERO
end

function modifier_sven_warcry_bh_talent_aura:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_sven_warcry_bh_talent_aura:IsHidden()
	return true
end

LinkLuaModifier( "modifier_sven_warcry_bh_talent_buff", "heroes/hero_sven/sven_warcry_bh" ,LUA_MODIFIER_MOTION_NONE )
modifier_sven_warcry_bh_talent_buff = class({})

function modifier_sven_warcry_bh_talent_buff:OnCreated()
	self:OnRefresh( )
end

function modifier_sven_warcry_bh_talent_buff:OnRefresh()
	self.armor = self:GetAbility():GetTalentSpecialValueFor("warcry_armor") * self:GetCaster():FindTalentValue("special_bonus_unique_sven_warcry_2") / 100
end

function modifier_sven_warcry_bh_talent_buff:GetEffectName()
	return "particles/units/heroes/hero_sven/sven_warcry_buff.vpcf"
end

function modifier_sven_warcry_bh_talent_buff:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
	return funcs
end

function modifier_sven_warcry_bh_talent_buff:GetModifierPhysicalArmorBonus()
	return self.armor
end

LinkLuaModifier( "modifier_sven_warcry_bh_buff", "heroes/hero_sven/sven_warcry_bh" ,LUA_MODIFIER_MOTION_NONE )
modifier_sven_warcry_bh_buff = class({})

function modifier_sven_warcry_bh_buff:OnCreated()
	self.ms = self:GetAbility():GetTalentSpecialValueFor("warcry_movespeed")
	self.armor = self:GetAbility():GetTalentSpecialValueFor("warcry_armor")
	self.as = self.ms * self:GetCaster():FindTalentValue("special_bonus_unique_sven_warcry_1") / 100
end

function modifier_sven_warcry_bh_buff:OnRefresh()
	self.ms = self:GetAbility():GetTalentSpecialValueFor("warcry_movespeed")
	self.armor = self:GetAbility():GetTalentSpecialValueFor("warcry_armor")
	self.as = self.ms * self:GetCaster():FindTalentValue("special_bonus_unique_sven_warcry_1") / 100
end

function modifier_sven_warcry_bh_buff:GetEffectName()
	return "particles/units/heroes/hero_sven/sven_warcry_buff.vpcf"
end

function modifier_sven_warcry_bh_buff:DeclareFunctions()
	local funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
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

function modifier_sven_warcry_bh_buff:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_sven_warcry_bh_buff:GetActivityTranslationModifiers()
	return "sven_warcry"
end