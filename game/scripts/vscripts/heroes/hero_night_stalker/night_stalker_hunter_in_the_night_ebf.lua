night_stalker_hunter_in_the_night_ebf = class({})


if IsClient() then -- thanks valve
	if GameRules.IsDaytime == nil then
		GameRules.IsDaytime = function()
			local timeofday = CustomNetTables:GetTableValue( "game_info", "timeofday")
			return timeofday["timeofday"] == 1
		end
	end
	
	if GameRules.IsTemporaryNight == nil then
		GameRules.IsTemporaryNight = function()
			local timeofday = CustomNetTables:GetTableValue( "game_info", "timeofday")
			return timeofday["timeofday"] == 2
		end
	end
	
	if GameRules.IsNightstalkerNight == nil then
		GameRules.IsNightstalkerNight = function()
			local timeofday = CustomNetTables:GetTableValue( "game_info", "timeofday")
			return timeofday["timeofday"] == 3
		end
	end
end

function night_stalker_hunter_in_the_night_ebf:GetBehavior()
	if GameRules:IsDaytime() then
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
end

function night_stalker_hunter_in_the_night_ebf:GetCooldown(nLvl)
	if not GameRules:IsDaytime() then
		return self.BaseClass.GetCooldown(self, nLvl)
	end
end

function night_stalker_hunter_in_the_night_ebf:GetManaCost(nLvl)
	if not GameRules:IsDaytime() then
		return self.BaseClass.GetManaCost(self, nLvl)
	end
end

function night_stalker_hunter_in_the_night_ebf:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_night_stalker_hunter_in_the_night_flying", {duration = self:GetTalentSpecialValueFor("duration")})
end

function night_stalker_hunter_in_the_night_ebf:GetIntrinsicModifierName()
	return "modifier_night_stalker_hunter_in_the_night_ebf"
end

modifier_night_stalker_hunter_in_the_night_ebf = class({})
LinkLuaModifier("modifier_night_stalker_hunter_in_the_night_ebf", "heroes/hero_night_stalker/night_stalker_hunter_in_the_night_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_night_stalker_hunter_in_the_night_ebf:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed_pct_night")
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed_night")
	self.amp = self:GetParent():FindTalentValue("special_bonus_unique_night_stalker_hunter_in_the_night_1")
	self.armor = self:GetParent():FindTalentValue("special_bonus_unique_night_stalker_hunter_in_the_night_2")
	
	self.scepter_pct = self:GetTalentSpecialValueFor("scepter_pct") / 100
end

function modifier_night_stalker_hunter_in_the_night_ebf:OnRefresh()
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed_pct_night")
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed_night")
	self.amp = self:GetParent():FindTalentValue("special_bonus_unique_night_stalker_hunter_in_the_night_1")
	self.armor = self:GetParent():FindTalentValue("special_bonus_unique_night_stalker_hunter_in_the_night_2")
	
	self.scepter_pct = self:GetTalentSpecialValueFor("scepter_pct") / 100
end

function modifier_night_stalker_hunter_in_the_night_ebf:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_night_stalker_hunter_in_the_night_ebf:GetModifierMoveSpeedBonus_Percentage()
	local ms = self.ms
	local caster = self:GetParent()
	if GameRules:IsDaytime() then 
		if caster:HasScepter() then
			ms = ms * self.scepter_pct
		else
			ms = 0 
		end
	end
	if GameRules:IsNightstalkerNight() and caster:HasTalent("special_bonus_unique_night_stalker_darkness_2") then 
		ms = ms * caster:FindTalentValue("special_bonus_unique_night_stalker_darkness_2") 
	end
	return ms
end

function modifier_night_stalker_hunter_in_the_night_ebf:GetModifierAttackSpeedBonus_Constant()
	local as = self.as
	local caster = self:GetParent()
	if GameRules:IsDaytime() then 
		if caster:HasScepter() then
			as = as * self.scepter_pct
		else
			as = 0 
		end
	end
	if GameRules:IsNightstalkerNight() and caster:HasTalent("special_bonus_unique_night_stalker_darkness_2") then 
		as = as * caster:FindTalentValue("special_bonus_unique_night_stalker_darkness_2") 
	end
	return as
end

function modifier_night_stalker_hunter_in_the_night_ebf:GetModifierSpellAmplify_Percentage()
	local amp = self.amp
	local caster = self:GetParent()
	if GameRules:IsDaytime() then 
		if caster:HasScepter() then
			amp = amp * self.scepter_pct
		else
			amp = 0 
		end
	end
	if GameRules:IsNightstalkerNight() and caster:HasTalent("special_bonus_unique_night_stalker_darkness_2") then 
		amp = amp * caster:FindTalentValue("special_bonus_unique_night_stalker_darkness_2") 
	end
	return amp
end

function modifier_night_stalker_hunter_in_the_night_ebf:GetModifierPhysicalArmorBonus()
	local armor = self.armor
	local caster = self:GetParent()
	if GameRules:IsDaytime() then 
		if caster:HasScepter() then
			armor = armor * self.scepter_pct
		else
			armor = 0 
		end
	end
	if GameRules:IsNightstalkerNight() and caster:HasTalent("special_bonus_unique_night_stalker_darkness_2") then 
		armor = armor * caster:FindTalentValue("special_bonus_unique_night_stalker_darkness_2") 
	end
	return armor
end

function modifier_night_stalker_hunter_in_the_night_ebf:IsHidden()
	return true
end

modifier_night_stalker_hunter_in_the_night_flying = class({})
LinkLuaModifier("modifier_night_stalker_hunter_in_the_night_flying", "heroes/hero_night_stalker/night_stalker_hunter_in_the_night_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_night_stalker_hunter_in_the_night_flying:CheckState()
	return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
end

function modifier_night_stalker_hunter_in_the_night_flying:DeclareFunctions()
	return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

function modifier_night_stalker_hunter_in_the_night_flying:GetActivityTranslationModifiers()
	return "haste"
end