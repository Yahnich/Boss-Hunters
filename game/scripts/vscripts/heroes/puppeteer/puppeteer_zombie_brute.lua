puppeteer_zombie_brute = class({})

function puppeteer_zombie_brute:OnSpellStart()
	local caster = self:GetCaster()
	local zombie = caster:CreateSummon("npc_dota_puppeteer_zombie_brute", caster:GetAbsOrigin() + RandomVector(300))
	zombie:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetTalentSpecialValueFor("lifetime")})
	if self:GetTalentSpecialValueFor("base_health") > self:GetTalentSpecialValueFor("hp_pct") * caster:GetMaxHealth() / 100 then
		zombie:SetBaseMaxHealth(self:GetTalentSpecialValueFor("base_health"))
		zombie:SetMaxHealth(self:GetTalentSpecialValueFor("base_health"))
		zombie:SetHealth(self:GetTalentSpecialValueFor("base_health"))
	else
		zombie:SetBaseMaxHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
		zombie:SetMaxHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
		zombie:SetHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
	end
	
	zombie:SetAverageBaseDamage(self:GetTalentSpecialValueFor("dmg_pct") * caster:GetAverageTrueAttackDamage(caster) / 100, 10)
	zombie:AddNewModifier(caster, self, "modifier_summon_handler", {duration = self:GetTalentSpecialValueFor("lifetime")})
	
	StartAnimation(zombie, {activity = ACT_DOTA_SPAWN, rate = 1.5, duration = 2})
	
	EmitSoundOn("Hero_Undying.FleshGolem.Cast", zombie)
	if caster:HasTalent("puppeteer_zombie_brute_talent_1") then
		zombie:AddNewModifier(caster, self, "modifier_puppeteer_zombie_brute_talent_merge", {duration = self:GetTalentSpecialValueFor("lifetime")})
	end
end

LinkLuaModifier("modifier_summon_handler", "heroes/generic/modifier_summon_handler.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_puppeteer_zombie_brute_talent_merge", "heroes/puppeteer/puppeteer_zombie_brute.lua", LUA_MODIFIER_MOTION_NONE)


modifier_puppeteer_zombie_brute_talent_merge = class({})

if IsServer() then
	function modifier_puppeteer_zombie_brute_talent_merge:OnCreated()
		self.radius = self:GetCaster():FindTalentValue("puppeteer_zombie_brute_talent_1")
		self:StartIntervalThink(0.2)
	end
	
	function modifier_puppeteer_zombie_brute_talent_merge:OnIntervalThink()
		for _, summon in pairs(self:GetCaster().summonTable) do
			if summon ~= self:GetParent() and summon:GetUnitName() == "npc_dota_puppeteer_zombie_brute" and CalculateDistance(self:GetParent(), summon) <= self.radius then
				local avgPos = (summon:GetAbsOrigin() + self:GetParent():GetAbsOrigin()) / 2
				summon:ForceKill(true)
				self:GetParent():ForceKill(true)
				local behemoth = self:GetCaster():CreateSummon("npc_dota_puppeteer_flesh_behemoth", avgPos)
				behemoth:AddNewModifier(self:GetCaster(), self, "modifier_summon_handler", {duration = self:GetAbility():GetTalentSpecialValueFor("lifetime")})
				behemoth:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetAbility():GetTalentSpecialValueFor("lifetime")})
				if self:GetAbility():GetTalentSpecialValueFor("base_health") * 2.5 > self:GetAbility():GetTalentSpecialValueFor("hp_pct") * 1.5 * self:GetCaster():GetMaxHealth() / 100 then
					behemoth:SetBaseMaxHealth(self:GetAbility():GetTalentSpecialValueFor("base_health") * 2.5)
					behemoth:SetMaxHealth(self:GetAbility():GetTalentSpecialValueFor("base_health") * 2.5)
					behemoth:SetHealth(self:GetAbility():GetTalentSpecialValueFor("base_health") * 2.5)
				else
					behemoth:SetBaseMaxHealth(self:GetCaster():GetMaxHealth() * self:GetAbility():GetTalentSpecialValueFor("hp_pct") * 1.5 / 100)
					behemoth:SetMaxHealth(self:GetCaster():GetMaxHealth() * self:GetAbility():GetTalentSpecialValueFor("hp_pct") * 1.5 / 100)
					behemoth:SetHealth(self:GetCaster():GetMaxHealth() * self:GetAbility():GetTalentSpecialValueFor("hp_pct") * 1.5 / 100)
				end
				
				behemoth:SetAverageBaseDamage(self:GetAbility():GetTalentSpecialValueFor("dmg_pct") * 2.5 * self:GetCaster():GetAverageTrueAttackDamage(self:GetCaster()) / 100, 10)
			end
		end
	end
end