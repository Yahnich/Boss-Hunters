night_stalker_hunter_in_the_night_bh = class({})

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

function night_stalker_hunter_in_the_night_bh:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function night_stalker_hunter_in_the_night_bh:GetIntrinsicModifierName()
	return "modifier_night_stalker_hunter_in_the_night_bh"
end

modifier_night_stalker_hunter_in_the_night_bh = class({})
LinkLuaModifier("modifier_night_stalker_hunter_in_the_night_bh", "heroes/hero_night_stalker/night_stalker_hunter_in_the_night_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_night_stalker_hunter_in_the_night_bh:OnCreated()
	self.ms = self:GetSpecialValueFor("bonus_movement_speed_pct_night")
	self.as = self:GetSpecialValueFor("bonus_attack_speed_night")
	self.amp = self:GetParent():FindTalentValue("special_bonus_unique_night_stalker_hunter_in_the_night_1")
	self.armor = self:GetParent():FindTalentValue("special_bonus_unique_night_stalker_hunter_in_the_night_2")
	
	self.scepter_pct = self:GetSpecialValueFor("scepter_pct") / 100
end

function modifier_night_stalker_hunter_in_the_night_bh:OnRefresh()
	self.ms = self:GetSpecialValueFor("bonus_movement_speed_pct_night")
	self.as = self:GetSpecialValueFor("bonus_attack_speed_night")
	self.amp = self:GetParent():FindTalentValue("special_bonus_unique_night_stalker_hunter_in_the_night_1")
	self.armor = self:GetParent():FindTalentValue("special_bonus_unique_night_stalker_hunter_in_the_night_2")
	
	self.scepter_pct = self:GetSpecialValueFor("scepter_pct") / 100
end

function modifier_night_stalker_hunter_in_the_night_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_night_stalker_hunter_in_the_night_bh:GetModifierMoveSpeedBonus_Percentage()
	local ms = self.ms
	local caster = self:GetParent()
	local multiplier = 1
	if GameRules:IsDaytime() then
		multiplier = 0
	end
	if caster:HasScepter() then
		multiplier = multiplier + self.scepter_pct
	end
	if GameRules:IsNightstalkerNight() and caster:HasTalent("special_bonus_unique_night_stalker_darkness_2") then 
		ms = ms * caster:FindTalentValue("special_bonus_unique_night_stalker_darkness_2") 
	end
	return ms * multiplier
end

function modifier_night_stalker_hunter_in_the_night_bh:GetModifierAttackSpeedBonus_Constant()
	local as = self.as
	local caster = self:GetParent()
	local multiplier = 1
	if GameRules:IsDaytime() then
		multiplier = 0
	end
	if caster:HasScepter() then
		multiplier = multiplier + self.scepter_pct
	end
	if GameRules:IsNightstalkerNight() and caster:HasTalent("special_bonus_unique_night_stalker_darkness_2") then 
		as = as * caster:FindTalentValue("special_bonus_unique_night_stalker_darkness_2") 
	end
	return as * multiplier
end

function modifier_night_stalker_hunter_in_the_night_bh:GetModifierSpellAmplify_Percentage()
	local amp = self.amp
	local caster = self:GetParent()
	local multiplier = 1
	if GameRules:IsDaytime() then
		multiplier = 0
	end
	if caster:HasScepter() then
		multiplier = multiplier + self.scepter_pct
	end
	if GameRules:IsNightstalkerNight() and caster:HasTalent("special_bonus_unique_night_stalker_darkness_2") then 
		amp = amp * caster:FindTalentValue("special_bonus_unique_night_stalker_darkness_2") 
	end
	return amp * multiplier
end

function modifier_night_stalker_hunter_in_the_night_bh:GetModifierPhysicalArmorBonus()
	local armor = self.armor
	local caster = self:GetParent()
	local multiplier = 1
	if GameRules:IsDaytime() then
		multiplier = 0
	end
	if caster:HasScepter() then
		multiplier = multiplier + self.scepter_pct
	end
	if GameRules:IsNightstalkerNight() and caster:HasTalent("special_bonus_unique_night_stalker_darkness_2") then 
		armor = armor * caster:FindTalentValue("special_bonus_unique_night_stalker_darkness_2") 
	end
	return armor * multiplier
end

function modifier_night_stalker_hunter_in_the_night_bh:IsHidden()
	return true
end