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
	self.modifierFunctions["GetModifierDamageReflectBonus"] = {}
	self.modifierFunctions["GetModifierLifestealBonus"] = {}
	self.modifierFunctions["GetModifierManacostReduction"] = {}
	self.modifierFunctions["GetModifierAttackSpeedBonus_Constant"] = {}
	self.modifierFunctions["GetModifierAttackSpeedLimitBonus"] = {}
	self.modifierFunctions["GetModifierAttackSpeedBonusPercentage"] = {}
	self.modifierFunctions["GetBaseAttackTime_Bonus"] = {}
	self.modifierFunctions["GetBaseAttackTime_BonusPercentage"] = {}
	self.modifierFunctions["GetModifierExtraHealthBonusPercentage"] = {}
	self.modifierFunctions["GetMoveSpeedLimitBonus"] = {}
	self.modifierFunctions["GetModifierAreaDamage"] = {}
	self.modifierFunctions["GetModifierStrengthBonusPercentage"] = {}
	self.modifierFunctions["GetModifierAgilityBonusPercentage"] = {}
	self.modifierFunctions["GetModifierIntellectBonusPercentage"] = {}
	if IsServer() then
		-- find all non-hooked functions on creation (mostly for illusions, but in case we missed any)
		for _, modifier in ipairs( self:GetParent():FindAllModifiers() ) do
			if modifier.GetModifierBaseCriticalChanceBonus then
				self.modifierFunctions["GetModifierBaseCriticalChanceBonus"][modifier] = true
			end
			if modifier.GetModifierBaseCriticalDamageBonus then
				self.modifierFunctions["GetModifierBaseCriticalDamageBonus"][modifier] = true
			end
			if modifier.GetModifierDamageReflectBonus then
				self.modifierFunctions["GetModifierDamageReflectBonus"][modifier] = true
			end
			if modifier.GetModifierLifestealBonus then
				self.modifierFunctions["GetModifierLifestealBonus"][modifier] = true
			end
			if modifier.GetModifierManacostReduction then
				self.modifierFunctions["GetModifierManacostReduction"][modifier] = true
			end
			if modifier.GetModifierAttackSpeedBonusPercentage then
				self.modifierFunctions["GetModifierAttackSpeedBonusPercentage"][modifier] = true
			end
			if modifier.GetModifierAttackSpeedLimitBonus then
				self.modifierFunctions["GetModifierAttackSpeedLimitBonus"][modifier] = true
			end
			if modifier.GetBaseAttackTime_Bonus then
				self.modifierFunctions["GetBaseAttackTime_Bonus"][modifier] = true
			end
			if modifier.GetBaseAttackTime_BonusPercentage then
				self.modifierFunctions["GetBaseAttackTime_BonusPercentage"][modifier] = true
			end
			if modifier.GetModifierExtraHealthBonusPercentage then
				self.modifierFunctions["GetModifierExtraHealthBonusPercentage"][modifier] = true
			end
			if modifier.GetMoveSpeedLimitBonus then
				self.modifierFunctions["GetMoveSpeedLimitBonus"][modifier] = true
			end
			if modifier.GetModifierAreaDamage then
				self.modifierFunctions["GetModifierAreaDamage"][modifier] = true
			end
			if modifier.GetModifierStrengthBonusPercentage then
				self.modifierFunctions["GetModifierStrengthBonusPercentage"][modifier] = true
			end
			if modifier.GetModifierAgilityBonusPercentage then
				self.modifierFunctions["GetModifierAgilityBonusPercentage"][modifier] = true
			end
			if modifier.GetModifierIntellectBonusPercentage then
				self.modifierFunctions["GetModifierIntellectBonusPercentage"][modifier] = true
			end
		end
		self:UpdateStatValues()
		self:SetHasCustomTransmitterData( true )
		self:GetParent():CalculateStatBonus()
	end
end

function modifier_stats_system_handler:OnRefresh(iStacks)
	if IsServer() then
		self:UpdateStatValues()
		self:SetHasCustomTransmitterData( true )
		self:GetParent():CalculateStatBonus()
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
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE 
	}
	return funcs
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
	-- if self.requestingMoveSpeedData then return end
	-- self.requestingMoveSpeedData = true
	-- local movespeed = self:GetParent():GetIdealSpeed()
	-- print( movespeed, self:GetParent():GetIdealSpeedNoSlows() )
	-- self.requestingMoveSpeedData = false
	local MOVESPEED_MAX = 550
	for modifier, active in pairs( self.modifierFunctions["GetMoveSpeedLimitBonus"]  ) do
		if modifier.GetMoveSpeedLimitBonus and modifier:GetMoveSpeedLimitBonus() then
			MOVESPEED_MAX = MOVESPEED_MAX + modifier:GetMoveSpeedLimitBonus()
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
	local baseAttackTime = self:GetParent():GetBaseAttackTime()
	local baseAttackTimeModifier = 0
	self.requestingBaseAttackTimeData = false
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
	if baseAttackTimeModifier ~= 0 then
		return (baseAttackTime + baseAttackTimeModifier)
	end
end

function modifier_stats_system_handler:GetModifierAttackSpeedBonus_Constant()
	if self.requestingAttackSpeedData then return end
	self.requestingAttackSpeedData = true
	local attackspeed = self:GetParent():GetAttackSpeed() * 100
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
	if bonusAttackspeed ~= 0 then
		return bonusAttackspeed
	end
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
	local intellect = self:GetParent():GetIntellect()
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
	local strength = self:GetParent():GetAgility()
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
	return owner:GetAgility() * 0.075 
end

function modifier_stats_system_handler:GetModifierPercentageManacostStacking()
	return (1 - (self.statsInfo.manacost or 1))*100
end

function modifier_stats_system_handler:GetModifierManaBonus()
	if self:GetParent():IsHero() then
		return 500 + (self.statsInfo.mp or 0)
	end
end
function modifier_stats_system_handler:GetModifierConstantManaRegen() 
	local owner = self:GetCaster() or self:GetParent()
	return 1.5 + (self.statsInfo.mpr or 0) - owner:GetIntellect() * 0.05 
end
	
function modifier_stats_system_handler:GetModifierSpellAmplify_Percentage()
	local owner = self:GetCaster() or self:GetParent()
	return owner:GetIntellect() * 0.25 + (self.statsInfo.sa or 0) 
end

-- function modifier_stats_system_handler:GetModifierPercentageCooldown() return self.cdr or 0 end

function modifier_stats_system_handler:GetModifierStatusAmplify_Percentage()
	local owner = self:GetCaster() or self:GetParent()
	return 0.15 * owner:GetStrength()
end

function modifier_stats_system_handler:GetModifierPhysicalArmorBonus()
	local bonusarmor = 0
	if not self:GetParent():IsRangedAttacker() then bonusarmor = 3 end
	return ( self.statsInfo.pr or 0 ) + bonusarmor
end

function modifier_stats_system_handler:GetModifierExtraHealthBonus() 
	if self:GetParent():IsHero() then
		return 300 + (self.statsInfo.hp or 0)
	end
end
function modifier_stats_system_handler:GetModifierConstantHealthRegen() 
	local owner = self:GetCaster() or self:GetParent()
	return 1 + (self.statsInfo.hpr or 0) - owner:GetStrength() * 0.1 
end
function modifier_stats_system_handler:GetModifierStatusResistance() return ( 1 - ( (1-(self.statsInfo.sr or 0)/100) ) ) * 100  end

function modifier_stats_system_handler:GetModifierEvasion_Constant()
	local owner = self:GetCaster() or self:GetParent()
	if self.requestingEvasionData then return end
	if self:GetParent():IsStunned() or self:GetParent():IsRooted() then
		self.requestingEvasionData = true
		local evasion = self:GetParent():GetEvasion()
		self.requestingEvasionData = false
		if evasion > 0 then
			return -evasion
		end
	else
		return 5 + (self.statsInfo.evasion or 0) + (1-(1-0.0035)^owner:GetAgility())*100 
	end
end
function modifier_stats_system_handler:GetModifierPreAttack_CriticalStrike(params)
	local critChance =  5 + (self.statsInfo.critChance or 0)
	local owner = self:GetCaster() or self:GetParent()
	if params.target and params.target:GetEvasion() < 0 then
		critChance = critChance + math.floor( (params.target:GetEvasion() * (-100)) + 0.5 )
	end
	local critAdded = 75 + (self.statsInfo.critDamage or 0) + owner:GetStrength() * 0.5
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
	if params.attacker == self:GetParent() and params.unit ~= parent and parent:GetHealth() > 0 and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		if self.lastIntCheck ~= caster:GetIntellect() then
			self.lastIntCheck = caster:GetIntellect()
			self.lifestealInnate = (1-(1-0.00125)^caster:GetIntellect())
		end
		if params.inflictor and params.unit:IsMinion() then
			self.lifestealInnate = self.lifestealInnate / 4
		end
		local intHeal = math.ceil(params.damage * self.lifestealInnate)
		params.attacker:HealEvent(intHeal, params.inflictor, self:GetCaster())
		if self.modifierFunctions["GetModifierLifestealBonus"] then
			for modifier, active in pairs( self.modifierFunctions["GetModifierLifestealBonus"] ) do
				if modifier:IsNull() then
					self.modifierFunctions["GetModifierLifestealBonus"][modifier] = nil
				elseif active and modifier.GetModifierLifestealBonus then
					local modLifesteal = (modifier:GetModifierLifestealBonus( params ) or 0) / 100
					local modHeal = math.ceil(params.damage * modLifesteal)
					params.attacker:HealEvent(modHeal, modifier:GetAbility(), modifier:GetCaster())
				end
			end
		end
		
	end
	-------------------------------
	--- DAMAGE REFLECTION
	-------------------------------
	if parent:IsIllusion() or params.unit ~= parent or params.attacker == parent or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) then 
	else
		if self.modifierFunctions["GetModifierDamageReflectBonus"] then
			for modifier, active in pairs( self.modifierFunctions["GetModifierDamageReflectBonus"] ) do
				if modifier:IsNull() then
					self.modifierFunctions["GetModifierDamageReflectBonus"][modifier] = nil
				elseif active and modifier.GetModifierDamageReflectBonus and modifier:GetAbility() then
					local reflect = (modifier:GetModifierDamageReflectBonus( params ) or 0) / 100
					if params.original_damage * reflect > 1  then
						modifier:GetAbility():DealDamage( parent, params.attacker, params.original_damage * reflect, {damage_type = params.damage_type, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL} )
					end
				end
			end
		end
	end
	-------------------------------
	--- AREA DAMAGE
	-------------------------------
	local countsAsAttack = ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK ) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE )
	local damage_flags = params.damage_flags
	if countAsAttack then
		damage_flags = bit.bor(damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION)
	end
	if self.processingAreaDamageIgnore or params.attacker ~= self:GetParent() or params.unit:IsSameTeam(params.attacker) or params.damage <= 0 then
	else
		local spellValid = false
		local spellValidTargeting = false
		local spellHasTarget = false
		if params.inflictor then
			spellValidTargeting = ( HasBit( params.inflictor:GetBehavior(), DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and not HasBit( params.inflictor:GetBehavior(), DOTA_ABILITY_BEHAVIOR_AOE) ) 
			spellHasTarget = ( params.unit == params.inflictor:GetCursorTarget() or not params.inflictor:GetCursorTarget() )
			spellValid = ( spellValidTargeting and spellHasTarget ) or ( params.inflictor.HasAreaDamage and params.inflictor:HasAreaDamage() )
		end
		if countsAsAttack or spellValid then
			local areaDamage = 0
			for modifier, active in pairs( self.modifierFunctions["GetModifierAreaDamage"] ) do
				if modifier:IsNull() then
					self.modifierFunctions["GetModifierAreaDamage"][modifier] = nil
				elseif active and modifier.GetModifierAreaDamage then
					areaDamage = areaDamage + (modifier:GetModifierAreaDamage() or 0)
				end
			end
			if not countsAsAttack or params.attacker:IsRangedAttacker() then
				areaDamage = areaDamage / 2
			end
			local damage = params.original_damage * areaDamage / 100
			if damage > 0 then
				self.processingAreaDamageIgnore = true
				for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.unit:GetAbsOrigin(), 325 ) ) do
					if enemy ~= params.unit then
						ApplyDamage({victim = enemy, attacker = params.attacker, damage_type = params.damage_type, damage = params.original_damage * areaDamage / 100, ability = params.inflictor, damage_flags = damage_flags})
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