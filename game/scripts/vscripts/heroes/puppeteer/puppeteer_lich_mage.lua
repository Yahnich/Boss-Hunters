puppeteer_lich_mage = class({})

function puppeteer_lich_mage:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local lich = caster:CreateSummon("npc_dota_puppeteer_lich_mage", position, self:GetSpecialValueFor("lifetime"))
	
	local spawn = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_zombie_spawn.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(spawn, 0, position)
	ParticleManager:ReleaseParticleIndex(spawn)
	
	lich:SetAverageBaseDamage(self:GetTalentSpecialValueFor("dmg_pct") * caster:GetAverageTrueAttackDamage(caster) / 100, 10)
	lich:SetBaseMaxHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
	lich:SetMaxHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
	lich:SetHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
	lich:SetPhysicalArmorBaseValue(caster:GetPhysicalArmorValue())
	
	local healAb = lich:AddAbilityPrecache("lich_mage_heal")
	healAb:ToggleAutoCast()
	healAb:SetLevel(self:GetLevel())
	local ampAb = lich:AddAbilityPrecache("lich_mage_damage_amp")
	ampAb:ToggleAutoCast()
	ampAb:SetLevel(self:GetLevel())
	
	self.necklace = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/lich/master_of_jiang_shi_lich_neck/master_of_jiang_shi_lich_neck.vmdl"})
	self.belt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/lich/lich_dress.vmdl"})
	-- lock to bone
	self.necklace:FollowEntity(lich, true)
	self.belt:FollowEntity(lich, true)
	
	EmitSoundOn("Ability.DarkRitual", lich)
end

LinkLuaModifier("modifier_summon_handler", "heroes/generic/modifier_summon_handler.lua", LUA_MODIFIER_MOTION_NONE)