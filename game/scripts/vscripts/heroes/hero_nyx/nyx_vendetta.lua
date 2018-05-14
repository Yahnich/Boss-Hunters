nyx_vendetta = class({})
LinkLuaModifier( "modifier_nyx_vendetta", "heroes/hero_nyx/nyx_vendetta.lua" ,LUA_MODIFIER_MOTION_NONE )

function nyx_vendetta:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_NyxAssassin.Vendetta", caster)

	ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_loadout.vpcf", PATTACH_POINT, caster, {})
	caster:AddNewModifier(caster, self, "modifier_nyx_vendetta", {Duration = self:GetTalentSpecialValueFor("duration")})

	self:StartDelayedCooldown(self:GetTalentSpecialValueFor("duration"))
end

modifier_nyx_vendetta = class({})
function modifier_nyx_vendetta:OnCreated(table)
    self.move = self:GetSpecialValueFor("movement_speed")
    self.damage = self:GetSpecialValueFor("damage")

	if IsServer() then self:GetCaster():CalculateStatBonus() end
end

function modifier_nyx_vendetta:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }

    return funcs
end

function modifier_nyx_vendetta:CheckState()
	local state = { [MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}

	if self:GetCaster():HasTalent("special_bonus_unique_nyx_vendetta_1") then
		state = { [MODIFIER_STATE_INVISIBLE] = true,
				  [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
				  [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	end
	return state
end

function modifier_nyx_vendetta:OnAbilityExecuted(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_nyx_vendetta:OnAttackStart(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			StartAnimation(self:GetParent(), {duration=self:GetParent():GetSecondsPerAttack(), activity=ACT_DOTA_ATTACK, rate=1/self:GetParent():GetSecondsPerAttack(), translate="vendetta"})
		end
	end
end

function modifier_nyx_vendetta:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			EmitSoundOn("Hero_NyxAssassin.Vendetta.Crit", params.target)
			if self:GetParent():HasModifier("modifier_nyx_burrow") then
				ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_impale_hit.vpcf", PATTACH_POINT, self:GetParent(), {[0]=params.target:GetAbsOrigin()})
			end
			ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_POINT, params.attacker, {[1]=params.target:GetAbsOrigin()})
			self:GetAbility():DealDamage(self:GetParent(), params.target, self.damage, {}, OVERHEAD_ALERT_DAMAGE)
			self:Destroy()
		end
	end
end

function modifier_nyx_vendetta:GetModifierInvisibilityLevel()
    return 1
end

function modifier_nyx_vendetta:GetModifierMoveSpeedBonus_Percentage()
    return self.move
end

function modifier_nyx_vendetta:GetModifierBonusStats_Intellect()
    if self:GetCaster():HasTalent("special_bonus_unique_nyx_vendetta_2") then
    	return self:GetCaster():FindTalentValue("special_bonus_unique_nyx_vendetta_2")
    end
end

function modifier_nyx_vendetta:GetModifierAttackRangeBonus()
	if self:GetParent():HasModifier("modifier_nyx_burrow") then
		return self:GetSpecialValueFor("attack_range")
	end
end

function modifier_nyx_vendetta:IsHidden()
    return false
end

function modifier_nyx_vendetta:IsPurgable()
    return false
end

function modifier_nyx_vendetta:IsPurgeException()
    return false
end

function modifier_nyx_vendetta:IsDebuff()
    return false
end

function modifier_nyx_vendetta:GetEffectName()
    return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_speed.vpcf"
end