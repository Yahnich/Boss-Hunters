lifestealer_infest_bh = class({})

function lifestealer_infest_bh:IsStealable()
    return false
end

function lifestealer_infest_bh:IsHiddenWhenStolen()
    return false
end

function lifestealer_infest_bh:GetCastPoint()
    if self:GetCaster():HasModifier("modifier_lifestealer_infest_bh") then
        return 0
    else
        return 0.2
    end
end

function lifestealer_infest_bh:GetManaCost(iLvl)
    if self:GetCaster():HasModifier("modifier_lifestealer_infest_bh") then
        return 0
    else
        return self.BaseClass.GetManaCost( self, iLvl )
    end
end

function lifestealer_infest_bh:GetCooldown(iLvl)
    if self:GetCaster():HasModifier("modifier_lifestealer_infest_bh") or IsClient() then
        return self.BaseClass.GetCooldown( self, iLvl )
    else
        return 0
    end
end

function lifestealer_infest_bh:GetCastAnimation()
    if self:GetCaster():HasModifier("modifier_lifestealer_infest_bh") then
        return ACT_DOTA_LIFESTEALER_INFEST
    else
        return ACT_DOTA_LIFESTEALER_INFEST_END
    end
end


function lifestealer_infest_bh:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_lifestealer_infest_bh") then
        return "life_stealer_consume"
    else
        return "life_stealer_infest"
    end
end



function lifestealer_infest_bh:GetBehavior()
    if self:GetCaster():HasModifier("modifier_lifestealer_infest_bh") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    else
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
end

function lifestealer_infest_bh:OnOwnerDied()
    if self.target then
        self.target:RemoveModifierByName("modifier_lifestealer_infest_bh_ally")
    end
end

function lifestealer_infest_bh:OnSpellStart()
    local caster = self:GetCaster()

    if caster:HasModifier("modifier_lifestealer_infest_bh") then
		caster:RemoveModifierByName("modifier_lifestealer_infest_bh")
    else
        self.target = self:GetCursorTarget()
		local duration = -1
        if not self.target:HasModifier("modifier_lifestealer_assimilate_bh_ally") then
            ParticleManager:FireParticle("particles/units/heroes/hero_life_stealer/life_stealer_loadout.vpcf", PATTACH_POINT, self.target, {[0]=caster:GetAbsOrigin(), [1]=self.target:GetAbsOrigin()})
			if self.target:IsSameTeam( caster ) then
				self.target:AddNewModifier(caster, self, "modifier_lifestealer_infest_bh_ally", {})
			elseif not self.target:IsMinion() then
				duration = self:GetTalentSpecialValueFor("duration")
			end
			caster:AddNewModifier(caster, self, "modifier_lifestealer_infest_bh", {duration = duration + 0.1})
        end
    end
end

function lifestealer_infest_bh:GetCastRange(location, target)
    return self:GetCaster():GetAttackRange()
end

modifier_lifestealer_infest_bh = class({})
LinkLuaModifier("modifier_lifestealer_infest_bh", "heroes/hero_lifestealer/lifestealer_infest_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lifestealer_infest_bh:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("aoe_damage")
	self.regen = self:GetTalentSpecialValueFor("max_hp_regen")
	
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_lifestealer_infest_2")
    if IsServer() then
		self.target = self:GetAbility():GetCursorTarget()
        self:GetParent():AddNoDraw()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_lifestealer_infest_bh:OnRemoved()
    if IsServer() then
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
        parent:RemoveNoDraw()
        ParticleManager:FireParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_POINT, ability.target, {[0]=ability.target:GetAbsOrigin()})
        FindClearSpaceForUnit(parent, parentPos, false)
        local enemies = parent:FindEnemyUnitsInRadius(parentPos, self:GetTalentSpecialValueFor("radius"))
        for _,enemy in pairs(enemies) do
            ability:DealDamage(parent, enemy, self.damage)
        end
        ability.target:RemoveModifierByName("modifier_lifestealer_infest_bh_ally")
		if self.talent2 then
			parent:RefreshAllCooldowns(true, true)
		end
    end
end

function modifier_lifestealer_infest_bh:OnIntervalThink()
	if self:GetAbility().target and self:GetAbility().target:IsAlive() and self:GetRemainingTime() > 0.1 then
		self:GetCaster():SetAbsOrigin(self:GetAbility().target:GetAbsOrigin())
	else
		self:GetAbility():CastSpell()
	end
end

function modifier_lifestealer_infest_bh:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_ROOTED] = true,
                    [MODIFIER_STATE_DISARMED] = true,
                    [MODIFIER_STATE_INVULNERABLE] = true}
    return state
end

function modifier_lifestealer_infest_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE }
end

function modifier_lifestealer_infest_bh:GetModifierHealthRegenPercentage()
	return self.regen
end


function modifier_lifestealer_infest_bh:GetModifierTotalPercentageManaRegen()
	if self.talent2 then
		return self.regen
	end
end


function modifier_lifestealer_infest_bh:IsDebuff()
    return false
end

modifier_lifestealer_infest_bh_ally = class({})
LinkLuaModifier("modifier_lifestealer_infest_bh_ally", "heroes/hero_lifestealer/lifestealer_infest_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lifestealer_infest_bh_ally:OnCreated()
	self.bonus_hp = self:GetTalentSpecialValueFor("ally_bonus_hp")
	
	if IsServer() then -- heal
		self:GetParent():HealEvent( self.bonus_hp, self:GetAbility(), self:GetCaster(), {heal_flags = HEAL_FLAG_IGNORE_AMPLIFICATION} )
	end
end

function modifier_lifestealer_infest_bh_ally:DeclareFunctions()
	return { MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS }
end

function modifier_lifestealer_infest_bh_ally:GetModifierExtraHealthBonus()
	return self.bonus_hp
end

function modifier_lifestealer_infest_bh_ally:IsDebuff()
    return false
end

function modifier_lifestealer_infest_bh_ally:GetEffectName()
    return "particles/units/heroes/hero_life_stealer/life_stealer_infested_unit.vpcf"
end

function modifier_lifestealer_infest_bh_ally:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end