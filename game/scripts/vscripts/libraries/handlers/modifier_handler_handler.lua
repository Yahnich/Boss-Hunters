modifier_handler_handler = class({})
	
INTERNAL_ATTACK_SPEED_CAP = 900
INTERNAL_MOVESPEED_CAP = 550

function modifier_handler_handler:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_bloodseeker_thirst") then
			parent:AddNewModifier(parent, nil, "modifier_bloodseeker_thirst", {})
		end
		self.acc = parent:AddNewModifier(parent, nil, "modifier_accuracy_handler", {})
		self.as = parent:AddNewModifier(parent, nil, "modifier_attack_speed_handler", {})
		self.bat = parent:AddNewModifier(parent, nil, "modifier_base_attack_time_handler", {})
		self.cdr = parent:AddNewModifier(parent, nil, "modifier_cooldown_reduction_handler", {})
		self.hp = parent:AddNewModifier(parent, nil, "modifier_health_handler", {})
		self.ms = parent:AddNewModifier(parent, nil, "modifier_move_speed_handler", {})
		self.ard = parent:AddNewModifier(parent, nil, "modifier_area_dmg_handler", {})
		self.ms.evasion = parent:AddNewModifier(parent, nil, "modifier_evasion_handler", {})
		-- base attack time init
		self.baseAttackTime = parent:GetBaseAttackTime() * 100
		if parent:IsRealHero() then
			self.baseAttackTime = self.baseAttackTime * 1.5
			self.str = parent:AddNewModifier(parent, nil, "modifier_strength_handler", {})
			self.agi = parent:AddNewModifier(parent, nil, "modifier_agility_handler", {})
			self.int = parent:AddNewModifier(parent, nil, "modifier_intellect_handler", {})
			
			self.strModifiers = {}
			self.agiModifiers = {}
			self.intModifiers = {}
		end
		self.baseAttackTime =  math.floor( self.baseAttackTime )
		self.bat:SetStackCount( self.baseAttackTime )
		-- health init
		self.baseMaxHealth = parent:GetMaxHealth()
		self.hp.hpPct = parent:GetHealth() / parent:GetMaxHealth()
		-- ms init
		self.ms:SetStackCount( parent:GetIdealSpeed() )
		self.accModifiers = {}
		self.asModifiers = {}
		self.batModifiers = {}
		self.cdrModifiers = {}
		self.hpModifiers = {}
		self.ms.msModifiers = {}
		self.ardModifiers = {}
		self.state = 1
		for id, modifier in ipairs( parent:FindAllModifiers() ) do
			-- accuracy --------------------------------------
			if modifier.GetAccuracy then
				table.insert(self.accModifiers, modifier)
			end
			-- attack speed ----------------------------------
			if ( modifier.GetModifierAttackSpeedBonus ) 
			or ( modifier.GetModifierAttackSpeedBonusPercentage )
			or ( modifier.GetModifierAttackSpeedLimitBonus ) then
				table.insert(self.asModifiers, modifier)
			end
			-- base attack time ------------------------------
			if ( modifier.GetBaseAttackTime_Bonus ) 
			or ( modifier.GetBaseAttackTime_BonusPercentage ) then
				table.insert(self.batModifiers, modifier)
			end
			-- cooldown reduction  ----------------------------
			if modifier.GetCooldownReduction then
				table.insert(self.cdrModifiers, modifier)
			end
			-- health -----------------------------------------
			if modifier.GetModifierExtraHealthBonusPercentage then
				table.insert(self.hpModifiers, modifier)
			end
			-- movespeed --------------------------------------
			if modifier.GetMoveSpeedLimitBonus then
				table.insert(self.ms.msModifiers, modifier)
			end
			-- area damage --------------------------------------
			if modifier.GetModifierAreaDamage then
				table.insert(self.ardModifiers, modifier)
			end
			if parent:IsRealHero() then
				if modifier.GetModifierStrengthBonusPercentage then
					table.insert(self.strModifiers, modifier)
				end
				if modifier.GetModifierAgilityBonusPercentage then
					table.insert(self.agiModifiers, modifier)
				end
				if modifier.GetModifierIntellectBonusPercentage then
					table.insert(self.intModifiers, modifier)
				end
			end
		end
	end
end

function modifier_handler_handler:OnIntervalThink()
	if IsServer() then
		if self.state == 1 then
			self.state = 2
			if #self.accModifiers > 0 then
				self:UpdateAccuracy()
				return
			end
		end
		if self.state == 2 then
			self.state = 3
			if #self.asModifiers > 0 then
				self:UpdateAttackSpeed()
				return
			end
		end
		if self.state == 3 then
			self.state = 4
			if #self.batModifiers > 0 then
				self:UpdateBaseAttackTime()
				return
			end
		end
		if self.state == 4 then
			self.state = 5
			if #self.cdrModifiers > 0 then
				self:UpdateCooldownReduction()
				return
			end
		end
		if self.state == 5 then
			self.state = 6
			if #self.hpModifiers > 0 then
				self:UpdateHealth()
				return
			end
		end
		if self.state == 5 then
			self.state = 6
			if #self.hpModifiers > 0 then
				self:UpdateHealth()
				return
			end
		end
		if self.state == 6 then
			self.state = 7
			if self:GetParent():IsRealHero() and #self.strModifiers + #self.agiModifiers + #self.intModifiers > 0 then
				self:UpdateStats()
				return
			end
		end
		if self.state == 7 then
			self.state = 8
			if #self.ardModifiers > 0 then
				self:UpdateAreaDamage()
				return
			end
		end
		if self.state == 8 then
			self.state = 1
			if #self.accModifiers <= 0
			and #self.asModifiers <= 0
			and #self.batModifiers <= 0
			and #self.cdrModifiers <= 0
			and #self.hpModifiers <= 0
			and #self.ms.msModifiers <= 0 
			and (self:GetParent():IsRealHero() and #self.strModifiers + #self.agiModifiers + #self.intModifiers <= 0) 
			and #self.ardModifiers <= 0 then
				self:StartIntervalThink(-1)
			end
		end
	end
end

function modifier_handler_handler:UpdateAccuracy()
	-- accuracy ------------------------------------------
	local accuracyStacks = 1
	for id, modifier in ipairs( self.accModifiers ) do
		if modifier and not modifier:IsNull() then
			local roll = modifier:GetAccuracy(true) 
			if roll then
				accuracyStacks = accuracyStacks * (1 - roll / 100)
			end
		else
			table.remove(self.accModifiers, id)
		end
	end
	local accuracy = (1 - accuracyStacks) * 100
	if self.acc:GetStackCount() ~= math.floor( accuracy ) then self.acc:SetStackCount( math.floor( accuracy ) ) end
end

function modifier_handler_handler:UpdateAttackSpeed()
	local parent = self:GetParent()
	self.as:SetStackCount(0)
	parent:CalculateStatBonus()
	local returnAttackSpeed = 0
	local attackSpeedPct = 1
	local bonusAttackSpeedCap = 0
	local attackSpeed = math.floor( parent:GetAttackSpeed() * 100 )
	for id, modifier in ipairs( self.asModifiers ) do
		if modifier and not modifier:IsNull() then
			if modifier.GetModifierAttackSpeedBonus then
				local bonus = modifier:GetModifierAttackSpeedBonus() 
				if bonus then returnAttackSpeed = returnAttackSpeed + (bonus or 0) end
			end
			if modifier.GetModifierAttackSpeedBonusPercentage then
				local bonus = modifier:GetModifierAttackSpeedBonusPercentage()
				if bonus then attackSpeedPct = attackSpeedPct + (bonus or 0) / 100 end
			end
			if modifier.GetModifierAttackSpeedLimitBonus then
				local bonus = modifier:GetModifierAttackSpeedLimitBonus()
				if bonus then bonusAttackSpeedCap = bonusAttackSpeedCap + (bonus or 0) end
			end
		else
			table.remove(self.asModifiers, id)
		end
	end
	local maxAttackSpeed = (INTERNAL_ATTACK_SPEED_CAP + bonusAttackSpeedCap ) - attackSpeed
	returnAttackSpeed = math.floor( math.min( returnAttackSpeed * attackSpeedPct, maxAttackSpeed ) )
	if returnAttackSpeed > 0 then
		returnAttackSpeed = math.abs(returnAttackSpeed).."0"
	else
		returnAttackSpeed = math.abs(returnAttackSpeed).."1"
	end
	local asStacks = tonumber(returnAttackSpeed)
	if self.as:GetStackCount() ~= asStacks then self.as:SetStackCount( asStacks ) end
	parent:CalculateStatBonus()
end

function modifier_handler_handler:UpdateBaseAttackTime()
	local parent = self:GetParent()
	self.bat:SetStackCount(0)
	local bonusBAT = 0
	local pctBAT = 1
	for id, modifier in ipairs( self.batModifiers ) do
		if modifier and not modifier:IsNull() then
			if modifier.GetBaseAttackTime_Bonus then
				local bonus = modifier:GetBaseAttackTime_Bonus() 
				if bonus then bonusBAT = bonusBAT + (bonus * 100) end
			end
			if modifier.GetBaseAttackTime_BonusPercentage then
				local bonus = modifier:GetBaseAttackTime_BonusPercentage()
				if bonus then pctBAT = pctBAT + ( bonus or 0 ) / 100 end
			end
		else
			table.remove(self.batModifiers, id)
		end
	end
	pctBAT = math.max(0.1, pctBAT)
	local newBAT =  math.min( math.max( self.baseAttackTime + bonusBAT, 10 ), 1000 )
	local batStacks = math.floor( newBAT * pctBAT )
	if self.bat:GetStackCount() ~= batStacks then self.bat:SetStackCount( batStacks ) end
	parent:CalculateStatBonus()
end

function modifier_handler_handler:UpdateCooldownReduction()
	local cdrStacks = 1
	local parent = self:GetParent()
	for id, modifier in ipairs( self.cdrModifiers ) do
		if modifier and not modifier:IsNull() then
			local cdr = modifier:GetCooldownReduction() 
			if cdr then
				cdrStacks = cdrStacks * (1 - cdr / 100)
			end
		else
			table.remove(self.cdrModifiers, id)
		end
	end
	cdrStacks = (1 - cdrStacks) * 100 * 100 -- support decimal values
	if self.cdr:GetStackCount() ~= cdrStacks then self.cdr:SetStackCount(cdrStacks) end
	parent:CalculateStatBonus()
end

function modifier_handler_handler:UpdateAreaDamage()
	local ardStacks = 0
	local parent = self:GetParent()
	for id, modifier in ipairs( self.ardModifiers ) do
		if modifier and not modifier:IsNull() then
			local ard = modifier:GetModifierAreaDamage() 
			if ard then
				ardStacks = ardStacks + ard
			end
		else
			table.remove(self.ardModifiers, id)
		end
	end
	if self.ard:GetStackCount() ~= ardStacks then self.ard:SetStackCount(ardStacks) end
end

function modifier_handler_handler:UpdateHealth()
	local parent = self:GetParent()
	local hpPct = parent:GetHealth() / parent:GetMaxHealth()
	local buffHP = self.hp:GetStackCount()
	if buffHP ~= 0 then
		-- check sign
		if buffHP % 10 == 0 then
			buffHP = math.floor( buffHP / 10 )
		else
			buffHP = math.floor( buffHP / 10 ) * (-1)
		end
	end
	self.baseMaxHealth = self:GetParent():GetMaxHealth() - buffHP
	local bonusPctHP = self.baseMaxHealth
	if bonusPctHP <= 0 then
		bonusPctHP = self.baseMaxHealth * (-1) + 1
	end
	for id, modifier in ipairs( self.hpModifiers ) do
		if modifier and not modifier:IsNull() then
			local bonus = modifier:GetModifierExtraHealthBonusPercentage()
			if bonus then
				bonusPctHP = bonusPctHP * ( 1 + bonus / 100 ) 
			end
		else
			table.remove(self.hpModifiers, id)
		end
	end
	bonusPctHP = bonusPctHP - self.baseMaxHealth
	local bonusHP = math.ceil( math.max( bonusPctHP, ( self.baseMaxHealth * (-1) ) + 1 ) )
	if bonusHP > 0 then
		bonusHP = math.abs(bonusHP).."0"
	else
		bonusHP = math.abs(bonusHP).."1"
	end
	local hpStacks = tonumber(bonusHP)
	if hpStacks ~= self.hp:GetStackCount() then 
		if parent:IsAlive() and parent:GetHealth() ~= parent:GetMaxHealth() * (hpPct or 100) then
			parent:SetHealth( parent:GetMaxHealth() * (hpPct or 100) )
		end
		self.hp:SetStackCount( hpStacks ) 
	end
	parent:CalculateStatBonus()
end

function modifier_handler_handler:UpdateStats()
	local strStacks = 0
	local intStacks = 0
	local agiStacks = 0
	
	local prevStr = self.str:GetStackCount()
	local prevAgi = self.agi:GetStackCount()
	local prevInt = self.int:GetStackCount()
	
	local parent = self:GetParent()
	for id, modifier in ipairs( self.strModifiers ) do
		if modifier and not modifier:IsNull() then
			local str = modifier:GetModifierStrengthBonusPercentage() 
			if str then
				strStacks = strStacks + str
			end
		else
			table.remove(self.strModifiers, id)
		end
	end
	for id, modifier in ipairs( self.agiModifiers ) do
		if modifier and not modifier:IsNull() then
			local agi = modifier:GetModifierAgilityBonusPercentage() 
			if agi then
				agiStacks = agiStacks + agi
			end
		else
			table.remove(self.agiModifiers, id)
		end
	end
	for id, modifier in ipairs( self.intModifiers ) do
		if modifier and not modifier:IsNull() then
			local int = modifier:GetModifierIntellectBonusPercentage() 
			if int then
				intStacks = intStacks + int
			end
		else
			table.remove(self.intModifiers, id)
		end
	end
	if math.floor( (parent:GetStrength() - prevStr) * (strStacks/100)) ~= prevStr then
		self.str:SetStackCount( math.floor( (parent:GetStrength() - prevStr) * (strStacks/100)) )
	end
	if math.floor( (parent:GetAgility() - prevAgi) * (agiStacks/100)) ~= prevAgi then
		self.agi:SetStackCount( math.floor( (parent:GetAgility() - prevAgi) * (agiStacks/100)) )
	end
	if math.floor( (parent:GetIntellect() - prevInt) * (intStacks/100)) ~= prevInt then
		self.int:SetStackCount( math.floor( (parent:GetIntellect() - prevInt) * (intStacks/100) ) )
	end
	local hpPct = self:GetParent():GetHealth() / self:GetParent():GetMaxHealth()
	parent:CalculateStatBonus()
	if hpPct - 0.1 <= self:GetParent():GetHealth() / self:GetParent():GetMaxHealth() then 
		parent:SetHealth( hpPct * self:GetParent():GetMaxHealth() )
	end
end

function modifier_handler_handler:CheckIfUpdateNeeded(name, ability, duration)
	if not self or self:IsNull() or not self:GetParent() or self:GetParent():IsNull() then return end
	local parent = self:GetParent()
	local newestModifier
	local lastTime = -9999
	for id, modifier in ipairs( parent:FindAllModifiersByName(name) ) do
		if ability == modifier:GetAbility() and modifier:GetCreationTime() > lastTime then
			lastTime = modifier:GetCreationTime()
			newestModifier = modifier
		end
	end
	if newestModifier then
		if newestModifier.GetAccuracy then
			table.insert(self.accModifiers, newestModifier)
		end
		-- attack speed ----------------------------------
		if ( newestModifier.GetModifierAttackSpeedBonus ) 
		or ( newestModifier.GetModifierAttackSpeedBonusPercentage )
		or ( newestModifier.GetModifierAttackSpeedLimitBonus ) then
			table.insert(self.asModifiers, newestModifier)
		end
		-- base attack time ------------------------------
		if ( newestModifier.GetBaseAttackTime_Bonus ) 
		or ( newestModifier.GetBaseAttackTime_BonusPercentage ) then
			table.insert(self.batModifiers, newestModifier)
		end
		-- cooldown reduction  ----------------------------
		if newestModifier.GetCooldownReduction then
			table.insert(self.cdrModifiers, newestModifier)
		end
		-- health -----------------------------------------
		if newestModifier.GetModifierExtraHealthBonusPercentage then
			table.insert(self.hpModifiers, newestModifier)
		end
		-- movespeed --------------------------------------
		if newestModifier.GetMoveSpeedLimitBonus then
			table.insert(self.ms.msModifiers, newestModifier)
		end
		-- area damage ------------------------------------
		if newestModifier.GetModifierAreaDamage then
			table.insert(self.ardModifiers, newestModifier)
		end
		-- stats ------------------------------------------
		if parent:IsRealHero() then
			if newestModifier.GetModifierStrengthBonusPercentage then
				table.insert(self.strModifiers, newestModifier)
			end
			if newestModifier.GetModifierAgilityBonusPercentage then
				table.insert(self.agiModifiers, newestModifier)
			end
			if newestModifier.GetModifierIntellectBonusPercentage then
				table.insert(self.intModifiers, newestModifier)
			end
		end
		--------------------------------
		--- UPDATE ---------------------
		--------------------------------
		self:StartIntervalThink(0.05)
	end
end

function modifier_handler_handler:IsHidden()
	return true
end

function modifier_handler_handler:IsPurgable()
	return false
end

function modifier_handler_handler:RemoveOnDeath()
	return false
end

function modifier_handler_handler:IsPermanent()
	return true
end

function modifier_handler_handler:AllowIllusionDuplicate()
	return true
end

function modifier_handler_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end