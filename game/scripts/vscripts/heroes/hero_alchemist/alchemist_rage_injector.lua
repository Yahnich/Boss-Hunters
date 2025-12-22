alchemist_rage_injector = class({})

function alchemist_rage_injector:OnSpellStart()
    local caster = self:GetCaster()
    local does_refresh = self:GetSpecialValueFor("does_refresh") ~= 0

    caster:Purge(false, true, false, false, false)
    caster:AddNewModifier(caster, self, "modifier_alchemist_rage_injector_transform", { duration = self:GetSpecialValueFor("transformation_time") })

    if does_refresh then
        local unstable_concoction = caster:FindAbilityByName("alchemist_unstable_concoction")
        if unstable_concoction ~= nil then
            unstable_concoction:EndCooldown()
        end

        local berserk_potion = caster:FindAbilityByName("alchemist_berserk_potion")
        if berserk_potion ~= nil then
            berserk_potion:EndCooldown()
        end
    end

    -- sounds
    local sound = "Hero_Alchemist.ChemicalRage.Cast"
    EmitSoundOn(sound, caster)
end

modifier_alchemist_rage_injector_transform = class({})
LinkLuaModifier( "modifier_alchemist_rage_injector_transform", "heroes/hero_alchemist/alchemist_rage_injector", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_rage_injector_transform:IsHidden()
    return true
end
function modifier_alchemist_rage_injector_transform:IsPurgable()
    return false
end
function modifier_alchemist_rage_injector_transform:OnCreated()
    if IsClient() then return end

    if self:GetParent():GetUnitName() == "npc_dota_hero_alchemist" then
        self:GetParent():StartGesture(ACT_DOTA_alchemist_rage_injector_START)
    end
end
function modifier_alchemist_rage_injector_transform:OnDestroy()
    if IsClient() then return end

    local parent = self:GetParent()
    if parent:HasModifier("modifier_alchemist_rage_injector") then
        parent:RemoveModifierByName("modifier_alchemist_rage_injector")
    end
    parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_alchemist_rage_injector", { duration = self:GetSpecialValueFor("duration") })
end
function modifier_alchemist_rage_injector_transform:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true
    }
end

modifier_alchemist_rage_injector = class({})
LinkLuaModifier( "modifier_alchemist_rage_injector", "heroes/hero_alchemist/alchemist_rage_injector", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_rage_injector:IsHidden()
    return false
end
function modifier_alchemist_rage_injector:IsDebuff()
    return false
end
function modifier_alchemist_rage_injector:IsPurgable()
    return false
end
function modifier_alchemist_rage_injector:AllowIllusionDuplicate()
    return true
end
function modifier_alchemist_rage_injector:GetEffectName()
    return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage.vpcf"
end
function modifier_alchemist_rage_injector:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_alchemist_rage_injector:GetStatusEffectName()
    return "particles/status_fx/status_effect_chemical_rage.vpcf"
end
function modifier_alchemist_rage_injector:StatusEffectPriority()
    return 10
end
function modifier_alchemist_rage_injector:GetHeroEffectName()
    return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage_hero_effect.vpcf"
end
function modifier_alchemist_rage_injector:HeroEffectPriority()
    return 10
end
function modifier_alchemist_rage_injector:OnCreated()
    self:SetHasCustomTransmitterData(true)
    self:OnRefresh()
    self.elapsed_time = 0
end
function modifier_alchemist_rage_injector:OnRefresh()
    self.parent = self:GetParent()
    self.bonus_health_regen = self:GetSpecialValueFor("bonus_health_regen")
    self.bonus_movespeed = self:GetSpecialValueFor("bonus_movespeed")
    self.base_attack_time = self:GetSpecialValueFor("base_attack_time")

    self.bonus_armor = self:GetSpecialValueFor("bonus_armor")
    self.bonus_health = self:GetSpecialValueFor("bonus_health")
    self.bonus_debuff_amp = self:GetSpecialValueFor("bonus_debuff_amp")
    self.bonus_aoe = self:GetSpecialValueFor("bonus_aoe")
    self.bonus_damage_per_second = self:GetSpecialValueFor("bonus_damage_per_second")
    self.cooldown_reduction = self:GetSpecialValueFor("cooldown_reduction") / 100
    self.bonus_unstable_damage_tooltip = 1+self:GetSpecialValueFor("bonus_unstable_damage_tooltip") / 100
    self.update_potions = self:GetSpecialValueFor("bonus_unstable_damage_tooltip") > 0
    self.silence_immune = self:GetSpecialValueFor("silence_immune") > 0

	if self.bonus_aoe > 0 then
		self:GetCaster()._aoeModifiersList = self:GetCaster()._aoeModifiersList or {}
		self:GetCaster()._aoeModifiersList[self] = true
	end
    if IsClient() then return end
    self.elapsed_time = 0
    self:StartIntervalThink(1.0)

    -- sounds
    self.sound = "Hero_Alchemist.ChemicalRage"
    EmitSoundOn(self.sound, self.parent)
	
end
function modifier_alchemist_rage_injector:OnDestroy()
    if IsClient() then return end

    if self.parent:GetUnitName() == "npc_dota_hero_alchemist" then
        self.parent:StartGesture(ACT_DOTA_alchemist_rage_injector_END)
    end
    
    StopSoundOn(self.sound, self.parent)
end
function modifier_alchemist_rage_injector:OnIntervalThink()
    self.elapsed_time = self.elapsed_time + 1
    self:SendBuffRefreshToClients()

    if self.cooldown_reduction ~= 0 then
        local unstable_concoction = self.parent:FindAbilityByName("alchemist_unstable_concoction")
        if unstable_concoction ~= nil and unstable_concoction:GetCooldownTimeRemaining() > 0 then
            unstable_concoction:ModifyCooldown(-self.cooldown_reduction)
        end

        local berserk_potion = self.parent:FindAbilityByName("alchemist_berserk_potion")
        if berserk_potion ~= nil and berserk_potion:GetCooldownTimeRemaining() > 0 then
            berserk_potion:ModifyCooldown(-self.cooldown_reduction)
        end
    end
end
function modifier_alchemist_rage_injector:CheckState()
	if self.silence_immune then
    return {[MODIFIER_STATE_SILENCED] = false }
	end
end
function modifier_alchemist_rage_injector:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, 
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE, 
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_AOE_BONUS_CONSTANT_STACKING,
		MODIFIER_PROPERTY_MAX_DEBUFF_DURATION 
    }
end


function modifier_alchemist_rage_injector:GetModifierOverrideAbilitySpecial(params)
	if not self.update_potions then return end
	if params.ability:GetAbilityName() == "alchemist_unstable_concoction" or params.ability:GetAbilityName() == "alchemist_unstable_concoction_throw"  then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "min_stun" or specialValue == "max_stun" or specialValue == "min_damage" or specialValue == "max_damage" or specialValue == "barrier" then
			return 1
		end
	elseif params.ability:GetAbilityName() == "alchemist_berserk_potion" then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "hp_regen" or specialValue == "attack_speed" or specialValue == "move_speed" then
			return 1
		end
	end
end

function modifier_alchemist_rage_injector:GetModifierOverrideAbilitySpecialValue(params)
	if not self.update_potions then return end
	if params.ability:GetAbilityName() == "alchemist_unstable_concoction" or params.ability:GetAbilityName() == "alchemist_unstable_concoction_throw"  then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "min_stun" or specialValue == "max_stun" or specialValue == "min_damage" or specialValue == "max_damage" or specialValue == "barrier" then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			return flBaseValue * self.bonus_unstable_damage_tooltip
		end
	elseif params.ability:GetAbilityName() == "alchemist_berserk_potion" then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "hp_regen" or specialValue == "attack_speed" or specialValue == "move_speed" then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			return flBaseValue * self.bonus_unstable_damage_tooltip
		end
	end
end

function modifier_alchemist_rage_injector:GetModifierAoEBonusConstantStacking()
    return self.bonus_aoe
end
function modifier_alchemist_rage_injector:GetModifierMaxDebuffDuration()
    return self.bonus_debuff_amp
end
function modifier_alchemist_rage_injector:GetModifierConstantHealthRegen()
    return self.bonus_health_regen
end
function modifier_alchemist_rage_injector:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_movespeed
end
function modifier_alchemist_rage_injector:GetModifierBaseAttackTimeConstant()
    return self.base_attack_time
end
function modifier_alchemist_rage_injector:GetActivityTranslationModifiers()
    return "chemical_rage"
end
function modifier_alchemist_rage_injector:GetAttackSound()
    return "Hero_Alchemist.ChemicalRage.Attack"
end
function modifier_alchemist_rage_injector:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end
function modifier_alchemist_rage_injector:GetModifierHealthBonus()
    return self.bonus_health
end
function modifier_alchemist_rage_injector:GetModifierBaseDamageOutgoing_Percentage()
    return self.bonus_damage_per_second * self.elapsed_time
end
function modifier_alchemist_rage_injector:AddCustomTransmitterData()
    return {
        elapsed_time = tonumber(self.elapsed_time)
    }
end
function modifier_alchemist_rage_injector:HandleCustomTransmitterData(data)
    self.elapsed_time = tonumber(data.elapsed_time)
end