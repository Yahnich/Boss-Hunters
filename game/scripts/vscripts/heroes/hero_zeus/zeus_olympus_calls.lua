zeus_olympus_calls = class({})
LinkLuaModifier( "modifier_zeus_olympus_calls", "heroes/hero_zeus/zeus_olympus_calls.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zeus_olympus_calls_ally", "heroes/hero_zeus/zeus_olympus_calls.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zeus_olympus_calls_talent", "heroes/hero_zeus/zeus_olympus_calls.lua" ,LUA_MODIFIER_MOTION_NONE )

function zeus_olympus_calls:GetIntrinsicModifierName()
	if self:GetCaster():HasTalent("special_bonus_unique_zeus_olympus_calls_1") then
		return "modifier_zeus_olympus_calls_talent"
	end
end

function zeus_olympus_calls:OnTalentLearned(talent)
	if talent == "special_bonus_unique_zeus_olympus_calls_1" then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_zeus_olympus_calls_talent", {})
	end
end

function zeus_olympus_calls:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Zuus.GodsWrath.PreCast", self:GetCaster())
	ParticleManager:FireParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", PATTACH_POINT, self:GetCaster(), {[1]="attach_attack1", [2]="attach_attack2"})
	return true
end

function zeus_olympus_calls:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Zuus.GodsWrath", caster)
	caster:AddNewModifier(caster, self, "modifier_zeus_olympus_calls", {Duration = self:GetTalentSpecialValueFor("duration")})

	if caster:HasTalent("special_bonus_unique_zeus_olympus_calls_2") then
		local allies = caster:FindFriendlyUnitsInRadius(caster, FIND_UNITS_EVERYWHERE)
		for _,ally in pairs(allies) do
			if ally ~= caster then
				ally:AddNewModifier(caster, self, "modifier_zeus_olympus_calls_ally", {Duration = self:GetTalentSpecialValueFor("duration")})
			end
		end
	end
end

modifier_zeus_olympus_calls = class({})
function modifier_zeus_olympus_calls:OnCreated(table)
	self.amp = self:GetTalentSpecialValueFor("bonus_spell_amp")
	if IsServer() then
		self:StartIntervalThink(self:GetTalentSpecialValueFor("tick_rate"))
	end
end

function modifier_zeus_olympus_calls:OnRefresh(table)
	self.amp = self:GetTalentSpecialValueFor("bonus_spell_amp")
end

function modifier_zeus_olympus_calls:OnIntervalThink()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()
	local pointRando = point + ActualRandomVector(self:GetTalentSpecialValueFor("radius"), -self:GetTalentSpecialValueFor("radius"))

	local enemies = caster:FindEnemyUnitsInRadius(point, self:GetTalentSpecialValueFor("radius"), {})
	if #enemies > 0 then
		for _,enemy in pairs(enemies) do
			EmitSoundOn("Hero_Zuus.GodsWrath.Target", enemy)
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zeus/zeus_olympus_calls.vpcf", PATTACH_POINT_FOLLOW, caster, enemy, {})
			self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage")*self:GetTalentSpecialValueFor("tick_rate"), {}, 0)
			break
		end
	else
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_zeus/zeus_olympus_calls.vpcf", PATTACH_POINT_FOLLOW, caster, pointRando, {})
	end
end

function modifier_zeus_olympus_calls:CheckState()
	local state = { [MODIFIER_STATE_FLYING] = true}
	return state
end

function modifier_zeus_olympus_calls:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_zeus_olympus_calls:GetModifierSpellAmplify_Percentage()
	return self.amp
end

function modifier_zeus_olympus_calls:GetEffectName()
	return "particles/units/heroes/hero_zeus/zeus_olympus_calls_cloud.vpcf"
end

function modifier_zeus_olympus_calls:IsDebuff()
	return false
end

modifier_zeus_olympus_calls_ally = class({})
function modifier_zeus_olympus_calls_ally:OnCreated(table)
	self.amp = self:GetTalentSpecialValueFor("bonus_spell_amp")
	if IsServer() then
		self:StartIntervalThink(self:GetTalentSpecialValueFor("tick_rate"))
	end
end

function modifier_zeus_olympus_calls_ally:OnRefresh(table)
	self.amp = self:GetTalentSpecialValueFor("bonus_spell_amp")
end

function modifier_zeus_olympus_calls_ally:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
	return funcs
end

function modifier_zeus_olympus_calls_ally:GetModifierSpellAmplify_Percentage()
	return self.amp
end

function modifier_zeus_olympus_calls_ally:IsDebuff()
	return false
end

modifier_zeus_olympus_calls_talent = class({})
function modifier_zeus_olympus_calls_talent:OnCreated()
	self.chance = self:GetCaster():FindTalentValue("special_bonus_unique_zeus_olympus_calls_1")
	self.damage = self:GetTalentSpecialValueFor("damage")
end

function modifier_zeus_olympus_calls_talent:OnRefresh()
	self.chance = self:GetCaster():FindTalentValue("special_bonus_unique_zeus_olympus_calls_1")
	self.damage = self:GetTalentSpecialValueFor("damage")
end

function modifier_zeus_olympus_calls_talent:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_zeus_olympus_calls_talent:OnAttackLanded(params)
	if IsServer() then
		local caster = params.attacker
		local enemy = params.target
		if caster:HasTalent("special_bonus_unique_zeus_olympus_calls_1") and self:RollPRNG( self.chance ) then
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zeus/zeus_olympus_calls.vpcf", PATTACH_POINT_FOLLOW, caster, enemy, {})
			self:GetAbility():DealDamage(caster, enemy, self.damage)
		end
	end
end

function modifier_zeus_olympus_calls_talent:IsHidden()
	return true
end