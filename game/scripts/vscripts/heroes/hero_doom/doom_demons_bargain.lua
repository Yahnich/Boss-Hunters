doom_demons_bargain = class({})

function doom_demons_bargain:OnAbilityPhaseStart()
	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	EmitSoundOn("Hero_DoomBringer.DevourCast", self.caster)
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_devour_beam.vpcf", PATTACH_POINT_FOLLOW, self.target, self.caster)
	return true
end

function doom_demons_bargain:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_DoomBringer.DevourCast", self.caster)
end

function doom_demons_bargain:OnSpellStart()
    local gold = self:GetTalentSpecialValueFor("total_gold")
	local deathChance = self:GetTalentSpecialValueFor("death_perc")
	local deathThreshold = self:GetTalentSpecialValueFor("death_chance")
    local kill_rand = math.random(100)
	local boss_curr = self.target:GetHealth()
	local boss_max = self.target:GetMaxHealth()
	local boss_perc = (boss_curr/boss_max)*100
	local mod_perc = deathThreshold*(deathThreshold/boss_perc) -- Scale chance up as HP goes down
	
	ParticleManager:FireParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_devour.vpcf", PATTACH_POINT_FOLLOW, self.target)
	EmitSoundOn("Hero_DoomBringer.Devour", self.target)
	
    local total_unit = 0
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if not unit:IsIllusion() then
            total_unit = total_unit + 1
        end
    end
    local gold_per_player = gold / total_unit
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if not unit:IsIllusion() then
            local totalgold = unit:GetGold() + gold_per_player
            unit:SetGold(0 , false)
            unit:SetGold(totalgold, true)
        end
    end
	if RollPercentage(mod_perc) and boss_perc <= deathThreshold  then
		self.target:AttemptKill(self, self.caster)
	end
end