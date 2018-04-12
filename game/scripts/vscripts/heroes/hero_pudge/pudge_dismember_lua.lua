pudge_dismember_lua = class({})
LinkLuaModifier( "modifier_pudge_dismember_lua", "heroes/hero_pudge/pudge_dismember_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pudge_dismember_lua_armor", "heroes/hero_pudge/pudge_dismember_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_pudge_flesh_heap_lua_effect", "heroes/hero_pudge/pudge_flesh_heap_lua", LUA_MODIFIER_MOTION_NONE)

function pudge_dismember_lua:GetConceptRecipientType()
	return DOTA_SPEECH_USER_ALL
end

function pudge_dismember_lua:SpeakTrigger()
	return DOTA_ABILITY_SPEAK_CAST
end

function pudge_dismember_lua:GetChannelTime()
	return self:GetTalentSpecialValueFor( "duration" )
end

function pudge_dismember_lua:GetChannelAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_4
end

function pudge_dismember_lua:GetAOERadius()
	return self:GetTalentSpecialValueFor("width")
end

function pudge_dismember_lua:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_pudge_dismember_lua_1") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_pudge_dismember_lua_1", "cdr") end
    return cooldown
end

function pudge_dismember_lua:OnSpellStart()
	local caster = self:GetCaster()

	if caster:HasTalent("special_bonus_unique_pudge_dismember_lua_2") then
		caster:AddNewModifier(caster, self, "modifier_pudge_dismember_lua_armor", {Duration = self:GetTalentSpecialValueFor("duration")})
	end

	ParticleManager:FireParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack1"})
	ParticleManager:FireParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack2"})

	self.counter = 0
end

function pudge_dismember_lua:OnChannelThink(flInterval)
	local caster = self:GetCaster()
	local endPoint = caster:GetAbsOrigin() + caster:GetForwardVector() * self:GetTrueCastRange()
	local speed = self:GetTalentSpecialValueFor("speed")*flInterval
	self.counter = self.counter + flInterval
	local enemies = caster:FindEnemyUnitsInLine(caster:GetAbsOrigin(), endPoint, self:GetTalentSpecialValueFor("width"), {})
	for _,enemy in pairs(enemies) do
		if CalculateDistance(enemy, caster) > caster:GetAttackRange() then
			enemy:SetAbsOrigin(enemy:GetAbsOrigin() - CalculateDirection(enemy, caster) * speed)
		end
	end

	if self.counter > 0.25 then
		EmitSoundOn("Hero_Pudge.Dismember", caster)
		EmitSoundOn("Hero_Pudge.DismemberSwings", caster)
		ParticleManager:FireParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack1"})
		ParticleManager:FireParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack2"})
			
		local enemies = caster:FindEnemyUnitsInLine(caster:GetAbsOrigin(), endPoint, self:GetTalentSpecialValueFor("width"), {})
		if #enemies > 0 then
			local fleshheap = caster:FindAbilityByName("pudge_flesh_heap_lua")
			caster:AddNewModifier(caster, fleshheap, "modifier_pudge_flesh_heap_lua_effect", {Duration = fleshheap:GetTalentSpecialValueFor("duration")}):AddIndependentStack(fleshheap:GetTalentSpecialValueFor("duration"))
		end
		for _,enemy in pairs(enemies) do
			if not enemy:HasModifier("modifier_pudge_dismember_lua") then
				enemy:AddNewModifier(caster, self, "modifier_pudge_dismember_lua", {})
			end
			local damage = self:GetTalentSpecialValueFor("damage") + self:GetTalentSpecialValueFor("str_damage")/100 * caster:GetStrength()
			damage = damage * 0.25
			caster:Lifesteal(self, self:GetTalentSpecialValueFor("heal_pct"), damage, enemy, self:GetAbilityDamageType(), DOTA_LIFESTEAL_SOURCE_ABILITY, false)
			self.enemyCheck = true
		end

		self.counter = 0
	end
end

function pudge_dismember_lua:OnChannelFinish( bInterrupted )
	self:GetCaster():RemoveModifierByName("modifier_pudge_dismember_lua_armor")

	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {flag=DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
	for _,enemy in pairs(enemies) do
		if enemy:HasModifier("modifier_pudge_dismember_lua") then
			enemy:RemoveModifierByName("modifier_pudge_dismember_lua")
			FindClearSpaceForUnit(enemy, enemy:GetAbsOrigin(), true)
		end
	end
end

modifier_pudge_dismember_lua = class({})

function modifier_pudge_dismember_lua:OnCreated(table)
	if IsServer() then
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_dismember_chain.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleAlwaysSimulate(self.nfx)
		ParticleManager:SetParticleControlEnt(self.nfx, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	end
end

function modifier_pudge_dismember_lua:OnRemoved()
	if IsServer() then
		ParticleManager:ClearParticle(self.nfx)
	end
end

function modifier_pudge_dismember_lua:IsDebuff()
	return true
end

function modifier_pudge_dismember_lua:IsStunDebuff()
	return true
end

function modifier_pudge_dismember_lua:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

function modifier_pudge_dismember_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_pudge_dismember_lua:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

function modifier_pudge_dismember_lua:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

modifier_pudge_dismember_lua_armor = class({})
function modifier_pudge_dismember_lua_armor:IsDebuff()
	return false
end

function modifier_pudge_dismember_lua_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}

	return funcs
end

function modifier_pudge_dismember_lua_armor:GetModifierPhysicalArmorBonus()
	return self:GetCaster():FindTalentValue("special_bonus_unique_pudge_dismember_lua_2")
end

function modifier_pudge_dismember_lua_armor:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end