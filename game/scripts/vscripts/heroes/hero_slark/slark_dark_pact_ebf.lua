slark_dark_pact_ebf = class({})

function slark_dark_pact_ebf:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	if self:GetCaster():HasTalent("special_bonus_unique_slark_dark_pact_1") then
		behavior = behavior + DOTA_ABILITY_BEHAVIOR_TOGGLE
	end
	return behavior
end

function slark_dark_pact_ebf:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		EmitSoundOn("Hero_Slark.DarkPact.Cast", caster)
		caster:AddNewModifier(caster, self, "modifier_slark_dark_pact_effect", {})
	else
		caster:RemoveModifierByName("modifier_slark_dark_pact_effect")
	end
end

function slark_dark_pact_ebf:OnSpellStart()
	local caster = self:GetCaster()
	
	local delay = self:GetTalentSpecialValueFor("delay")
	local duration = self:GetTalentSpecialValueFor("pulse_duration")
	ParticleManager:FireParticle("particles/units/heroes/hero_slark/slark_dark_pact_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, {[1] = "attach_hitloc"})
	EmitSoundOn("Hero_Slark.DarkPact.PreCast", caster)
	Timers:CreateTimer(delay, function()
		caster:AddNewModifier(caster, self, "modifier_slark_dark_pact_effect", {duration = duration})
		EmitSoundOn("Hero_Slark.DarkPact.Cast", caster)
	end)
end

modifier_slark_dark_pact_effect = class({})
LinkLuaModifier("modifier_slark_dark_pact_effect", "heroes/hero_slark/slark_dark_pact_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_dark_pact_effect:OnCreated()
	self.rate = self:GetTalentSpecialValueFor("pulse_interval")
	self.damage = self:GetTalentSpecialValueFor("total_damage")
	self.radius = self:GetTalentSpecialValueFor("radius")
	if IsServer() then
		local caster = self:GetCaster()
		self:GetParent():StartGesture( ACT_DOTA_CAST_ABILITY_1 )
		self.particleFire = 0
		self:StartIntervalThink(self.rate)
	end
end

function modifier_slark_dark_pact_effect:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local damage = self.damage * self.rate
	local self_damage = damage / 2
	if self.particleFire <= 0 then
		ParticleManager:FireParticle("particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, {[1] = "attach_hitloc", [2] = Vector(self.radius, self.radius, self.radius)})
		self.particleFire = 1
	else
		self.particleFire = self.particleFire - self.rate
	end
	if caster:HasTalent("special_bonus_unique_slark_dark_pact_1") then self_damage = damage * caster:FindTalentValue("special_bonus_unique_slark_dark_pact_1") end
	
	local enemies = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius )
	for _, enemy in ipairs( enemies ) do
		local enemyDamage = damage
		if caster:HasTalent("special_bonus_unique_slark_dark_pact_2") then
			enemyDamage = damage + self_damage
		end
		ability:DealDamage( caster, enemy, enemyDamage)
	end
	if caster:HasTalent("special_bonus_unique_slark_dark_pact_2") and #enemies > 0 then
		self_damage = 0
	end
	caster:Dispel(caster, true)
	ability:DealDamage( caster, caster, self_damage, {damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS})
end

function modifier_slark_dark_pact_effect:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end