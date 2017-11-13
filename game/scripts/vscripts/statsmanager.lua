require("stats")

if StatsManager == nil then
  print ( 'creating projectile manager' )
  StatsManager = {}
  StatsManager.__index = StatsManager
end

function StatsManager:new( o )
  o = o or {}
  setmetatable( o, StatsManager )
  return o
end

STATS_THINK = 0.3

function StatsManager:start()
  StatsManager = self
  self.heroes = {}
  GameRules:GetGameModeEntity():SetThink("StatsThink", self, DoUniqueString("statThinker"), STATS_THINK)
end

function StatsManager:StatsThink()
	if not GameRules:IsGamePaused() then
		for id, hero in pairs( self.heroes ) do
			local status, err, ret = xpcall(hero.customStatEntity.ManageStats, debug.traceback, hero.customStatEntity, hero)
			if not status then
				print(err)
			end
		end
	end
	return STATS_THINK
end

function StatsManager:CreateCustomStatsForHero(hero)
	if not hero.customStatEntity then 
		hero.customStatEntity = Stats(hero)
		hero.customStatEntity:ManageStats(hero)
		table.insert( self.heroes, hero )
	end
	return hero.customStatEntity
end

if not StatsManager.heroes then 
	StatsManager:start() 
end

function CDOTA_BaseNPC_Hero:GetStrength()
	if self:IsIllusion() and not self.customStatEntity then self.customStatEntity = PlayerResource:GetSelectedHeroEntity( self:GetPlayerOwnerID() ).customStatEntity end
	return self.customStatEntity.customStrength
end

function CDOTA_BaseNPC_Hero:GetIntellect()
	if self:IsIllusion() and not self.customStatEntity then self.customStatEntity = PlayerResource:GetSelectedHeroEntity( self:GetPlayerOwnerID() ).customStatEntity end
	return self.customStatEntity.customIntellect
end

function CDOTA_BaseNPC_Hero:GetAgility()
	if self:IsIllusion() and not self.customStatEntity then self.customStatEntity = PlayerResource:GetSelectedHeroEntity( self:GetPlayerOwnerID() ).customStatEntity end
	return self.customStatEntity.customAgility
end

function CDOTA_BaseNPC_Hero:GetVitality()
	if self:IsIllusion() and not self.customStatEntity then self.customStatEntity = PlayerResource:GetSelectedHeroEntity( self:GetPlayerOwnerID() ).customStatEntity end
	return self.customStatEntity.customVitality
end

function CDOTA_BaseNPC_Hero:GetLuck()
	if self:IsIllusion() and not self.customStatEntity then self.customStatEntity = PlayerResource:GetSelectedHeroEntity( self:GetPlayerOwnerID() ).customStatEntity end
	return self.customStatEntity.customLuck
end

function CDOTA_BaseNPC_Hero:GetBaseStrength()
	if GameRules.UnitKV[self:GetUnitName()] then
		return GameRules.UnitKV[self:GetUnitName()]["BaseStrength"] or 0
	end
	return 0
end

function CDOTA_BaseNPC_Hero:GetBaseIntellect()
	if GameRules.UnitKV[self:GetUnitName()] then
		return GameRules.UnitKV[self:GetUnitName()]["BaseIntellect"] or 0
	end
	return 0
end

function CDOTA_BaseNPC_Hero:GetBaseAgility()
	if GameRules.UnitKV[self:GetUnitName()] then
		return GameRules.UnitKV[self:GetUnitName()]["BaseAgility"] or 0
	end
	return 0
end

function CDOTA_BaseNPC_Hero:GetBaseLuck()
	if GameRules.UnitKV[self:GetUnitName()] then
		return GameRules.UnitKV[self:GetUnitName()]["BaseLuck"] or 0
	end
	return 0
end

function CDOTA_BaseNPC_Hero:GetBaseVitality()
	if GameRules.UnitKV[self:GetUnitName()] then
		return GameRules.UnitKV[self:GetUnitName()]["BaseVitality"] or 0
	end
	return 0
end

function CDOTA_BaseNPC_Hero:GetStrengthGain()
	if self:IsIllusion() and not self.customStatEntity then self.customStatEntity = PlayerResource:GetSelectedHeroEntity( self:GetPlayerOwnerID() ).customStatEntity end
	if self.customStatEntity then
		if not self.customStatEntity.customStrengthGain then
			self.customStatEntity.customStrengthGain = 0
			if GameRules.UnitKV[self:GetUnitName()] then
				self.customStatEntity.customStrengthGain = GameRules.UnitKV[self:GetUnitName()]["BaseStrengthGain"] or 0
			end
		end
		return self.customStatEntity.customStrengthGain
	else
		if GameRules.UnitKV[self:GetUnitName()] then
			return GameRules.UnitKV[self:GetUnitName()]["BaseStrengthGain"] or 0
		end
		return 0
	end
end

function CDOTA_BaseNPC_Hero:GetIntellectGain()
	if self:IsIllusion() and not self.customStatEntity then self.customStatEntity = PlayerResource:GetSelectedHeroEntity( self:GetPlayerOwnerID() ).customStatEntity end
	if self.customStatEntity then
		if not self.customStatEntity.customIntellectGain then
			self.customStatEntity.customIntellectGain = 0
			if GameRules.UnitKV[self:GetUnitName()] then
				self.customStatEntity.customIntellectGain = GameRules.UnitKV[self:GetUnitName()]["BaseIntellectGain"] or 0
			end
		end
		return self.customStatEntity.customIntellectGain
	else
		if GameRules.UnitKV[self:GetUnitName()] then
			return GameRules.UnitKV[self:GetUnitName()]["BaseIntellectGain"] or 0
		end
		return 0
	end
end

function CDOTA_BaseNPC_Hero:GetAgilityGain()
	if self:IsIllusion() and not self.customStatEntity then self.customStatEntity = PlayerResource:GetSelectedHeroEntity( self:GetPlayerOwnerID() ).customStatEntity end
	if self.customStatEntity then
		if not self.customStatEntity.customAgilityGain then
			self.customStatEntity.customAgilityGain = 0
			if GameRules.UnitKV[self:GetUnitName()] then
				self.customStatEntity.customAgilityGain = GameRules.UnitKV[self:GetUnitName()]["BaseAgilityGain"] or 0
			end
		end
		return self.customStatEntity.customAgilityGain
	else
		if GameRules.UnitKV[self:GetUnitName()] then
			return GameRules.UnitKV[self:GetUnitName()]["BaseAgilityGain"] or 0
		end
		return 0
	end
end

function CDOTA_BaseNPC_Hero:GetLuckGain()
	if self:IsIllusion() and not self.customStatEntity then self.customStatEntity = PlayerResource:GetSelectedHeroEntity( self:GetPlayerOwnerID() ).customStatEntity end
	if self.customStatEntity then
		if not self.customStatEntity.customLuckGain then
			self.customStatEntity.customLuckGain = 0
			if GameRules.UnitKV[self:GetUnitName()] then
				self.customStatEntity.customLuckGain = GameRules.UnitKV[self:GetUnitName()]["BaseLuckGain"] or 0
			end
		end
		return self.customStatEntity.customLuckGain
	else
		if GameRules.UnitKV[self:GetUnitName()] then
			return GameRules.UnitKV[self:GetUnitName()]["BaseLuckGain"] or 0
		end
		return 0
	end
end

function CDOTA_BaseNPC_Hero:GetVitalityGain()
	if self:IsIllusion() and not self.customStatEntity then self.customStatEntity = PlayerResource:GetSelectedHeroEntity( self:GetPlayerOwnerID() ).customStatEntity end
	if self.customStatEntity then
		if not self.customStatEntity.customVitalityGain then
			self.customStatEntity.customVitalityGain = 0
			if GameRules.UnitKV[self:GetUnitName()] then
				self.customStatEntity.customVitalityGain = GameRules.UnitKV[self:GetUnitName()]["BaseVitalityGain"] or 0
			end
		end
		return self.customStatEntity.customVitalityGain
	else
		if GameRules.UnitKV[self:GetUnitName()] then
			return GameRules.UnitKV[self:GetUnitName()]["BaseVitalityGain"] or 0
		end
		return 0
	end
end