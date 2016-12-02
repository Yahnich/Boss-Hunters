-- Custom Stat Values
require( "libraries/Timers" )
HP_PER_STR = 18
MR_PER_STR = 0.4
HP_REGEN_PER_STR = 0.025
MANA_PER_INT = 10
MANA_REGEN_PER_INT = 0.035
ARMOR_PER_AGI = 0.06
ATKSPD_PER_AGI = 0.04
DMG_PER_INT = 0.5
MAX_MOVE_SPEED = 1500

-- Default Dota Values
DEFAULT_HP_PER_STR = 20
DEFAULT_HP_REGEN_PER_STR = 0.03
DEFAULT_MANA_PER_INT = 12
DEFAULT_MANA_REGEN_PER_INT = 0.01
DEFAULT_ARMOR_PER_AGI = 0.14
DEFAULT_ATKSPD_PER_AGI = 1.0

THINK_INTERVAL = 0.03

if stats == nil then
	stats = class({})
end

function stats:ModifyStatBonuses(unit)
	local hero = unit
	local applier = CreateItem("item_stat_modifier", nil, nil)

	local hp_adjustment = math.abs(HP_PER_STR - DEFAULT_HP_PER_STR)
	local hp_regen_adjustment = math.abs(HP_REGEN_PER_STR - DEFAULT_HP_REGEN_PER_STR)
	local mana_adjustment = math.abs(MANA_PER_INT - DEFAULT_MANA_PER_INT)
	local mana_regen_adjustment = math.abs(MANA_REGEN_PER_INT - DEFAULT_MANA_REGEN_PER_INT)
	local armor_adjustment = math.abs(ARMOR_PER_AGI - DEFAULT_ARMOR_PER_AGI)
	local attackspeed_adjustment = math.abs(ATKSPD_PER_AGI - DEFAULT_ATKSPD_PER_AGI)
	local damage_adjustment = DMG_PER_INT

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
			-- HP Bonus BREAKS THE FUCKING GAME UGH
			-- if not hero:HasModifier("modifier_health_bonus") then
				-- applier:ApplyDataDrivenModifier(hero, hero, "modifier_health_bonus", {})
			-- end
			-- local health_stacks = strength * hp_adjustment
			-- hero:SetModifierStackCount("modifier_health_bonus", hero, health_stacks)
			if not hero:HasModifier("modifier_magic_resistance_bonus") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_health_bonus", {})
			end
			local mr_stacks = math.floor(strength^MR_PER_STR + 0.5)
			hero:SetBaseMagicalResistanceValue(mr_stacks)
		end

		-- AGI
		if agility ~= hero.customagility then
			-- Armor Bonus
			-- if not hero:HasModifier("modifier_physical_armor_bonus") then
				-- applier:ApplyDataDrivenModifier(hero, hero, "modifier_physical_armor_bonus", {})
			-- end

			local armor_stacks = agility * -armor_adjustment
			hero:SetPhysicalArmorBaseValue(hero.customarmor + armor_stacks)

			-- Attack Speed Bonus
			if not hero:HasModifier("modifier_attackspeed_bonus_constant") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_attackspeed_bonus_constant", {})
			end

			local attackspeed_stacks = agility * attackspeed_adjustment
			hero:SetModifierStackCount("modifier_attackspeed_bonus_constant", hero, attackspeed_stacks)
		end

		-- INT
		if intellect ~= hero.customintellect then
			--damage boost per int
			-- if not hero:HasModifier("modifier_mana_bonus") then
				-- applier:ApplyDataDrivenModifier(hero, hero, "modifier_mana_bonus", {})
			-- end

			-- local mana_stacks = intellect * mana_adjustment
			-- hero:SetModifierStackCount("modifier_mana_bonus", hero, mana_stacks)
			
			if not hero:HasModifier("modifier_base_mana_regen") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_base_mana_regen", {})
			end

			local mana_regen_stacks = math.abs(intellect * mana_regen_adjustment)
			hero:SetModifierStackCount("modifier_base_mana_regen", hero, mana_regen_stacks)

			if not hero:HasModifier("modifier_base_damage") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_base_damage", {})
			end

			local damage_stacks = math.floor(intellect * damage_adjustment + 0.5)
			hero:SetModifierStackCount("modifier_base_damage", hero, damage_stacks)
		end
		if hero:GetLevel() ~= hero.currentLevel or hero:IsRangedAttacker() ~= hero.attackCapability then
			print(hero:GetLevel(), hero.currentLevel)
			if hero:IsRangedAttacker() then
				if not hero:HasModifier("modifier_ranged_bonus_constant") then
					applier:ApplyDataDrivenModifier(hero, hero, "modifier_ranged_bonus_constant", {})
				end
				hero:SetModifierStackCount("modifier_ranged_bonus_constant", hero, math.floor(2.5*hero:GetLevel() + 0.5) )
				if hero:HasModifier("modifier_melee_bonus_constant") then
					hero:RemoveModifierByName("modifier_melee_bonus_constant")
				end
			else
				if not hero:HasModifier("modifier_melee_bonus_constant") then
					applier:ApplyDataDrivenModifier(hero, hero, "modifier_melee_bonus_constant", {})
				end
				hero:SetModifierStackCount("modifier_melee_bonus_constant", hero, math.floor(2.5*hero:GetLevel() + 0.5) )
				if hero:HasModifier("modifier_ranged_bonus_constant") then
					hero:RemoveModifierByName("modifier_ranged_bonus_constant")
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