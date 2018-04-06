boss_broodmother_arachnids_hunger = class({})

function boss_broodmother_arachnids_hunger:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_status_immunity", {duration = self:GetCastPoint() - 0.01})
	caster:AddNewModifier(caster, self, "modifier_boss_broodmother_arachnids_hunger_active", {duration = self:GetCastPoint()})
	ParticleManager:FireTargetWarningParticle(caster)
	return true
end

function boss_broodmother_arachnids_hunger:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_boss_broodmother_arachnids_hunger_active", {duration = self:GetSpecialValueFor("duration")})
end

modifier_boss_broodmother_arachnids_hunger_active = class({})
LinkLuaModifier("modifier_boss_broodmother_arachnids_hunger_active", "bosses/boss_broodmother/boss_broodmother_arachnids_hunger", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_broodmother_arachnids_hunger_active:OnCreated()
	self.dmg = self:GetSpecialValueFor("damage")
	self.as = self:GetSpecialValueFor("attack_speed")
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
	self.ms = self:GetParent():GetIdealSpeedNoSlows()
	self:StartIntervalThink(0.5)
	if IsServer() then
		local hFX = ParticleManager:CreateParticle("particles/bosses/boss_broodmother/boss_broodmother_hunger_buff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(hFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(hFX)
	end
end

function modifier_boss_broodmother_arachnids_hunger_active:OnIntervalThink()
	self.ms = self:GetParent():GetIdealSpeedNoSlows()
end

function modifier_boss_broodmother_arachnids_hunger_active:OnRefresh()
	self.dmg = self:GetSpecialValueFor("damage")
	self.as = self:GetSpecialValueFor("attack_speed")
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
end

function modifier_boss_broodmother_arachnids_hunger_active:CheckState()
	return {[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_DISARMED] = false,
			[MODIFIER_STATE_SILENCED] = false,
			[MODIFIER_STATE_MUTED] = false,
			[MODIFIER_STATE_STUNNED] = false,
			[MODIFIER_STATE_HEXED] = false,
			[MODIFIER_STATE_FROZEN] = false,
			[MODIFIER_STATE_PASSIVES_DISABLED] = false}
end

function modifier_boss_broodmother_arachnids_hunger_active:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_boss_broodmother_arachnids_hunger_active:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
				MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
				MODIFIER_EVENT_ON_TAKEDAMAGE
			}
	return funcs
end

function modifier_boss_broodmother_arachnids_hunger_active:GetModifierDamageOutgoing_Percentage()
	return self.dmg
end

function modifier_boss_broodmother_arachnids_hunger_active:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_boss_broodmother_arachnids_hunger_active:GetModifierMoveSpeed_AbsoluteMin()
	return self.ms
end

function modifier_boss_broodmother_arachnids_hunger_active:OnTakeDamage(params)
	if IsServer() then
		if params.attacker == self:GetParent() and not params.inflictor then
			local flHeal = params.damage * self.lifesteal
			params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
		end
	end
end

function modifier_boss_broodmother_arachnids_hunger_active:GetHeroEffectName()
	return "particles/units/heroes/hero_broodmother/broodmother_hunger_hero_effect.vpcf"
end

function modifier_boss_broodmother_arachnids_hunger_active:HeroEffectPriority()
	return 10
end