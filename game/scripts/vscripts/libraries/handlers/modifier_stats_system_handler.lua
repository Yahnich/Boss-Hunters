modifier_stats_system_handler = class({})

function modifier_stats_system_handler:OnCreated()
	self.statsInfo = {}
	if self:GetParent() ~= self:GetCaster() then
		self:GetParent().unitOwnerEntity = self:GetCaster()
	end
	self:GetParent().statsSystemHandlerModifier = self
	self.modifierFunctions = {}
	self.modifierFunctions["GetModifierBaseCriticalChanceBonus"] = {}
	self.modifierFunctions["GetModifierBaseCriticalDamageBonus"] = {}
	self.modifierFunctions["GetModifierDamageReflectPercentageBonus"] = {}
	self.modifierFunctions["GetModifierDamageReflectBonus"] = {}
	self.modifierFunctions["GetModifierLifestealBonus"] = {}
	self.modifierFunctions["GetModifierLifestealTargetBonus"] = {}
	self.modifierFunctions["GetModifierManacostReduction"] = {}
	self.modifierFunctions["GetModifierAttackSpeedBonus_Constant"] = {}
	self.modifierFunctions["GetModifierAttackSpeedLimitBonus"] = {}
	self.modifierFunctions["GetModifierAttackSpeedBonusPercentage"] = {}
	self.modifierFunctions["GetBaseAttackTimeOverride"] = {}
	self.modifierFunctions["GetBaseAttackTime_Bonus"] = {}
	self.modifierFunctions["GetBaseAttackTime_BonusPercentage"] = {}
	self.modifierFunctions["GetModifierExtraHealthBonusPercentage"] = {}
	self.modifierFunctions["GetMoveSpeedLimitBonus"] = {}
	self.modifierFunctions["GetModifierAreaDamage"] = {}
	self.modifierFunctions["GetModifierStrengthBonusPercentage"] = {}
	self.modifierFunctions["GetModifierAgilityBonusPercentage"] = {}
	self.modifierFunctions["GetModifierIntellectBonusPercentage"] = {}
	self.modifierFunctions["GetReincarnationDelay"] = {}
	if IsServer() then
		-- find all non-hooked functions on creation (mostly for illusions, but in case we missed any)
		for _, modifier in ipairs( self:GetParent():FindAllModifiers() ) do
			if modifier.GetModifierBaseCriticalChanceBonus then
				self.modifierFunctions["GetModifierBaseCriticalChanceBonus"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierBaseCriticalDamageBonus then
				self.modifierFunctions["GetModifierBaseCriticalDamageBonus"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierDamageReflectBonus then
				self.modifierFunctions["GetModifierDamageReflectBonus"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierDamageReflectPercentageBonus then
				self.modifierFunctions["GetModifierDamageReflectPercentageBonus"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierLifestealBonus then
				self.modifierFunctions["GetModifierLifestealBonus"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierLifestealTargetBonus then
				self.modifierFunctions["GetModifierLifestealTargetBonus"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierManacostReduction then
				self.modifierFunctions["GetModifierManacostReduction"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierAttackSpeedBonusPercentage then
				self.modifierFunctions["GetModifierAttackSpeedBonusPercentage"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierAttackSpeedLimitBonus then
				self.modifierFunctions["GetModifierAttackSpeedLimitBonus"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetBaseAttackTimeOverride then
				self.modifierFunctions["GetBaseAttackTimeOverride"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetBaseAttackTime_Bonus then
				self.modifierFunctions["GetBaseAttackTime_Bonus"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetBaseAttackTime_BonusPercentage then
				self.modifierFunctions["GetBaseAttackTime_BonusPercentage"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierExtraHealthBonusPercentage then
				self.modifierFunctions["GetModifierExtraHealthBonusPercentage"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetMoveSpeedLimitBonus then
				self.modifierFunctions["GetMoveSpeedLimitBonus"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierAreaDamage then
				self.modifierFunctions["GetModifierAreaDamage"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierStrengthBonusPercentage then
				self.modifierFunctions["GetModifierStrengthBonusPercentage"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierAgilityBonusPercentage then
				self.modifierFunctions["GetModifierAgilityBonusPercentage"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetModifierIntellectBonusPercentage then
				self.modifierFunctions["GetModifierIntellectBonusPercentage"][modifier] = modifier:GetPriority() or 1
			end
			if modifier.GetReincarnationDelay then
				self.modifierFunctions["GetReincarnationDelay"][modifier] = modifier:GetPriority() or 1
			end
		end
		self:UpdateStatValues()
		self:SetHasCustomTransmitterData( true )
		self:GetParent():CalculateStatBonus(true)
	end
end

function modifier_stats_system_handler:OnRefresh(iStacks)
	if IsServer() then
		self:UpdateStatValues()
		self:SendBuffRefreshToClients()
		self:GetParent():CalculateStatBonus(true)
	end
end

function modifier_stats_system_handler:UpdateStatValues()
	self.statsInfo.ms = 0
	self.statsInfo.mp = 0
	self.statsInfo.mpr = 0
	self.statsInfo.ha = 0
	self.statsInfo.ad = 0
	self.statsInfo.sa = 0
	self.statsInfo.sta = 0
	-- DEFENSE
	self.statsInfo.pr = 0
	self.statsInfo.mr = 0
	
	self.statsInfo.ard = 0
	
	self.statsInfo.hp = 0
	self.statsInfo.hpr = 0
	self.statsInfo.sr = 0
	
	self.statsInfo.critChance = 0
	if self.modifierFunctions["GetModifierBaseCriticalChanceBonus"] then
		for modifier, active in pairs( self.modifierFunctions["GetModifierBaseCriticalChanceBonus"] ) do
			if modifier:IsNull() then
				self.modifierFunctions["GetModifierBaseCriticalChanceBonus"][modifier] = nil
			elseif active and modifier.GetModifierBaseCriticalChanceBonus then
				self.statsInfo.critChance = self.statsInfo.critChance + (modifier:GetModifierBaseCriticalChanceBonus() or 0)
			end
		end
	end
	self.statsInfo.critDamage = 0
	if self.modifierFunctions["GetModifierBaseCriticalDamageBonus"] then
		for modifier, active in pairs( self.modifierFunctions["GetModifierBaseCriticalDamageBonus"] ) do
			if modifier:IsNull() then
				self.modifierFunctions["GetModifierBaseCriticalDamageBonus"][modifier] = nil
			elseif active and modifier.GetModifierBaseCriticalDamageBonus then
				self.statsInfo.critDamage = self.statsInfo.critDamage + (modifier:GetModifierBaseCriticalDamageBonus() or 0)
			end
		end
	end
	self.statsInfo.manacost = 1
	if self.modifierFunctions["GetModifierManacostReduction"] then
		for modifier, active in pairs( self.modifierFunctions["GetModifierManacostReduction"] ) do
			if modifier:IsNull() then
				self.modifierFunctions["GetModifierManacostReduction"][modifier] = nil
			elseif active and modifier.GetModifierManacostReduction then
				self.statsInfo.manacost = self.statsInfo.manacost * (1 - (modifier:GetModifierManacostReduction() or 0)/100)
			end
		end
	end
end

function modifier_stats_system_handler:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		-- MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		-- MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
		MODIFIER_PROPERTY_REINCARNATION
	}
	return funcs
end

function modifier_stats_system_handler:GetModifierBaseAttack_BonusDamage()
	local owner = self:GetCaster() or self:GetParent()
	if owner:IsRealHero() and self:GetParent():IsHero() then
		heroBonus = owner:GetLevel()
		return owner:GetAgility() * 0.5 + heroBonus
	end
	
end

function modifier_stats_system_handler:ReincarnateTime(params)
	if IsServer() then
		local firstToCheck
		local firstToCheckPriority = MODIFIER_PRIORITY_LOW
		local checking = true
		local modifiersToCheck = MergeTables( self.modifierFunctions["GetReincarnationDelay"], {} )
		if self:GetParent().tombstoneDisabled then
			self:GetParent().tombstoneDisabled = false
			return
		else
			while checking do
				for modifier, priority in pairs( modifiersToCheck ) do
					if priority >= firstToCheckPriority then
						firstToCheckPriority = priority
						firstToCheck = modifier
					end
				end
				if firstToCheck then
					if firstToCheck.GetReincarnationDelay then
						modifiersToCheck[firstToCheck] = nil
						local resurrectionDelay = firstToCheck:GetReincarnationDelay(params)
						if resurrectionDelay then
							checking = false
							return resurrectionDelay
						end
					end
					firstToCheckPriority = MODIFIER_PRIORITY_LOW
					firstToCheck = nil
				else
					checking = false
				end
			end
			return
		end
	end
end

function modifier_stats_system_handler:GetModifierExtraHealthPercentage()
	local bonusHealth = 1
	for modifier, active in pairs( self.modifierFunctions["GetModifierExtraHealthBonusPercentage"]  ) do
		if modifier.GetModifierExtraHealthBonusPercentage and modifier:GetModifierExtraHealthBonusPercentage() then
			bonusHealth = bonusHealth * (1 + modifier:GetModifierExtraHealthBonusPercentage() / 100 )
		end
	end
	if bonusHealth < 0 then
		bonusHealth = math.max( bonusHealth, -0.9 )
	end
	if bonusHealth ~= 1 then
		return (bonusHealth-1)*100
	end
end

function modifier_stats_system_handler:GetModifierMoveSpeed_Limit()
	local MOVESPEED_MAX = 550
	for modifier, active in pairs( self.modifierFunctions["GetMoveSpeedLimitBonus"]  ) do
		if modifier.GetMoveSpeedLimitBonus and modifier:GetMoveSpeedLimitBonus() then
			local bonusMS = modifier:GetMoveSpeedLimitBonus()
			if bonusMS == -1 then
				return
			else
				MOVESPEED_MAX = MOVESPEED_MAX + bonusMS
			end
		end
	end
	return MOVESPEED_MAX
end

function modifier_stats_system_handler:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_stats_system_handler:GetModifierBaseAttackTimeConstant()
	if self.requestingBaseAttackTimeData then return end
	self.requestingBaseAttackTimeData = true
	local baseAttackTimeOriginal = self:GetParent():GetBaseAttackTime()
	local baseAttackTime = self:GetParent():GetBaseAttackTime()
	local baseAttackTimeModifier = 0
	self.requestingBaseAttackTimeData = false
	local maxPriority = 0
	for modifier, priority in pairs( self.modifierFunctions["GetBaseAttackTimeOverride"]  ) do
		if modifier.GetBaseAttackTimeOverride and modifier:GetBaseAttackTimeOverride() and priority >= maxPriority then
			maxPriority = priority
			baseAttackTime = modifier:GetBaseAttackTimeOverride()
		end
	end
	for modifier, active in pairs( self.modifierFunctions["GetBaseAttackTime_Bonus"]  ) do
		if modifier.GetBaseAttackTime_Bonus and modifier:GetBaseAttackTime_Bonus() then
			baseAttackTimeModifier = baseAttackTimeModifier + modifier:GetBaseAttackTime_Bonus()
		end
	end
	for modifier, active in pairs( self.modifierFunctions["GetBaseAttackTime_BonusPercentage"]  ) do
		if modifier.GetBaseAttackTime_BonusPercentage and modifier:GetBaseAttackTime_BonusPercentage() then
			baseAttackTimeModifier = baseAttackTimeModifier + baseAttackTime * (modifier:GetBaseAttackTime_BonusPercentage() / 100)
		end
	end
	if baseAttackTimeModifier ~= 0 or baseAttackTime ~= baseAttackTimeOriginal then
		return (baseAttackTime + baseAttackTimeModifier)
	end
end

function modifier_stats_system_handler:GetModifierAttackSpeedBonus_Constant()
	if self.requestingAttackSpeedData then return end
	self.requestingAttackSpeedData = true
	local attackspeed = self:GetParent():GetAttackSpeed( false ) * 100
	local bonusAttackspeed = 0
	self.requestingAttackSpeedData = false
	local ATTACK_SPEED_MAX = 700
	for modifier, active in pairs( self.modifierFunctions["GetModifierAttackSpeedLimitBonus"]  ) do
		if modifier.GetModifierAttackSpeedLimitBonus and modifier:GetModifierAttackSpeedLimitBonus() then
			ATTACK_SPEED_MAX = ATTACK_SPEED_MAX + modifier:GetModifierAttackSpeedLimitBonus()
		end
	end
	for modifier, active in pairs( self.modifierFunctions["GetModifierAttackSpeedBonusPercentage"]  ) do
		if modifier.GetModifierAttackSpeedBonusPercentage and modifier:GetModifierAttackSpeedBonusPercentage() then
			bonusAttackspeed = bonusAttackspeed + attackspeed * (modifier:GetModifierAttackSpeedBonusPercentage() / 100)
		end
	end
	if attackspeed + bonusAttackspeed > ATTACK_SPEED_MAX then
		bonusAttackspeed = ATTACK_SPEED_MAX - (attackspeed + bonusAttackspeed)
	end
	local unitAttackspeed = 0
	if self:GetParent():IsRealHero() then
		unitAttackspeed = self:GetParent():GetLevel()
	end
	if bonusAttackspeed ~= 0 then
		return bonusAttackspeed + unitAttackspeed
	end
	return unitAttackspeed
end

function modifier_stats_system_handler:GetModifierBonusStats_Agility()
	if self.requestingAgilityData then return end
	self.requestingAgilityData = true
	local agility = self:GetParent():GetAgility()
	local bonusAgi = 0
	self.requestingAgilityData = false
	for modifier, active in pairs( self.modifierFunctions["GetModifierAgilityBonusPercentage"]  ) do
		if modifier.GetModifierAgilityBonusPercentage and modifier:GetModifierAgilityBonusPercentage() then
			bonusAgi = bonusAgi + agility * (modifier:GetModifierAgilityBonusPercentage() / 100)
		end
	end
	if bonusAgi ~= 0 then
		return bonusAgi
	end
end

function modifier_stats_system_handler:GetModifierBonusStats_Intellect()
	if self.requestingIntellectData then return end
	self.requestingIntellectData = true
	local intellect = self:GetParent():GetIntellect( false)
	local bonusInt = 0
	self.requestingIntellectData = false
	for modifier, active in pairs( self.modifierFunctions["GetModifierIntellectBonusPercentage"]  ) do
		if modifier.GetModifierIntellectBonusPercentage and modifier:GetModifierIntellectBonusPercentage() then
			bonusInt = bonusInt + intellect * (modifier:GetModifierIntellectBonusPercentage() / 100)
		end
	end
	if bonusInt ~= 0 then
		return bonusInt
	end
end

function modifier_stats_system_handler:GetModifierBonusStats_Strength()
	if self.requestingStrengthData then return end
	self.requestingStrengthData = true
	local strength = self:GetParent():GetStrength()
	local bonusStr = 0
	self.requestingStrengthData = false
	for modifier, active in pairs( self.modifierFunctions["GetModifierStrengthBonusPercentage"]  ) do
		if modifier.GetModifierStrengthBonusPercentage and modifier:GetModifierStrengthBonusPercentage() then
			bonusStr = bonusStr + strength * (modifier:GetModifierStrengthBonusPercentage() / 100)
		end
	end
	if bonusStr ~= 0 then
		return bonusStr
	end
end

function modifier_stats_system_handler:GetModifierMoveSpeedBonus_Percentage()
	local owner = self:GetCaster() or self:GetParent()
	if self:GetParent():IsHero() then
		return owner:GetAgility() * 0.1
	end
end

function modifier_stats_system_handler:GetModifierPercentageManacostStacking()
	return (1 - (self.statsInfo.manacost or 1))*100
end

function modifier_stats_system_handler:GetModifierManaBonus()
	local owner = self:GetCaster() or self:GetParent()
	if self:GetParent():IsHero() then
		return (self.statsInfo.mp or 0) + owner:GetLevel() * 5
	end
end
function modifier_stats_system_handler:GetModifierConstantManaRegen() 
	local owner = self:GetCaster() or self:GetParent()
	if self:GetParent():IsHero() then
		return 1.5 + (self.statsInfo.mpr or 0)
	end
end
	
function modifier_stats_system_handler:GetModifierSpellAmplify_Percentage()
	local owner = self:GetCaster() or self:GetParent()
	local heroBonus = 0
	if owner:IsRealHero() and self:GetParent():IsHero() then
		heroBonus = owner:GetLevel() * 0.5
	end
	return owner:GetIntellect( false) * 0.15 + (self.statsInfo.sa or 0) + heroBonus
end
	
-- function modifier_stats_system_handler:GetModifierHealAmplify_Percentage()
	-- local owner = self:GetCaster() or self:GetParent()
	-- return owner:GetIntellect( false) * 0.15
-- end

-- function modifier_stats_system_handler:GetModifierPercentageCooldown() return self.cdr or 0 end

-- function modifier_stats_system_handler:GetModifierStatusAmplify_Percentage()
	-- local owner = self:GetCaster() or self:GetParent()
	-- return 0.15 * owner:GetStrength()
-- end

function modifier_stats_system_handler:GetModifierPhysicalArmorBonus()
	local bonusarmor = 0
	if not self:GetParent():IsRangedAttacker() then bonusarmor = 3 end
	return ( self.statsInfo.pr or 0 ) + bonusarmor
end

function modifier_stats_system_handler:GetModifierExtraHealthBonus() 
	local owner = self:GetCaster() or self:GetParent()
	if self:GetParent():IsHero() then
		return (self.statsInfo.hp or 0) + owner:GetLevel() * 5
	end
end
function modifier_stats_system_handler:GetModifierConstantHealthRegen() 
	local owner = self:GetCaster() or self:GetParent()
	local base = TernaryOperator( 1, self:GetParent():IsRealHero(), 0 )
	return base + (self.statsInfo.hpr or 0)
end
function modifier_stats_system_handler:GetModifierStatusResistance() return ( 1 - ( (1-(self.statsInfo.sr or 0)/100) ) ) * 100  end

if IsServer() then
	GOLD_BONUS_BASE = 50 / (GameRules.BasePlayers - 1)
	function modifier_stats_system_handler:GetBonusGold()
		local playerMult = (GameRules.BasePlayers - HeroList:GetActiveHeroCount())
		return GOLD_BONUS_BASE * playerMult
	end

	function modifier_stats_system_handler:GetBonusExp()
		local playerMult = (GameRules.BasePlayers - HeroList:GetActiveHeroCount())
		return GOLD_BONUS_BASE * playerMult
	end
end

function modifier_stats_system_handler:GetModifierEvasion_Constant()
	local owner = self:GetCaster() or self:GetParent()
	if self.requestingEvasionData then return end
	if self:GetParent():IsStunned() or self:GetParent():IsRooted() then
		self.requestingEvasionData = true
		local evasion = 0
		if not self:GetParent():IsNull() and self:GetParent().GetEvasion then
			evasion = self:GetParent():GetEvasion()
		end
		self.requestingEvasionData = false
		if evasion > 0 then
			return -evasion
		end
	else
		-- if owner.statsSystemLastAgiCheck ~= owner:GetAgility() then
			-- owner.statsSystemLastAgiCheck = owner:GetAgility()
			-- owner.statsSystemEvasionInnate = (1-(1-0.0035)^owner:GetAgility())*100 
		-- end
		return 5 + (self.statsInfo.evasion or 0)
	end
end

function modifier_stats_system_handler:GetModifierPreAttack_CriticalStrike(params)
	local critChance =  5 + (self.statsInfo.critChance or 0)
	local owner = self:GetCaster() or self:GetParent()
	if params.target and params.target:GetEvasion() < 0 then
		critChance = critChance + math.floor( (params.target:GetEvasion() * (-100)) + 0.5 )
	end
	local critAdded = 75 + (self.statsInfo.critDamage or 0)
	if owner:IsRealHero() and self:GetParent():IsHero() then
		critAdded = critAdded + owner:GetStrength() * 0.5
	end
	local critDamage = 100
	local crit = false
	while critChance > 100 do
		critDamage = critDamage + critAdded
		critChance = critChance - 100
		crit = true
	end
	if self:RollPRNG( critChance ) then
		crit = true
		critDamage = critDamage + critAdded
	end
	if self.modifierFunctions["GetModifierCriticalDamage"] then
		for modifier, active in pairs( self.modifierFunctions["GetModifierCriticalDamage"] ) do
			if modifier:IsNull() then
				self.modifierFunctions["GetModifierCriticalDamage"][modifier] = nil
			elseif active and modifier.GetModifierCriticalDamage then
				local modCrit = modifier:GetModifierCriticalDamage(params)
				if modCrit then
					crit = true
					critDamage = critDamage + (modCrit - 100)
				end
			end
		end
	end
	if crit then
		return critDamage
	end
end

function modifier_stats_system_handler:OnTakeDamage( params )
	local parent = self:GetParent()
	local caster = self:GetCaster() or parent
	-------------------------------
	--- LIFESTEAL
	-------------------------------
	if params.attacker == parent and params.unit ~= parent and parent:GetHealth() > 0 and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		-- if caster.statsSystemLastIntCheck ~= caster:GetIntellect( false) then
			-- caster.statsSystemLastIntCheck = caster:GetIntellect( false)
			-- caster.statsSystemLifestealInnate = (1-(1-0.00125)^caster:GetIntellect( false))
		-- end
		-- local innateLifesteal = caster.statsSystemLifestealInnate
		-- if params.inflictor and params.unit:IsMinion() then
			-- innateLifesteal = caster.statsSystemLifestealInnate / 4
		-- end
		-- local intHeal = math.ceil(params.damage * innateLifesteal)
		-- params.attacker:HealEvent(intHeal, params.inflictor, self:GetCaster())
		if self.modifierFunctions["GetModifierLifestealBonus"] then
			for modifier, active in pairs( self.modifierFunctions["GetModifierLifestealBonus"] ) do
				if modifier:IsNull() then
					self.modifierFunctions["GetModifierLifestealBonus"][modifier] = nil
				elseif active and modifier.GetModifierLifestealBonus then
					local modLifesteal = (modifier:GetModifierLifestealBonus( params ) or 0) / 100
					local modHeal = math.ceil(params.damage * modLifesteal)
					params.attacker:HealEvent(modHeal, modifier:GetAbility(), modifier:GetCaster(), {heal_type = HEAL_TYPE_LIFESTEAL} )
				end
			end
		end
	end
	if params.unit == parent and ( params.attacker and params.attacker ~= parent ) and params.attacker:GetHealth() > 0 and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		if self.modifierFunctions["GetModifierLifestealTargetBonus"] then
			for modifier, active in pairs( self.modifierFunctions["GetModifierLifestealTargetBonus"] ) do
				if modifier:IsNull() then
					self.modifierFunctions["GetModifierLifestealTargetBonus"][modifier] = nil
				elseif active and modifier.GetModifierLifestealTargetBonus then
					local modLifesteal = (modifier:GetModifierLifestealTargetBonus( params ) or 0) / 100
					local modHeal = math.ceil(params.damage * modLifesteal)
					params.attacker:HealEvent(modHeal, modifier:GetAbility(), modifier:GetCaster(), {heal_type = HEAL_TYPE_LIFESTEAL} )
				end
			end
		end
	end
	-------------------------------
	--- DAMAGE REFLECTION
	-------------------------------
	if parent:IsIllusion() or params.unit ~= parent or params.attacker == parent or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) then 
	else
		local damageTables = {}
		local spellAmp = 1 + parent:GetSpellAmplification( false )
		if self.modifierFunctions["GetModifierDamageReflectBonus"] then
			for modifier, active in pairs( self.modifierFunctions["GetModifierDamageReflectBonus"] ) do
				if modifier:IsNull() then
					self.modifierFunctions["GetModifierDamageReflectBonus"][modifier] = nil
				elseif active and modifier.GetModifierDamageReflectBonus and modifier:GetAbility() then
					local modAb =  modifier:GetAbility()
					damageTables[modAb] = damageTables[modAb] or {}
					damageTables[modAb][DAMAGE_TYPE_PHYSICAL] = (damageTables[modAb][DAMAGE_TYPE_PHYSICAL] or 0) + (modifier:GetModifierDamageReflectBonus( params ) or 0) * spellAmp
				end
			end
		end
		if self.modifierFunctions["GetModifierDamageReflectPercentageBonus"] then
			for modifier, active in pairs( self.modifierFunctions["GetModifierDamageReflectPercentageBonus"] ) do
				if modifier:IsNull() then
					self.modifierFunctions["GetModifierDamageReflectPercentageBonus"][modifier] = nil
				elseif active and modifier.GetModifierDamageReflectPercentageBonus and modifier:GetAbility() then
					local modAb =  modifier:GetAbility()
					damageTables[modAb] = damageTables[modAb] or {}
					local reflect = (modifier:GetModifierDamageReflectPercentageBonus( params ) or 0) / 100
					if params.original_damage * reflect >= 1  then
						damageTables[modAb][params.damage_type] = (damageTables[modAb][params.damage_type] or 0) + params.original_damage * reflect
					end
				end
			end
		end
		for ability, damageTable in pairs( damageTables ) do
			if (damageTable[DAMAGE_TYPE_PHYSICAL] or 0) > 0 then
				ability:DealDamage( ability:GetCaster() or parent, params.attacker, damageTable[DAMAGE_TYPE_PHYSICAL], {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL} )
			end
			if (damageTable[DAMAGE_TYPE_MAGICAL] or 0) > 0 then
				ability:DealDamage( ability:GetCaster() or parent, params.attacker, damageTable[DAMAGE_TYPE_MAGICAL], {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL} )
			end
			if (damageTable[DAMAGE_TYPE_PURE] or 0) > 0 then
				ability:DealDamage( ability:GetCaster() or parent, params.attacker, damageTable[DAMAGE_TYPE_PURE], {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL} )
			end
		end
		
	end
	-------------------------------
	--- AREA DAMAGE
	-------------------------------
	local countsAsAttack = ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK ) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE )
	local damage_flags = params.damage_flags
	if countsAsAttack then
		damage_flags = bit.bor(damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION)
	end
	if params.attacker and params.attacker.processingAreaDamageIgnore or self.processingAreaDamageIgnore or params.attacker ~= self:GetParent() or params.unit:IsSameTeam(params.attacker) or params.damage <= 0 then
	else
		local spellValid = false
		local spellValidTargeting = false
		local spellHasTarget = false
		if params.inflictor then
			local abilityBehavior = params.inflictor:GetBehavior()
			spellValidTargeting =  HasBit( abilityBehavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and not HasBit( abilityBehavior, DOTA_ABILITY_BEHAVIOR_AOE) 
			spellHasTarget = ( params.unit == params.inflictor:GetCursorTarget() or not params.inflictor:GetCursorTarget() )
			spellValid = ( spellValidTargeting and spellHasTarget ) or ( params.inflictor.HasAreaDamage and params.inflictor:HasAreaDamage() )
		end
		if countsAsAttack or spellValid then
			local areaDamage = 0
			for modifier, active in pairs( self.modifierFunctions["GetModifierAreaDamage"] ) do
				if modifier:IsNull() then
					self.modifierFunctions["GetModifierAreaDamage"][modifier] = nil
				elseif active and modifier.GetModifierAreaDamage then
					areaDamage = areaDamage + (modifier:GetModifierAreaDamage( params ) or 0)
				end
			end
			if not countsAsAttack or params.attacker:IsRangedAttacker() then
				areaDamage = areaDamage / 2
			end
			local damage = params.original_damage * areaDamage / 100
			if damage > 0 then
				self.processingAreaDamageIgnore = true
				for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.unit:GetAbsOrigin(), 325, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES} ) ) do
					if enemy ~= params.unit then
						ApplyDamage({victim = enemy, attacker = params.attacker, damage_type = params.damage_type, damage = damage, ability = params.inflictor, damage_flags = damage_flags})
					end
				end
				self.processingAreaDamageIgnore = false
			end
		end
	end
end

function modifier_stats_system_handler:AddCustomTransmitterData( )
	return
	{
		statsInfo = self.statsInfo
	}
end

--------------------------------------------------------------------------------

function modifier_stats_system_handler:HandleCustomTransmitterData( data )
	self.statsInfo = table.copy( data.statsInfo )
end

function modifier_stats_system_handler:IsHidden()
	return true
end

function modifier_stats_system_handler:IsPermanent()
	return true
end

function modifier_stats_system_handler:IsPurgable()
	return false
end

function modifier_stats_system_handler:RemoveOnDeath()
	return false
end

function modifier_stats_system_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end