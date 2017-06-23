puppeteer_skeleton_archer = puppeteer_skeleton_archer or class({})

function puppeteer_skeleton_archer:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local skeleton = self:CreateSkeleton(position)
	
	local spawn = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_zombie_spawn.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(spawn, 0, position)
	ParticleManager:ReleaseParticleIndex(spawn)
	EmitSoundOn("Hero_Clinkz.DeathPact.Cast", skeleton)
	
	if caster:HasTalent("puppeteer_skeleton_archer_talent_1") then
		skeleton:AddNewModifier(caster, self, "modifier_puppeteer_skeleton_archer_talent_resurrect", {duration = self:GetTalentSpecialValueFor("lifetime")})
	end
end

function puppeteer_skeleton_archer:CreateSkeleton(position)
	local caster = self:GetCaster()
	local skeleton = caster:CreateSummon("npc_dota_puppeteer_skeleton_archer", position, self:GetSpecialValueFor("lifetime"))
	if self:GetTalentSpecialValueFor("base_damage") > self:GetTalentSpecialValueFor("dmg_pct") * caster:GetAverageTrueAttackDamage(caster) / 100 then
		skeleton:SetAverageBaseDamage(self:GetTalentSpecialValueFor("base_damage"), 10)
	else
		skeleton:SetAverageBaseDamage(self:GetTalentSpecialValueFor("dmg_pct") * caster:GetAverageTrueAttackDamage(caster) / 100, 10)
	end
	
	skeleton:SetBaseMaxHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
	skeleton:SetMaxHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
	skeleton:SetHealth(caster:GetMaxHealth() * self:GetTalentSpecialValueFor("hp_pct")  / 100)
	skeleton:SetPhysicalArmorBaseValue(caster:GetPhysicalArmorValue())
	
	self.bow = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/clinkz/redbull_clinkz_weapon/redbull_clinkz_weapon.vmdl"})
	self.horns = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/clinkz/redbull_clinkz_head/redbull_clinkz_head.vmdl"})
	self.quiver = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/clinkz/clinkz_back.vmdl"})
	self.gloves = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/clinkz/claw/claw.vmdl"})
	self.shoulder = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/clinkz/guard/guard.vmdl"})
	-- lock to bone
	self.bow:FollowEntity(skeleton, true)
	self.horns:FollowEntity(skeleton, true)
	self.quiver:FollowEntity(skeleton, true)
	self.gloves:FollowEntity(skeleton, true)
	self.shoulder:FollowEntity(skeleton, true)

	return skeleton
end

LinkLuaModifier("modifier_puppeteer_skeleton_archer_talent_resurrect", "heroes/puppeteer/puppeteer_skeleton_archer.lua", LUA_MODIFIER_MOTION_NONE)

modifier_puppeteer_skeleton_archer_talent_resurrect = class({})

if IsServer() then
	function modifier_puppeteer_skeleton_archer_talent_resurrect:OnDeath(params)
		if params.unit == self:GetParent() then
			self:GetAbility():CreateSkeleton(self:GetParent():GetAbsOrigin())
		end
	end
end

function modifier_puppeteer_skeleton_archer_talent_resurrect:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_DEATH,
			}
	return funcs
end

function modifier_puppeteer_skeleton_archer_talent_resurrect:IsHidden()
	return true
end