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
	self.aura_radius = self:GetAbility():GetTalentSpecialValueFor("radius")
end

function modifier_luna_lunar_blessing_passive:OnRefresh()
	self.aura_radius = self:GetAbility():GetTalentSpecialValueFor("radius")
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
    self.str = TernaryOperator( self:GetAbility():GetTalentSpecialValueFor("bonus_primary"), self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH, 0 )
    self.agi = TernaryOperator( self:GetAbility():GetTalentSpecialValueFor("bonus_primary"), self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY, 0 )
    self.int = TernaryOperator( self:GetAbility():GetTalentSpecialValueFor("bonus_primary"), self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT, 0 )
	
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_2", "as")
	self.ms = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_2", "ms")
	self.mult = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_1")
	self.dmg_pct = self:GetAbility():GetTalentSpecialValueFor("bonus_damage_pct")
end

function modifier_luna_lunar_blessing_bh_aura:OnRefresh()
    self.str = TernaryOperator( self:GetAbility():GetTalentSpecialValueFor("bonus_primary"), self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH, 0 )
    self.agi = TernaryOperator( self:GetAbility():GetTalentSpecialValueFor("bonus_primary"), self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY, 0 )
    self.int = TernaryOperator( self:GetAbility():GetTalentSpecialValueFor("bonus_primary"), self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT, 0 )
	
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_2", "as")
	self.ms = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_2", "ms")
	self.mult = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_1")
	self.dmg_pct = self:GetAbility():GetTalentSpecialValueFor("bonus_damage_pct")
end

function modifier_luna_lunar_blessing_bh_aura:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
				MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
				MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
				MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
				,
			}
	return funcs
end

function modifier_luna_lunar_blessing_bh_aura:GetModifierBonusStats_Strength()
	local damage = self.str
	if damage <= 0 then return end
	if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then damage = damage * self.mult end
    return damage
end

function modifier_luna_lunar_blessing_bh_aura:GetModifierBonusStats_Agility()
	local damage = self.agi
	if damage <= 0 then return end
	if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then damage = damage * self.mult end
    return damage
end

function modifier_luna_lunar_blessing_bh_aura:GetModifierBonusStats_Intellect()
	local damage = self.int
	if damage <= 0 then return end
	if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then damage = damage * self.mult end
    return damage
end

function modifier_luna_lunar_blessing_bh_aura:GetModifierBaseDamageOutgoing_Percentage()
	if not GameRules:IsDaytime() then
		local damage = self.dmg_pct
		if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then damage = damage * self.mult end
		return damage
	end
end

function modifier_luna_lunar_blessing_bh_aura:GetModifierAttackSpeedBonus_Constant()
	local as = self.as
	if as <= 0 then return end
	if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then as = as * self.mult end
	return as
end

function modifier_luna_lunar_blessing_bh_aura:GetModifierMoveSpeedBonus_Percentage()
	local ms = self.ms
	if ms <= 0 then return end
	if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then ms = ms * self.mult end
	return ms
end