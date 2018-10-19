bh_shadow_walk = class({})
LinkLuaModifier( "modifier_bh_shadow_walk", "heroes/hero_bounty_hunter/bh_shadow_walk.lua" ,LUA_MODIFIER_MOTION_NONE )

function bh_shadow_walk:OnSpellStart()
	local caster = self:GetCaster()
	local fadeTime = self:GetTalentSpecialValueFor("fade_time")

	if caster:HasTalent("special_bonus_unique_bh_shadow_walk_2") then
		fadeTime = 0

		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), 300)
		for _,enemy in pairs(enemies) do
			enemy:Blind(50, self, caster, 3)
		end
	end

	EmitSoundOn("Hero_BountyHunter.WindWalk", caster)

	ParticleManager:FireParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", PATTACH_POINT, caster, {})

	Timers:CreateTimer(fadeTime, function()
		caster:AddNewModifier(caster, self, "modifier_bh_shadow_walk", {Duration = self:GetTalentSpecialValueFor("duration")})
	end)

	self:StartDelayedCooldown(self:GetTalentSpecialValueFor("duration"))
end

modifier_bh_shadow_walk = class({})
function modifier_bh_shadow_walk:OnCreated(table)
    self.damage = self:GetTalentSpecialValueFor("damage")

	if IsServer() then self:GetCaster():CalculateStatBonus() end
end

function modifier_bh_shadow_walk:OnRefresh(table)
    self.damage = self:GetTalentSpecialValueFor("damage")

	if IsServer() then self:GetCaster():CalculateStatBonus() end
end

function modifier_bh_shadow_walk:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }

    return funcs
end

function modifier_bh_shadow_walk:CheckState()
	local state = { [MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	return state
end

function modifier_bh_shadow_walk:OnAbilityExecuted(params)
	if IsServer() then
		local parent = self:GetParent()
		local unit = params.unit
		local ability = params.ability

		if unit == parent then
			if parent:HasTalent("special_bonus_unique_bh_shadow_walk_1") and ability:GetAbilityName() == "bh_shuriken" then
				self:GetAbility():DealDamage(parent, ability:GetCursorTarget(), self.damage, {}, OVERHEAD_ALERT_DAMAGE)
			end

			self:GetAbility():EndDelayedCooldown()
			self:Destroy()
		end
	end
end

function modifier_bh_shadow_walk:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:GetAbility():DealDamage(self:GetParent(), params.target, self.damage, {}, OVERHEAD_ALERT_DAMAGE)
			self:GetAbility():EndDelayedCooldown()
			self:Destroy()
		end
	end
end

function modifier_bh_shadow_walk:GetModifierInvisibilityLevel()
    return 1
end

function modifier_bh_shadow_walk:IsHidden()
    return false
end

function modifier_bh_shadow_walk:IsPurgable()
    return false
end

function modifier_bh_shadow_walk:IsPurgeException()
    return false
end

function modifier_bh_shadow_walk:IsDebuff()
    return false
end

function modifier_bh_shadow_walk:GetEffectName()
    return "particles/generic_hero_status/status_invisibility_start.vpcf"
end