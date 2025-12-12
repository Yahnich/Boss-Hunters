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
    self.dmg = self:GetAbility():GetSpecialValueFor("bonus_primary")
	self.night_dmg = self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
	
	self.mult = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_1")
	self.mult2 = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_2", "value2")
	
	self.lucent = self:GetCaster():FindAbilityByName("luna_lucent_beam_bh")
end

function modifier_luna_lunar_blessing_bh_aura:OnRefresh()
    self.dmg = self:GetAbility():GetSpecialValueFor("bonus_primary")
	self.night_dmg = self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
	
	self.mult = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_1")
	self.mult2 = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_2", "value2")
	
	self.lucent = self:GetCaster():FindAbilityByName("luna_lucent_beam_bh")
end

function modifier_luna_lunar_blessing_bh_aura:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
				MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
				MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
			}
	return funcs
end

function modifier_luna_lunar_blessing_bh_aura:GetModifierOverrideAbilitySpecial(params)
	if params.ability == self.lucent then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "beam_damage" or specialValue == "night_beam_damage" then
			return 1
		end
	end
end

function modifier_luna_lunar_blessing_bh_aura:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability == self.lucent then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "beam_damage" then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			local bonusDmg = self.dmg + TernaryOperator( 0, GameRules:IsDaytime(), self.night_dmg )
			if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then bonusDmg = bonusDmg * self.mult end
			return flBaseValue + bonusDmg
		elseif specialValue == "night_beam_damage" then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			local bonusDmg = self.dmg + self.night_dmg
			if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then bonusDmg = bonusDmg * self.mult end
			return flBaseValue + bonusDmg
		end
	end
end

function modifier_luna_lunar_blessing_bh_aura:GetModifierPreAttack_BonusDamage()
	local damage = self.dmg + TernaryOperator( 0, GameRules:IsDaytime(), self.night_dmg )
	if damage <= 0 then return end
	if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then damage = damage * self.mult end
	if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_bh_talent") then damage = damage * self.mult2 end
    return damage
end


LinkLuaModifier( "modifier_luna_lunar_blessing_bh_talent", "heroes/hero_luna/luna_lunar_blessing_bh.lua", LUA_MODIFIER_MOTION_NONE )
modifier_luna_lunar_blessing_bh_talent = class({})

function modifier_luna_lunar_blessing_bh_talent:OnCreated()
	self.ms = self:GetSpecialValueFor("bonus_primary")
	self.night_ms = self:GetSpecialValueFor("bonus_damage_pct")
	
	self.mult = self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_1")
end

function modifier_luna_lunar_blessing_bh_talent:DeclareFunctions()
	funcs = { 
				MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
				MODIFIER_EVENT_ON_ATTACK_LANDED 
			}
	return funcs
end

function modifier_luna_lunar_blessing_bh_talent:GetModifierMoveSpeedBonus_Constant()
	local speed = self.ms + TernaryOperator( 0, GameRules:IsDaytime(), self.night_ms )
	if speed <= 0 then return end
	if self:GetCaster():HasModifier("modifier_luna_lunar_blessing_active") then speed = speed * self.mult end
    return speed
end

function modifier_luna_lunar_blessing_bh_talent:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:Destroy()
	end
end