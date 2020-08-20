lycan_apex_predator = class({})

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

function lycan_apex_predator:GetIntrinsicModifierName()
	return "modifier_lycan_apex_predator"
end

modifier_lycan_apex_predator = class({})
LinkLuaModifier("modifier_lycan_apex_predator", "heroes/hero_lycan/lycan_apex_predator", LUA_MODIFIER_MOTION_NONE)

function modifier_lycan_apex_predator:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
end

function modifier_lycan_apex_predator:OnRefresh()
	self.radius = self:GetTalentSpecialValueFor("radius")
end

function modifier_lycan_apex_predator:IsAura()
	return true
end

function modifier_lycan_apex_predator:GetModifierAura()
	return "modifier_lycan_apex_predator_aura"
end

function modifier_lycan_apex_predator:GetAuraRadius()
	return -1
end

function modifier_lycan_apex_predator:GetAuraDuration()
	return 0.5
end

function modifier_lycan_apex_predator:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_lycan_apex_predator:GetAuraEntityReject(entity)
	if entity == self:GetParent() or (entity:GetOwnerEntity() and entity:GetOwnerEntity() == self:GetParent()) then 
		return false
	else
		return true
	end
end

function modifier_lycan_apex_predator:IsHidden()
	return true
end

function modifier_lycan_apex_predator:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

modifier_lycan_apex_predator_aura = class({})
LinkLuaModifier("modifier_lycan_apex_predator_aura", "heroes/hero_lycan/lycan_apex_predator", LUA_MODIFIER_MOTION_NONE)

function modifier_lycan_apex_predator_aura:OnCreated()
	self.chance = self:GetTalentSpecialValueFor("day_critical_chance")
	self.damage = self:GetTalentSpecialValueFor("critical_damage")
	self:StartIntervalThink(0.33)
	if (not GameRules:IsDaytime()) or self:GetCaster():HasModifier("modifier_lycan_shapeshift_bh") then
		self.chance = self:GetTalentSpecialValueFor("night_critical_chance")
		if self:GetCaster():HasTalent("special_bonus_unique_lycan_shapeshift_2") and self:GetCaster():HasModifier("modifier_lycan_shapeshift_bh") then
			self.chance = self:GetCaster():FindTalentValue("special_bonus_unique_lycan_shapeshift_2")
		end
	end
	if IsServer() then
		self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_lycan_apex_predator_aura:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_lycan_apex_predator_aura:OnIntervalThink()
	self.chance = self:GetTalentSpecialValueFor("day_critical_chance")
	self.damage = self:GetTalentSpecialValueFor("critical_damage")
	if (not GameRules:IsDaytime()) or self:GetCaster():HasModifier("modifier_lycan_shapeshift_bh") then
		self.chance = self:GetTalentSpecialValueFor("night_critical_chance")
		if self:GetCaster():HasTalent("special_bonus_unique_lycan_shapeshift_2") and self:GetCaster():HasModifier("modifier_lycan_shapeshift_bh") then
			self.chance = self:GetCaster():FindTalentValue("special_bonus_unique_lycan_shapeshift_2")
		end
	end
end

function modifier_lycan_apex_predator_aura:GetModifierCriticalDamage()
	if IsClient() then
		return self.damage
	end
	if self:RollPRNG( self.chance ) then
		return self.damage
	end
end