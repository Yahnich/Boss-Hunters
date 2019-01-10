luna_lunar_blessing_bh = class({})

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

function luna_lunar_blessing_bh:GetIntrinsicModifierName()
	return "modifier_luna_lunar_blessing_passive"
end

function luna_lunar_blessing_bh:GetCooldown(iLvl)
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_luna_lunar_blessing_1") then
		return caster:FindTalentValue("special_bonus_unique_luna_lunar_blessing_1", "cd")
	end
end

function luna_lunar_blessing_bh:GetBehavior()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_luna_lunar_blessing_1") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA
	end
end

function luna_lunar_blessing_bh:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_luna_lunar_blessing_active", {duration = caster:FindTalentValue("special_bonus_unique_luna_lunar_blessing_1", "duration")})
end

LinkLuaModifier( "modifier_luna_lunar_blessing_passive", "heroes/hero_luna/luna_lunar_blessing_bh.lua", LUA_MODIFIER_MOTION_NONE )
modifier_luna_lunar_blessing_passive = class({})

function modifier_luna_lunar_blessing_passive:OnCreated()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_luna_lunar_blessing_passive:OnRefresh()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_luna_lunar_blessing_passive:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:GetModifierAura()
	return "modifier_luna_lunar_blessing_bh_aura"
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_luna_lunar_blessing_passive:IsPurgable()
    return false
end

LinkLuaModifier( "modifier_luna_lunar_blessing_active", "heroes/hero_luna/luna_lunar_blessing_bh.lua", LUA_MODIFIER_MOTION_NONE )
modifier_luna_lunar_blessing_active = class({})

LinkLuaModifier( "modifier_luna_lunar_blessing_bh_aura", "heroes/hero_luna/luna_lunar_blessing_bh.lua", LUA_MODIFIER_MOTION_NONE )
modifier_luna_lunar_blessing_bh_aura = class({})

function modifier_luna_lunar_blessing_bh_aura:OnCreated()
    self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.dmg_pct = self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
end

function modifier_luna_lunar_blessing_bh_aura:OnRefresh()
    self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.dmg_pct = self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
end

function modifier_luna_lunar_blessing_bh_aura:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
				MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
				
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
				,
			}
	return funcs
end

if GameRules == nil and IsClient() then
	GameRules = class({})
	
	GameRules.IsDaytime = function()
		local timeofday = CustomNetTables:GetTableValue( "game_info", "timeofday")
		return tonumber(timeofday["timeofday"]) == 1
	end
	
	GameRules.IsTemporaryNight = function()
		local timeofday = CustomNetTables:GetTableValue( "game_info", "timeofday")
		return tonumber(timeofday["timeofday"]) == 2
	end
	
	GameRules.IsNightstalkerNight = function()
		local timeofday = CustomNetTables:GetTableValue( "game_info", "timeofday")
		return tonumber(timeofday["timeofday"]) == 3
	end
end
	

function modifier_luna_lunar_blessing_bh_aura:GetModifierPreAttack_BonusDamage()
	local damage = self.damage
	if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then damage = damage * self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_1") end
    return damage
end

function modifier_luna_lunar_blessing_bh_aura:GetModifierBaseDamageOutgoing_Percentage()
	if not GameRules:IsDaytime() then
		local damage = self.dmg_pct
		if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then damage = damage * self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_1") end
		return damage
	end
end

function modifier_luna_lunar_blessing_bh_aura:GetModifierAttackSpeedBonus()
	if not GameRules:IsDaytime() and self:GetCaster():HasTalent("special_bonus_unique_luna_lunar_blessing_2") then
		local as = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_2", "as")
		if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then as = as * self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_1") end
		return as
	end
end

function modifier_luna_lunar_blessing_bh_aura:GetModifierMoveSpeedBonus_Percentage()
	if not GameRules:IsDaytime() and self:GetCaster():HasTalent("special_bonus_unique_luna_lunar_blessing_2") then
		local ms = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_2", "ms")
		if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then ms = ms * self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_1") end
		return ms
	end
end