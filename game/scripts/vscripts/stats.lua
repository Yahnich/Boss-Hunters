-- Custom Stat Values
HP_PER_STR = 18
MR_PER_STR = 0.4
HP_REGEN_PER_STR = 0.025
MANA_PER_INT = 10
MANA_REGEN_PER_INT = 0.035
ARMOR_PER_AGI = 0.07
ATKSPD_PER_AGI = 0.08
DMG_PER_AGI = 0.5
CDR_PER_INT = 0.385
SPELL_AMP_PER_INT = 0.0075

-- Default Dota Values
DEFAULT_HP_PER_STR = 20
DEFAULT_HP_REGEN_PER_STR = 0.03
DEFAULT_MANA_PER_INT = 12
DEFAULT_MANA_REGEN_PER_INT = 0.01
DEFAULT_ARMOR_PER_AGI = 0.14
DEFAULT_ATKSPD_PER_AGI = 1.0
DEFAULT_SPELL_AMP_PER_INT = 0.0714

THINK_INTERVAL = 0.03

if stats == nil then
	stats = class({})
end

function stats:ModifyStatBonuses(unit)
	local hero = unit
	
	local armor_adjustment = math.abs(ARMOR_PER_AGI - DEFAULT_ARMOR_PER_AGI)
	local attackspeed_adjustment = math.abs(ATKSPD_PER_AGI - DEFAULT_ATKSPD_PER_AGI)
	local damage_adjustment = DMG_PER_AGI
	local spell_amp_adjustment = math.abs(SPELL_AMP_PER_INT - DEFAULT_SPELL_AMP_PER_INT)
	
	Timers:CreateTimer(function()

		if not IsValidEntity(hero) then return end
		if hero:IsIllusion() then return end
		
		-- Initialize value tracking
		if not hero.custom_stats then
			hero.custom_stats = true
			hero.customstrength = 0
			hero.customagility = 0
			hero.customintellect = 0
			hero.custommovespeed = 0
			hero.customarmor = hero:GetPhysicalArmorBaseValue()
			hero:SetBaseMagicalResistanceValue(0)
			hero.attackCapability = hero:IsRangedAttacker()
			hero.currentLevel = hero:GetLevel()
		end

		-- Get player attribute values
		local strength = hero:GetStrength()
		local agility = hero:GetAgility()
		local intellect = hero:GetIntellect()
		local movespeed = hero:GetIdealSpeed()
		
		-- Adjustments

		-- STR
		if strength ~= hero.customstrength then
			local mr_stacks = math.floor(strength^MR_PER_STR + 0.5)
			hero:SetBaseMagicalResistanceValue(mr_stacks)
		end

		-- AGI
		if agility ~= hero.customagility then
			local armor_stacks = agility * -armor_adjustment
			hero:SetPhysicalArmorBaseValue(hero.customarmor + armor_stacks)

			-- Attack Speed Bonus
			if not hero:HasModifier("modifier_stat_adjustment_as_per_agi") then
				hero:AddNewModifier(hero, nil, "modifier_stat_adjustment_as_per_agi", {})
			end

			local attackspeed_stacks = agility * attackspeed_adjustment
			hero:FindModifierByName("modifier_stat_adjustment_as_per_agi"):SetStackCount(attackspeed_stacks)
			
			if not hero:HasModifier("modifier_stat_adjustment_dmg_per_agi") then
				hero:AddNewModifier(hero, nil, "modifier_stat_adjustment_dmg_per_agi", {})
			end

			local damage_stacks = math.floor(agility * damage_adjustment + 0.5)
			hero:FindModifierByName("modifier_stat_adjustment_dmg_per_agi"):SetStackCount(damage_stacks)
		end

		-- INT
		if intellect ~= hero.customintellect then
			if not hero:HasModifier("modifier_stat_adjustment_cdr_per_int") then
				hero:AddNewModifier(hero, nil, "modifier_stat_adjustment_cdr_per_int", {})
			end

			local cdr = 1 - math.floor(intellect ^ CDR_PER_INT + 0.5) / 100
			local octarine = get_core_cdr(hero)
			local cdr_stacks = math.floor((1 - (octarine * cdr))*100)
			hero:FindModifierByName("modifier_stat_adjustment_cdr_per_int"):SetStackCount(cdr_stacks)
			
			local spell_amp_stacks = math.floor(spell_amp_adjustment * intellect + 0.5)
			if not hero:HasModifier("modifier_stat_adjustment_amp_per_int") then
				hero:AddNewModifier(hero, nil, "modifier_stat_adjustment_amp_per_int", {})
			end
			hero:FindModifierByName("modifier_stat_adjustment_amp_per_int"):SetStackCount(spell_amp_stacks)
		end
		if hero:GetLevel() ~= hero.currentLevel or hero:IsRangedAttacker() ~= hero.attackCapability then
			if hero:IsRangedAttacker() then
				if not hero:HasModifier("modifier_stat_adjustment_range_ranged") then
					hero:AddNewModifier(hero, nil, "modifier_stat_adjustment_range_ranged", {})
				end
				hero:FindModifierByName("modifier_stat_adjustment_range_ranged"):SetStackCount(math.floor(2.5*hero:GetLevel() + 0.5) )
				if hero:HasModifier("modifier_stat_adjustment_armor_melee") then
					hero:RemoveModifierByName("modifier_stat_adjustment_armor_melee")
				end
			else
				if not hero:HasModifier("modifier_stat_adjustment_armor_melee") then
					hero:AddNewModifier(hero, nil, "modifier_stat_adjustment_armor_melee", {})
				end
				hero:FindModifierByName("modifier_stat_adjustment_armor_melee"):SetStackCount(math.floor(2.5*hero:GetLevel() + 0.5) )
				if hero:HasModifier("modifier_stat_adjustment_range_ranged") then
					hero:RemoveModifierByName("modifier_stat_adjustment_range_ranged")
				end
			end
		end

		-- Update the stored values for next timer cycle
		hero.customstrength = strength
		hero.customagility = agility
		hero.customintellect = intellect
		hero.custommovespeed = movespeed
		hero.attackCapability = hero:IsRangedAttacker()
		hero.currentLevel = hero:GetLevel()
		
		hero:CalculateStatBonus() -- update stat bonuses

		return THINK_INTERVAL
	end)
end

modifier_stat_adjustment_cdr_per_int = class({})
LinkLuaModifier("modifier_stat_adjustment_cdr_per_int", "stats.lua", 0)

function modifier_stat_adjustment_cdr_per_int:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE ,
    }

    return funcs
end

function modifier_stat_adjustment_cdr_per_int:GetModifierPercentageCooldown( params )
    return self:GetStackCount()
end

function modifier_stat_adjustment_cdr_per_int:IsHidden()
    return true
end

function modifier_stat_adjustment_cdr_per_int:AllowIllusionDuplicate()
    return true
end

function modifier_stat_adjustment_cdr_per_int:RemoveOnDeath()
    return false
end

function modifier_stat_adjustment_cdr_per_int:IsPurgable()
    return false
end

modifier_stat_adjustment_amp_per_int = class({})
LinkLuaModifier("modifier_stat_adjustment_amp_per_int", "stats.lua", 0)

function modifier_stat_adjustment_amp_per_int:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }

    return funcs
end

function modifier_stat_adjustment_amp_per_int:GetModifierSpellAmplify_Percentage()
    return self:GetStackCount() * -1
end

function modifier_stat_adjustment_amp_per_int:IsHidden()
    return true
end

function modifier_stat_adjustment_amp_per_int:AllowIllusionDuplicate()
    return true
end

function modifier_stat_adjustment_amp_per_int:RemoveOnDeath()
    return false
end

function modifier_stat_adjustment_amp_per_int:IsPurgable()
    return false
end

modifier_stat_adjustment_as_per_agi = class({})
LinkLuaModifier("modifier_stat_adjustment_as_per_agi", "stats.lua", 0)

function modifier_stat_adjustment_as_per_agi:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT ,
    }

    return funcs
end

function modifier_stat_adjustment_as_per_agi:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetStackCount() * -1
end

function modifier_stat_adjustment_as_per_agi:IsHidden()
    return true
end

function modifier_stat_adjustment_as_per_agi:AllowIllusionDuplicate()
    return true
end

function modifier_stat_adjustment_as_per_agi:RemoveOnDeath()
    return false
end

function modifier_stat_adjustment_as_per_agi:IsPurgable()
    return false
end

modifier_stat_adjustment_dmg_per_agi = class({})
LinkLuaModifier("modifier_stat_adjustment_dmg_per_agi", "stats.lua", 0)

function modifier_stat_adjustment_dmg_per_agi:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    }

    return funcs
end

function modifier_stat_adjustment_dmg_per_agi:GetModifierBaseAttack_BonusDamage( params )
    return self:GetStackCount()
end

function modifier_stat_adjustment_dmg_per_agi:IsHidden()
    return true
end

function modifier_stat_adjustment_dmg_per_agi:AllowIllusionDuplicate()
    return true
end

function modifier_stat_adjustment_dmg_per_agi:RemoveOnDeath()
    return false
end

function modifier_stat_adjustment_dmg_per_agi:IsPurgable()
    return false
end

modifier_stat_adjustment_range_ranged = class({})
LinkLuaModifier("modifier_stat_adjustment_range_ranged", "stats.lua", 0)

function modifier_stat_adjustment_range_ranged:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    }

    return funcs
end

function modifier_stat_adjustment_range_ranged:GetModifierAttackRangeBonus( params )
    return self:GetStackCount()
end

function modifier_stat_adjustment_range_ranged:IsHidden()
    return true
end

function modifier_stat_adjustment_range_ranged:AllowIllusionDuplicate()
    return true
end

function modifier_stat_adjustment_range_ranged:RemoveOnDeath()
    return false
end

function modifier_stat_adjustment_range_ranged:IsPurgable()
    return false
end

modifier_stat_adjustment_armor_melee = class({})
LinkLuaModifier("modifier_stat_adjustment_armor_melee", "stats.lua", 0)

function modifier_stat_adjustment_armor_melee:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS ,
    }

    return funcs
end

function modifier_stat_adjustment_armor_melee:GetModifierPhysicalArmorBonus( params )
    return self:GetStackCount()
end

function modifier_stat_adjustment_armor_melee:IsHidden()
    return true
end

function modifier_stat_adjustment_armor_melee:AllowIllusionDuplicate()
    return true
end

function modifier_stat_adjustment_armor_melee:RemoveOnDeath()
    return false
end

function modifier_stat_adjustment_armor_melee:IsPurgable()
    return false
end

function modifier_stat_adjustment_armor_melee:IsPermanent()
    return false
end