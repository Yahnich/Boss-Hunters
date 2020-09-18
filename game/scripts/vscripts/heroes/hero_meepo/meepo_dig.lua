meepo_dig = class({})
LinkLuaModifier("modifier_meepo_dig_arcane", "heroes/hero_meepo/meepo_dig", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meepo_dig_dd", "heroes/hero_meepo/meepo_dig", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meepo_dig_gold", "heroes/hero_meepo/meepo_dig", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meepo_dig_haste", "heroes/hero_meepo/meepo_dig", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meepo_dig_illusion", "heroes/hero_meepo/meepo_dig", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meepo_dig_invis", "heroes/hero_meepo/meepo_dig", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meepo_dig_regen", "heroes/hero_meepo/meepo_dig", LUA_MODIFIER_MOTION_NONE)

function meepo_dig:IsStealable()
    return true
end

function meepo_dig:IsHiddenWhenStolen()
    return false
end

function meepo_dig:GetChannelTime()
    return self:GetSpecialValueFor("channel_duration")
end

function meepo_dig:GetChannelAnimation()
    return ACT_DOTA_GENERIC_CHANNEL_1
end

function meepo_dig:OnSpellStart()
    local caster = self:GetCaster()

    self.tickRate = 0.5
    self.currentTime = 0.5

    self.talentTickRate = 0.25
    self.talentCurrentTime = 0
end

function meepo_dig:OnChannelThink(flInterval)
    local caster = self:GetCaster()

    if self.currentTime < self.tickRate then
    	self.currentTime = self.currentTime + flInterval
    else
    	ParticleManager:FireParticle("particles/generic_gameplay/dust_impact_medium.vpcf", PATTACH_ABSORIGIN, caster, {})

    	self.currentTime = 0
    end

    if caster:HasTalent("special_bonus_unique_meepo_dig_2") then
	    if self.talentCurrentTime < self.talentTickRate then
	    	self.talentCurrentTime = self.talentCurrentTime + flInterval
	    else
	    	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_meepo_dig_2"))
	    	for _,enemy in pairs(enemies) do
	    		enemy:ApplyKnockBack(caster:GetAbsOrigin(), 0.5, 0.5, caster:FindTalentValue("special_bonus_unique_meepo_dig_2"), 100, caster, self, true)
	    	end
	    	self.talentCurrentTime = 0
	    end
	end
end

function meepo_dig:OnChannelFinish(bInterrupted)
    if not bInterrupted then
    	local caster = self:GetCaster()
	
		local duration = self:GetSpecialValueFor("rune_duration")

		local runes = { "item_meepo_rune_dd",
						"item_meepo_rune_regen",
						"item_meepo_rune_invis",
						"item_meepo_rune_arcane",
						"item_meepo_rune_bounty",
						"item_meepo_rune_haste",
						"item_meepo_rune_illusion"}

		if caster:HasTalent("special_bonus_unique_meepo_dig_1") then
			table.insert(runes, "item_meepo_rune_reduc")
		end

		local rune = runes[ RandomInt( 1, #runes ) ]
		local item = CreateItem(rune, caster, caster)
		local randoPoint = GetGroundPosition(caster:GetAbsOrigin(), caster) + ActualRandomVector(150, 50)
		CreateItemOnPositionSync(randoPoint, item)
		ParticleManager:FireParticle("particles/generic_gameplay/dust_impact_medium.vpcf", PATTACH_ABSORIGIN, caster, {[0]=randoPoint})
		item:SetCastOnPickup(true)
		
		local PID = caster:GetPlayerOwnerID()
		local mainMeepo = PlayerResource:GetSelectedHeroEntity(PID)
		if caster:HasScepter() and caster == mainMeepo then
			local rune = runes[ RandomInt( 1, #runes ) ]
			local item = CreateItem(rune, nil, nil)
			local randoPoint = GetGroundPosition(caster:GetAbsOrigin(), caster) + ActualRandomVector(150, 50)
			CreateItemOnPositionSync(randoPoint, item)
			ParticleManager:FireParticle("particles/generic_gameplay/dust_impact_medium.vpcf", PATTACH_ABSORIGIN, caster, {[0]=randoPoint})
			item:SetCastOnPickup(true)
		end
    end
end
