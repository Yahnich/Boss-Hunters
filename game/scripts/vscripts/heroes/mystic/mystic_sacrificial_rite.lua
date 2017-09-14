mystic_sacrificial_rite = class({})


function mystic_sacrificial_rite:OnAbilityPhaseStart()
	self. warning = ParticleManager:CreateParticle("particles/heroes/mystic/mystic_sacrificial_rite_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
	EmitSoundOn("Hero_Bloodseeker.BloodRite.Cast", self:GetCaster())
	return true
end

function mystic_sacrificial_rite:OnAbilityPhaseInterrupted()
	ParticleManager:DestroyParticle(self.warning, false)
	ParticleManager:ReleaseParticleIndex(self.warning)
	self.warning = nil
	StopSoundOn("Hero_Bloodseeker.BloodRite.Cast", self:GetCaster())
end

function mystic_sacrificial_rite:OnSpellStart()
	local caster = self:GetCaster()
	local targets = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
	
	
	EmitSoundOn("hero_bloodseeker.bloodRite", caster)
	local currHp = caster:GetHealth() - 1
	print(currHp)
	caster:SetHealth(1)
	for _, target in ipairs(targets) do
		if target ~= caster then
			if target:IsSameTeam(caster) then
				target:AddNewModifier(caster, self, "modifier_mystic_sacrificial_rite_heal", {duration = self:GetSpecialValueFor("heal_duration"), heal = currHp})
				if caster:HasTalent("mystic_sacrificial_rite_talent_1") then
					target:AddNewModifier(caster, self, "modifier_mystic_sacrificial_rite_talent", {duration = self:GetSpecialValueFor("talent_buff_duration")})
				end
			else
				target:AddNewModifier(caster, self, "modifier_mystic_sacrificial_rite_debuff", {duration = self:GetSpecialValueFor("debuff_duration")})
			end
		end
		local bloodFX = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_ring.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(bloodFX, 1, Vector(target:GetHullRadius() * 6, RandomInt(1, 150), RandomInt(1, 15)))
		Timers:CreateTimer(0.5, function()
			ParticleManager:DestroyParticle(bloodFX, false)
			ParticleManager:ReleaseParticleIndex(bloodFX)
		end)
	end
	Timers:CreateTimer(0.5, function() EmitSoundOn("hero_bloodseeker.bloodRite.silence", caster) end)
	caster:AddNewModifier(caster, self, "modifier_mystic_sacrificial_rite_invulnerability", {duration = self:GetSpecialValueFor("invuln_duration")})
	if caster:HasTalent("mystic_sacrificial_rite_talent_1") then
		caster:AddNewModifier(caster, self, "modifier_mystic_sacrificial_rite_talent", {duration = self:GetSpecialValueFor("talent_buff_duration")})
	end
end

modifier_mystic_sacrificial_rite_heal = class({})
LinkLuaModifier("modifier_mystic_sacrificial_rite_heal", "heroes/mystic/mystic_sacrificial_rite.lua", 0)

if IsServer() then
	function modifier_mystic_sacrificial_rite_heal:OnCreated(kv)
		print(kv.heal)
		self.heal = tonumber(kv.heal)
		self.healtick = (self.heal / self:GetRemainingTime()) * 0.3
		self:StartIntervalThink(0.3)
	end

	function modifier_mystic_sacrificial_rite_heal:OnRefresh(kv)
		self.heal = self.heal + tonumber(kv.heal)
		self.healtick = (self.heal / self:GetRemainingTime()) * 0.3
	end

	function modifier_mystic_sacrificial_rite_heal:OnIntervalThink()
		print("ok")
		self:GetParent():HealEvent(self.healtick, self:GetAbility(), self:GetCaster())
		self.heal = math.max(0, self.heal - self.healtick)
	end
end

modifier_mystic_sacrificial_rite_debuff = class({})
LinkLuaModifier("modifier_mystic_sacrificial_rite_debuff", "heroes/mystic/mystic_sacrificial_rite.lua", 0)

function modifier_mystic_sacrificial_rite_debuff:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_PASSIVES_DISABLED] = true}
end

function modifier_mystic_sacrificial_rite_debuff:GetEffectName()
	return "particles/items_fx/aura_endurance.vpcf"
end

modifier_mystic_sacrificial_rite_invulnerability = class({})
LinkLuaModifier("modifier_mystic_sacrificial_rite_invulnerability", "heroes/mystic/mystic_sacrificial_rite.lua", 0)

if IsServer() then
	function modifier_mystic_sacrificial_rite_invulnerability:OnCreated()
		self:GetAbility():StartDelayedCooldown()
	end

	function modifier_mystic_sacrificial_rite_invulnerability:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_mystic_sacrificial_rite_invulnerability:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,}
end

function modifier_mystic_sacrificial_rite_invulnerability:DeclareFunctions()
	return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE}
end

function modifier_mystic_sacrificial_rite_invulnerability:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_mystic_sacrificial_rite_invulnerability:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_mystic_sacrificial_rite_invulnerability:GetAbsoluteNoDamagePure()
	return 1
end

function modifier_mystic_sacrificial_rite_invulnerability:GetStatusEffectName()
	return "particles/heroes/mystic/mystic_sacrificial_rite_invulnerability_status_effect.vpcf"
end

function modifier_mystic_sacrificial_rite_invulnerability:StatusEffectPriority()
	return 20
end

modifier_mystic_sacrificial_rite_talent = class({})
LinkLuaModifier("modifier_mystic_sacrificial_rite_talent", "heroes/mystic/mystic_sacrificial_rite.lua", 0)

function modifier_mystic_sacrificial_rite_talent:OnCreated(kv)
	self.dmgRed = self:GetSpecialValueFor("talent_dmg_reduction")
end

function modifier_mystic_sacrificial_rite_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_mystic_sacrificial_rite_talent:GetStatusEffectName()
	return "particles/heroes/mystic/mystic_sacrificial_rite_invulnerability_status_effect.vpcf"
end

function modifier_mystic_sacrificial_rite_talent:StatusEffectPriority()
	return 20
end


function modifier_mystic_sacrificial_rite_talent:GetModifierTotalDamageOutgoing_Percentage()
	return self.dmgRed
end