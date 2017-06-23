puppeteer_zombie_brute = class({})

function puppeteer_zombie_brute:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local spawn = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_zombie_spawn.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(spawn, 0, position)
	ParticleManager:ReleaseParticleIndex(spawn)
	
	if caster:HasTalent("puppeteer_zombie_brute_talent_1") then
		local behemoth = self:GetCaster():CreateSummon("npc_dota_puppeteer_flesh_behemoth", position, self:GetTalentSpecialValueFor("lifetime"))
		EmitSoundOn("Hero_Undying.Tombstone", behemoth)
		if self:GetTalentSpecialValueFor("base_health") * 1.5 > self:GetTalentSpecialValueFor("hp_pct") * 1.5 * self:GetCaster():GetMaxHealth() / 100 then
			behemoth:SetBaseMaxHealth(self:GetTalentSpecialValueFor("base_health") * 1.5)
			behemoth:SetMaxHealth(self:GetTalentSpecialValueFor("base_health") * 1.5)
			behemoth:SetHealth(self:GetTalentSpecialValueFor("base_health") * 1.5)
		else
			behemoth:SetBaseMaxHealth(self:GetCaster():GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct") * 1.5 / 100)
			behemoth:SetMaxHealth(self:GetCaster():GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct") * 1.5 / 100)
			behemoth:SetHealth(self:GetCaster():GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct") * 1.5 / 100)
		end
		behemoth:SetPhysicalArmorBaseValue( (self:GetCaster():GetPhysicalArmorValue() + 25*(1.5^(self:GetLevel()-1) ) ) * 1.5)
		behemoth:SetAverageBaseDamage(self:GetTalentSpecialValueFor("dmg_pct") * 1.5 * self:GetCaster():GetAverageTrueAttackDamage(self:GetCaster()) / 100, 10)
		local screech = behemoth:AddAbilityPrecache("zombie_screech")
		behemoth:FindAbilityByName("flesh_behemoth_plague_aura"):SetLevel(1)
		screech:SetLevel(self:GetLevel())
		screech:ToggleAutoCast()
	else
		local zombie = caster:CreateSummon("npc_dota_puppeteer_zombie_brute", position, self:GetTalentSpecialValueFor("lifetime"))
		EmitSoundOn("Hero_Undying.Tombstone", zombie)
		if self:GetTalentSpecialValueFor("base_health") > self:GetTalentSpecialValueFor("hp_pct") * caster:GetMaxHealth() / 100 then
			zombie:SetBaseMaxHealth(self:GetTalentSpecialValueFor("base_health"))
			zombie:SetMaxHealth(self:GetTalentSpecialValueFor("base_health"))
			zombie:SetHealth(self:GetTalentSpecialValueFor("base_health"))
		else
			zombie:SetBaseMaxHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
			zombie:SetMaxHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
			zombie:SetHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
		end
		
		zombie:SetPhysicalArmorBaseValue( self:GetCaster():GetPhysicalArmorValue() + 25*(1.5^(self:GetLevel()-1) ) )
		zombie:SetAverageBaseDamage(self:GetTalentSpecialValueFor("dmg_pct") * caster:GetAverageTrueAttackDamage(caster) / 100, 10)
		local screech = zombie:AddAbilityPrecache("zombie_screech")
		screech:SetLevel(self:GetLevel())
		screech:ToggleAutoCast()
	end
end
