puppeteer_lich_mage = class({})

function puppeteer_lich_mage:OnSpellStart()
	local caster = self:GetCaster()
	local lich = caster:CreateSummon("npc_dota_puppeteer_lich_mage", caster:GetAbsOrigin() + RandomVector(300))
	lich:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetTalentSpecialValueFor("lifetime")})
	lich:AddNewModifier(caster, self, "modifier_summon_handler", {duration = self:GetTalentSpecialValueFor("lifetime")})
	
	lich:SetAverageBaseDamage(self:GetTalentSpecialValueFor("dmg_pct") * caster:GetAverageTrueAttackDamage(caster) / 100, 10)
	lich:SetBaseMaxHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
	lich:SetMaxHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
	lich:SetHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
	
	local healAb = lich:AddAbilityPrecache("lich_mage_heal")
	healAb:SetLevel(self:GetLevel())
	local ampAb = lich:AddAbilityPrecache("lich_mage_damage_amp")
	ampAb:SetLevel(self:GetLevel())
	
	self.necklace = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/lich/master_of_jiang_shi_lich_neck/master_of_jiang_shi_lich_neck.vmdl"})
	self.belt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/lich/lich_dress.vmdl"})
	-- lock to bone
	self.necklace:FollowEntity(lich, true)
	self.belt:FollowEntity(lich, true)
	
	StartAnimation(lich, {activity = ACT_DOTA_SPAWN, rate = 1.0, duration = 3})
	
	EmitSoundOn("Ability.DarkRitual", lich)
end

LinkLuaModifier("modifier_summon_handler", "heroes/generic/modifier_summon_handler.lua", LUA_MODIFIER_MOTION_NONE)