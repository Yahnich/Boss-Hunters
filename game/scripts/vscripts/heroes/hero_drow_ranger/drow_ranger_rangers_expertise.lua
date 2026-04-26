drow_ranger_rangers_expertise = class({})

function drow_ranger_rangers_expertise:GetIntrinsicModifierName()
    return "modifier_drow_ranger_rangers_expertise"
end

function drow_ranger_rangers_expertise:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		caster:PerformAbilityAttack(target, true, self, (caster:GetAttackDamage() * self:GetSpecialValueFor("split_damage_reduction")/100) * (-1))
	end
end

modifier_drow_ranger_rangers_expertise = class({})
LinkLuaModifier("modifier_drow_ranger_rangers_expertise", "heroes/hero_drow_ranger/drow_ranger_rangers_expertise", LUA_MODIFIER_MOTION_NONE)

function modifier_drow_ranger_rangers_expertise:IsHidden()
    return self:GetStackCount() == 0
end

function modifier_drow_ranger_rangers_expertise:OnCreated()
    self:OnRefresh()
end

function modifier_drow_ranger_rangers_expertise:OnRefresh()
    self.markCDR = self:GetSpecialValueFor("huntress_mark_cd")
    self.frozen_breath_damage = self:GetSpecialValueFor("frozen_breath_damage")
    self.volley_extra_salvos = self:GetSpecialValueFor("volley_extra_salvos")
    self.volley_extra_arrows = self:GetSpecialValueFor("volley_extra_arrows")

    self.chill_buff_radius = self:GetSpecialValueFor("chill_buff_radius")
    self.minion_bonus = self:GetSpecialValueFor("minion_bonus")
    self.monster_bonus = self:GetSpecialValueFor("monster_bonus")
    self.boss_bonus = self:GetSpecialValueFor("boss_bonus")

    if self.chill_buff_radius ~= 0 then
        self:StartIntervalThink(0.1)
    end
end

function modifier_drow_ranger_rangers_expertise:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()

    local totalBuff  = 0
    if not IsServer() then return end
    for _, enemies in ipairs(caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.chill_buff_radius)) do
        if enemies:IsFrozen()  then
            if enemies:IsBoss() then
                totalBuff = totalBuff + self.boss_bonus
            else
                if enemies:IsMinion() then
                    totalBuff = totalBuff + self.minion_bonus
                else
                    totalBuff = totalBuff + self.monster_bonus
                end
            end
        end
    end
    self:SetStackCount(totalBuff)
end

function modifier_drow_ranger_rangers_expertise:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
        MODIFIER_PROPERTY_TOOLTIP
    }
end

function modifier_drow_ranger_rangers_expertise:OnTooltip()
    return self:GetStackCount()
end

function modifier_drow_ranger_rangers_expertise:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount()
end

function modifier_drow_ranger_rangers_expertise:GetModifierPercentageCooldownStacking()
    return 100 * (100/100+self:GetStackCount())
end

function modifier_drow_ranger_rangers_expertise:GetModifierOverrideAbilitySpecial(params)
    if params.ability:GetName() == "drow_ranger_huntress_mark"
    or params.ability:GetName() == "drow_ranger_volley_of_arrows" then
        local caster = params.ability:GetCaster()
        local specialValue = params.ability_special_value
        if specialValue == "AbilityCooldown"
        or specialValue == "arrow_count"
        or specialValue == "salvos"
        then
            return 1
        end
    end
end

--fix this, it's stacking
function modifier_drow_ranger_rangers_expertise:GetModifierOverrideAbilitySpecialValue(params)
    if params.ability:GetName() == "drow_ranger_huntress_mark"
    or params.ability:GetName() == "drow_ranger_volley_of_arrows" then
        local caster = params.ability:GetCaster()
        local specialValue = params.ability_special_value
        if specialValue == "AbilityCooldown" and params.ability:GetName() == "drow_ranger_huntress_mark" then
            local flBaseValue = params.ability:GetLevelSpecialValueNoOverride(specialValue, params.ability_special_level)
            return flBaseValue - self.markCDR
        elseif specialValue == "arrow_count" and params.ability:GetName() == "drow_ranger_volley_of_arrows" then
            local flBaseValue = params.ability:GetLevelSpecialValueNoOverride(specialValue, params.ability_special_level)
            return flBaseValue + self.volley_extra_arrows
        elseif specialValue == "salvos" and params.ability:GetName() == "drow_ranger_volley_of_arrows" then
            local flBaseValue = params.ability:GetLevelSpecialValueNoOverride(specialValue, params.ability_special_level)
            return flBaseValue + self.volley_extra_salvos
        end
    end
    --[[
    if params.ability:GetName() == "drow_ranger_volley_of_arrows" then
        local specialValue = params.ability_special_value
        if specialValue == "arrows_per_salvo" then
            local flBaseValue = params.ability:GetLevelSpecialValueNoOverride(specialValue, params.ability_special_level)
            return flBaseValue + self.volley_extra_arrows
        end
    end]]

end

function modifier_drow_ranger_rangers_expertise:GetModifierProcAttack_BonusDamage_Magical(params)
    if params.attacker == self:GetParent() then
        if params.target:HasModifier("modifier_drow_ranger_frozen_breath_re") then
            return self.frozen_breath_damage
        else
            return 0
        end
    end
end

function modifier_drow_ranger_rangers_expertise:OnAttackLanded(params)
	if params.attacker == self:GetParent() and not params.attacker.autoAttackFromAbilityState and self:GetSpecialValueFor("split_count") ~= 0 then
		local caster = self:GetCaster()
		local count = self:GetSpecialValueFor("split_count")
		local radius = self:GetSpecialValueFor("split_range")

        for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), radius ) ) do
			if enemy ~= params.target then
                local projTable = {
					EffectName = "particles/units/heroes/hero_drow/drow_base_attack.vpcf",
					Ability = self:GetAbility(),
					Target = enemy,
					Source = params.target,
					bDodgeable = true,
					bProvidesVision = false,
					vSpawnOrigin = params.target:GetAbsOrigin(),
					iMoveSpeed = caster:GetProjectileSpeed(),
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
				}
				ProjectileManager:CreateTrackingProjectile( projTable )
				count = count - 1
				if count == 0 then break end
			end
		end
    end
end