puppeteer_pestilence = class({})

function puppeteer_pestilence:OnSpellStart()
	local caster = self:GetCaster()
	caster.summonTable = caster.summonTable or {}
	EmitSoundOn("Hero_Venomancer.Plague_Ward", caster)
	local explodeTable = {}
	for _,summon in pairs(caster.summonTable) do -- insert global table in local table
		table.insert(explodeTable, summon)
	end
	for _, explodeSummon in pairs(explodeTable) do
		self:ExplodeSummon(explodeSummon)
	end
end


function puppeteer_pestilence:ExplodeSummon(entity)
	local radius = self:GetSpecialValueFor("explode_radius")
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), entity:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	for _, enemy in pairs(enemies) do
		if self:GetCaster():HasTalent("puppeteer_pestilence_talent_1") then
			
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_puppeteer_pestilence_talent_resurrect", {duration = self:GetCaster():FindTalentValue("puppeteer_pestilence_talent_1")})
		end
		ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self:GetSpecialValueFor("explode_damage"), damage_type = self:GetAbilityDamageType(), ability = self})
		local plague = self:GetCaster():FindAbilityByName("puppeteer_black_plague")
		for i = 1, self:GetSpecialValueFor("plague_increase") do
			enemy:AddNewModifier(self:GetCaster(), plague, "modifier_puppeteer_black_plague_stack", {duration = plague:GetSpecialValueFor("duration")})
		end
	end
	EmitSoundOn("Hero_Venomancer.PoisonNovaImpact", entity)
	local pestilence = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_POINT_FOLLOW, entity)
	ParticleManager:SetParticleControl(pestilence, 0, entity:GetAbsOrigin())
	ParticleManager:SetParticleControl(pestilence, 1, Vector(radius,1, radius))
	ParticleManager:ReleaseParticleIndex(pestilence)
	entity:ForceKill(true)
end


LinkLuaModifier("modifier_puppeteer_pestilence_talent_resurrect", "heroes/puppeteer/puppeteer_pestilence.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_summon_handler", "heroes/generic/modifier_summon_handler.lua", LUA_MODIFIER_MOTION_NONE)

modifier_puppeteer_pestilence_talent_resurrect = class({})

if IsServer() then
	function modifier_puppeteer_pestilence_talent_resurrect:OnDeath(params)
		if params.unit == self:GetParent() and not params.unit:GetUnitName() ~= "npc_dota_boss36" then
			local caster = self:GetCaster()
			local summon = caster:CreateSummon(self:GetParent():GetUnitName(), self:GetParent():GetAbsOrigin())
			StartAnimation(summon, {activity = ACT_DOTA_SPAWN, rate = 1.5, duration = 2})
			summon:AddNewModifier(caster, self, "modifier_kill", {duration = caster:FindSpecificTalentValue("puppeteer_pestilence_talent_1", "duration")})
			summon:AddNewModifier(caster, self, "modifier_summon_handler", {duration = caster:FindSpecificTalentValue("puppeteer_pestilence_talent_1", "duration")})
			for i = 0, 16 do
				local ability = summon:GetAbilityByIndex(i)
				if ability then ability:SetActivated(false) end
			end
			local timer = 0
			Timers:CreateTimer(FrameTime(), function()
				summon:SetHealth(summon:GetMaxHealth() * caster:FindTalentValue("puppeteer_pestilence_talent_1") / 100)
				summon:SetMaxHealth(summon:GetMaxHealth() * caster:FindTalentValue("puppeteer_pestilence_talent_1") / 100)
				summon:SetBaseMaxHealth(summon:GetMaxHealth() * caster:FindTalentValue("puppeteer_pestilence_talent_1") / 100)
			end)
			
		end
	end
end

function modifier_puppeteer_pestilence_talent_resurrect:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_DEATH,
			}
	return funcs
end

