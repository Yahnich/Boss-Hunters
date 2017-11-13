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

if Stats == nil then
	Stats = class({})
end

function Stats:constructor(hero)
	self.customIntellect = hero:GetBaseIntellect()
	self.customStrength = hero:GetBaseStrength()
	self.customAgility = hero:GetBaseAgility()
	self.customVitality = hero:GetBaseVitality()
	self.customLuck = hero:GetBaseLuck()
	
	self.customIntellectGain = hero:GetIntellectGain()
	self.customStrengthGain = hero:GetStrengthGain()
	self.customAgilityGain = hero:GetAgilityGain()
	self.customVitalityGain = hero:GetVitalityGain()
	self.customLuckGain = hero:GetLuckGain()
end

function Stats:ManageStats(hero)
	local data = CustomNetTables:GetTableValue("hero_properties", hero:GetUnitName()..hero:entindex() ) or {}
	self.customIntellect = hero:GetBaseIntellect() + hero:GetLevel() * hero:GetIntellectGain()
	self.customStrength = hero:GetBaseStrength() + hero:GetLevel() * hero:GetStrengthGain()
	self.customAgility = hero:GetBaseAgility() + hero:GetLevel() * hero:GetAgilityGain()
	self.customVitality = hero:GetBaseVitality() + hero:GetLevel() * hero:GetVitalityGain()
	self.customLuck = hero:GetBaseLuck() + hero:GetLevel() * hero:GetLuckGain()
	
	for _, modifier in ipairs(hero:FindAllModifiers()) do
		if modifier.GetModifierBonusStats_Strength and modifier:GetModifierBonusStats_Strength() then
			self.customStrength = self.customStrength + modifier:GetModifierBonusStats_Strength()
		end
		if modifier.GetModifierBonusStats_Intellect and modifier:GetModifierBonusStats_Intellect() then
			self.customIntellect = self.customIntellect + modifier:GetModifierBonusStats_Intellect()
		end
		if modifier.GetModifierBonusStats_Agility and modifier:GetModifierBonusStats_Agility() then
			self.customAgility = self.customAgility + modifier:GetModifierBonusStats_Agility()
		end
		if modifier.GetModifierBonusStats_Luck and modifier:GetModifierBonusStats_Luck() then
			self.customLuck = self.customLuck + modifier:GetModifierBonusStats_Luck()
		end
		if modifier.GetModifierBonusStats_Vitality and modifier:GetModifierBonusStats_Vitality() then
			self.customVitality = self.customVitality + modifier:GetModifierBonusStats_Vitality()
		end
	end
	
	data.intellect = self.customIntellect
	data.strength = self.customStrength
	data.agility = self.customAgility
	-- data.vitality = self.customVitality
	-- data.luck = self.customLuck
	
	hero:AddNewModifier(hero, nil, "modifier_stat_handler", {})

	Timers:CreateTimer(function() CustomNetTables:SetTableValue("hero_properties", hero:GetUnitName()..hero:entindex(), data ) end)
end

modifier_stat_handler = class({})
LinkLuaModifier("modifier_stat_handler", "stats.lua", 0)

function modifier_stat_handler:OnCreated()
    self.HP_PER_STR = 21
	self.HP_REGEN_PER_STR = 0.12
	self.MR_PER_STR = 0.1
	
	self.ARMOR_PER_AGI = 0.07
	self.ATKSPD_PER_AGI = 1
	self.MS_PER_AGI = 0.1
	
	self.MANA_PER_INT = 12
	self.MANA_REGEN_PER_INT = 0.08
	self.SPELL_AMP_PER_INT = 0.05
	
	self.intelligence = self:GetParent():GetIntellect()
	self.strength = self:GetParent():GetStrength()
	self.agility = self:GetParent():GetAgility()
end

function modifier_stat_handler:OnRefresh()
    self.intelligence = self:GetParent():GetIntellect()
	self.strength = self:GetParent():GetStrength()
	self.agility = self:GetParent():GetAgility()
end

function modifier_stat_handler:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    }

    return funcs
end

function modifier_stat_handler:GetModifierBaseAttack_BonusDamage()
	local parent = self:GetParent()
	if parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
		return parent:GetStrength()
	elseif parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
		return parent:GetAgility()
	elseif parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
		return parent:GetIntellect()
	end
end

function modifier_stat_handler:GetModifierHealthBonus( params )
    return self.strength * self.HP_PER_STR
end

function modifier_stat_handler:GetModifierConstantHealthRegen( params )
    return self.strength * self.HP_REGEN_PER_STR
end

function modifier_stat_handler:GetModifierMagicalResistanceBonus( params )
    return self.strength * self.MR_PER_STR
end

function modifier_stat_handler:GetModifierPhysicalArmorBonus( params )
    return self.agility * self.ARMOR_PER_AGI
end

function modifier_stat_handler:GetModifierAttackSpeedBonus_Constant( params )
    return self.agility * self.ATKSPD_PER_AGI
end

function modifier_stat_handler:GetModifierMoveSpeedBonus_Constant( params )
    return self.agility * self.MS_PER_AGI
end

function modifier_stat_handler:GetModifierConstantManaRegen( params )
    return self.intelligence * self.MANA_REGEN_PER_INT
end

function modifier_stat_handler:GetModifierManaBonus( params )
    return self.intelligence * self.MANA_PER_INT
end

function modifier_stat_handler:GetModifierSpellAmplify_Percentage( params )
    return self.intelligence * self.SPELL_AMP_PER_INT
end

function modifier_stat_handler:IsHidden()
    return true
end

function modifier_stat_handler:AllowIllusionDuplicate()
    return true
end

function modifier_stat_handler:RemoveOnDeath()
    return false
end

function modifier_stat_handler:IsPurgable()
    return false
end